const std = @import("std");
const rl = @import("raylib");
const _ih = @import("../../_ih/root.zig");
const _utils = @import("../../utils.zig");
const Data = @import("./lib/data.zig").Data;
const Timer = @import("../timer/root.zig").Timer;
const Sprite = @import("../sprite/root.zig").Sprite;
const _sprite_utils = @import("../sprite/lib/utils.zig");

pub const Player = struct {
    data: Data = .{},
    timer: Timer = .init(0.2),
    texture: ?rl.Texture2D = null,

    max_speed: f32 = 1.0,
    current_drag: f32 = 0.89,
    velocity: rl.Vector2 = .zero(),
    acceleration: rl.Vector2 = .zero(),
    sprite: Sprite = .init(.AnimalBoar, .Right, .Walk),

    pub fn init() Player {
        return .{};
    }

    pub fn deinit(self: *Player) void {
        std.debug.print("Player : Deinitializing...\n", .{});
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
        std.debug.print("Player : Loading player data...\n", .{});
        self.data.load(io);
        if (texture.*) |*txt| self.sprite.load(txt, io);
    }

    pub fn save(self: *Player, io: *std.Io) void {
        std.debug.print("Player : Saving player data...\n", .{});
        self.data.save(io);
    }

    pub fn update(self: *Player, camera: *rl.Camera2D, ih: *_ih.InputHandler) void {
        self.updateFromInput(camera, ih);
        self.sprite.update();
    }

    fn updateFromInput(self: *Player, camera: *rl.Camera2D, ih: *_ih.InputHandler) void {
        const stop_epsilon: f32 = 0.01;
        const idle_drag_min: f32 = 0.59;
        const idle_drag_max: f32 = 0.89;
        const run_multiplier: f32 = 2.8;
        const kb = ih.keyboard;
        const drag_lerp_speed: f32 = 1.0;
        const attack_drag_min: f32 = 1;
        const attack_drag_max: f32 = 1;
        const acceleration_step: f32 = 0.2;
        const delta = rl.getFrameTime();
        const orthogonal_drag_min: f32 = 0.79;
        const orthogonal_drag_max: f32 = 0.89;

        self.acceleration = rl.Vector2.zero();
        var next_state = _sprite_utils.State.Idle;

        if (self.sprite.noInterrupt()) {
            // do nothing, keep current state and ignore input
        } else if (kb.activeKeysInclude(&[_]_ih.Key{.Space}, .Or)) {
            next_state = .Attack;
        } else {
            var latest_order: u64 = 0;
            var latest_key: ?_ih.Key = null;

            for (_sprite_utils.movement_keys) |key| {
                if (kb.activeKeyIndex(key)) |order| {
                    if (order > latest_order) {
                        latest_key = key;
                        latest_order = order;
                    }
                }
            }

            if (latest_key) |key| {
                if (_sprite_utils.Direction.fromKey(key)) |direction| {
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

        const attack_active = next_state == .Attack or (self.sprite.state == .Attack and !self.sprite.animation.finished);
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
            const target_drag = orthogonal_drag_min + (orthogonal_drag_max - orthogonal_drag_min) * speed_ratio;
            const drag_blend = @min(delta * drag_lerp_speed, 1.0);
            self.current_drag += (target_drag - self.current_drag) * drag_blend;
            const acceleration_dir = self.acceleration.normalize();
            const parallel_dot = self.velocity.x * acceleration_dir.x + self.velocity.y * acceleration_dir.y;
            const parallel_velocity = rl.Vector2.init(acceleration_dir.x * parallel_dot, acceleration_dir.y * parallel_dot);
            const orthogonal_velocity = rl.Vector2.init(
                self.velocity.x - parallel_velocity.x,
                self.velocity.y - parallel_velocity.y,
            ).scale(self.current_drag);
            self.velocity = parallel_velocity.add(orthogonal_velocity);
        } else {
            const max_speed_for_drag = @max(self.max_speed * run_multiplier, 0.001);
            const speed_ratio = @min(self.velocity.length() / max_speed_for_drag, 1.0);
            const target_drag = if (attack_active)
                attack_drag_min + (attack_drag_max - attack_drag_min) * speed_ratio
            else
                idle_drag_min + (idle_drag_max - idle_drag_min) * speed_ratio;
            const drag_blend = @min(delta * drag_lerp_speed, 1.0);
            self.current_drag += (target_drag - self.current_drag) * drag_blend;
            self.velocity = self.velocity.scale(self.current_drag);
            if (self.velocity.length() < stop_epsilon) self.velocity = rl.Vector2.zero();
        }

        if (self.velocity.length() > speed_cap) self.velocity = self.velocity.normalize().scale(speed_cap);
        self.sprite.setState(next_state);
        self.data.pos = self.data.pos.add(self.velocity);
    }
};
