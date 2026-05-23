const std = @import("std");
const rl = @import("raylib");
const Dev = @import("./modules/__dev.zig").Dev;
const UI = @import("./modules/ui/root.zig").UI;
const AppState = @import("./utils.zig").AppState;
const InputHandler = @import("./modules/input_handler/root.zig").InputHandler;

pub const App = struct {
    __dev: ?Dev = Dev.init(),
    ui: UI,
    state: AppState = .Intro,
    input_handler: InputHandler,
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator) App {
        const ui = UI.init();
        const input_handler = InputHandler.init(allocator);
        return App{ .ui = ui, .input_handler = input_handler, .allocator = allocator };
    }

    pub fn deinit(self: *App) void {
        self.ui.deinit();
        self.input_handler.deinit();
        if (self.__dev) |*dev| dev.deinit();
    }

    fn draw(self: *App) void {
        rl.beginDrawing();
        rl.clearBackground(rl.Color.white);
        if (self.__dev) |*dev| dev.draw(&self, self.allocator);
        rl.endDrawing();
    }

    fn handleResize(self: App) void {
        if (rl.isWindowResized()) return;
        const new_width = @as(f32, @floatFromInt(rl.getScreenWidth()));
        const new_height = @as(f32, @floatFromInt(rl.getScreenHeight()));
        _ = new_width; // Avoid unused variable warning
        _ = new_height; // Avoid unused variable warning
        _ = self; // Avoid unused parameter warning
        // if (self.canvas.rect.x == new_width and self.canvas.rect.y == new_height) return;
        // const new_offset = rl.Vector2.init(new_width, new_height).scale(0.5);
        // const new_rect = rl.Rectangle.init(0, 0, new_width, new_height);
        // self.canvas.resize(new_rect);
        // self.camera.resize(new_offset);
    }

    fn load(self: *App) void {
        self.ui.load();
        self.input_handler.load();
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
        if (self.__dev) |*dev| dev.update(&self.input_handler);
    }
};
