const std = @import("std");
const rl = @import("raylib");
const d = @import("./lib/data.zig");
const is = @import("../intro/root.zig");
const ih = @import("../input_handler/root.zig");

const Key = ih.Key;
const Data = d.Data;
const Intro = is.Intro;
const InputHandler = ih.InputHandler;
const UI = @import("../ui/root.zig").UI;
const App = @import("../../root.zig").App;
const Timer = @import("../timer/root.zig").Timer;
const JobRequest = @import("../../utils.zig").JobRequest;
const Resources = @import("./lib/resources.zig").Resources;
const loadIntroTask = is.loadIntroTask;
const saveDataOnThread = d.saveDataOnThread;

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

    fn back(self: *Settings, app: *App) void {
        defer self.deinit();
        self.option_index = 0;
        self.data.save(app.io);
        if (app.intro == null) app.intro = Intro.init();
        if (app.intro) |*p| {
            const job_request: JobRequest = .{ .Task = .{
                .io = app.io,
                .ctx = @ptrCast(p),
                .run_on_main_thread = true,
                .run = loadIntroTask,
            } };
            return app.setState(app.prev_state, job_request);
        }
        return std.debug.panic("Failed to initialize the intro\n", .{});
    }

    pub fn drawSettingsScreen(self: *Settings, ui: *UI) void {
        var alpha: f32 = 1.0;
        if (self.fade_in_timer.is_active) alpha = 1.0 - self.fade_in_timer.value_ms / self.fade_in_timer.initial_value_ms;
        const tint = rl.Color.white.alpha(alpha);
        const rect = ui.defaultRect();
        var pos = rl.Vector2.init(rect.x + 16, rect.y + 16);
        ui.drawRect(rect, rl.Color.black.alpha(alpha));
        // if (self.resources.texture) |texture| rl.drawTextureV(texture, rl.Vector2.init(rect.x, rect.y), tint);
        for (self.options, 0..) |option, i| {
            var option_buf: [128]u8 = undefined;
            const active = i == self.option_index;
            switch (i) {
                0 => {
                    const option_txt = if (active)
                        std.fmt.bufPrint(&option_buf, "> {s}: {d}", .{ option, self.data.volume }) catch continue
                    else
                        std.fmt.bufPrint(&option_buf, "{s}: {d}", .{ option, self.data.volume }) catch continue;
                    ui.drawText(option_txt, pos, ui.font.size, tint);
                },
                1 => {
                    const option_txt = if (active)
                        std.fmt.bufPrint(&option_buf, "> {s}: {d}", .{ option, self.data.difficulty }) catch continue
                    else
                        std.fmt.bufPrint(&option_buf, "{s}: {d}", .{ option, self.data.difficulty }) catch continue;
                    ui.drawText(option_txt, pos, ui.font.size, tint);
                },
                else => {
                    const option_txt = if (active)
                        std.fmt.bufPrint(&option_buf, "> {s}", .{option}) catch continue
                    else
                        std.fmt.bufPrint(&option_buf, "{s}", .{option}) catch continue;
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
};

pub fn loadSettingsTask(ctx: *anyopaque, io: *std.Io) void {
    _ = io;
    const module: *Settings = @ptrCast(@alignCast(ctx));
    module.resources.load();
    module.fade_in_timer.is_active = true;
}
