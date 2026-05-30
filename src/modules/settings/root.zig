const std = @import("std");
const rl = @import("raylib");
const _data = @import("./lib/data.zig");
const _ui = @import("../../_ui/root.zig");
const App = @import("../../root.zig").App;
const _intro = @import("../intro/root.zig");
const _job = @import("../loader/lib/job.zig");
const _ih = @import("../input_handler/root.zig");
const Timer = @import("../timer/root.zig").Timer;
const Resources = @import("./lib/resources.zig").Resources;

pub const Settings = struct {
    option_index: u4 = 0,
    data: _data.Data = .{},
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
        if (app.intro == null) app.intro = _intro.Intro.init();
        if (app.intro) |*p| {
            const request: _job.Request = .{ .Task = .{
                .io = app.io,
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
                        std.fmt.bufPrint(&option_buf, "> {s}: {d}", .{ option, self.data.volume }) catch continue
                    else
                        std.fmt.bufPrint(&option_buf, "{s}: {d}", .{ option, self.data.volume }) catch continue;
                    _ui.drawText(.{ .text = option_txt, .pos = pos, .font = font.*, .color = tint });
                },
                1 => {
                    const option_txt = if (active)
                        std.fmt.bufPrint(&option_buf, "> {s}: {d}", .{ option, self.data.difficulty }) catch continue
                    else
                        std.fmt.bufPrint(&option_buf, "{s}: {d}", .{ option, self.data.difficulty }) catch continue;
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
        const kb = app.ih.keyboard;
        switch (self.option_index) {
            0 => {
                if (kb.activeKeysInclude(&[_]_ih.Key{ .D, .Right }, .Or)) self.data.volume = (self.data.volume + 10) % 110;
                if (kb.activeKeysInclude(&[_]_ih.Key{ .A, .Left }, .Or)) {
                    self.data.volume = if (self.data.volume == 0) 100 else self.data.volume - 10;
                }
            },
            1 => {
                if (kb.activeKeysInclude(&[_]_ih.Key{ .D, .Right }, .Or)) self.data.difficulty = (self.data.difficulty + 1) % 4;
                if (kb.activeKeysInclude(&[_]_ih.Key{ .A, .Left }, .Or)) {
                    self.data.difficulty = if (self.data.difficulty == 0) 3 else self.data.difficulty - 1;
                }
            },
            else => {},
        }
    }

    fn handleVerticalInput(self: *Settings, app: *App) void {
        var next_index: usize = self.option_index;
        const kb = app.ih.keyboard;
        if (kb.activeKeysInclude(&[_]_ih.Key{ .W, .Up }, .Or)) next_index = if (next_index == 0) self.options.len - 1 else next_index - 1;
        if (kb.activeKeysInclude(&[_]_ih.Key{ .S, .Down }, .Or)) next_index = (next_index + 1) % self.options.len;
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

pub fn loadSettingsTask(ctx: *anyopaque, io: *std.Io) void {
    _ = io;
    const module: *Settings = @ptrCast(@alignCast(ctx));
    module.resources.load();
    module.fade_in_timer.is_active = true;
}
