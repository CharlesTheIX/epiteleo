const std = @import("std");
const rl = @import("raylib");
const _game = @import("../game/root.zig");
const _ui = @import("../../_ui/root.zig");
const App = @import("../../root.zig").App;
const _job = @import("../loader/lib/job.zig");
const Timer = @import("../timer/root.zig").Timer;
const Resources = @import("./lib/resources.zig").Resources;

pub const NewGame = struct {
    text_box: _ui.TextBox,
    text_input: _ui.TextInput,
    resources: Resources = .{},
    fade_in_timer: Timer = .init(0.5),

    pub fn init(font: *_ui.Font) NewGame {
        const spacing: f32 = 16;
        const template = _ui.initScreenRect();
        const font_size = @as(f32, @floatFromInt(font.size));
        const box_height = (font_size * 3) + (spacing * 2);
        const text_padding = rl.Rectangle.init(8, 8, 8, 8);
        const text_box_rect = rl.Rectangle.init(0, 0, template.width - (spacing * 16), box_height);
        const text_box = _ui.TextBox.init(.{
            .rect = text_box_rect,
            .padding = text_padding,
            .content = "Welcome to Epiteleo!\nPlease enter your name to start a new game.",
        });
        const text_input_rect = rl.Rectangle.init(0, 0, template.width - (spacing * 16), font_size + (8 * 2));
        var text_input = _ui.TextInput.init(.{
            .rect = text_input_rect,
            .padding = text_padding,
        });
        text_input.focus();
        return .{ .text_input = text_input, .text_box = text_box };
    }

    pub fn deinit(self: *NewGame) void {
        self.text_box.deinit();
        self.resources.deinit();
        self.text_input.deinit();
    }

    pub fn draw(self: *NewGame, allocator: std.mem.Allocator, font: *_ui.Font) void {
        var alpha: f32 = 1.0;
        const spacing: f32 = 16;
        if (self.fade_in_timer.is_active) alpha = 1.0 - self.fade_in_timer.value_ms / self.fade_in_timer.initial_value_ms;
        const template = _ui.initScreenRect();
        _ui.drawRect(.{ .rect = template, .color = rl.Color.dark_purple.alpha(alpha) });
        // const tint = rl.Color.white.alpha(alpha);
        if (self.resources.texture != null) {}
        var box_pos = rl.Vector2.init(template.x + (spacing * 8), template.y + (spacing * 8));
        self.text_box.draw(font, &box_pos);
        var input_pos = rl.Vector2.init(template.x + (spacing * 8), box_pos.y + self.text_box.rect.height + spacing);
        self.text_input.draw(allocator, font, &input_pos);
    }

    pub fn resize(self: *NewGame) void {
        const spacing: f32 = 16;
        const template = _ui.initScreenRect();
        self.text_box.rect.width = template.width - (spacing * 16);
        self.text_input.rect.width = template.width - (spacing * 16);
    }

    pub fn update(self: *NewGame, app: *App) void {
        if (self.fade_in_timer.is_active) return self.fade_in_timer.update();
        self.text_input.update();
        if (rl.isKeyPressed(rl.KeyboardKey.enter)) {
            defer self.deinit();
            if (app.game == null) app.game = _game.Game.init();
            if (app.game) |*_gm| {
                _gm.new_game = true;
                _gm.player.data.setName(self.text_input.getText());
                const request: _job.Request = .{ .Task = .{
                    .io = app.io,
                    .ctx = @ptrCast(_gm),
                    .run_on_main_thread = true,
                    .run = _game.loadGameTask,
                } };
                return app.setState(.Game, request);
            }
            return std.debug.panic("Failed to initialize the new game\n", .{});
        }
    }
};

pub fn loadNewGameTask(ctx: *anyopaque, io: *std.Io) void {
    _ = io;
    const module: *NewGame = @ptrCast(@alignCast(ctx));
    module.resources.load();
    module.fade_in_timer.is_active = true;
}
