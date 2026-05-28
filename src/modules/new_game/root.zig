const std = @import("std");
const rl = @import("raylib");
const _ui = @import("../../_ui/root.zig");
const Timer = @import("../timer/root.zig").Timer;
const Resources = @import("./lib/resources.zig").Resources;

pub const NewGame = struct {
    text_box: _ui.TextBox,
    text_input: _ui.TextInput,
    resources: Resources = .{},
    fade_in_timer: Timer = .init(0.5),

    pub fn init(font: *_ui.Font) NewGame {
        var spacing: f32 = 8;
        const screen_w = @as(f32, @floatFromInt(rl.getScreenWidth()));
        const padding = rl.Rectangle.init(spacing, spacing, spacing, spacing);
        const input_height = padding.y + font.size + padding.height;
        const text_input_rect = rl.Rectangle.init(0, 0, screen_w, input_height);
        var text_input = _ui.TextInput.init(.{ .rect = text_input_rect, .padding = padding });
        spacing = 16;
        const box_y = text_input_rect.y + text_input_rect.height + spacing;
        const box_height = padding.y + font.size * 3 + padding.height;
        const text_box_rect = rl.Rectangle.init(screen_w / 4, box_y, screen_w / 2, box_height);
        const text_box = _ui.TextBox.init(.{
            .padding = padding,
            .rect = text_box_rect,
            .content = "Lorem\n ipsum\n dolor\n sit\n amet,\n consectetur\n adipiscing\n elit.\n Donec a diam lectus. Sed sit amet ipsum mauris. Maecenas congue ligula ac quam viverra nec consectetur ante hendrerit. Donec et mollis dolor.",
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
        if (self.fade_in_timer.is_active) alpha = 1.0 - self.fade_in_timer.value_ms / self.fade_in_timer.initial_value_ms;
        const screen_w = @as(f32, @floatFromInt(rl.getScreenWidth()));
        const screen_h = @as(f32, @floatFromInt(rl.getScreenHeight()));
        _ui.drawRect(.{ .rect = .init(0, 0, screen_w, screen_h), .color = rl.Color.green.alpha(alpha) });
        // const tint = rl.Color.white.alpha(alpha);
        if (self.resources.texture != null) {}
        self.text_box.draw(font);
        self.text_input.draw(allocator, font);
    }

    pub fn update(self: *NewGame) void {
        if (self.fade_in_timer.is_active) return self.fade_in_timer.update();
        self.text_input.update();
        if (rl.isKeyPressed(rl.KeyboardKey.enter)) {
            return std.debug.print("Start game with name: {s}\n", .{self.text_input.getText()});
        }
    }
};

pub fn loadNewGameTask(ctx: *anyopaque, io: *std.Io) void {
    _ = io;
    const module: *NewGame = @ptrCast(@alignCast(ctx));
    module.resources.load();
    module.fade_in_timer.is_active = true;
}
