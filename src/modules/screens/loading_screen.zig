const std = @import("std");
const rl = @import("raylib");
const App = @import("../../root.zig").App;
const Timer = @import("../timer.zig").Timer;
const AppState = @import("../../lib/utils.zig").AppState;

pub const LoadingScreen = struct {
    fade_timer: Timer,
    loading: bool = false,
    completion_state: AppState = .Intro,
    fade_state: enum { FadingIn, FadingOut } = .FadingIn,

    pub fn init() LoadingScreen {
        return LoadingScreen{ .fade_timer = .init(0.3) };
    }

    pub fn deinit(self: *LoadingScreen) void {
        _ = self; // Avoid unused parameter warning
    }

    pub fn draw(self: *LoadingScreen) void {
        var alpha: f32 = 1.0;
        if (self.fade_timer.is_active) {
            const percent = self.fade_timer.value_ms / self.fade_timer.initial_value_ms;
            switch (self.fade_state) {
                .FadingOut => alpha = percent,
                .FadingIn => alpha = 1.0 - percent,
            }
            self.fade_timer.update();
            if (self.fade_timer.value_ms == 0) {
                self.fade_state = switch (self.fade_state) {
                    .FadingIn => .FadingOut,
                    .FadingOut => .FadingIn,
                };
            }
        }
        const tint = rl.Color.black.alpha(alpha);
        rl.drawRectangle(0, 0, rl.getScreenWidth(), rl.getScreenHeight(), tint);
    }

    pub fn update(self: *LoadingScreen, app: *App) void {
        if (self.loading) return;
        self.fade_timer.is_active = true;
        if (self.fade_state == .FadingOut) return;
        return app.setState(self.completion_state);
    }
};
