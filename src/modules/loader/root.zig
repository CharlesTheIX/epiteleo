const std = @import("std");
const rl = @import("raylib");
const a = @import("../../root.zig");
const utils = @import("../../utils.zig");

const App = a.App;
const AppState = a.State;
const JobCtx = utils.JobCtx;
const JobStatus = utils.JobStatus;
const JobRequest = utils.JobRequest;
const doJob = utils.doJob;
const UI = @import("../ui/root.zig").UI;
const Timer = @import("../timer/root.zig").Timer;
const Resources = @import("./lib/resources.zig").Resources;

pub const Loader = struct {
    loading: bool = false,
    showing: bool = false,
    resources: Resources = .{},
    completion_pending: bool = false,
    fade_in_timer: Timer = .init(0.5),
    fade_out_timer: Timer = .init(0.5),
    active_request: ?JobRequest = null,
    completion_state: ?AppState = null,
    job_status: std.atomic.Value(u8) = std.atomic.Value(u8).init(JobStatus.toInt(.Idle)),

    pub fn init() Loader {
        return .{};
    }

    pub fn deinit(self: *Loader) void {
        self.resources.deinit();
    }

    pub fn drawLoadingScreen(self: *Loader, ui: *UI) void {
        if (!self.showing) return;
        var alpha: f32 = 1.0;
        var tint = rl.Color.white;
        const template = ui.defaultRect();
        const loading_txt = "LOADING";
        var pos = rl.Vector2.init(template.width, template.height);
        ui.drawRect(template, rl.Color.black);
        if (self.resources.texture != null) {
            pos.x -= 32;
            pos.y -= 32;
            if (self.fade_in_timer.is_active) {
                alpha = 1.0 - self.fade_in_timer.value_ms / self.fade_in_timer.initial_value_ms;
            } else if (self.fade_out_timer.is_active) alpha = self.fade_out_timer.value_ms / self.fade_out_timer.initial_value_ms;
            tint = rl.Color.white.alpha(alpha);
            self.resources.sprite.draw(&pos, tint);
        }
        pos.y -= 16;
        pos.x -= ui.font.measureText(loading_txt, ui.font.size).x + 32;
        ui.drawText(loading_txt, pos, ui.font.size, tint);
    }

    pub fn load(self: *Loader, job_request: JobRequest, completion_state: ?AppState) !void {
        self.loading = true;
        self.showing = true;
        self.completion_pending = false;
        self.active_request = job_request;
        self.fade_in_timer.is_active = true;
        self.fade_out_timer.is_active = false;
        self.fade_in_timer.value_ms = self.fade_in_timer.initial_value_ms;
        if (completion_state) |state| self.completion_state = state;
        self.fade_out_timer.value_ms = self.fade_out_timer.initial_value_ms;
        self.job_status.store(JobStatus.toInt(.Idle), .release);
        const ctx = JobCtx{ .request = job_request, .status = &self.job_status };
        var thread = std.Thread.spawn(.{}, doJob, .{ctx}) catch return;
        thread.detach();
    }

    pub fn update(self: *Loader, app: *App) void {
        if (!self.showing) return;
        self.resources.sprite.update();
        if (self.loading) {
            const status = JobStatus.fromInt(self.job_status.load(.acquire));
            switch (status) {
                .Success => {
                    self.loading = false;
                    self.completion_pending = true;
                    if (self.active_request) |request| {
                        switch (request) {
                            .SleepNs => {},
                            .Task => |task| if (task.run_on_main_thread) task.run(task.ctx, task.io),
                        }
                    }
                    self.active_request = null;
                },
                .Failed => {
                    self.loading = false;
                    self.active_request = null;
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
            if (self.completion_state) |state| app.setState(state, null);
        }
    }
};
