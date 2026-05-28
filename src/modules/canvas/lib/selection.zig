const rl = @import("raylib");
const _ui = @import("../../../_ui/root.zig");
const ih = @import("../../input_handler/root.zig");

const Key = ih.Key;
const InputHandler = ih.InputHandler;
const Camera = @import("../../camera/root.zig").Camera;

pub const Selection = struct {
    end: ?rl.Vector2 = null,
    start: ?rl.Vector2 = null,
    rect: ?rl.Rectangle = null,

    fn reset(self: *Selection) void {
        self.end = null;
        self.rect = null;
        self.start = null;
    }

    pub fn draw(self: *Selection) void {
        if (self.rect) |rect| _ui.drawRect(.{ .rect = rect, .color = rl.Color.white.alpha(0.5) });
    }

    pub fn getRect(self: *Selection, camera: *Camera) ?rl.Rectangle {
        if (self.start) |start| {
            if (self.end) |end| {
                const min_x = @min(start.x, end.x);
                const max_x = @max(start.x, end.x);
                const min_y = @min(start.y, end.y);
                const max_y = @max(start.y, end.y);
                const top_left = rl.getScreenToWorld2D(rl.Vector2{ .x = min_x, .y = min_y }, camera.camera);
                const top_right = rl.getScreenToWorld2D(rl.Vector2{ .x = max_x, .y = min_y }, camera.camera);
                const bottom_right = rl.getScreenToWorld2D(rl.Vector2{ .x = max_x, .y = max_y }, camera.camera);
                const bottom_left = rl.getScreenToWorld2D(rl.Vector2{ .x = min_x, .y = max_y }, camera.camera);
                const world_min_x = @min(@min(top_left.x, top_right.x), @min(bottom_right.x, bottom_left.x));
                const world_max_x = @max(@max(top_left.x, top_right.x), @max(bottom_right.x, bottom_left.x));
                const world_min_y = @min(@min(top_left.y, top_right.y), @min(bottom_right.y, bottom_left.y));
                const world_max_y = @max(@max(top_left.y, top_right.y), @max(bottom_right.y, bottom_left.y));
                return rl.Rectangle{
                    .x = world_min_x,
                    .y = world_min_y,
                    .width = world_max_x - world_min_x,
                    .height = world_max_y - world_min_y,
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
