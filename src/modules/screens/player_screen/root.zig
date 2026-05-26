const std = @import("std");
const rl = @import("raylib");

const UI = @import("../../ui/root.zig").UI;
const Timer = @import("../../timer/root.zig").Timer;
const Resources = @import("./lib/resources.zig").Resources;

pub const PlayerScreen = struct {
    resources: Resources = .{},
    fade_in_timer: Timer = .init(0.5),

    pub fn init() PlayerScreen {
        return .{};
    }

    pub fn deinit(self: *PlayerScreen) void {
        self.resources.deinit();
    }

    pub fn draw(self: *PlayerScreen, ui: *UI) void {
        var alpha: f32 = 1.0;
        if (self.fade_in_timer.is_active) alpha = 1.0 - self.fade_in_timer.value_ms / self.fade_in_timer.initial_value_ms;
        ui.drawRect(
            rl.Rectangle.init(0, 0, @as(f32, @floatFromInt(rl.getScreenWidth())), @as(f32, @floatFromInt(rl.getScreenHeight()))),
            rl.Color.green.alpha(alpha),
        );
        const tint = rl.Color.white.alpha(alpha);
        if (self.resources.texture != null) {}
        const txt = "Playing";
        const pos = rl.Vector2.init(16, 16);
        ui.drawText(txt, pos, ui.font.size, tint);
    }

    pub fn update(self: *PlayerScreen) void {
        if (self.fade_in_timer.is_active) return self.fade_in_timer.update();
    }

    pub fn load(self: *PlayerScreen, io: *std.Io) void {
        _ = io;
        self.resources.load();
        self.fade_in_timer.is_active = true;
    }
};

pub fn loadPlayerScreenTask(ctx: *anyopaque, io: *std.Io) void {
    const screen: *PlayerScreen = @ptrCast(@alignCast(ctx));
    screen.load(io);
}
