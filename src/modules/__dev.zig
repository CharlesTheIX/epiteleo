const std = @import("std");
const rl = @import("raylib");
const App = @import("../root.zig").App;
const Key = @import("./input_handler/root.zig").Key;
const InputHandler = @import("./input_handler/root.zig").InputHandler;

const Module = enum {
    __App,
    __InputHandler,
};

pub const Dev = struct {
    show_module: ?Module = null,

    pub fn init() Dev {
        return Dev{};
    }

    pub fn deinit(self: *Dev) void {
        self.show_module = null;
    }

    pub fn draw(self: Dev, app: *const App, allocator: std.mem.Allocator) void {
        if (self.show_module == null) return;
        app.input_handler.__DEV_DRAW__(&app.ui, allocator);
    }

    pub fn update(self: *Dev, input_handler: *InputHandler) void {
        if (input_handler.keyboard.getActiveKeysInclude(&[_]Key{ .LeftControl, .D }, .And)) {
            if (self.show_module == null) {
                self.show_module = .__InputHandler;
            } else self.show_module = null;
        }
    }
};
