const std = @import("std");
const rl = @import("raylib");
const UI = @import("./modules/ui/root.zig").UI;
const InputHandler = @import("./modules/input_handler/root.zig").InputHandler;

pub const App = struct {
    ui: UI,
    input_handler: InputHandler,

    pub fn init(allocator: std.mem.Allocator) App {
        const ui = UI.init();
        const input_handler = InputHandler.init(allocator);
        return App{ .ui = ui, .input_handler = input_handler };
    }

    pub fn deinit(self: *App) void {
        self.ui.deinit();
        self.input_handler.deinit();
    }

    fn draw(self: App) void {
        rl.beginDrawing();
        rl.clearBackground(rl.Color.white);
        const pos = rl.Vector2.init(10, 10);
        const txt = "Hello, my name is David!";
        self.ui.drawText(txt, pos, null, null);
        self.drawInfo();
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
    }

    // ********************************************************************************************
    // DEV ITEMS
    // ********************************************************************************************

    pub fn drawInfo(self: App) void {
        self.input_handler.drawInfo(self.ui);
    }
};
