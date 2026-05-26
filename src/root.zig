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
    shut_down: bool = false,
    state: AppState = .Init,
    camera: Camera = .init(),
    canvas: Canvas = .init(),
    loader: Loader = .init(),
    __dev: ?Dev = Dev.init(),
    input_handler: InputHandler,
    allocator: std.mem.Allocator,
    prev_state: AppState = .Init,
    player_screen: ?PlayerScreen = null,
    settings: Settings = Settings.init(),
    intro_screen: ?IntroScreen = IntroScreen.init(),

    pub fn init(allocator: std.mem.Allocator, io: *std.Io) App {
        return App{
            .io = io,
            .allocator = allocator,
            .input_handler = .init(allocator),
        };
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
        const new_width = @as(f32, @floatFromInt(rl.getScreenWidth()));
        const new_height = @as(f32, @floatFromInt(rl.getScreenHeight()));
        if (self.canvas.rect.x == new_width and self.canvas.rect.y == new_height) return;
        const new_offset = rl.Vector2.init(new_width, new_height).scale(0.5);
        self.camera.resize(new_offset);
        self.canvas.rect = rl.Rectangle.init(0, 0, new_width, new_height);
    }

    fn load(self: *App) void {
        self.ui.load();
        self.settings.load();
        self.input_handler.load();
        self.loader.resources.load(self.io);
        const screen_size = rl.Vector2.init(
            @as(f32, @floatFromInt(rl.getScreenWidth())),
            @as(f32, @floatFromInt(rl.getScreenHeight())),
        );
        self.camera.load(rl.Vector2.init(screen_size.x, screen_size.y).scale(0.5));
        self.canvas.rect = rl.Rectangle.init(0, 0, screen_size.x, screen_size.y);
    }

    pub fn run(self: *App) void {
        rl.setTargetFPS(60);
        var config_flags = rl.ConfigFlags{ .vsync_hint = true };
        if (self.__dev != null) config_flags.window_resizable = true;
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
            .Intro => self.camera.state = .Fixed,
            .Settings => self.camera.state = .Fixed,
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
            .Playing => if (self.player_screen) |*p| return p.update(),
            .Intro => if (self.intro_screen) |*i| return i.update(self),
            .Settings => return self.settings.update(self),
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
