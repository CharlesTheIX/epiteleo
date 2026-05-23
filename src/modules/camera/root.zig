const std = @import("std");
const rl = @import("raylib");
const Zoom = @import("./lib/zoom.zig").Zoom;
const utils = @import("../../lib/utils.zig");
const State = @import("./lib/utils.zig").State;
const Movement = @import("./lib/movement.zig").Movement;
const Rotation = @import("./lib/rotation.zig").Rotation;
const InputHandler = @import("../input_handler/root.zig").InputHandler;

const invertScroll = utils.invertScroll;
const rotateVector = utils.rotateVector;

pub const Camera = struct {
    zoom: Zoom,
    movement: Movement,
    rotation: Rotation,
    camera: rl.Camera2D,
    state: State = .Fixed,

    pub fn init() Camera {
        const zoom = Zoom.init();
        const rotation = Rotation.init();
        const movement = Movement.init(rl.Vector2.init(0, 0));
        return .{
            .zoom = zoom,
            .movement = movement,
            .rotation = rotation,
            .camera = rl.Camera2D{
                .zoom = zoom.target,
                .rotation = rotation.target,
                .target = movement.target_position,
                .offset = movement.target_position,
            },
        };
    }

    pub fn deinit(self: *Camera) void {
        _ = self;
    }

    pub fn load(self: *Camera, offset: rl.Vector2) void {
        self.camera.offset = offset;
        switch (self.state) {
            .Free => {
                self.camera.target = offset;
                self.movement.target_position = offset;
            },
            .Fixed => {
                self.camera.target = offset;
                self.movement.target_position = offset;
            },
            .Follow => {
                self.camera.target = offset;
                self.movement.target_position = offset;
            },
        }
    }

    pub fn resize(self: *Camera, offset: rl.Vector2) void {
        self.load(offset);
    }

    pub fn setTarget(self: *Camera, target: rl.Vector2) void {
        self.camera.target = target;
        self.movement.target_position = target;
    }

    pub fn update(self: *Camera, input_handler: *InputHandler, target: ?rl.Vector2) void {
        switch (self.state) {
            .Free => {
                self.zoom.update(&self.camera, input_handler);
                self.movement.update(&self.camera, input_handler);
                self.rotation.update(&self.camera, input_handler);
                return;
            },
            .Follow => {
                self.zoom.update(&self.camera, input_handler);
                if (target) |t| {
                    self.movement.target_position = t;
                } else self.movement.target_position = self.camera.target;
                const diff = self.movement.target_position.subtract(self.camera.target);
                const diff_scaled = diff.scale(self.movement.lerp_speed);
                self.camera.target = self.camera.target.add(diff_scaled);
                return;
            },
            .Fixed => return,
        }
    }
};
