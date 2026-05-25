const std = @import("std");
const rl = @import("raylib");
const utils = @import("./utils.zig");
const UI = @import("../../ui/root.zig").UI;
const App = @import("../../../root.zig").App;
const Timer = @import("../../timer.zig").Timer;
const Resources = @import("./resources.zig").Resources;
const AppState = @import("../../../lib/utils.zig").AppState;

const JobCtx = utils.JobCtx;
const doJob = utils.doJob;
pub const LoadRequest = utils.LoadRequest;
const statusToInt = utils.statusToInt;
const statusFromInt = utils.statusFromInt;

pub const LoadingScreen = struct {
    loading: bool = false,
    showing: bool = false,
    resources: Resources = .{},
    completion_pending: bool = false,
    fade_in_timer: Timer = .init(0.5),
    fade_out_timer: Timer = .init(0.5),
    completion_state: AppState = .Intro,
    job_status: std.atomic.Value(u8) = std.atomic.Value(u8).init(statusToInt(.Idle)),

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
        if (self.loading) {
            const status = statusFromInt(self.job_status.load(.acquire));
            switch (status) {
                .Success => {
                    self.loading = false;
                    self.completion_pending = true;
                },
                .Failed => {
                    self.loading = false;
                    self.completion_pending = true;
                },
                else => {},
            }
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
            app.setState(self.completion_state, null);
        }
    }

    pub fn load(self: *LoadingScreen, load_request: LoadRequest, completion_state: AppState) !void {
        self.loading = true;
        self.showing = true;
        self.completion_pending = false;
        self.fade_in_timer.is_active = true;
        self.fade_out_timer.is_active = false;
        self.completion_state = completion_state;
        self.job_status.store(statusToInt(.Idle), .release);
        self.fade_in_timer.value_ms = self.fade_in_timer.initial_value_ms;
        self.fade_out_timer.value_ms = self.fade_out_timer.initial_value_ms;
        const ctx = JobCtx{ .request = load_request, .status = &self.job_status };
        var thread = std.Thread.spawn(.{}, doJob, .{ctx}) catch return;
        thread.detach();
    }
};
