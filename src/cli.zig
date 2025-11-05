//! cli: command line interface for grainvalidate
//!
//! How do users interact with grainvalidate? This module provides
//! a simple CLI for validating zig code style.

const std = @import("std");
const grainvalidate = @import("grainvalidate");

// TODO: Implement CLI interface
// This will handle:
// - `grainvalidate check <file>` - validate style rules
// - `grainvalidate check <dir>` - validate all files in directory
// - `grainvalidate check --function-length <file>` - check functions

pub fn main() !void {
    const stdout = std.io.stdOut().writer();

    try stdout.print(
        \\grainvalidate - complete style validation for grain network
        \\
        \\Usage:
        \\  grainvalidate check <file>
        \\  grainvalidate check <directory>
        \\  grainvalidate check --function-length <file>
        \\
        \\Commands:
        \\  check    Validate code against grain style rules
        \\
        \\Options:
        \\  --function-length    Check only function length (70 lines)
        \\  --line-width         Check only line width (73 chars)
        \\  --help               Show this help
        \\
        \\Examples:
        \\  grainvalidate check src/main.zig
        \\  grainvalidate check src/
        \\  grainvalidate check --function-length src/main.zig
        \\
        \\
    , .{});

    // TODO: Parse arguments and implement commands
}

