const std = @import("std");
const rl = @import("raylib");

pub const Ctx = struct { request: Request, status: *std.atomic.Value(u8) };

pub const Request = union(enum) { SleepNs: u64, Task: Task };

pub fn run(ctx: Ctx) void {
    ctx.status.store(Status.toInt(.Running), .release);
    switch (ctx.request) {
        .SleepNs => |duration_ns| {
            const duration_s: f64 = @as(f64, @floatFromInt(duration_ns)) / @as(f64, @floatFromInt(std.time.ns_per_s));
            rl.waitTime(duration_s);
            ctx.status.store(Status.toInt(.Success), .release);
        },
        .Task => |task| {
            if (!task.run_on_main_thread) task.run(task.ctx, task.io);
            ctx.status.store(Status.toInt(.Success), .release);
        },
    }
}

pub const Status = enum(u8) {
    Idle,
    Running,
    Success,
    Failed,

    pub fn fromInt(raw: u8) Status {
        return switch (raw) {
            0 => .Idle,
            1 => .Running,
            2 => .Success,
            3 => .Failed,
            else => .Failed,
        };
    }

    pub fn toInt(status: Status) u8 {
        return @intFromEnum(status);
    }
};

pub const Task = struct {
    io: *std.Io,
    ctx: *anyopaque,
    run_on_main_thread: bool = false,
    run: *const fn (ctx: *anyopaque, io: *std.Io) void,
};
