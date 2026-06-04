const std = @import("std");
const rl = @import("raylib");
const _data = @import("./lib/data.zig");
const _ah = @import("../../_ah/root.zig");
const _ih = @import("../../_ih/root.zig");
const _ui = @import("../../_ui/root.zig");
const App = @import("../../root.zig").App;
const _intro = @import("../intro/root.zig");
const _job = @import("../loader/lib/job.zig");
const Timer = @import("../timer/root.zig").Timer;
const Resources = @import("./lib/resources.zig").Resources;

const loadData = _data.load;
const saveData = _data.save;

pub const Settings = struct {
    volume: u8 = 50,
    difficulty: u8 = 1,
    option_index: u4 = 0,
    resources: Resources = .{},
    input_timer: Timer = .init(0.3),
    fade_in_timer: Timer = .init(0.5),
    path: *const [16:0]u8 = ".data/settings.z",
    options: [3][]const u8 = .{ "Volume", "Difficulty", "Back" },

    pub fn init() Settings {
        std.debug.print("Settings : Initializing...\n", .{});
        return .{};
    }

    pub fn deinit(self: *Settings) void {
        std.debug.print("Settings : Deinitializing...\n", .{});
        self.resources.deinit();
    }

    fn back(self: *Settings, app: *App) void {
        app.ah.playAudio(.Sfx, "test");
        defer self.deinit();
        self.option_index = 0;
        saveData(self, app.io);
        if (app.intro == null) app.intro = _intro.Intro.init();
        if (app.intro) |*p| {
            const request: _job.Request = .{ .Task = .{
                .io = app.io,
                .ah = &app.ah,
                .ctx = @ptrCast(p),
                .run_on_main_thread = true,
                .run = _intro.loadIntroTask,
            } };
            return app.setState(app.prev_state, request);
        }
        return std.debug.panic("Failed to initialize the intro\n", .{});
    }

    pub fn drawSettingsScreen(self: *Settings, font: *_ui.Font) void {
        var alpha: f32 = 1.0;
        const spacing: f32 = 16;
        if (self.fade_in_timer.is_active) alpha = 1.0 - self.fade_in_timer.value_ms / self.fade_in_timer.initial_value_ms;
        const tint = rl.Color.white.alpha(alpha);
        const rect = _ui.initScreenRect();
        var pos = rl.Vector2.init(rect.x + spacing, rect.y + spacing);
        _ui.drawRect(.{ .rect = rect, .color = rl.Color.black.alpha(alpha) });
        // if (self.resources.texture) |texture| rl.drawTextureV(texture, rl.Vector2.init(rect.x, rect.y), tint);
        for (self.options, 0..) |option, i| {
            var option_buf: [128]u8 = undefined;
            const active = i == self.option_index;
            switch (i) {
                0 => {
                    const option_txt = if (active)
                        std.fmt.bufPrint(&option_buf, "> {s}: {d}", .{ option, self.volume }) catch continue
                    else
                        std.fmt.bufPrint(&option_buf, "{s}: {d}", .{ option, self.volume }) catch continue;
                    _ui.drawText(.{ .text = option_txt, .pos = pos, .font = font.*, .color = tint });
                },
                1 => {
                    const option_txt = if (active)
                        std.fmt.bufPrint(&option_buf, "> {s}: {d}", .{ option, self.difficulty }) catch continue
                    else
                        std.fmt.bufPrint(&option_buf, "{s}: {d}", .{ option, self.difficulty }) catch continue;
                    _ui.drawText(.{ .text = option_txt, .pos = pos, .font = font.*, .color = tint });
                },
                else => {
                    const option_txt = if (active)
                        std.fmt.bufPrint(&option_buf, "> {s}", .{option}) catch continue
                    else
                        std.fmt.bufPrint(&option_buf, "{s}", .{option}) catch continue;
                    _ui.drawText(.{ .text = option_txt, .pos = pos, .font = font.*, .color = tint });
                },
            }
            pos.y += font.size + @as(f32, @divFloor(spacing, 2));
        }
    }

    fn handleHorizontalInput(self: *Settings, app: *App) void {
        app.ah.playAudio(.Sfx, "test");
        const kb = app.ih.keyboard;
        switch (self.option_index) {
            0 => {
                if (kb.activeKeysInclude(&[_]_ih.Key{ .D, .Right }, .Or)) self.volume = (self.volume + 10) % 110;
                if (kb.activeKeysInclude(&[_]_ih.Key{ .A, .Left }, .Or)) {
                    self.volume = if (self.volume == 0) 100 else self.volume - 10;
                }
                app.ah.setMasterVolume(self.volume);
            },
            1 => {
                if (kb.activeKeysInclude(&[_]_ih.Key{ .D, .Right }, .Or)) self.difficulty = (self.difficulty + 1) % 4;
                if (kb.activeKeysInclude(&[_]_ih.Key{ .A, .Left }, .Or)) {
                    self.difficulty = if (self.difficulty == 0) 3 else self.difficulty - 1;
                }
            },
            else => {},
        }
    }

    fn handleVerticalInput(self: *Settings, app: *App) void {
        app.ah.playAudio(.Sfx, "test");
        const kb = app.ih.keyboard;
        var next_index: usize = self.option_index;
        if (kb.activeKeysInclude(&[_]_ih.Key{ .W, .Up }, .Or)) {
            next_index = if (next_index == 0) self.options.len - 1 else next_index - 1;
        }
        if (kb.activeKeysInclude(&[_]_ih.Key{ .S, .Down }, .Or)) next_index = (next_index + 1) % self.options.len;
        if (next_index != self.option_index) {
            self.input_timer.is_active = true;
            self.option_index = @intCast(next_index);
        }
    }

    pub fn load(self: *Settings, io: *std.Io) void {
        std.debug.print("Settings : Loading...\n", .{});
        loadData(self, io);
    }

    pub fn update(self: *Settings, app: *App) void {
        if (self.fade_in_timer.is_active) return self.fade_in_timer.update();
        if (self.input_timer.is_active) return self.input_timer.update();
        const kb = app.ih.keyboard;
        switch (self.option_index) {
            2 => if (kb.activeKeysInclude(&[_]_ih.Key{.Enter}, .And)) return self.back(app),
            else => {
                if (kb.activeKeysInclude(&[_]_ih.Key{ .A, .D, .Left, .Right }, .Or)) {
                    self.input_timer.is_active = true;
                    return self.handleHorizontalInput(app);
                }
            },
        }
        return self.handleVerticalInput(app);
    }
};

pub fn loadSettingsTask(ctx: *anyopaque, io: *std.Io, ah: *_ah.AudioHandler) void {
    _ = ah;
    _ = io;
    const module: *Settings = @ptrCast(@alignCast(ctx));
    module.resources.load();
    module.fade_in_timer.is_active = true;
}
