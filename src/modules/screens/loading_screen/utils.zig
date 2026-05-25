const std = @import("std");
const rl = @import("raylib");

pub fn doJob(ctx: JobCtx) void { // here
    const duration_s: f64 = @as(f64, @floatFromInt(ctx.duration_ns)) / @as(f64, @floatFromInt(std.time.ns_per_s));
    rl.waitTime(duration_s);
    ctx.done.store(true, .release);
}

pub const JobCtx = struct {
    duration_ns: anytype,
    done: *std.atomic.Value(bool),
};
