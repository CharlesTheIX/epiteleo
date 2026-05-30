const std = @import("std");
const rl = @import("raylib");
const _job = @import("./lib/job.zig");
const _app = @import("../../root.zig");
const _ui = @import("../../_ui/root.zig");
const Timer = @import("../timer/root.zig").Timer;
const Resources = @import("./lib/resources.zig").Resources;

pub const Loader = struct {
    loading: bool = false,
    showing: bool = false,
    resources: Resources = .{},
    completion_pending: bool = false,
    fade_in_timer: Timer = .init(0.5),
    fade_out_timer: Timer = .init(0.5),
    active_request: ?_job.Request = null,
    completion_state: ?_app.State = null,
    job_status: std.atomic.Value(u8) = std.atomic.Value(u8).init(_job.Status.toInt(.Idle)),

    pub fn init() Loader {
        return .{};
    }

    pub fn deinit(self: *Loader) void {
        self.resources.deinit();
    }

    pub fn drawLoadingScreen(self: *Loader, font: *_ui.Font) void {
        if (!self.showing) return;
        var alpha: f32 = 1.0;
        const spacing: f32 = 32;
        var tint = rl.Color.white;
        const loading_txt = "LOADING";
        const template = _ui.initScreenRect();
        var pos = rl.Vector2.init(template.width + template.x, template.height + template.y);
        _ui.drawRect(.{ .rect = template, .color = rl.Color.black.alpha(alpha) });
        if (self.resources.texture != null) {
            pos.x -= spacing;
            pos.y -= spacing;
            if (self.fade_in_timer.is_active) {
                alpha = 1.0 - self.fade_in_timer.value_ms / self.fade_in_timer.initial_value_ms;
            } else if (self.fade_out_timer.is_active) alpha = self.fade_out_timer.value_ms / self.fade_out_timer.initial_value_ms;
            tint = rl.Color.white.alpha(alpha);
            self.resources.sprite.draw(&pos, tint);
        }
        pos.y -= @as(f32, @divFloor(spacing, 2));
        pos.x -= _ui.measureText(loading_txt, font.*).x + spacing;
        _ui.drawText(.{ .text = loading_txt, .pos = pos, .font = font.*, .color = tint });
    }

    pub fn load(self: *Loader, request: _job.Request, completion_state: ?_app.State) !void {
        self.loading = true;
        self.showing = true;
        self.active_request = request;
        self.completion_pending = false;
        self.fade_in_timer.is_active = true;
        self.fade_out_timer.is_active = false;
        self.fade_in_timer.value_ms = self.fade_in_timer.initial_value_ms;
        if (completion_state) |state| self.completion_state = state;
        self.fade_out_timer.value_ms = self.fade_out_timer.initial_value_ms;
        self.job_status.store(_job.Status.toInt(.Idle), .release);
        const ctx = _job.Ctx{ .request = request, .status = &self.job_status };
        var thread = std.Thread.spawn(.{}, _job.run, .{ctx}) catch return;
        thread.detach();
    }

    pub fn update(self: *Loader, app: *_app.App) void {
        if (!self.showing) return;
        self.resources.sprite.update();
        if (self.loading) {
            const status = _job.Status.fromInt(self.job_status.load(.acquire));
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
