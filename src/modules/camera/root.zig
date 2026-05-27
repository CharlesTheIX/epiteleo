const std = @import("std");
const rl = @import("raylib");
const utils = @import("../../utils.zig");

const Zoom = @import("./lib/zoom.zig").Zoom;
const Movement = @import("./lib/movement.zig").Movement;
const Rotation = @import("./lib/rotation.zig").Rotation;
const invertScroll = utils.invertScroll;
const rotateVector = utils.rotateVector;
const InputHandler = @import("../input_handler/root.zig").InputHandler;

pub const Camera = struct {
    zoom: Zoom,
    movement: Movement,
    rotation: Rotation,
    camera: rl.Camera2D,
    state: State = .Fixed,
    snap_to_canvas: bool = true,

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

    fn snapToCanvas(self: *Camera, canvas_rect: *rl.Rectangle) void {
        if (!self.snap_to_canvas) return;
        const zoom = @max(self.camera.zoom, 0.0001);
        const screen_w = @as(f32, @floatFromInt(rl.getScreenWidth()));
        const screen_h = @as(f32, @floatFromInt(rl.getScreenHeight()));
        const top_extent = self.camera.offset.y / zoom;
        const left_extent = self.camera.offset.x / zoom;
        const right_extent = (screen_w - self.camera.offset.x) / zoom;
        const bottom_extent = (screen_h - self.camera.offset.y) / zoom;
        var min_x = canvas_rect.x + left_extent;
        var min_y = canvas_rect.y + top_extent;
        var max_x = canvas_rect.x + canvas_rect.width - right_extent;
        var max_y = canvas_rect.y + canvas_rect.height - bottom_extent;
        if (min_x > max_x) {
            const center_x = canvas_rect.x + (canvas_rect.width * 0.5);
            min_x = center_x;
            max_x = center_x;
        }
        if (min_y > max_y) {
            const center_y = canvas_rect.y + (canvas_rect.height * 0.5);
            min_y = center_y;
            max_y = center_y;
        }
        self.camera.target.x = std.math.clamp(self.camera.target.x, min_x, max_x);
        self.camera.target.y = std.math.clamp(self.camera.target.y, min_y, max_y);
        self.movement.target_position.x = std.math.clamp(self.movement.target_position.x, min_x, max_x);
        self.movement.target_position.y = std.math.clamp(self.movement.target_position.y, min_y, max_y);
    }

    pub fn update(self: *Camera, input_handler: *InputHandler, target: ?rl.Vector2, canvas_rect: ?*rl.Rectangle) void {
        switch (self.state) {
            .Free => {
                self.zoom.update(&self.camera, input_handler);
                self.movement.update(&self.camera, input_handler);
                if (!self.snap_to_canvas) {
                    self.rotation.update(&self.camera, input_handler);
                } else {
                    if (canvas_rect) |rect| self.snapToCanvas(rect);
                }
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
                if (canvas_rect) |rect| self.snapToCanvas(rect);
                return;
            },
            .Fixed => return,
        }
    }
};

pub const State = enum {
    Free,
    Fixed,
    Follow,

    pub fn toString(self: State) []const u8 {
        return switch (self) {
            .Free => "Free",
            .Fixed => "Fixed",
            .Follow => "Follow",
        };
    }
};
