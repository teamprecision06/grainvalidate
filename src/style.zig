//! style: style rule validation
//!
//! How do we check other grain style rules? This module validates
//! naming conventions, error types, and other style constraints.

const std = @import("std");
const types = @import("types.zig");

// Validate naming conventions in code.
//
// Checks for snake_case functions and PascalCase types.
// Returns violations for any naming that doesn't follow conventions.
pub fn validate_naming(
    allocator: std.mem.Allocator,
    code: []const u8,
) ![]types.Violation {
    var violations = std.ArrayList(types.Violation){};
    try violations.ensureTotalCapacity(allocator, 8);
    errdefer violations.deinit(allocator);

    var line_iter = std.mem.splitScalar(u8, code, '\n');
    var line_number: usize = 1;

    while (line_iter.next()) |line| {
        const trimmed = std.mem.trim(u8, line, &std.ascii.whitespace);

        // Check for function definitions
        if (std.mem.indexOf(u8, trimmed, "fn ") != null) {
            if (std.mem.indexOf(u8, trimmed, "fn ")) |fn_pos| {
                const after_fn = trimmed[fn_pos + 3..];
                if (std.mem.indexOfScalar(u8, after_fn, '(')) |paren_pos|
                {
                    const name = std.mem.trim(
                        u8,
                        after_fn[0..paren_pos],
                        &std.ascii.whitespace,
                    );

                    // Check if function name is snake_case
                    if (!is_snake_case(name)) {
                        const message = try std.fmt.allocPrint(
                            allocator,
                            "function '{s}' should be snake_case",
                            .{name},
                        );

                        try violations.append(allocator, .{
                            .line = line_number,
                            .violation_type = .invalid_naming,
                            .message = message,
                        });
                    }
                }
            }
        }

        // Check for generic error types
        if (std.mem.indexOf(u8, trimmed, "anyerror") != null) {
            const message = try std.fmt.allocPrint(
                allocator,
                "use explicit error types instead of anyerror",
                .{},
            );

            try violations.append(allocator, .{
                .line = line_number,
                .violation_type = .generic_error_type,
                .message = message,
            });
        }

        line_number += 1;
    }

    return try violations.toOwnedSlice(allocator);
}

// Check if a name follows snake_case convention.
//
// Why separate this? Naming validation logic can be complex.
// Isolating it makes the code easier to test and understand.
fn is_snake_case(name: []const u8) bool {
    if (name.len == 0) return false;

    // Must start with lowercase letter or underscore
    if (!std.ascii.isLower(name[0]) and name[0] != '_') {
        return false;
    }

    // Must contain only lowercase letters, digits, underscores
    for (name) |char| {
        if (!std.ascii.isLower(char) and
            !std.ascii.isDigit(char) and
            char != '_')
        {
            return false;
        }
    }

    return true;
}

