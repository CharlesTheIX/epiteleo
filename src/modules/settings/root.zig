const std = @import("std");
const rl = @import("raylib");
const ih = @import("../input_handler/root.zig");
const is = @import("../screens/intro_screen/root.zig");

const Key = ih.Key;
const IntroScreen = is.IntroScreen;
const InputHandler = ih.InputHandler;
const UI = @import("../ui/root.zig").UI;
const App = @import("../../root.zig").App;
const Timer = @import("../timer.zig").Timer;
const Resources = @import("./resources.zig").Resources;
const LoadRequest = @import("../loader/utils.zig").LoadRequest;
const loadIntroScreenTask = is.loadIntroScreenTask;

pub const Settings = struct {
    option_index: u2 = 0,
    resources: Resources = .{},
    input_timer: Timer = .init(0.3),
    fade_in_timer: Timer = .init(0.5),
    options: [2][]const u8 = .{ "Test", "Back" },

    pub fn init() Settings {
        return .{};
    }

    pub fn deinit(self: *Settings) void {
        self.resources.deinit();
    }

    pub fn drawSettingsScreen(self: *Settings, ui: *UI, allocator: std.mem.Allocator) void {
        var alpha: f32 = 1.0;
        if (self.fade_in_timer.is_active) alpha = 1.0 - self.fade_in_timer.value_ms / self.fade_in_timer.initial_value_ms;
        const tint = rl.Color.white.alpha(alpha);
        const rect = ui.defaultRect();
        var pos = rl.Vector2.init(rect.x + 16, rect.y + 16);
        ui.drawRect(rect, rl.Color.blue.alpha(alpha));
        if (self.resources.texture) |texture| rl.drawTextureV(texture, rl.Vector2.init(rect.x, rect.y), tint);
        const title = "Settings";
        ui.drawText(title, pos, ui.font.size, tint);
        pos.y += ui.font.size + ui.font.size + 8;
        for (self.options, 0..) |option, i| {
            var option_txt = std.fmt.allocPrint(allocator, "{s}", .{option}) catch "";
            if (i == self.option_index) option_txt = std.fmt.allocPrint(allocator, "> {s}", .{option}) catch "";
            ui.drawText(option_txt, pos, ui.font.size, tint);
            pos.y += ui.font.size + 8;
        }
    }

    pub fn load(self: *Settings) void {
        _ = self;
    }

    pub fn update(self: *Settings, app: *App) void {
        if (self.fade_in_timer.is_active) return self.fade_in_timer.update();
        if (self.input_timer.is_active) return self.input_timer.update();
        var next_index: usize = self.option_index;
        if (app.input_handler.keyboard.getActiveKeysInclude(&[_]Key{.Enter}, .And)) {
            switch (self.option_index) {
                0 => {},
                1 => {
                    defer self.deinit();
                    self.option_index = 0;
                    self.input_timer.is_active = true;
                    if (app.intro_screen == null) app.intro_screen = IntroScreen.init();
                    if (app.intro_screen) |*p| {
                        const load_request: LoadRequest = .{ .Task = .{
                            .io = app.io,
                            .ctx = @ptrCast(p),
                            .run_on_main_thread = true,
                            .run = loadIntroScreenTask,
                        } };
                        return app.setState(app.prev_state, load_request);
                    }
                    return std.debug.panic("Failed to initialize the intro screen\n", .{});
                },
                else => return,
            }
        } else if (app.input_handler.keyboard.getActiveKeysInclude(&[_]Key{ .W, .Up }, .Or)) {
            next_index = if (next_index == 0) self.options.len - 1 else next_index - 1;
        } else if (app.input_handler.keyboard.getActiveKeysInclude(&[_]Key{ .S, .Down }, .Or)) {
            next_index = (next_index + 1) % self.options.len;
        }
        if (next_index != self.option_index) {
            self.input_timer.is_active = true;
            self.option_index = @intCast(next_index);
        }
    }
};

pub fn loadSettingsTask(ctx: *anyopaque, io: *std.Io) void {
    _ = io;
    const screen: *Settings = @ptrCast(@alignCast(ctx));
    screen.resources.load();
    screen.fade_in_timer.is_active = true;
}
