const std = @import("std");
const rl = @import("raylib");
const UI = @import("../ui/root.zig").UI;
pub const Key = @import("lib/keyboard.zig").Key;
pub const Click = @import("lib/mouse.zig").Click;
pub const Mouse = @import("lib/mouse.zig").Mouse;
pub const Keyboard = @import("lib/keyboard.zig").Keyboard;

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

    pub fn load(self: *InputHandler) void {
        _ = self;
    }

    pub fn update(self: *InputHandler) void {
        self.mouse.update();
        self.keyboard.update();
    }
};
