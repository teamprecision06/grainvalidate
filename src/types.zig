//! types: grainvalidate data structures
//!
//! What makes up a style violation? What configuration do we need?
//! This module defines the core data structures for grainvalidate.

// Style violation represents a code style rule violation.
//
// Why separate this into a struct? It makes violations explicit and
// easy to report. You get line number, violation type, and message.
pub const Violation = struct {
    line: usize,
    violation_type: ViolationType,
    message: []const u8,
};

// Types of style violations we can detect.
//
// Why an enum? It makes violation types explicit and extensible.
// We can add new violation types without breaking existing code.
pub const ViolationType = enum {
    function_too_long,
    line_too_long,
    invalid_naming,
    generic_error_type,
};

// Validation result containing all violations found.
//
// Why a separate result? It makes the API explicit. You can check
// if there are violations, iterate over them, and handle them
// appropriately. No hidden state, no side effects.
pub const ValidationResult = struct {
    violations: []Violation,
    total_functions: usize,
    total_lines: usize,
    compliant: bool,
};

// Validation configuration.
//
// This struct holds all the parameters needed to validate code.
// Making it explicit means callers understand what options they have.
pub const ValidateConfig = struct {
    max_function_length: usize = 70,
    max_line_width: usize = 73,
    check_naming: bool = true,
    check_errors: bool = true,
};

