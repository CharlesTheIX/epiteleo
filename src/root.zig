const std = @import("std");
const rl = @import("raylib");
const Dev = @import("./modules/__dev.zig").Dev;
const UI = @import("./modules/ui/root.zig").UI;
const AppState = @import("./lib/utils.zig").AppState;
const Camera = @import("./modules/camera/root.zig").Camera;
const Canvas = @import("./modules/canvas/root.zig").Canvas;
const InputHandler = @import("./modules/input_handler/root.zig").InputHandler;
const LoadingScreen = @import("./modules/screens/loading_screen/root.zig").LoadingScreen;

pub const App = struct {
    ui: UI,
    io: *std.Io,
    camera: Camera,
    canvas: Canvas,
    __dev: ?Dev = Dev.init(),
    state: AppState = .Intro,
    input_handler: InputHandler,
    allocator: std.mem.Allocator,
    loading_screen: LoadingScreen,

    pub fn init(allocator: std.mem.Allocator, io: *std.Io) App {
        return App{
            .io = io,
            .ui = UI.init(),
            .camera = Camera.init(),
            .canvas = Canvas.init(),
            .allocator = allocator,
            .loading_screen = LoadingScreen.init(),
            .input_handler = InputHandler.init(allocator),
        };
    }

    pub fn deinit(self: *App) void {
        self.ui.deinit();
        self.camera.deinit();
        self.input_handler.deinit();
        self.loading_screen.deinit();
        if (self.__dev) |*dev| dev.deinit();
    }

    fn draw(self: *App) void {
        rl.beginDrawing();
        defer rl.endDrawing();
        rl.clearBackground(rl.Color.black);
        if (self.loading_screen.showing) {
            self.loading_screen.draw(&self.ui);
        } else {
            switch (self.state) {
                .Intro => {
                    rl.beginMode2D(self.camera.camera);
                    self.canvas.draw(&self.ui);
                    rl.endMode2D();
                },
                else => {},
            }
        }
        if (self.__dev) |*dev| dev.draw(self, self.allocator);
    }

    fn handleResize(self: *App) void {
        if (!rl.isWindowResized()) return;
        const new_width = @as(f32, @floatFromInt(rl.getScreenWidth()));
        const new_height = @as(f32, @floatFromInt(rl.getScreenHeight()));
        if (self.canvas.rect.x == new_width and self.canvas.rect.y == new_height) return;
        const new_offset = rl.Vector2.init(new_width, new_height).scale(0.5);
        self.camera.resize(new_offset);
    }

    fn load(self: *App) void {
        self.ui.load();
        self.input_handler.load();
        self.loading_screen.resources.load(self.io);
        const screen_size = rl.Vector2.init(
            @as(f32, @floatFromInt(rl.getScreenWidth())),
            @as(f32, @floatFromInt(rl.getScreenHeight())),
        );
        self.camera.load(rl.Vector2.init(screen_size.x, screen_size.y).scale(0.5));
        self.canvas.rect = rl.Rectangle.init(0, 0, screen_size.x, screen_size.y);
        // self.loading_screen.loading = true;
    }

    pub fn run(self: *App) void {
        rl.setTargetFPS(60);
        rl.setConfigFlags(rl.ConfigFlags{ .window_resizable = true, .vsync_hint = true });
        rl.initWindow(960, 540, "Epiteleo");
        defer rl.closeWindow();
        self.load();
        while (!rl.windowShouldClose()) {
            self.update();
            self.draw();
        }
    }

    pub fn setState(self: *App, state: AppState) void {
        if (self.loading_screen.loading) return;
        switch (state) {
            else => {
                self.state = state;
                self.camera.state = .Free;
            },
        }
    }

    fn update(self: *App) void {
        self.handleResize();
        self.input_handler.update();
        if (self.loading_screen.showing) {
            self.loading_screen.update(self);
        } else {
            self.camera.update(&self.input_handler, null, &self.canvas.rect);
            switch (self.state) {
                .Intro => self.canvas.update(&self.input_handler, &self.camera),
                else => {},
            }
        }
        if (self.__dev) |*dev| dev.update(self);
    }
};
