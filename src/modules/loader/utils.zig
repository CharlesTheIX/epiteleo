const std = @import("std");
const rl = @import("raylib");

pub fn doJob(ctx: JobCtx) void {
    ctx.status.store(statusToInt(.Running), .release);
    switch (ctx.request) {
        .SleepNs => |duration_ns| {
            const duration_s: f64 = @as(f64, @floatFromInt(duration_ns)) / @as(f64, @floatFromInt(std.time.ns_per_s));
            rl.waitTime(duration_s);
            ctx.status.store(statusToInt(.Success), .release);
        },
        .Task => |task| {
            if (!task.run_on_main_thread) task.run(task.ctx, task.io);
            ctx.status.store(statusToInt(.Success), .release);
        },
    }
}

pub const JobCtx = struct {
    request: LoadRequest,
    status: *std.atomic.Value(u8),
};

pub const LoadRequest = union(enum) {
    SleepNs: u64,
    Task: LoadTask,
};

pub const LoadStatus = enum(u8) {
    Idle,
    Running,
    Success,
    Failed,
};

pub const LoadTask = struct {
    io: *std.Io,
    ctx: *anyopaque,
    run_on_main_thread: bool = false,
    run: *const fn (ctx: *anyopaque, io: *std.Io) void,
};

pub fn statusToInt(status: LoadStatus) u8 {
    return @intFromEnum(status);
}

pub fn statusFromInt(raw: u8) LoadStatus {
    return switch (raw) {
        0 => .Idle,
        1 => .Running,
        2 => .Success,
        3 => .Failed,
        else => .Failed,
    };
}
