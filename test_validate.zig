// test program to validate fuzzed zig code
const std = @import("std");
const grainvalidate = @import("grainvalidate");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const test_files = [_][]const u8{
        "test_data/long_functions.zig",
        "test_data/mixed_style.zig",
    };

    for (test_files) |file_path| {
        std.debug.print("\n=== Testing {s} ===\n", .{file_path});

        const file = try std.fs.cwd().openFile(file_path, .{});
        defer file.close();

        const file_size = try file.getEndPos();
        const code = try allocator.alloc(u8, file_size);
        defer allocator.free(code);

        _ = try file.readAll(code);

        const config = grainvalidate.default_config;
        const result = try grainvalidate.validate(allocator, code, config);
        defer grainvalidate.free_result(allocator, result);

        std.debug.print(
            "Total functions: {d}\n",
            .{result.total_functions},
        );
        std.debug.print(
            "Total lines: {d}\n",
            .{result.total_lines},
        );
        std.debug.print(
            "Compliant: {}\n",
            .{result.compliant},
        );
        std.debug.print(
            "Violations: {d}\n",
            .{result.violations.len},
        );

        if (result.violations.len > 0) {
            std.debug.print("\nViolations:\n", .{});
            for (result.violations) |violation| {
                std.debug.print(
                    "  Line {d}: {s}\n",
                    .{ violation.line, violation.message },
                );
            }
        }
    }
}

