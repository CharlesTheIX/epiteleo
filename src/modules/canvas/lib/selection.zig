const rl = @import("raylib");
const ih = @import("../../input_handler/root.zig");

const Key = ih.Key;
const InputHandler = ih.InputHandler;
const UI = @import("../../ui/root.zig").UI;
const Camera = @import("../../camera/root.zig").Camera;
const rotateVector = @import("../../../lib/utils.zig").rotateVector;
const translateWindowVectorToCanvasVector = @import("./utils.zig").translateWindowVectorToCanvasVector;

pub const Selection = struct {
    end: ?rl.Vector2 = null,
    start: ?rl.Vector2 = null,
    rect: ?rl.Rectangle = null,

    fn reset(self: *Selection) void {
        self.end = null;
        self.rect = null;
        self.start = null;
    }

    pub fn draw(self: *Selection, ui: *UI) void {
        if (self.rect) |rect| ui.drawRect(rect, rl.Color.white.alpha(0.5));
    }

    pub fn getRect(self: *Selection, camera: *Camera) ?rl.Rectangle {
        if (self.start) |start| {
            if (self.end) |end| {
                const rect = rl.Rectangle.init(
                    @min(start.x, end.x),
                    @min(start.y, end.y),
                    @abs(end.x - start.x),
                    @abs(end.y - start.y),
                );
                const top_left = translateWindowVectorToCanvasVector(rl.Vector2{ .x = rect.x, .y = rect.y }, camera);
                const bottom_right = translateWindowVectorToCanvasVector(rl.Vector2{
                    .x = rect.x + rect.width,
                    .y = rect.y + rect.height,
                }, camera);
                return rl.Rectangle{
                    .x = @min(top_left.x, bottom_right.x),
                    .y = @min(top_left.y, bottom_right.y),
                    .width = @abs(bottom_right.x - top_left.x),
                    .height = @abs(bottom_right.y - top_left.y),
                };
            } else return null;
        } else return null;
    }

    pub fn update(self: *Selection, input_handler: *InputHandler, camera: *Camera) void {
        if (input_handler.keyboard.getActiveKeysInclude(&[_]Key{ .LeftShift, .RightShift }, .Or)) return self.reset();
        if (input_handler.mouse.active_clicks.get(.Left) != null) {
            if (self.start == null) {
                self.start = input_handler.mouse.pos;
            } else self.end = input_handler.mouse.pos;
            self.rect = self.getRect(camera);
        } else self.reset();
    }
};
