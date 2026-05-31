const std = @import("std");
const rl = @import("raylib");
const _ih = @import("../_ih/root.zig");
const App = @import("../root.zig").App;
const _job = @import("../modules/loader/lib/job.zig");
const Timer = @import("../modules/timer/root.zig").Timer;
const Camera = @import("../modules/camera/root.zig").Camera;
const Canvas = @import("../modules/canvas/root.zig").Canvas;
const SpriteType = @import("../modules/sprite/lib/utils.zig").SpriteType;
const drawAppInfo = @import("./lib/draw_app_info.zig").drawAppInfo;
const drawGameInfo = @import("./lib/draw_game_info.zig").drawGameInfo;
const drawCameraInfo = @import("./lib/draw_camera_info.zig").drawCameraInfo;
const drawCanvasInfo = @import("./lib/draw_canvas_info.zig").drawCanvasInfo;
const drawInputHandlerInfo = @import("./lib/draw_input_handler_info.zig").drawInputHandlerInfo;
const Module = enum {
    __App,
    __Game,
    __Camera,
    __Canvas,
    __Settings,
    __InputHandler,
};

pub const Dev = struct {
    input_timer: Timer,
    show_module: ?Module = null,

    pub fn init() Dev {
        return .{ .input_timer = Timer.init(0.3) };
    }

    pub fn deinit(self: *Dev) void {
        std.debug.print("__Dev : Deinitializing...\n", .{});
        self.show_module = null;
    }

    pub fn draw(self: Dev, app: *App) void {
        if (self.show_module) |module| {
            switch (module) {
                .__Settings => return, // TODO: draw settings info
                .__App => return drawAppInfo(app),
                .__Game => return drawGameInfo(app),
                .__Camera => return drawCameraInfo(app),
                .__Canvas => return drawCanvasInfo(app),
                .__InputHandler => return drawInputHandlerInfo(app),
            }
        }
    }

    pub fn update(self: *Dev, app: *App) void {
        if (self.input_timer.is_active) return self.input_timer.update();
        const kb = app.ih.keyboard;
        if (kb.activeKeysInclude(&[_]_ih.Key{ .LeftControl, .Zero }, .And)) {
            self.show_module = null;
            return;
        }

        if (kb.activeKeysInclude(&[_]_ih.Key{ .LeftControl, .One }, .And)) {
            self.input_timer.is_active = true;
            if (self.show_module == null or self.show_module != .__App) {
                self.show_module = .__App;
            } else self.show_module = null;
            return;
        }

        if (kb.activeKeysInclude(&[_]_ih.Key{ .LeftControl, .Two }, .And)) {
            self.input_timer.is_active = true;
            if (self.show_module == null or self.show_module != .__InputHandler) {
                self.show_module = .__InputHandler;
            } else self.show_module = null;
            return;
        }

        if (kb.activeKeysInclude(&[_]_ih.Key{ .LeftControl, .Three }, .And)) {
            self.input_timer.is_active = true;
            if (self.show_module == null or self.show_module != .__Camera) {
                self.show_module = .__Camera;
            } else self.show_module = null;
            return;
        }

        if (kb.activeKeysInclude(&[_]_ih.Key{ .LeftControl, .Four }, .And)) {
            self.input_timer.is_active = true;
            if (self.show_module == null or self.show_module != .__Canvas) {
                self.show_module = .__Canvas;
            } else self.show_module = null;
            return;
        }

        if (kb.activeKeysInclude(&[_]_ih.Key{ .LeftControl, .Five }, .And)) {
            self.input_timer.is_active = true;
            if (self.show_module == null or self.show_module != .__Settings) {
                self.show_module = .__Settings;
            } else self.show_module = null;
            return;
        }

        if (kb.activeKeysInclude(&[_]_ih.Key{ .LeftControl, .Six }, .And)) {
            self.input_timer.is_active = true;
            if (self.show_module == null or self.show_module != .__Game) {
                self.show_module = .__Game;
            } else self.show_module = null;
            return;
        }

        if (self.show_module) |module| {
            switch (module) {
                .__App => {
                    if (app.ih.keyboard.activeKeysInclude(&[_]_ih.Key{.Zero}, .And)) {
                        self.input_timer.is_active = true;
                        if (!app.loader.loading) {
                            app.loader.load(
                                _job.Request{ .SleepNs = std.time.ns_per_s * 5 },
                                app.state,
                            ) catch {};
                        }
                    }
                },
                .__Camera => {
                    if (app.ih.keyboard.activeKeysInclude(&[_]_ih.Key{.Zero}, .And)) {
                        self.input_timer.is_active = true;
                        switch (app.camera.state) {
                            .Free => app.camera.state = .Fixed,
                            .Follow => app.camera.state = .Free,
                            .Fixed => app.camera.state = .Follow,
                        }
                    }
                    if (app.ih.keyboard.activeKeysInclude(&[_]_ih.Key{.Nine}, .And)) {
                        self.input_timer.is_active = true;
                        if (app.camera.snap_to_canvas) {
                            app.camera.snap_to_canvas = false;
                        } else app.camera.snap_to_canvas = true;
                    }
                },
                .__Game => {
                    if (app.ih.keyboard.activeKeysInclude(&[_]_ih.Key{.Zero}, .And)) {
                        self.input_timer.is_active = true;
                        if (app.game) |*g| g.player.save(app.io);
                    }
                    if (app.ih.keyboard.activeKeysInclude(&[_]_ih.Key{.One}, .And)) {
                        if (app.game) |*game| {
                            const next_id = game.player.sprite.id.toInt() + 1;
                            if (SpriteType.fromInt(@as(u8, next_id))) |new_id| {
                                game.player.sprite.id = new_id;
                                if (game.player.texture) |*texture| {
                                    game.player.sprite.load(texture, app.io);
                                }
                            }
                        }
                    }
                },
                .__Canvas, .__InputHandler, .__Settings => return,
            }
        }
    }
};
