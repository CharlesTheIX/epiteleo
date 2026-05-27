const std = @import("std");
const rl = @import("raylib");
const _ui = @import("../ui/root.zig");

const UI = _ui.UI;
const TextInput = _ui.TextInput;
const Timer = @import("../timer/root.zig").Timer;
const Resources = @import("./lib/resources.zig").Resources;

pub const NewGame = struct {
    text_input: TextInput,
    resources: Resources = .{},
    input_timer: Timer = .init(0.1),
    fade_in_timer: Timer = .init(0.5),

    pub fn init(ui: *UI) NewGame {
        const screen_w = @as(f32, @floatFromInt(rl.getScreenWidth()));
        const padding = rl.Rectangle.init(8, 8, 8, 8);
        const text_input_rect = rl.Rectangle.init(
            0,
            0,
            screen_w,
            padding.y + ui.font.size + padding.height,
        );
        var text_input = ui.textInput(text_input_rect, null, padding);
        text_input.focused = true;
        return .{ .text_input = text_input };
    }

    pub fn deinit(self: *NewGame) void {
        self.resources.deinit();
        self.text_input.deinit();
    }

    pub fn draw(self: *NewGame, ui: *UI) void {
        var alpha: f32 = 1.0;
        if (self.fade_in_timer.is_active) alpha = 1.0 - self.fade_in_timer.value_ms / self.fade_in_timer.initial_value_ms;
        const screen_w = @as(f32, @floatFromInt(rl.getScreenWidth()));
        const screen_h = @as(f32, @floatFromInt(rl.getScreenHeight()));
        ui.drawRect(rl.Rectangle.init(0, 0, screen_w, screen_h), rl.Color.green.alpha(alpha));
        // const tint = rl.Color.white.alpha(alpha);
        if (self.resources.texture != null) {}
        self.text_input.draw();
    }

    pub fn update(self: *NewGame) void {
        if (self.fade_in_timer.is_active) return self.fade_in_timer.update();
        if (self.input_timer.is_active) return self.input_timer.update();
        if (rl.isKeyPressed(rl.KeyboardKey.enter)) return std.debug.print("Start game with name: {s}\n", .{self.text_input.asStr()});
        self.text_input.update();
    }
};

pub fn loadNewGameTask(ctx: *anyopaque, io: *std.Io) void {
    _ = io;
    const module: *NewGame = @ptrCast(@alignCast(ctx));
    module.resources.load();
    module.fade_in_timer.is_active = true;
}
