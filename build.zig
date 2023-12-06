const std = @import("std");

const version = get_version: {
    const version_from_file = @embedFile("./VERSION");
    const trimed_version = std.mem.trim(u8, version_from_file, "\n");
    const version_string = std.fmt.comptimePrint("\"{s}\"", .{trimed_version});
    break :get_version version_string;
};

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const lib = b.addStaticLibrary(.{
        .name = "quickjs",
        .link_libc = true,
        .target = target,
        .optimize = optimize,
    });
    lib.addCSourceFiles(.{ .files = &[_][]const u8{
        "cutils.c",
        "libbf.c",
        "libregexp.c",
        "libunicode.c",
        "quickjs.c",
    }, .flags = &[_][]const u8{
        "-Wextra",
        "-Wno-sign-compare",
        "-Wno-missing-field-initializers",
        "-Wundef",
        "-Wuninitialized",
        "-Wunused",
        "-Wno-unused-parameter",
        "-Wwrite-strings",
        "-Wchar-subscripts",
        "-funsigned-char",
    } });
    lib.defineCMacro("_GNU_SOURCE", null);
    lib.defineCMacro("CONFIG_VERSION", version);
    lib.defineCMacro("CONFIG_BIGNUM", null);
    lib.pie = true;

    b.installArtifact(lib);

    lib.installHeader("quickjs.h", "quickjs.h");
}
