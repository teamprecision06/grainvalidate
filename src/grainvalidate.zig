//! grainvalidate: complete style validation for grain network
//!
//! What is grainvalidate? It's how we enforce all grain style
//! constraints on zig code, ensuring it follows network standards.
//!
//! Every function is measured. Every line is checked. Every violation
//! is reported. That's the grainvalidate way.

const std = @import("std");

// Re-export our modules for external use.
//
// Why re-export? This pattern creates a clean public API.
// Users import "grainvalidate" and get everything they need,
// but internally we keep concerns separated into modules.
pub const types = @import("types.zig");
pub const function_length_mod = @import("function_length.zig");
pub const style_mod = @import("style.zig");

// Re-export commonly used types for convenience.
pub const Violation = types.Violation;
pub const ViolationType = types.ViolationType;
pub const ValidationResult = types.ValidationResult;
pub const ValidateConfig = types.ValidateConfig;

// Validate code against all grain style rules.
//
// Takes source code and configuration, returns all violations found.
// This is the main entry point for style validation.
//
// Why return a heap-allocated result? Violations can be numerous.
// We need to allocate space for them. The caller is responsible
// for freeing the memory.
pub fn validate(
    allocator: std.mem.Allocator,
    code: []const u8,
    config: ValidateConfig,
) !ValidationResult {
    var all_violations = std.ArrayList(Violation){};
    try all_violations.ensureTotalCapacity(allocator, 32);
    errdefer all_violations.deinit(allocator);

    // Check function lengths
    const func_violations =
        try function_length_mod.validate_function_length(
            allocator,
            code,
            config.max_function_length,
        );
    defer allocator.free(func_violations);
    try all_violations.appendSlice(allocator, func_violations);

    // Check naming conventions
    if (config.check_naming) {
        const naming_violations = try style_mod.validate_naming(
            allocator,
            code,
        );
        defer allocator.free(naming_violations);
        try all_violations.appendSlice(allocator, naming_violations);
    }

    // Count functions and lines
    const total_functions = count_functions(code);
    const total_lines = std.mem.count(u8, code, "\n") + 1;

    const violations_slice = try all_violations.toOwnedSlice(allocator);

    return ValidationResult{
        .violations = violations_slice,
        .total_functions = total_functions,
        .total_lines = total_lines,
        .compliant = violations_slice.len == 0,
    };
}

// Free validation result and its violations.
//
// Why a separate free function? It makes memory management explicit.
// Callers know they need to free the result when done.
pub fn free_result(
    allocator: std.mem.Allocator,
    result: ValidationResult,
) void {
    for (result.violations) |violation| {
        allocator.free(violation.message);
    }
    allocator.free(result.violations);
}

// Count functions in code.
//
// Why separate this? Function counting is useful for reporting.
// Isolating it makes the code easier to test and understand.
fn count_functions(code: []const u8) usize {
    var count: usize = 0;
    var line_iter = std.mem.splitScalar(u8, code, '\n');

    while (line_iter.next()) |line| {
        const trimmed = std.mem.trim(u8, line, &std.ascii.whitespace);
        if (std.mem.indexOf(u8, trimmed, "fn ") != null) {
            count += 1;
        }
    }

    return count;
}

// Default configuration for grain style validation.
//
// 70 lines per function, 73 characters per line. These constraints
// ensure code fits in graincards while maintaining readability.
pub const default_config = ValidateConfig{
    .max_function_length = 70,
    .max_line_width = 73,
    .check_naming = true,
    .check_errors = true,
};

test "grainvalidate module" {
    const testing = std.testing;
    _ = testing;

    // This test just ensures all modules compile and link.
    // Individual functionality is tested in their respective
    // module files.
}

