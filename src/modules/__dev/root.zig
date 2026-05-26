const std = @import("std");
const rl = @import("raylib");

const Key = ih.Key;
const InputHandler = ih.InputHandler;
const App = @import("../../root.zig").App;
const ih = @import("../input_handler/root.zig");
const Timer = @import("../timer/root.zig").Timer;
const Camera = @import("../camera/root.zig").Camera;
const Canvas = @import("../canvas/root.zig").Canvas;
const LoadRequest = @import("../loader/lib/utils.zig").LoadRequest;
const drawAppInfo = @import("./lib/draw_app_info.zig").drawAppInfo;
const drawCameraInfo = @import("./lib/draw_camera_info.zig").drawCameraInfo;
const drawCanvasInfo = @import("./lib/draw_canvas_info.zig").drawCanvasInfo;
const drawInputHandlerInfo = @import("./lib/draw_input_handler_info.zig").drawInputHandlerInfo;
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

    pub fn draw(self: Dev, app: *App) void {
        if (self.show_module) |module| {
            switch (module) {
                .__App => return drawAppInfo(app),
                .__Camera => return drawCameraInfo(app),
                .__Canvas => return drawCanvasInfo(app),
                .__InputHandler => return drawInputHandlerInfo(app),
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
                        if (!app.loader.loading) {
                            app.loader.load(
                                LoadRequest{ .SleepNs = std.time.ns_per_s * 5 },
                                app.state,
                            ) catch {};
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
