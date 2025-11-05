const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Create the grainvalidate module
    const grainvalidate_mod = b.addModule("grainvalidate", .{
        .root_source_file = b.path("src/grainvalidate.zig"),
    });

    // Create CLI root module
    const cli_root_mod = b.createModule(.{
        .root_source_file = b.path("src/cli.zig"),
        .target = target,
        .optimize = optimize,
    });
    cli_root_mod.addImport("grainvalidate", grainvalidate_mod);

    // Create CLI executable
    const cli_exe = b.addExecutable(.{
        .name = "grainvalidate",
        .root_module = cli_root_mod,
    });

    b.installArtifact(cli_exe);

    const run_cli = b.addRunArtifact(cli_exe);
    run_cli.step.dependOn(b.getInstallStep());

    const run_step = b.step("run", "Run the CLI");
    run_step.dependOn(&run_cli.step);

    // Create test root module
    const test_root_mod = b.createModule(.{
        .root_source_file = b.path("src/grainvalidate.zig"),
        .target = target,
        .optimize = optimize,
    });

    // Create test executable
    const tests = b.addTest(.{
        .root_module = test_root_mod,
    });

    const run_tests = b.addRunArtifact(tests);

    const test_step = b.step("test", "Run grainvalidate tests");
    test_step.dependOn(&run_tests.step);

    // Test executables for validation
    const test_validate_exe_root_mod = b.createModule(.{
        .root_source_file = b.path("test_validate.zig"),
        .target = target,
        .optimize = optimize,
    });
    test_validate_exe_root_mod.addImport("grainvalidate", grainvalidate_mod);
    const test_validate_exe = b.addExecutable(.{
        .name = "test-validate",
        .root_module = test_validate_exe_root_mod,
    });
    const test_validate_run = b.addRunArtifact(test_validate_exe);
    const test_validate_step = b.step(
        "test-validate",
        "Test validation",
    );
    test_validate_step.dependOn(&test_validate_run.step);
}

