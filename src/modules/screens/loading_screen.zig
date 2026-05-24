const std = @import("std");
const rl = @import("raylib");
const UI = @import("../ui/root.zig").UI;
const App = @import("../../root.zig").App;
const Timer = @import("../timer.zig").Timer;
const Sprite = @import("../sprite/root.zig").Sprite;
const AppState = @import("../../lib/utils.zig").AppState;

pub const LoadingScreen = struct {
    loading: bool = false,
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
        var pos = rl.Vector2.init(@as(f32, @floatFromInt(rl.getScreenWidth())), @as(f32, @floatFromInt(rl.getScreenHeight())));
        ui.drawRect(rl.Rectangle.init(0, 0, pos.x, pos.y), rl.Color.black);
        if (self.resources.texture != null) {
            pos.x -= 32;
            pos.y -= 32;
            var alpha: f32 = 1.0;
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
            self.resources.sprite.draw(&pos, rl.Color.white.alpha(alpha));
        }
        const loading_txt = "LOADING";
        pos.y -= 12;
        pos.x -= ui.font.measureText(loading_txt, ui.font.size).x + 24;
        ui.drawText(loading_txt, pos, ui.font.size, rl.Color.white);
    }

    pub fn update(self: *LoadingScreen, app: *App) void {
        self.resources.sprite.update();
        if (self.loading) return;
        if (app.state != .Loading) return;
        if (self.resources.texture != null) {
            if (self.fade_in_timer.is_active or self.fade_out_timer.is_active) return;
        }
        return app.setState(self.completion_state);
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
