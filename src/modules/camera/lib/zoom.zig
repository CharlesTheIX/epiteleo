const std = @import("std");
const rl = @import("raylib");
const ih = @import("../../input_handler/root.zig");

const Key = ih.Key;
const InputHandler = ih.InputHandler;
const invertScroll = @import("../../../utils.zig").invertScroll;

pub const Zoom = struct {
    min: f32 = 1.0,
    max: f32 = 10.0,
    speed: f32 = 0.1,
    target: f32 = 3.0,
    lerp_speed: f32 = 0.1,

    pub fn init() Zoom {
        return .{};
    }

    pub fn deinit(self: *Zoom) void {
        _ = self;
    }

    fn setTarget(self: *Zoom, value: f32) void {
        self.target = std.math.clamp(value, self.min, self.max);
    }

    pub fn update(self: *Zoom, camera: *rl.Camera2D, input_handler: *InputHandler) void {
        self.updateFromInput(camera, input_handler);
        self.updateFromScroll(camera, input_handler);
    }

    fn updateFromInput(self: *Zoom, camera: *rl.Camera2D, input_handler: *InputHandler) void {
        const zoom_out = input_handler.keyboard.getActiveKeysInclude(&[_]Key{.Minus}, .And);
        const zoom_in = input_handler.keyboard.getActiveKeysInclude(&[_]Key{.Equal}, .And);
        if (zoom_in) self.setTarget(self.target + self.speed);
        if (zoom_out) self.setTarget(self.target - self.speed);
        const zoom_diff = self.target - camera.zoom;
        if (@abs(zoom_diff) > 0.001) {
            camera.zoom += zoom_diff * self.lerp_speed;
        } else camera.zoom = self.target;
    }

    fn updateFromScroll(self: *Zoom, camera: *rl.Camera2D, input_handler: *InputHandler) void {
        if (input_handler.mouse.scroll.y == 0) return;
        if (input_handler.keyboard.getActiveKeysInclude(&[_]Key{ .LeftShift, .RightShift }, .Or)) {
            self.setTarget(self.target + invertScroll(&input_handler.mouse.scroll).y * self.speed);
            camera.zoom = self.target;
        }
    }
};
