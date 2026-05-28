const std = @import("std");
const rl = @import("raylib");
const _ui = @import("../../_ui/root.zig");
const Timer = @import("../timer/root.zig").Timer;
const Resources = @import("./lib/resources.zig").Resources;

pub const Game = struct {
    resources: Resources = .{},
    fade_in_timer: Timer = .init(0.5),

    pub fn init() Game {
        return .{};
    }

    pub fn deinit(self: *Game) void {
        self.resources.deinit();
    }

    pub fn draw(self: *Game) void {
        var alpha: f32 = 1.0;
        if (self.fade_in_timer.is_active) alpha = 1.0 - self.fade_in_timer.value_ms / self.fade_in_timer.initial_value_ms;
        const screen_w = @as(f32, @floatFromInt(rl.getScreenWidth()));
        const screen_h = @as(f32, @floatFromInt(rl.getScreenHeight()));
        _ui.drawRect(.{ .rect = .init(0, 0, screen_w, screen_h), .color = rl.Color.maroon.alpha(alpha) });
        // const tint = rl.Color.white.alpha(alpha);
        if (self.resources.texture != null) {}
    }

    pub fn update(self: *Game) void {
        if (self.fade_in_timer.is_active) return self.fade_in_timer.update();
    }
};

pub fn loadGameTask(ctx: *anyopaque, io: *std.Io) void {
    _ = io;
    const module: *Game = @ptrCast(@alignCast(ctx));
    module.resources.load();
    module.fade_in_timer.is_active = true;
}
