# grainvalidate

complete style validation for grain network

## what is grainvalidate?

grainvalidate enforces all grain style constraints on zig code. it checks
function length, line width, naming conventions, and other grain_style
rules. every violation is reported with precision.

when you use grainvalidate, you're ensuring your code follows grain
network standards. 70-line functions, 73-character lines, explicit
error handling. these constraints breed clarity and force thoughtful
design.

## what does it validate?

grainvalidate checks:

- **function length**: max 70 lines per function
- **line width**: max 73 characters per line (uses grainwrap)
- **naming conventions**: snake_case for functions, PascalCase for types
- **explicit error handling**: no generic `anyerror`
- **module organization**: decomplected, focused modules

these constraints ensure code fits in graincards while maintaining
readability and clarity.

## architecture

grainvalidate is decomplected into focused modules:

- `types.zig` - data structures and configuration
- `function_length.zig` - function length validation
- `style.zig` - naming and error type validation
- `grainvalidate.zig` - public API and re-exports
- `cli.zig` - command line interface (work in progress - Zig 0.15.2 API)

each module has one clear responsibility. this makes the code
easier to understand, test, and extend.

note: the CLI interface is currently being updated for Zig 0.15.2
API compatibility. the core functionality works through the library
API and test executables.

## usage

### as a library

```zig
const std = @import("std");
const grainvalidate = @import("grainvalidate");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const code = @embedFile("src/main.zig");
    const config = grainvalidate.default_config;
    const result = try grainvalidate.validate(allocator, code, config);
    defer grainvalidate.free_result(allocator, result);

    if (!result.compliant) {
        std.debug.print(
            "Found {d} violations:\n",
            .{result.violations.len},
        );
        for (result.violations) |violation| {
            std.debug.print(
                "  {s} at line {d}: {s}\n",
                .{
                    @tagName(violation.violation_type),
                    violation.line,
                    violation.message,
                },
            );
        }
    }
}
```

### as a CLI tool

```bash
# validate a zig file
grainvalidate check src/main.zig

# validate all files in directory
grainvalidate check src/

# check only function length
grainvalidate check --function-length src/main.zig

# check only line width (uses grainwrap)
grainvalidate check --line-width src/main.zig
```

## integration

grainvalidate integrates with the zig workflow:

1. write your code normally
2. run `zig fmt` for standard formatting
3. run `grainwrap wrap` to enforce 73-char limit
4. run `grainvalidate check` to validate all style rules

this ensures your code follows grain style completely.

## team

**teamprecision06** (Virgo ♍ / VI. The Lovers)

the precision-makers who measure, validate, and enforce boundaries.
virgo's analytical nature meets the lovers' conscious choice. we make
constraints visible, measurable, and beautiful.

## license

multi-licensed: MIT / Apache 2.0 / CC BY 4.0

choose whichever license suits your needs.

