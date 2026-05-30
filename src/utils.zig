const std = @import("std");
const rl = @import("raylib");

pub fn invertScroll(scroll: *rl.Vector2) rl.Vector2 {
    return rl.Vector2{ .x = scroll.x * -1, .y = scroll.y * -1 };
}

pub fn nowEpochYearSeconds() i64 {
    var ts: std.posix.timespec = undefined;
    switch (std.posix.errno(std.posix.system.clock_gettime(.REALTIME, &ts))) {
        .SUCCESS => {
            const unix_secs = @as(i64, @intCast(ts.sec));
            const ios_offset = @as(i64, @intCast(std.time.epoch.epoch_year));
            return unix_secs - ios_offset;
        },
        else => return 0,
    }
}

pub fn rotateVector(v: rl.Vector2, angle_degrees: f32) rl.Vector2 {
    const angle_radians = angle_degrees * std.math.pi / 180.0;
    const cos_a = @cos(angle_radians);
    const sin_a = @sin(angle_radians);
    return .{ .x = v.x * cos_a - v.y * sin_a, .y = v.x * sin_a + v.y * cos_a };
}
