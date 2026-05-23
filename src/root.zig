const std = @import("std");
const rl = @import("raylib");
const Dev = @import("./modules/__dev.zig").Dev;
const UI = @import("./modules/ui/root.zig").UI;
const AppState = @import("./lib/utils.zig").AppState;
const Camera = @import("./modules/camera/root.zig").Camera;
const Canvas = @import("./modules/canvas/root.zig").Canvas;
const InputHandler = @import("./modules/input_handler/root.zig").InputHandler;

pub const App = struct {
    __dev: ?Dev = Dev.init(),
    ui: UI,
    camera: Camera,
    canvas: Canvas,
    state: AppState = .Intro,
    input_handler: InputHandler,
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator) App {
        return App{
            .ui = UI.init(),
            .camera = Camera.init(),
            .canvas = Canvas.init(),
            .allocator = allocator,
            .input_handler = InputHandler.init(allocator),
        };
    }

    pub fn deinit(self: *App) void {
        self.ui.deinit();
        self.camera.deinit();
        self.input_handler.deinit();
        if (self.__dev) |*dev| dev.deinit();
    }

    fn draw(self: *App) void {
        rl.beginDrawing();
        defer rl.endDrawing();
        rl.clearBackground(rl.Color.black);
        rl.beginMode2D(self.camera.camera);
        self.canvas.draw(&self.ui);
        rl.endMode2D();
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
        self.camera.load(rl.Vector2.init(
            @as(f32, @floatFromInt(rl.getScreenWidth())),
            @as(f32, @floatFromInt(rl.getScreenHeight())),
        ).scale(0.5));
        self.canvas.rect = rl.Rectangle.init(
            0,
            0,
            @as(f32, @floatFromInt(rl.getScreenWidth())) * 2,
            @as(f32, @floatFromInt(rl.getScreenHeight())) * 2,
        );
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

    fn update(self: *App) void {
        self.handleResize();
        self.input_handler.update();
        self.camera.update(&self.input_handler, null);
        self.canvas.update(&self.input_handler, &self.camera);
        if (self.__dev) |*dev| dev.update(self);
    }
};
