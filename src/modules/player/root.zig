const std = @import("std");
const rl = @import("raylib");
const _ih = @import("../../_ih/root.zig");
const _utils = @import("../../utils.zig");
const Data = @import("./lib/data.zig").Data;
const Timer = @import("../timer/root.zig").Timer;
const Sprite = @import("../sprite/root.zig").Sprite;
const SpriteUtils = @import("../sprite/lib/utils.zig");
const SpriteState = SpriteUtils.State;

pub const Player = struct {
    data: Data = .{},
    timer: Timer = .init(0.2),
    texture: ?rl.Texture2D = null,

    max_speed: f32 = 2.0,
    velocity: rl.Vector2 = .zero(),
    acceleration: rl.Vector2 = .zero(),
    sprite: Sprite = .init(.AnimalBoar, .Right, .Walk),

    pub fn init() Player {
        return .{};
    }

    pub fn deinit(self: *Player) void {
        self.sprite.deinit();
        if (self.texture) |texture| {
            rl.unloadTexture(texture);
            self.texture = null;
        }
    }

    pub fn draw(self: *Player, tint: ?rl.Color) void {
        const clr = if (tint) |t| t else rl.Color.white;
        self.sprite.draw(&self.data.pos, clr);
    }

    pub fn focus(self: *Player) void {
        self.sprite.focalPoint(self.data.pos);
    }

    pub fn load(self: *Player, texture: *?rl.Texture2D, io: *std.Io) void {
        self.data.load(io);
        if (texture.*) |*txt| self.sprite.load(txt, io);
    }

    pub fn save(self: *Player, io: *std.Io) void {
        self.data.save(io);
    }

    pub fn update(self: *Player, camera: *rl.Camera2D, ih: *_ih.InputHandler) void {
        self.updateFromInput(camera, ih);
        self.sprite.update();
    }

    fn updateFromInput(self: *Player, camera: *rl.Camera2D, ih: *_ih.InputHandler) void {
        const stop_epsilon: f32 = 0.01;
        const idle_drag_min: f32 = 0.80;
        const idle_drag_max: f32 = 0.99;
        const run_multiplier: f32 = 1.8;
        const kb = ih.keyboard;
        const acceleration_step: f32 = 0.2;
        const orthogonal_drag_min: f32 = 0.79;
        const orthogonal_drag_max: f32 = 0.89;

        self.acceleration = rl.Vector2.zero();
        var next_state = SpriteUtils.State.Idle;

        if (self.sprite.noInterrupt()) {
            // do nothing, keep current state and ignore input
        } else if (kb.activeKeysInclude(&[_]_ih.Key{.Space}, .Or)) {
            next_state = .Attack;
        } else {
            var latest_key: ?_ih.Key = null;
            var latest_order: u64 = 0;

            for (SpriteUtils.movement_keys) |key| {
                if (kb.activeKeyIndex(key)) |order| {
                    if (order > latest_order) {
                        latest_order = order;
                        latest_key = key;
                    }
                }
            }

            if (latest_key) |key| {
                if (SpriteUtils.Direction.fromKey(key)) |direction| {
                    self.sprite.direction = direction;
                    switch (direction) {
                        .Up => self.acceleration.y -= 1,
                        .Down => self.acceleration.y += 1,
                        .Left => self.acceleration.x -= 1,
                        .Right => self.acceleration.x += 1,
                    }
                }
            }
        }

        var speed_cap = self.max_speed;
        if (self.acceleration.length() > 0) {
            next_state = .Walk;
            if (kb.activeKeysInclude(&[_]_ih.Key{ .LeftShift, .RightShift }, .Or)) {
                next_state = .Run;
                speed_cap *= run_multiplier;
            }
            self.acceleration = self.acceleration.normalize().scale(acceleration_step);
            self.acceleration = _utils.rotateVector(self.acceleration, -camera.rotation);
            self.velocity = self.velocity.add(self.acceleration);

            const max_speed_for_drag = @max(self.max_speed * run_multiplier, 0.001);
            const speed_ratio = @min(self.velocity.length() / max_speed_for_drag, 1.0);
            const orthogonal_drag = orthogonal_drag_min + (orthogonal_drag_max - orthogonal_drag_min) * speed_ratio;
            const accel_dir = self.acceleration.normalize();
            const parallel_dot = self.velocity.x * accel_dir.x + self.velocity.y * accel_dir.y;
            const parallel_velocity = rl.Vector2.init(accel_dir.x * parallel_dot, accel_dir.y * parallel_dot);
            const orthogonal_velocity = rl.Vector2.init(
                self.velocity.x - parallel_velocity.x,
                self.velocity.y - parallel_velocity.y,
            ).scale(orthogonal_drag);
            self.velocity = parallel_velocity.add(orthogonal_velocity);
        } else {
            const max_speed_for_drag = @max(self.max_speed * run_multiplier, 0.001);
            const speed_ratio = @min(self.velocity.length() / max_speed_for_drag, 1.0);
            const idle_drag = idle_drag_min + (idle_drag_max - idle_drag_min) * speed_ratio;
            self.velocity = self.velocity.scale(idle_drag);
            if (self.velocity.length() < stop_epsilon) self.velocity = rl.Vector2.zero();
        }

        if (self.velocity.length() > speed_cap) self.velocity = self.velocity.normalize().scale(speed_cap);
        self.sprite.setState(next_state);
        self.data.pos = self.data.pos.add(self.velocity);
    }
};
