const std = @import("std");
const rl = @import("raylib");
const App = @import("../root.zig").App;
const Timer = @import("./timer.zig").Timer;
const ih = @import("./input_handler/root.zig");
const Camera = @import("./camera/root.zig").Camera;
const Canvas = @import("./canvas/root.zig").Canvas;
const LoadRequest = @import("./screens/loading_screen/utils.zig").LoadRequest;
const drawAppInfo = @import("../lib/utils.zig").drawInfo;
const drawCameraInfo = @import("./camera/lib/utils.zig").drawInfo;
const drawCanvasInfo = @import("./canvas/lib/utils.zig").drawInfo;
const drawInputHandlerInfo = @import("./input_handler/lib/utils.zig").drawInfo;

const Key = ih.Key;
const InputHandler = ih.InputHandler;
const Module = enum {
    __App,
    __Camera,
    __Canvas,
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
                .__App => return drawAppInfo(app, allocator),
                .__Camera => return drawCameraInfo(&app.camera, &app.ui, allocator),
                .__InputHandler => return drawInputHandlerInfo(&app.input_handler, &app.ui, allocator),
                .__Canvas => return drawCanvasInfo(
                    &app.canvas,
                    &app.ui,
                    allocator,
                    &app.input_handler,
                    &app.camera,
                ),
            }
        }
    }

    pub fn update(self: *Dev, app: *App) void {
        if (self.input_timer.is_active) return self.input_timer.update();
        if (app.input_handler.keyboard.getActiveKeysInclude(&[_]Key{ .LeftControl, .Zero }, .And)) {
            self.show_module = null;
            return;
        }

        if (app.input_handler.keyboard.getActiveKeysInclude(&[_]Key{ .LeftControl, .One }, .And)) {
            self.input_timer.is_active = true;
            if (self.show_module == null or self.show_module != .__App) {
                self.show_module = .__App;
            } else self.show_module = null;
            return;
        }

        if (app.input_handler.keyboard.getActiveKeysInclude(&[_]Key{ .LeftControl, .Two }, .And)) {
            self.input_timer.is_active = true;
            if (self.show_module == null or self.show_module != .__InputHandler) {
                self.show_module = .__InputHandler;
            } else self.show_module = null;
            return;
        }

        if (app.input_handler.keyboard.getActiveKeysInclude(&[_]Key{ .LeftControl, .Three }, .And)) {
            self.input_timer.is_active = true;
            if (self.show_module == null or self.show_module != .__Camera) {
                self.show_module = .__Camera;
            } else self.show_module = null;
            return;
        }

        if (app.input_handler.keyboard.getActiveKeysInclude(&[_]Key{ .LeftControl, .Four }, .And)) {
            self.input_timer.is_active = true;
            if (self.show_module == null or self.show_module != .__Canvas) {
                self.show_module = .__Canvas;
            } else self.show_module = null;
            return;
        }

        if (self.show_module) |module| {
            switch (module) {
                .__App => {
                    if (app.input_handler.keyboard.getActiveKeysInclude(&[_]Key{.Zero}, .And)) {
                        self.input_timer.is_active = true;
                        if (!app.loading_screen.loading) {
                            app.loading_screen.load(LoadRequest{ .SleepNs = std.time.ns_per_s * 5 }, .Intro) catch {};
                        }
                    }
                },
                .__Camera => {
                    if (app.input_handler.keyboard.getActiveKeysInclude(&[_]Key{.Zero}, .And)) {
                        self.input_timer.is_active = true;
                        switch (app.camera.state) {
                            .Free => app.camera.state = .Fixed,
                            .Follow => app.camera.state = .Free,
                            .Fixed => app.camera.state = .Follow,
                        }
                    }
                    if (app.input_handler.keyboard.getActiveKeysInclude(&[_]Key{.Nine}, .And)) {
                        self.input_timer.is_active = true;
                        if (app.camera.snap_to_canvas) {
                            app.camera.snap_to_canvas = false;
                        } else app.camera.snap_to_canvas = true;
                    }
                },
                .__Canvas, .__InputHandler => return,
            }
        }
    }
};
