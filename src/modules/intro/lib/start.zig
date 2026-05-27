const std = @import("std");
const rl = @import("raylib");
const gm = @import("../../game/root.zig");
const ng = @import("../../new_game/root.zig");

const Game = gm.Game;
const NewGame = ng.NewGame;
const UI = @import("../../ui/root.zig").UI;
const Intro = @import("../root.zig").Intro;
const App = @import("../../../root.zig").App;
const Timer = @import("../../timer/root.zig").Timer;
const Key = @import("../../input_handler/root.zig").Key;
const loadGameTask = gm.loadGameTask;
const JobRequest = @import("../../../utils.zig").JobRequest;
const loadNewGameTask = ng.loadNewGameTask;

pub const Start = struct {
    option_index: u2 = 0,
    fade_in_timer: Timer = .init(0.5),
    no_save_options: [2][]const u8 = .{ "New Game", "Back" },
    has_save_options: [3][]const u8 = .{ "Continue", "New Game", "Back" },

    pub fn draw(self: *Start, intro: *Intro, ui: *UI, allocator: std.mem.Allocator) void {
        var alpha: f32 = 1.0;
        if (self.fade_in_timer.is_active) alpha = 1.0 - self.fade_in_timer.value_ms / self.fade_in_timer.initial_value_ms;
        const template = ui.defaultRect();
        ui.drawRect(template, rl.Color.black.alpha(alpha));
        const tint = rl.Color.white.alpha(alpha);
        var pos = rl.Vector2.init(template.x + 16, template.y + 16);
        if (intro.has_save_data) {
            for (self.has_save_options, 0..) |option, i| {
                var option_txt = std.fmt.allocPrint(allocator, "{s}", .{option}) catch "";
                if (i == self.option_index) option_txt = std.fmt.allocPrint(allocator, "> {s}", .{option}) catch "";
                ui.drawText(option_txt, pos, ui.font.size, tint);
                pos.y += ui.font.size + 8;
            }
        } else {
            for (self.no_save_options, 0..) |option, i| {
                var option_txt = std.fmt.allocPrint(allocator, "{s}", .{option}) catch "";
                if (i == self.option_index) option_txt = std.fmt.allocPrint(allocator, "> {s}", .{option}) catch "";
                ui.drawText(option_txt, pos, ui.font.size, tint);
                pos.y += ui.font.size + 8;
            }
        }
    }

    pub fn update(self: *Start, intro: *Intro, app: *App) void {
        var next_index: usize = self.option_index;
        const option_count = if (intro.has_save_data) self.has_save_options.len else self.no_save_options.len;
        if (app.input_handler.keyboard.getActiveKeysInclude(&[_]Key{ .W, .Up }, .Or)) {
            next_index = if (next_index == 0) option_count - 1 else next_index - 1;
        }
        if (app.input_handler.keyboard.getActiveKeysInclude(&[_]Key{ .S, .Down }, .Or)) {
            next_index = (next_index + 1) % option_count;
        }
        if (next_index != self.option_index) {
            intro.input_timer.is_active = true;
            self.option_index = @intCast(next_index);
        }
        if (app.input_handler.keyboard.getActiveKeysInclude(&[_]Key{.Enter}, .And)) {
            intro.input_timer.is_active = true;
            if (intro.has_save_data) {
                switch (self.option_index) {
                    0 => {
                        defer intro.deinit();
                        self.option_index = 0;
                        if (app.game == null) app.game = Game.init();
                        if (app.game) |*_gm| {
                            const job_request: JobRequest = .{ .Task = .{
                                .io = app.io,
                                .ctx = @ptrCast(_gm),
                                .run_on_main_thread = true,
                                .run = loadGameTask,
                            } };
                            return app.setState(.Game, job_request);
                        }
                        return std.debug.panic("Failed to initialize the new game\n", .{});
                    },
                    1 => {
                        defer intro.deinit();
                        self.option_index = 0;
                        if (app.new_game == null) app.new_game = NewGame.init(&app.ui);
                        if (app.new_game) |*_ng| {
                            const job_request: JobRequest = .{ .Task = .{
                                .io = app.io,
                                .ctx = @ptrCast(_ng),
                                .run_on_main_thread = true,
                                .run = loadNewGameTask,
                            } };
                            return app.setState(.NewGame, job_request);
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
                        if (app.new_game == null) app.new_game = NewGame.init(&app.ui);
                        if (app.new_game) |*_ng| {
                            const job_request: JobRequest = .{ .Task = .{
                                .io = app.io,
                                .ctx = @ptrCast(_ng),
                                .run_on_main_thread = true,
                                .run = loadNewGameTask,
                            } };
                            return app.setState(.NewGame, job_request);
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
