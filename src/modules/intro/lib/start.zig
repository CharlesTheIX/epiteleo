const std = @import("std");
const rl = @import("raylib");
const Intro = @import("../root.zig").Intro;
const _game = @import("../../game/root.zig");
const _ui = @import("../../../_ui/root.zig");
const App = @import("../../../root.zig").App;
const Timer = @import("../../timer/root.zig").Timer;
const _new_game = @import("../../new_game/root.zig");
const Key = @import("../../input_handler/root.zig").Key;
const _job = @import("../../../modules/loader/lib/job.zig");

pub const Start = struct {
    option_index: u2 = 0,
    fade_in_timer: Timer = .init(0.5),
    no_save_options: [2][]const u8 = .{ "New Game", "Back" },
    has_save_options: [3][]const u8 = .{ "Continue", "New Game", "Back" },

    pub fn draw(self: *Start, intro: *Intro, font: *_ui.Font, allocator: std.mem.Allocator) void {
        var alpha: f32 = 1.0;
        const spacing: f32 = 16;
        if (self.fade_in_timer.is_active) alpha = 1.0 - self.fade_in_timer.value_ms / self.fade_in_timer.initial_value_ms;
        const template = _ui.initScreenRect();
        _ui.drawRect(.{ .rect = template, .color = rl.Color.black.alpha(alpha) });
        const tint = rl.Color.white.alpha(alpha);
        var pos = rl.Vector2.init(template.x + spacing, template.y + spacing);
        if (intro.has_save_data) {
            for (self.has_save_options, 0..) |option, i| {
                var option_txt = std.fmt.allocPrint(allocator, "{s}", .{option}) catch "";
                if (i == self.option_index) option_txt = std.fmt.allocPrint(allocator, "> {s}", .{option}) catch "";
                _ui.drawText(.{ .text = option_txt, .pos = pos, .font = font.*, .color = tint });
                pos.y += font.size + @as(f32, @divFloor(spacing, 2));
            }
        } else {
            for (self.no_save_options, 0..) |option, i| {
                var option_txt = std.fmt.allocPrint(allocator, "{s}", .{option}) catch "";
                if (i == self.option_index) option_txt = std.fmt.allocPrint(allocator, "> {s}", .{option}) catch "";
                _ui.drawText(.{ .text = option_txt, .pos = pos, .font = font.*, .color = tint });
                pos.y += font.size + @as(f32, @divFloor(spacing, 2));
            }
        }
    }

    pub fn update(self: *Start, intro: *Intro, app: *App) void {
        const kb = app.ih.keyboard;
        var next_index: usize = self.option_index;
        const option_count = if (intro.has_save_data) self.has_save_options.len else self.no_save_options.len;
        if (kb.activeKeysInclude(&[_]Key{ .W, .Up }, .Or)) next_index = if (next_index == 0) option_count - 1 else next_index - 1;
        if (kb.activeKeysInclude(&[_]Key{ .S, .Down }, .Or)) next_index = (next_index + 1) % option_count;
        if (next_index != self.option_index) {
            intro.input_timer.is_active = true;
            self.option_index = @intCast(next_index);
        }
        if (kb.activeKeysInclude(&[_]Key{.Enter}, .And)) {
            intro.input_timer.is_active = true;
            if (intro.has_save_data) {
                switch (self.option_index) {
                    0 => {
                        defer intro.deinit();
                        self.option_index = 0;
                        if (app.game == null) app.game = _game.Game.init();
                        if (app.game) |*_gm| {
                            const request: _job.Request = .{ .Task = .{
                                .io = app.io,
                                .ctx = @ptrCast(_gm),
                                .run_on_main_thread = true,
                                .run = _game.loadGameTask,
                            } };
                            return app.setState(.Game, request);
                        }
                        return std.debug.panic("Failed to initialize the new game\n", .{});
                    },
                    1 => {
                        defer intro.deinit();
                        self.option_index = 0;
                        if (app.new_game == null) app.new_game = _new_game.NewGame.init(&app.ui.font);
                        if (app.new_game) |*_ng| {
                            const request: _job.Request = .{ .Task = .{
                                .io = app.io,
                                .ctx = @ptrCast(_ng),
                                .run_on_main_thread = true,
                                .run = _new_game.loadNewGameTask,
                            } };
                            return app.setState(.NewGame, request);
                        }
                        return std.debug.panic("Failed to initialize the new game\n", .{});
                    },
                    else => {
                        intro.state = .Init;
                        return;
                    },
                }
            } else {
                switch (self.option_index) {
                    0 => {
                        defer intro.deinit();
                        self.option_index = 0;
                        if (app.new_game == null) app.new_game = _new_game.NewGame.init(&app.ui.font);
                        if (app.new_game) |*_ng| {
                            const request: _job.Request = .{ .Task = .{
                                .io = app.io,
                                .ctx = @ptrCast(_ng),
                                .run_on_main_thread = true,
                                .run = _new_game.loadNewGameTask,
                            } };
                            return app.setState(.NewGame, request);
                        }
                        return std.debug.panic("Failed to initialize the new game\n", .{});
                    },
                    else => {
                        intro.state = .Init;
                        return;
                    },
                }
            }
        }
    }
};
