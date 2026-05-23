const std = @import("std");
const UI = @import("../ui/root.zig").UI;
const Mouse = @import("lib/mouse.zig").Mouse;
const Keyboard = @import("lib/keyboard.zig").Keyboard;

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
        _ = self; // Avoid unused parameter warning
    }

    pub fn update(self: *InputHandler) void {
        self.mouse.update();
        self.keyboard.update();
    }

    // ********************************************************************************************
    // DEV ITEMS
    // ********************************************************************************************

    pub fn drawInfo(self: InputHandler, ui: UI) void {
        _ = self; // Avoid unused parameter warning
        _ = ui; // Avoid unused parameter warning
    }
};
