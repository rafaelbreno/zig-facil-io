const std = @import("std");
const Builder = std.build.Builder;

pub fn build(b: *std.build.Builder) void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target = b.standardTargetOptions(.{});

    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const mode = b.standardReleaseOptions();

    const exe = b.addExecutable("zig-facil-io", "src/main.zig");
    exe.setTarget(target);
    exe.setBuildMode(mode);
    exe.install();

    const run_cmd = exe.run();
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    const exe_tests = b.addTest("src/main.zig");
    exe_tests.setTarget(target);
    exe_tests.setBuildMode(mode);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&exe_tests.step);
}

const WebServer = struct {
    facilio: *std.build.LibExeObjStep,

    fn create(
        b: *Builder,
        target: *std.zig.CrossTarget,
        mode: *std.builtin.Mode,
        debug_mode: *std.builtin.Mode,
    ) WebServer {
        _ = debug_mode;

        const facilio = b.addStaticLibrary("facilio", null);
        facilio.setTarget(target);
        facilio.setBuildMode(mode);
        facilio.linkLibC();
        facilio.addIncludePath("deps/facilio");
        facilio.addCSourceFiles(&.{
            "deps/facilio/lib/facil/cli/fio_cli.c",
            "deps/facilio/lib/facil/fiobj/fiobj_ary.c",
            "deps/facilio/lib/facil/fiobj/fiobj_data.c",
            "deps/facilio/lib/facil/fiobj/fiobject.c",
            "deps/facilio/lib/facil/fiobj/fiobj_hash.c",
            "deps/facilio/lib/facil/fiobj/fiobj_json.c",
            "deps/facilio/lib/facil/fiobj/fiobj_mustache.c",
            "deps/facilio/lib/facil/fiobj/fiobj_numbers.c",
            "deps/facilio/lib/facil/fiobj/fiobj_str.c",
            "deps/facilio/lib/facil/fiobj/fio_siphash.c",
            "deps/facilio/lib/facil/fio.c",
            "deps/facilio/lib/facil/http/http1.c",
            "deps/facilio/lib/facil/http/http.c",
            "deps/facilio/lib/facil/http/http_internal.c",
            "deps/facilio/lib/facil/http/websockets.c",
            "deps/facilio/lib/facil/legacy/fio_mem.c",
            "deps/facilio/lib/facil/redis/redis_engine.c",
            "deps/facilio/lib/facil/tls/fio_tls_missing.c",
            "deps/facilio/lib/facil/tls/fio_tls_openssl.c",
        }, &.{});

        return .{
            .facilio = facilio,
        };
    }

    fn link(webserver: WebServer, artifact: *std.build.LibExeObjStep) void {
        artifact.linkLibrary(webserver.facilio);
    }
};
