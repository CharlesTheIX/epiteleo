const std = @import("std");
const rl = @import("raylib");
const UI = @import("../ui/root.zig").UI;
const App = @import("../../root.zig").App;
const Timer = @import("../timer.zig").Timer;
const Sprite = @import("../sprite/root.zig").Sprite;
const AppState = @import("../../lib/utils.zig").AppState;

pub const LoadingScreen = struct {
    loading: bool = false,
    showing: bool = false,
    job_done: std.atomic.Value(bool) = std.atomic.Value(bool).init(false),
    completion_pending: bool = false,
    resources: Resources = .{},
    fade_in_timer: Timer = .init(0.5),
    fade_out_timer: Timer = .init(0.5),
    completion_state: AppState = .Intro,

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
            } else if (self.fade_out_timer.is_active) {
                alpha = self.fade_out_timer.value_ms / self.fade_out_timer.initial_value_ms;
            }
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
            if (!self.fade_in_timer.is_active and self.completion_pending) {
                self.fade_out_timer.is_active = true;
            }
            return;
        }

        if (self.completion_pending and !self.fade_out_timer.is_active) {
            self.fade_out_timer.is_active = true;
        }

        if (self.fade_out_timer.is_active) {
            self.fade_out_timer.update();
            if (self.fade_out_timer.is_active) return;
        }

        if (self.completion_pending) {
            self.completion_pending = false;
            self.showing = false;
            app.setState(self.completion_state);
        }
    }

    pub fn load(self: *LoadingScreen, duration_ns: u64, completion_state: AppState) !void {
        self.loading = true;
        self.showing = true;
        self.completion_pending = false;
        self.job_done.store(false, .release);
        self.completion_state = completion_state;
        self.fade_in_timer.is_active = true;
        self.fade_out_timer.is_active = false;
        self.fade_in_timer.value_ms = self.fade_in_timer.initial_value_ms;
        self.fade_out_timer.value_ms = self.fade_out_timer.initial_value_ms;

        const job_ctx = JobCtx{
            .duration_ns = duration_ns,
            .done = &self.job_done,
        };
        var job_thread = std.Thread.spawn(.{}, doJob, .{job_ctx}) catch return;
        job_thread.detach();
    }

    fn doJob(ctx: JobCtx) void {
        const duration_s: f64 = @as(f64, @floatFromInt(ctx.duration_ns)) / @as(f64, @floatFromInt(std.time.ns_per_s));
        rl.waitTime(duration_s);
        ctx.done.store(true, .release);
    }
};

const Resources = struct {
    texture: ?rl.Texture2D = null,
    sprite: Sprite = .init(.AnimalBoar, .Right, .Walk),

    pub fn deinit(self: *Resources) void {
        self.sprite.deinit();
        if (self.texture) |texture| {
            rl.unloadTexture(texture);
            self.texture = null;
        }
    }

    pub fn load(self: *Resources, io: *std.Io) void {
        const img = rl.loadImage("src/assets/screens/loading_screen.png") catch return;
        defer rl.unloadImage(img);
        const texture = rl.loadTextureFromImage(img) catch return;
        self.texture = texture;
        if (self.texture) |*txt| self.sprite.load(txt, io);
    }
};

pub const JobCtx = struct {
    duration_ns: u64,
    done: *std.atomic.Value(bool),
};
