//! function_length: function length validation
//!
//! How do we check if functions exceed the 70-line limit? This
//! module parses zig code and validates function lengths.

const std = @import("std");
const types = @import("types.zig");

// Function information extracted from code.
//
// Why a separate struct? It makes function boundaries explicit.
// We can track start line, end line, and name independently.
const FunctionInfo = struct {
    name: []const u8,
    start_line: usize,
    end_line: usize,
    length: usize,
};

// Validate function lengths in code.
//
// Takes source code and max length, returns violations for functions
// that exceed the limit. Each violation includes function name and
// actual length.
//
// Why return a heap-allocated result? Violations can be numerous.
// We need to allocate space for them. The caller is responsible
// for freeing the memory.
pub fn validate_function_length(
    allocator: std.mem.Allocator,
    code: []const u8,
    max_length: usize,
) ![]types.Violation {
    var violations = std.ArrayList(types.Violation){};
    try violations.ensureTotalCapacity(allocator, 8);
    errdefer violations.deinit(allocator);

    const functions = try find_functions(allocator, code);
    defer {
        for (functions) |func| {
            allocator.free(func.name);
        }
        allocator.free(functions);
    }

    for (functions) |func| {
        if (func.length > max_length) {
            const message = try std.fmt.allocPrint(
                allocator,
                "function '{s}' is {d} lines (max {d})",
                .{ func.name, func.length, max_length },
            );

            try violations.append(allocator, .{
                .line = func.start_line,
                .violation_type = .function_too_long,
                .message = message,
            });
        }
    }

    return try violations.toOwnedSlice(allocator);
}

// Find all functions in zig code.
//
// Why separate this? Function parsing is complex. Isolating it
// makes the code easier to test and understand.
fn find_functions(
    allocator: std.mem.Allocator,
    code: []const u8,
) ![]FunctionInfo {
    var functions = std.ArrayList(FunctionInfo){};
    try functions.ensureTotalCapacity(allocator, 16);
    errdefer functions.deinit(allocator);

    var line_iter = std.mem.splitScalar(u8, code, '\n');
    var line_number: usize = 1;
    var in_function = false;
    var function_start: usize = 0;
    var function_name: ?[]const u8 = null;
    var brace_count: i32 = 0;

    while (line_iter.next()) |line| {
        const trimmed = std.mem.trim(u8, line, &std.ascii.whitespace);

        // Look for function definition
        if (std.mem.indexOf(u8, trimmed, "fn ") != null and
            !in_function)
        {
            in_function = true;
            function_start = line_number;

            // Extract function name (simplified - assumes "fn name")
            if (std.mem.indexOf(u8, trimmed, "fn ")) |fn_pos| {
                const after_fn = trimmed[fn_pos + 3..];
                if (std.mem.indexOfScalar(u8, after_fn, '(')) |paren_pos|
                {
                    const name_slice = std.mem.trim(
                        u8,
                        after_fn[0..paren_pos],
                        &std.ascii.whitespace,
                    );
                    function_name =
                        try allocator.dupe(u8, name_slice);
                }
            }
            brace_count = 0;
        }

        // Count braces to detect function end
        if (in_function) {
            for (trimmed) |char| {
                if (char == '{') brace_count += 1;
                if (char == '}') brace_count -= 1;
            }

            // Function ended when braces balance
            if (brace_count == 0 and trimmed.len > 0) {
                const func_name = function_name orelse "unknown";
                const func_name_owned =
                    try allocator.dupe(u8, func_name);
                if (function_name) |name| {
                    allocator.free(name);
                }

                try functions.append(allocator, .{
                    .name = func_name_owned,
                    .start_line = function_start,
                    .end_line = line_number,
                    .length = line_number - function_start + 1,
                });

                in_function = false;
                function_name = null;
            }
        }

        line_number += 1;
    }

    // Handle function that extends to end of file
    if (in_function) {
        if (function_name) |name| {
            const func_name_owned = try allocator.dupe(u8, name);
            allocator.free(name);
            try functions.append(allocator, .{
                .name = func_name_owned,
                .start_line = function_start,
                .end_line = line_number - 1,
                .length = line_number - function_start,
            });
        }
    }

    return try functions.toOwnedSlice(allocator);
}

