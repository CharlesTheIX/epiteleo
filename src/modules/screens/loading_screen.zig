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
                std.debug.print("fade_in\n", .{});
                alpha = 1.0 - self.fade_in_timer.value_ms / self.fade_in_timer.initial_value_ms;
                self.fade_in_timer.update();
            } else if (self.fade_out_timer.is_active) {
                std.debug.print("fade_out\n", .{});
                alpha = 1.0 - self.fade_in_timer.value_ms / self.fade_in_timer.initial_value_ms;
                alpha = self.fade_out_timer.value_ms / self.fade_out_timer.initial_value_ms;
                self.fade_out_timer.update();
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
        if (self.loading) return;
        if (self.resources.texture != null) {
            if (self.fade_in_timer.is_active or self.fade_out_timer.is_active) return;
        }
        self.showing = false;
        return app.setState(self.completion_state);
    }

    pub fn placeholder(self: *LoadingScreen, job_ctx: *JobCtx, ui: *UI) !void {
        self.loading = true;
        self.showing = true;
        self.fade_in_timer.is_active = true;
        // var job_done = std.atomic.Value(bool).init(false);
        // const cpus = std.Thread.getCpuCount() catch |err| {
        //     return self.Err.handle(err, "Failed to get CPU count\n\n", true, true);
        // };
        // const cpu_id = std.Thread.getCurrentId();
        // const job_ctx = JobCtx{
        //     .name = "job",
        //     .done = &job_done,
        //     .duration_ns = std.time.ns_per_s * 5,
        // };
        const loading_ctx = LoadingCtx{ .job_done = job_ctx.done };
        var job_thread = std.Thread.spawn(.{}, doJob, .{job_ctx}) catch return;
        var loading_thread = std.Thread.spawn(.{}, __test, .{ self, ui, loading_ctx }) catch return;
        job_thread.detach();
        loading_thread.join();
    }

    fn __test(self: *LoadingScreen, ui: *UI, ctx: LoadingCtx) void {
        var i: usize = 0;
        while (true) {
            if (ctx.job_done.load(.acquire)) break;
            i += 1;
            std.Thread.sleep(90 * std.time.ns_per_ms);
            self.update(self);
            self.draw(ui);
        }
        self.loading = false;
    }

    fn doJob(ctx: *JobCtx) void {
        std.Thread.sleep(ctx.duration_ns);
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
    name: []const u8,
    duration_ns: u64,
    done: *std.atomic.Value(bool),
};

const LoadingCtx = struct {
    job_done: *std.atomic.Value(bool),
};
