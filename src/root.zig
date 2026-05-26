const std = @import("std");
const rl = @import("raylib");
const loader = @import("./modules/loader/root.zig");
const ih = @import("./modules/input_handler/root.zig");
const is = @import("./modules/screens/intro_screen/root.zig");

const Loader = loader.Loader;
const IntroScreen = is.IntroScreen;
const InputHandler = ih.InputHandler;
const LoadRequest = loader.LoadRequest;
const UI = @import("./modules/ui/root.zig").UI;
const Dev = @import("./modules/__dev/root.zig").Dev;
const AppState = @import("./lib/utils.zig").AppState;
const Camera = @import("./modules/camera/root.zig").Camera;
const Canvas = @import("./modules/canvas/root.zig").Canvas;
const Settings = @import("./modules/settings/root.zig").Settings;
const loadIntroScreenTask = is.loadIntroScreenTask;
const PlayerScreen = @import("./modules/screens/player_screen/root.zig").PlayerScreen;

pub const App = struct {
    io: *std.Io,
    ui: UI = .init(),
    __dev: ?Dev = .init(),
    shut_down: bool = false,
    state: AppState = .Init,
    camera: Camera = .init(),
    canvas: Canvas = .init(),
    loader: Loader = .init(),
    input_handler: InputHandler,
    settings: Settings = .init(),
    prev_state: AppState = .Init,
    allocator: std.mem.Allocator,
    player_screen: ?PlayerScreen = null,
    intro_screen: ?IntroScreen = .init(),

    pub fn init(allocator: std.mem.Allocator, io: *std.Io) App {
        return App{ .io = io, .allocator = allocator, .input_handler = .init(allocator) };
    }

    pub fn deinit(self: *App) void {
        self.ui.deinit();
        self.camera.deinit();
        self.loader.deinit();
        self.settings.deinit();
        self.input_handler.deinit();
        if (self.__dev) |*dev| dev.deinit();
        if (self.intro_screen) |*i| i.deinit();
        if (self.player_screen) |*p| p.deinit();
        self.allocator.destroy(self);
        self.io.close();
    }

    fn draw(self: *App) void {
        if (self.shut_down) return;
        rl.beginDrawing();
        defer rl.endDrawing();
        rl.clearBackground(rl.Color.black);
        if (self.loader.showing) return self.loader.drawLoadingScreen(&self.ui);

        switch (self.state) {
            .Init => return,
            .Intro => if (self.intro_screen) |*i| i.draw(&self.ui, self.allocator),
            .Settings => self.settings.drawSettingsScreen(&self.ui, self.allocator),
            .Playing => {
                rl.beginMode2D(self.camera.camera);
                if (self.player_screen) |*p| p.draw(&self.ui);
                rl.endMode2D();
            },
        }
        if (self.__dev) |*dev| dev.draw(self);
    }

    fn handleResize(self: *App) void {
        if (!rl.isWindowResized()) return;
        const screen_w = @as(f32, @floatFromInt(rl.getScreenWidth()));
        const screen_h = @as(f32, @floatFromInt(rl.getScreenHeight()));
        self.camera.resize(rl.Vector2.init(screen_w, screen_h).scale(0.5));
        self.canvas.rect = rl.Rectangle.init(0, 0, screen_w, screen_h);
    }

    fn load(self: *App) void {
        self.ui.load();
        self.settings.load(self.io);
        self.loader.resources.load(self.io);
        const screen_w = @as(f32, @floatFromInt(rl.getScreenWidth()));
        const screen_h = @as(f32, @floatFromInt(rl.getScreenHeight()));
        self.camera.load(rl.Vector2.init(screen_w, screen_h).scale(0.5));
        self.canvas.rect = rl.Rectangle.init(0, 0, screen_w, screen_h);
    }

    pub fn run(self: *App) void {
        var config_flags = rl.ConfigFlags{ .vsync_hint = true };
        if (self.__dev != null) config_flags.window_resizable = true;
        rl.setTargetFPS(60);
        rl.setConfigFlags(config_flags);
        rl.initWindow(960, 540, "Epiteleo");
        defer rl.closeWindow();
        self.load();
        while (!rl.windowShouldClose() and !self.shut_down) {
            self.update();
            self.draw();
        }
    }

    pub fn setState(self: *App, state: AppState, load_request: ?LoadRequest) void {
        if (self.loader.loading) return;
        if (load_request) |request| return self.loader.load(request, state) catch return;
        self.prev_state = self.state;
        self.state = state;
        switch (state) {
            // TODO: update the playing - this is here for testing - CIX
            .Playing => self.camera.state = .Free,
            else => self.camera.state = .Fixed,
        }
    }

    fn update(self: *App) void {
        if (self.shut_down) return;
        self.handleResize();
        if (self.loader.showing) return self.loader.update(self);
        self.input_handler.update();
        self.camera.update(&self.input_handler, null, &self.canvas.rect);
        self.canvas.update(&self.input_handler, &self.camera);
        if (self.__dev) |*dev| dev.update(self);
        switch (self.state) {
            .Settings => return self.settings.update(self),
            .Playing => if (self.player_screen) |*p| return p.update(),
            .Intro => if (self.intro_screen) |*i| return i.update(self),
            .Init => {
                if (self.intro_screen) |*i| {
                    const load_request: LoadRequest = .{ .Task = .{
                        .io = self.io,
                        .ctx = @ptrCast(i),
                        .run_on_main_thread = true,
                        .run = loadIntroScreenTask,
                    } };
                    return self.setState(.Intro, load_request);
                }
                return std.debug.panic("Failed to initialize the application\n", .{});
            },
        }
    }
};
