const std = @import("std");
const rl = @import("raylib");
const App = @import("../root.zig").App;
const Timer = @import("./timer.zig").Timer;
const ih = @import("./input_handler/root.zig");
const drawAppInfo = @import("../utils.zig").drawInfo;
const drawInputHandlerInfo = @import("./input_handler/utils.zig").drawInfo;

const Key = ih.Key;
const InputHandler = ih.InputHandler;
const Module = enum {
    __App,
    __InputHandler,
};

pub const Dev = struct {
    input_timer: Timer,
    show_module: ?Module = null,

    pub fn init() Dev {
        return Dev{ .input_timer = Timer.init(0.3) };
    }

    pub fn deinit(self: *Dev) void {
        self.show_module = null;
    }

    pub fn draw(self: Dev, app: *App, allocator: std.mem.Allocator) void {
        if (self.show_module) |module| {
            switch (module) {
                .__App => return drawAppInfo(&app.state, &app.ui),
                .__InputHandler => return drawInputHandlerInfo(
                    &app.input_handler.keyboard,
                    &app.input_handler.mouse,
                    &app.ui,
                    allocator,
                ),
            }
        }
    }

    pub fn update(self: *Dev, input_handler: *InputHandler) void {
        if (self.input_timer.is_active) return self.input_timer.update(rl.getFrameTime());
        if (!input_handler.keyboard.getActiveKeysInclude(&[_]Key{.LeftControl}, .And)) return;
        if (input_handler.keyboard.getActiveKeysInclude(&[_]Key{.A}, .And)) {
            self.input_timer.is_active = true;
            if (self.show_module == null) {
                self.show_module = .__App;
            } else self.show_module = null;
        }
        if (input_handler.keyboard.getActiveKeysInclude(&[_]Key{.D}, .And)) {
            self.input_timer.is_active = true;
            if (self.show_module == null) {
                self.show_module = .__InputHandler;
            } else self.show_module = null;
        }
    }
};
