const std = @import("std");
const rl = @import("raylib");
const App = @import("../root.zig").App;

pub const AppState = enum {
    Init,
    Intro,
    Playing,
    Settings,

    pub fn toString(self: AppState) []const u8 {
        return switch (self) {
            .Init => "Init",
            .Intro => "Intro",
            .Playing => "Playing",
            .Settings => "Settings",
        };
    }
};

pub fn invertScroll(scroll: *rl.Vector2) rl.Vector2 {
    return rl.Vector2{ .x = scroll.x * -1, .y = scroll.y * -1 };
}

pub fn rotateVector(v: rl.Vector2, angle_degrees: f32) rl.Vector2 {
    const angle_radians = angle_degrees * std.math.pi / 180.0;
    const cos_a = @cos(angle_radians);
    const sin_a = @sin(angle_radians);
    return .{
        .x = v.x * cos_a - v.y * sin_a,
        .y = v.x * sin_a + v.y * cos_a,
    };
}
