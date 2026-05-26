const std = @import("std");
const rl = @import("raylib");
const ih = @import("../input_handler/root.zig");
const is = @import("../screens/intro_screen/root.zig");

const Key = ih.Key;
const IntroScreen = is.IntroScreen;
const InputHandler = ih.InputHandler;
const UI = @import("../ui/root.zig").UI;
const App = @import("../../root.zig").App;
const Data = @import("./lib/data.zig").Data;
const Timer = @import("../timer/root.zig").Timer;
const Resources = @import("./lib/resources.zig").Resources;
const LoadRequest = @import("../loader/lib/utils.zig").LoadRequest;
const loadIntroScreenTask = is.loadIntroScreenTask;

pub const Settings = struct {
    data: Data = .{},
    option_index: u4 = 0,
    resources: Resources = .{},
    input_timer: Timer = .init(0.3),
    fade_in_timer: Timer = .init(0.5),
    options: [3][]const u8 = .{ "Volume", "Difficulty", "Back" },

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
        ui.drawRect(rect, rl.Color.black.alpha(alpha));
        if (self.resources.texture) |texture| rl.drawTextureV(texture, rl.Vector2.init(rect.x, rect.y), tint);
        const title = "Settings";
        ui.drawText(title, pos, ui.font.size, tint);
        pos.y += ui.font.size + ui.font.size + 8;
        for (self.options, 0..) |option, i| {
            const active = i == self.option_index;
            switch (i) {
                0 => {
                    var option_txt = std.fmt.allocPrint(allocator, "{s}: {d}", .{ option, self.data.volume }) catch "";
                    if (active) option_txt = std.fmt.allocPrint(allocator, "> {s}: {d}", .{ option, self.data.volume }) catch "";
                    ui.drawText(option_txt, pos, ui.font.size, tint);
                },
                1 => {
                    var option_txt = std.fmt.allocPrint(allocator, "{s}: {d}", .{ option, self.data.difficulty }) catch "";
                    if (active) option_txt = std.fmt.allocPrint(allocator, "> {s}: {d}", .{ option, self.data.difficulty }) catch "";
                    ui.drawText(option_txt, pos, ui.font.size, tint);
                },
                else => {
                    var option_txt = std.fmt.allocPrint(allocator, "{s}", .{option}) catch "";
                    if (active) option_txt = std.fmt.allocPrint(allocator, "> {s}", .{option}) catch "";
                    ui.drawText(option_txt, pos, ui.font.size, tint);
                },
            }
            pos.y += ui.font.size + 8;
        }
    }

    fn handleHorizontalInput(self: *Settings, app: *App) void {
        switch (self.option_index) {
            0 => {
                if (app.input_handler.keyboard.getActiveKeysInclude(&[_]Key{ .D, .Right }, .Or)) {
                    self.data.volume = (self.data.volume + 10) % 110;
                }
                if (app.input_handler.keyboard.getActiveKeysInclude(&[_]Key{ .A, .Left }, .Or)) {
                    self.data.volume = if (self.data.volume == 0) 100 else self.data.volume - 10;
                }
            },
            1 => {
                if (app.input_handler.keyboard.getActiveKeysInclude(&[_]Key{ .D, .Right }, .Or)) {
                    self.data.difficulty = (self.data.difficulty + 1) % 4;
                }
                if (app.input_handler.keyboard.getActiveKeysInclude(&[_]Key{ .A, .Left }, .Or)) {
                    self.data.difficulty = if (self.data.difficulty == 0) 3 else self.data.difficulty - 1;
                }
            },
            else => {},
        }
    }

    fn handleVerticalInput(self: *Settings, app: *App) void {
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
    }

    pub fn load(self: *Settings, io: *std.Io) void {
        self.data.load(io);
    }

    pub fn update(self: *Settings, app: *App) void {
        if (self.fade_in_timer.is_active) return self.fade_in_timer.update();
        if (self.input_timer.is_active) return self.input_timer.update();
        switch (self.option_index) {
            2 => if (app.input_handler.keyboard.getActiveKeysInclude(&[_]Key{.Enter}, .And)) return self.back(app),
            else => {
                if (app.input_handler.keyboard.getActiveKeysInclude(&[_]Key{ .A, .D, .Left, .Right }, .Or)) {
                    self.input_timer.is_active = true;
                    return self.handleHorizontalInput(app);
                }
            },
        }
        return self.handleVerticalInput(app);
    }

    fn back(self: *Settings, app: *App) void {
        defer self.deinit();
        self.option_index = 0;
        self.data.save(app.io);
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
    }
};

pub fn loadSettingsTask(ctx: *anyopaque, io: *std.Io) void {
    _ = io;
    const screen: *Settings = @ptrCast(@alignCast(ctx));
    screen.resources.load();
    screen.fade_in_timer.is_active = true;
}
