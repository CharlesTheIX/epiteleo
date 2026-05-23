const rl = @import("raylib");
const UI = @import("../ui/root.zig").UI;
const ih = @import("../input_handler/root.zig");
const Camera = @import("../camera/root.zig").Camera;
const Selection = @import("./lib/selection.zig").Selection;

const Key = ih.Key;
const InputHandler = ih.InputHandler;

pub const Canvas = struct {
    selection: Selection = .{},
    rect: rl.Rectangle = rl.Rectangle.init(0, 0, 0, 0),

    pub fn init() Canvas {
        return Canvas{};
    }

    pub fn deinit(self: *Canvas) void {
        _ = self;
    }

    pub fn draw(self: *Canvas, ui: *UI) void {
        ui.drawRect(self.rect, rl.Color.orange.alpha(0.5));
        ui.drawGrid(self.rect, 16, rl.Color.black.alpha(0.8));
        self.selection.draw(ui);
    }

    pub fn load(self: *Canvas, rect: rl.Rectangle) void {
        self.selection.reset();
        self.rect = rect;
    }

    pub fn update(self: *Canvas, input_handler: *InputHandler, camera: *Camera) void {
        self.selection.update(input_handler, camera);
    }
};
