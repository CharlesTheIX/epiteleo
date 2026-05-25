const rl = @import("raylib");
const ih = @import("../../input_handler/root.zig");
const invertScroll = @import("../../../lib/utils.zig").invertScroll;
const rotateVector = @import("../../../lib/utils.zig").rotateVector;

const Key = ih.Key;
const Click = ih.Click;
const InputHandler = ih.InputHandler;

pub const Movement = struct {
    lerp_speed: f32 = 0.1,
    movement_speed: f32 = 32.0,
    target_position: rl.Vector2,
    mouse_pan_start: rl.Vector2,
    mouse_pan_target: rl.Vector2,
    mouse_pan_active: bool = false,

    pub fn init(v: rl.Vector2) Movement {
        return .{ .target_position = v, .mouse_pan_start = v, .mouse_pan_target = v };
    }

    pub fn deinit(self: *Movement) void {
        _ = self;
    }

    pub fn update(self: *Movement, camera: *rl.Camera2D, input_handler: *InputHandler) void {
        self.updateFromScroll(camera, input_handler);
        self.updateFromClick(camera, input_handler);
        if (!self.mouse_pan_active) self.updateFromInput(camera, input_handler);
    }

    fn updateFromClick(self: *Movement, camera: *rl.Camera2D, input_handler: *InputHandler) void {
        if (input_handler.mouse.getActiveClicksInclude(&[_]Click{.Left}, .And)) {
            if (!input_handler.keyboard.getActiveKeysInclude(&[_]Key{ .LeftShift, .RightShift }, .Or)) return;
            const mouse_pos = input_handler.mouse.pos;
            if (!self.mouse_pan_active) {
                self.mouse_pan_active = true;
                self.mouse_pan_start = mouse_pos;
                self.mouse_pan_target = camera.target;
            } else {
                var delta = mouse_pos.subtract(self.mouse_pan_start);
                delta = rotateVector(delta, -camera.rotation);
                self.target_position = self.mouse_pan_target.subtract(delta.scale(1.0 / camera.zoom));
            }
        } else self.mouse_pan_active = false;

        const diff = self.target_position.subtract(camera.target);
        camera.target = camera.target.add(diff.scale(self.lerp_speed));
    }

    fn updateFromInput(self: *Movement, camera: *rl.Camera2D, input_handler: *InputHandler) void {
        var movement = rl.Vector2.zero();
        var speed = self.movement_speed;
        if (input_handler.keyboard.getActiveKeysInclude(&[_]Key{ .LeftShift, .RightShift }, .Or)) speed *= 4;
        if (input_handler.keyboard.getActiveKeysInclude(&[_]Key{.W}, .And)) movement.y -= 1;
        if (input_handler.keyboard.getActiveKeysInclude(&[_]Key{.S}, .And)) movement.y += 1;
        if (input_handler.keyboard.getActiveKeysInclude(&[_]Key{.A}, .And)) movement.x -= 1;
        if (input_handler.keyboard.getActiveKeysInclude(&[_]Key{.D}, .And)) movement.x += 1;
        if (movement.x == 0 and movement.y == 0) return;
        movement = rotateVector(movement, -camera.rotation);
        movement = movement.scale(speed * self.lerp_speed / camera.zoom);
        self.target_position = self.target_position.add(movement);
    }

    fn updateFromScroll(self: *Movement, camera: *rl.Camera2D, input_handler: *InputHandler) void {
        if (input_handler.keyboard.getActiveKeysInclude(&[_]Key{ .LeftShift, .RightShift }, .Or)) return;
        var movement = input_handler.mouse.scroll.scale(self.movement_speed * self.lerp_speed / camera.zoom);
        movement = rotateVector(movement, -camera.rotation);
        movement = invertScroll(&input_handler.mouse.scroll);
        self.target_position = self.target_position.add(movement);
    }
};
