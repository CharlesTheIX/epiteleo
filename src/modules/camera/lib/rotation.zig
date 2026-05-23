const rl = @import("raylib");
const ih = @import("../../input_handler/root.zig");
const invertScroll = @import("../../../lib/utils.zig").invertScroll;

const Key = ih.Key;
const InputHandler = ih.InputHandler;

pub const Rotation = struct {
    speed: f32 = 5.0,
    target: f32 = 0.0,
    lerp_speed: f32 = 0.1,

    pub fn init() Rotation {
        return .{};
    }
    pub fn deinit(self: *Rotation) void {
        _ = self;
    }

    pub fn update(self: *Rotation, camera: *rl.Camera2D, input_handler: *InputHandler) void {
        self.updateFromInput(camera, input_handler);
        self.updateFromScroll(input_handler);
    }

    fn updateFromInput(self: *Rotation, camera: *rl.Camera2D, input_handler: *InputHandler) void {
        const rotate_left = input_handler.keyboard.getActiveKeysInclude(&[_]Key{.RightBracket}, .And);
        const rotate_right = input_handler.keyboard.getActiveKeysInclude(&[_]Key{.LeftBracket}, .And);
        if (rotate_left) self.target -= self.speed;
        if (rotate_right) self.target += self.speed;
        const rotation_diff = self.target - camera.rotation;
        if (@abs(rotation_diff) > 0.001) {
            camera.rotation += rotation_diff * self.lerp_speed;
        } else camera.rotation = self.target;
    }

    fn updateFromScroll(self: *Rotation, input_handler: *InputHandler) void {
        if (input_handler.mouse.scroll.x == 0 and input_handler.mouse.scroll.y == 0) return;
        const has_rotation_modifier = input_handler.keyboard.getActiveKeysInclude(&[_]Key{ .LeftAlt, .RightAlt }, .Or);
        if (has_rotation_modifier) self.target += invertScroll(&input_handler.mouse.scroll).y * self.speed;
    }
};
