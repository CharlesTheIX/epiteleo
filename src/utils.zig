const std = @import("std");
const rl = @import("raylib");
const Camera = @import("./modules/camera/root.zig").Camera;

pub fn doJob(ctx: JobCtx) void {
    ctx.status.store(JobStatus.toInt(.Running), .release);
    switch (ctx.request) {
        .SleepNs => |duration_ns| {
            const duration_s: f64 = @as(f64, @floatFromInt(duration_ns)) / @as(f64, @floatFromInt(std.time.ns_per_s));
            rl.waitTime(duration_s);
            ctx.status.store(JobStatus.toInt(.Success), .release);
        },
        .Task => |task| {
            if (!task.run_on_main_thread) task.run(task.ctx, task.io);
            ctx.status.store(JobStatus.toInt(.Success), .release);
        },
    }
}

pub fn invertScroll(scroll: *rl.Vector2) rl.Vector2 {
    return rl.Vector2{ .x = scroll.x * -1, .y = scroll.y * -1 };
}

pub const JobCtx = struct {
    request: JobRequest,
    status: *std.atomic.Value(u8),
};

pub const JobRequest = union(enum) {
    SleepNs: u64,
    Task: JobTask,
};

pub const JobStatus = enum(u8) {
    Idle,
    Running,
    Success,
    Failed,

    pub fn fromInt(raw: u8) JobStatus {
        return switch (raw) {
            0 => .Idle,
            1 => .Running,
            2 => .Success,
            3 => .Failed,
            else => .Failed,
        };
    }

    pub fn toInt(status: JobStatus) u8 {
        return @intFromEnum(status);
    }
};

pub const JobTask = struct {
    io: *std.Io,
    ctx: *anyopaque,
    run_on_main_thread: bool = false,
    run: *const fn (ctx: *anyopaque, io: *std.Io) void,
};

pub fn rotateVector(v: rl.Vector2, angle_degrees: f32) rl.Vector2 {
    const angle_radians = angle_degrees * std.math.pi / 180.0;
    const cos_a = @cos(angle_radians);
    const sin_a = @sin(angle_radians);
    return .{ .x = v.x * cos_a - v.y * sin_a, .y = v.x * sin_a + v.y * cos_a };
}

pub fn windowVectorToCameraVector(v: rl.Vector2, camera: *const Camera) rl.Vector2 {
    var pos = v.subtract(camera.camera.offset);
    pos = rotateVector(pos, -camera.camera.rotation);
    pos = pos.scale(1.0 / camera.camera.zoom);
    return pos.add(camera.camera.target);
}
