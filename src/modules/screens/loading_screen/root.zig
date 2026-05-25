const std = @import("std");
const rl = @import("raylib");
const UI = @import("../../ui/root.zig").UI;
const App = @import("../../../root.zig").App;
const JobCtx = @import("./utils.zig").JobCtx;
const Timer = @import("../../timer.zig").Timer;
const Resources = @import("./resources.zig").Resources;
const doJob = @import("./utils.zig").doJob;
const AppState = @import("../../../lib/utils.zig").AppState;

pub const LoadingScreen = struct {
    loading: bool = false,
    showing: bool = false,
    resources: Resources = .{},
    completion_pending: bool = false,
    fade_in_timer: Timer = .init(0.5),
    fade_out_timer: Timer = .init(0.5),
    completion_state: AppState = .Intro,
    job_done: std.atomic.Value(bool) = std.atomic.Value(bool).init(false),

    pub fn init() LoadingScreen {
        return .{};
    }

    pub fn deinit(self: *LoadingScreen) void {
        self.resources.deinit();
    }

    pub fn draw(self: *LoadingScreen, ui: *UI) void {
        if (!self.showing) return;
        var alpha: f32 = 1.0;
        var tint = rl.Color.white;
        const loading_txt = "LOADING";
        var pos = rl.Vector2.init(@as(f32, @floatFromInt(rl.getScreenWidth())), @as(f32, @floatFromInt(rl.getScreenHeight())));
        ui.drawRect(rl.Rectangle.init(0, 0, pos.x, pos.y), rl.Color.black);
        if (self.resources.texture != null) {
            pos.x -= 32;
            pos.y -= 32;
            if (self.fade_in_timer.is_active) {
                alpha = 1.0 - self.fade_in_timer.value_ms / self.fade_in_timer.initial_value_ms;
            } else if (self.fade_out_timer.is_active) alpha = self.fade_out_timer.value_ms / self.fade_out_timer.initial_value_ms;
            tint = rl.Color.white.alpha(alpha);
            self.resources.sprite.draw(&pos, tint);
        }
        pos.y -= 12;
        pos.x -= ui.font.measureText(loading_txt, ui.font.size).x + 24;
        ui.drawText(loading_txt, pos, ui.font.size, tint);
    }

    pub fn update(self: *LoadingScreen, app: *App) void {
        if (!self.showing) return;
        self.resources.sprite.update();
        if (self.loading and self.job_done.load(.acquire)) {
            self.loading = false;
            self.completion_pending = true;
        }

        if (self.fade_in_timer.is_active) {
            self.fade_in_timer.update();
            if (!self.fade_in_timer.is_active and self.completion_pending) self.fade_out_timer.is_active = true;
            return;
        }

        if (self.completion_pending and !self.fade_out_timer.is_active) self.fade_out_timer.is_active = true;
        if (self.fade_out_timer.is_active) {
            self.fade_out_timer.update();
            if (self.fade_out_timer.is_active) return;
        }

        if (self.completion_pending) {
            self.showing = false;
            self.completion_pending = false;
            app.setState(self.completion_state);
        }
    }

    pub fn load(self: *LoadingScreen, duration_ns: u64, completion_state: AppState) !void {
        self.loading = true;
        self.showing = true;
        self.completion_pending = false;
        self.fade_in_timer.is_active = true;
        self.fade_out_timer.is_active = false;
        self.completion_state = completion_state;
        self.job_done.store(false, .release);
        self.fade_in_timer.value_ms = self.fade_in_timer.initial_value_ms;
        self.fade_out_timer.value_ms = self.fade_out_timer.initial_value_ms;

        const job_ctx = JobCtx{
            .duration_ns = duration_ns, //here
            .done = &self.job_done,
        };
        var job_thread = std.Thread.spawn(.{}, doJob, .{job_ctx}) catch return;
        job_thread.detach();
    }
};
