const std = @import("std");
const rl = @import("raylib");
const UI = @import("../../ui/root.zig").UI;
const Timer = @import("../../timer.zig").Timer;
const Resources = @import("./resources.zig").Resources;

pub const IntroScreen = struct {
    resources: Resources = .{},
    fade_in_timer: Timer = .init(0.5),

    pub fn init() IntroScreen {
        return .{};
    }

    pub fn deinit(self: *IntroScreen) void {
        self.resources.deinit();
    }

    pub fn draw(self: *IntroScreen, ui: *UI) void {
        var alpha: f32 = 1.0;
        if (self.fade_in_timer.is_active) alpha = 1.0 - self.fade_in_timer.value_ms / self.fade_in_timer.initial_value_ms;
        ui.drawRect(
            rl.Rectangle.init(0, 0, @as(f32, @floatFromInt(rl.getScreenWidth())), @as(f32, @floatFromInt(rl.getScreenHeight()))),
            rl.Color.maroon.alpha(alpha),
        );
        const tint = rl.Color.white.alpha(alpha);
        if (self.resources.texture != null) {}
        const txt = "Intro";
        const pos = rl.Vector2.init(12, 12);
        ui.drawText(txt, pos, ui.font.size, tint);
    }

    pub fn update(self: *IntroScreen) void {
        if (self.fade_in_timer.is_active) self.fade_in_timer.update();
    }

    pub fn load(self: *IntroScreen) void {
        self.resources.load();
        self.fade_in_timer.is_active = true;
    }
};
