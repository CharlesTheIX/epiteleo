const std = @import("std");
const rl = @import("raylib");
const _ui = @import("../../../_ui/root.zig");

const Intro = @import("../root.zig").Intro;
const App = @import("../../../root.zig").App;
const Timer = @import("../../timer/root.zig").Timer;
const Key = @import("../../input_handler/root.zig").Key;
const JobRequest = @import("../../../utils.zig").JobRequest;
const loadSettingsTask = @import("../../settings/root.zig").loadSettingsTask;

pub const Init = struct {
    option_index: u2 = 0,
    fade_in_timer: Timer = .init(0.5),
    options: [3][]const u8 = .{ "Stat Game", "Settings", "Exit" },

    pub fn draw(self: *Init, font: *_ui.Font, allocator: std.mem.Allocator) void {
        var alpha: f32 = 1.0;
        const spacing: f32 = 16;
        if (self.fade_in_timer.is_active) alpha = 1.0 - self.fade_in_timer.value_ms / self.fade_in_timer.initial_value_ms;
        const template = _ui.initScreenRect();
        _ui.drawRect(.{ .rect = template, .color = rl.Color.black.alpha(alpha) });
        const tint = rl.Color.white.alpha(alpha);
        var pos = rl.Vector2.init(template.x + spacing, template.y + spacing);
        for (self.options, 0..) |option, i| {
            var option_txt = std.fmt.allocPrint(allocator, "{s}", .{option}) catch "";
            if (i == self.option_index) option_txt = std.fmt.allocPrint(allocator, "> {s}", .{option}) catch "";
            _ui.drawText(.{ .text = option_txt, .pos = pos, .font = font.*, .color = tint });
            pos.y += font.size + @as(f32, @divFloor(spacing, 2));
        }
    }

    pub fn update(self: *Init, intro: *Intro, app: *App) void {
        var next_index: usize = self.option_index;
        if (app.input_handler.keyboard.getActiveKeysInclude(&[_]Key{ .W, .Up }, .Or)) {
            next_index = if (next_index == 0) self.options.len - 1 else next_index - 1;
        }
        if (app.input_handler.keyboard.getActiveKeysInclude(&[_]Key{ .S, .Down }, .Or)) {
            next_index = (next_index + 1) % self.options.len;
        }
        if (next_index != self.option_index) {
            intro.input_timer.is_active = true;
            self.option_index = @intCast(next_index);
        }
        if (app.input_handler.keyboard.getActiveKeysInclude(&[_]Key{.Enter}, .And)) {
            intro.input_timer.is_active = true;
            switch (self.option_index) {
                0 => {
                    intro.state = .Start;
                    self.option_index = 0;
                    intro._start.option_index = 0;
                    return;
                },
                1 => {
                    defer app.intro = null;
                    defer intro.deinit();
                    intro.input_timer.is_active = true;
                    const job_request: JobRequest = .{ .Task = .{
                        .io = app.io,
                        .run_on_main_thread = true,
                        .ctx = @ptrCast(&app.settings),
                        .run = loadSettingsTask,
                    } };
                    return app.setState(.Settings, job_request);
                },
                2 => {
                    app.shut_down = true;
                    return;
                },
                else => return,
            }
        }
    }
};
