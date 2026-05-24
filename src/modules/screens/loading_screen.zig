const std = @import("std");
const rl = @import("raylib");
const App = @import("../../root.zig").App;
const Timer = @import("../timer.zig").Timer;
const AppState = @import("../../lib/utils.zig").AppState;

pub const LoadingScreen = struct {
    fade_in_timer: Timer,
    fade_out_timer: Timer,
    loading: bool = false,
    completion_state: AppState = .Intro,

    pub fn init() LoadingScreen {
        return LoadingScreen{ .fade_in_timer = .init(0.5), .fade_out_timer = .init(0.5) };
    }

    pub fn deinit(self: *LoadingScreen) void {
        _ = self; // Avoid unused parameter warning
    }

    pub fn draw(self: *LoadingScreen) void {
        var alpha: f32 = 1.0;
        if (self.fade_in_timer.is_active) {
            alpha = 1.0 - self.fade_in_timer.value_ms / self.fade_in_timer.initial_value_ms;
            self.fade_in_timer.update();
        } else if (self.fade_out_timer.is_active) {
            alpha = self.fade_out_timer.value_ms / self.fade_out_timer.initial_value_ms;
            self.fade_out_timer.update();
        }
        const tint = rl.Color.black.alpha(alpha);
        _ = tint; // Avoid unused variable warning if alpha is always 1
        rl.drawRectangle(0, 0, rl.getScreenWidth(), rl.getScreenHeight(), rl.Color.black);
    }

    pub fn update(self: *LoadingScreen, app: *App) void {
        if (self.loading) return;
        if (app.state != .Loading) return;
        if (self.fade_in_timer.is_active or self.fade_out_timer.is_active) return;
        return app.setState(self.completion_state);
    }
};
