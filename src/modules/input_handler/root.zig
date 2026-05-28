const std = @import("std");
const rl = @import("raylib");
const m = @import("lib/mouse.zig");
const kb = @import("./lib/keyboard.zig");

pub const Key = kb.Key;
pub const Click = m.Click;
pub const Mouse = m.Mouse;
pub const Keyboard = kb.Keyboard;

pub const InputHandler = struct {
    mouse: Mouse,
    keyboard: Keyboard,

    pub fn init(allocator: std.mem.Allocator) InputHandler {
        const mouse = Mouse.init(allocator);
        const keyboard = Keyboard.init(allocator);
        return InputHandler{ .mouse = mouse, .keyboard = keyboard };
    }

    pub fn deinit(self: *InputHandler) void {
        self.mouse.deinit();
        self.keyboard.deinit();
    }

    pub fn update(self: *InputHandler) void {
        self.mouse.update();
        self.keyboard.update();
    }
};
