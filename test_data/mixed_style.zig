// mixed file with some valid and some invalid style
const std = @import("std");

pub fn main() !void {
    try validFunction();
    try invalidFunction();
}

fn validFunction() !void {
    // this function is valid - under 70 lines
    const x = 42;
    std.debug.print("ok\n", .{});
}

fn invalid_function() !void {
    // this function name is invalid - should be snake_case
    const x = 42;
    std.debug.print("invalid\n", .{});
}

fn function_with_anyerror() anyerror!void {
    // this uses anyerror which violates grain style
    return;
}

fn good_function() void {
    // this function follows all rules
    const result = "ok";
    std.debug.print("{s}\n", .{result});
}

