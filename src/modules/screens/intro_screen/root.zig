const std = @import("std");
const rl = @import("raylib");
const ps = @import("../player_screen/root.zig");
const ih = @import("../../input_handler/root.zig");

const Key = ih.Key;
const InputHandler = ih.InputHandler;
const PlayerScreen = ps.PlayerScreen;
const UI = @import("../../ui/root.zig").UI;
const App = @import("../../../root.zig").App;
const Timer = @import("../../timer.zig").Timer;
const Resources = @import("./resources.zig").Resources;
const loadPlayerScreenTask = ps.loadPlayerScreenTask;
const LoadRequest = @import("../loading_screen/utils.zig").LoadRequest;

pub const IntroScreen = struct {
    option_index: u2 = 0,
    resources: Resources = .{},
    input_timer: Timer = .init(0.3),
    fade_in_timer: Timer = .init(0.5),
    options: [3][]const u8 = .{ "Stat Game", "Settings", "Exit" },

    pub fn init() IntroScreen {
        return .{};
    }

    pub fn deinit(self: *IntroScreen) void {
        self.resources.deinit();
    }

    pub fn draw(self: *IntroScreen, ui: *UI, allocator: std.mem.Allocator) void {
        var alpha: f32 = 1.0;
        if (self.fade_in_timer.is_active) alpha = 1.0 - self.fade_in_timer.value_ms / self.fade_in_timer.initial_value_ms;
        const template = ui.defaultRect();
        ui.drawRect(template, rl.Color.maroon.alpha(alpha));
        const tint = rl.Color.white.alpha(alpha);
        if (self.resources.texture) |texture| {
            rl.drawTextureV(texture, rl.Vector2.init(template.x, template.y), tint);
        }
        var pos = rl.Vector2.init(template.x + 16, template.y + 16);
        for (self.options, 0..) |option, i| {
            var option_txt = std.fmt.allocPrint(allocator, "{s}", .{option}) catch "";
            if (i == self.option_index) option_txt = std.fmt.allocPrint(allocator, "> {s}", .{option}) catch "";
            ui.drawText(option_txt, pos, ui.font.size, tint);
            pos.y += ui.font.size + 8;
        }
    }

    pub fn load(self: *IntroScreen) void {
        self.resources.load();
        self.fade_in_timer.is_active = true;
    }

    pub fn update(self: *IntroScreen, app: *App) void {
        if (self.fade_in_timer.is_active) return self.fade_in_timer.update();
        if (self.input_timer.is_active) return self.input_timer.update();
        var next_index: usize = self.option_index;
        if (app.input_handler.keyboard.getActiveKeysInclude(&[_]Key{ .W, .Up }, .Or)) {
            next_index = if (next_index == 0) self.options.len - 1 else next_index - 1;
        }
        if (app.input_handler.keyboard.getActiveKeysInclude(&[_]Key{ .S, .Down }, .Or)) {
            next_index = (next_index + 1) % self.options.len;
        }
        if (next_index != self.option_index) {
            self.input_timer.is_active = true;
            self.option_index = @intCast(next_index);
        }
        if (app.input_handler.keyboard.getActiveKeysInclude(&[_]Key{.Enter}, .And)) {
            self.input_timer.is_active = true;
            switch (self.option_index) {
                0 => {
                    defer self.deinit();
                    defer app.intro_screen = null;
                    self.input_timer.is_active = true;
                    if (app.player_screen == null) app.player_screen = PlayerScreen.init();
                    if (app.player_screen) |*p| {
                        const load_request: LoadRequest = .{ .Task = .{
                            .ctx = @ptrCast(p),
                            .run_on_main_thread = true,
                            .run = loadPlayerScreenTask,
                        } };
                        return app.setState(.Playing, load_request);
                    }
                    return std.debug.panic("Failed to initialize the player screen\n", .{});
                },
                1 => {},
                2 => app.shut_down = true,
                else => {},
            }
        }
    }
};

pub fn loadIntroScreenTask(ctx: *anyopaque) void {
    const screen: *IntroScreen = @ptrCast(@alignCast(ctx));
    screen.load();
}
