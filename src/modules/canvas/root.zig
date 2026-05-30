const rl = @import("raylib");
const _ui = @import("../../_ui/root.zig");
const _ih = @import("../input_handler/root.zig");
const Camera = @import("../camera/root.zig").Camera;
const Selection = @import("./lib/selection.zig").Selection;

pub const Canvas = struct {
    selection: Selection = .{},
    rect: rl.Rectangle = rl.Rectangle.init(0, 0, 0, 0),

    pub fn init() Canvas {
        return Canvas{};
    }

    pub fn deinit(self: *Canvas) void {
        _ = self;
    }

    pub fn draw(self: *Canvas) void {
        _ui.drawRect(.{ .rect = self.rect, .color = rl.Color.orange.alpha(0.5) });
        _ui.drawGrid(.{ .rect = self.rect, .gap = 8, .color = rl.Color.gray.alpha(0.5) });
        self.selection.draw();
    }

    pub fn load(self: *Canvas, rect: rl.Rectangle) void {
        self.selection.reset();
        self.rect = rect;
    }

    pub fn update(self: *Canvas, ih: *_ih.InputHandler, camera: *Camera) void {
        self.selection.update(ih, camera);
    }
};
