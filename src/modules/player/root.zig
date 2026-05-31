const std = @import("std");
const rl = @import("raylib");
const _ih = @import("../../_ih/root.zig");
const _utils = @import("../../utils.zig");
const Data = @import("./lib/data.zig").Data;
const Timer = @import("../timer/root.zig").Timer;
const Sprite = @import("../sprite/root.zig").Sprite;
const _physics = @import("../../_physics/root.zig");
const _sprite_utils = @import("../sprite/lib/utils.zig");

pub const Player = struct {
    data: Data = .{},
    max_speed: f32 = 2.0,
    timer: Timer = .init(0.2),
    texture: ?rl.Texture2D = null,
    surface: _physics.Surface = .init(.Ground),
    sprite: Sprite = .init(.AnimalBoar, .Right, .Walk),
    body: _physics.Body = .{ .mass = 100.0, .velocity = rl.Vector2.zero(), .acceleration = rl.Vector2.zero() },

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

    pub fn update(self: *Player, ih: *_ih.InputHandler) void {
        self.updateFromInput(ih);
        self.sprite.update();
    }

    fn updateFromInput(self: *Player, ih: *_ih.InputHandler) void {
        var latest_order: u64 = 0;
        const base_force: f32 = 950;
        const stop_speed: f32 = 0.01;
        var latest_key: ?_ih.Key = null;
        const kb = ih.keyboard;
        const force_multiplier: f32 = 2.8;
        const dt = rl.getFrameTime();
        const wants_attack = kb.activeKeysInclude(&[_]_ih.Key{.Space}, .Or);
        var speed_cap: f32 = self.max_speed;
        var input_force = rl.Vector2.zero();
        var next_state = _sprite_utils.State.Idle;

        self.body.resetAcceleration();

        if (wants_attack and !self.sprite.noInterrupt()) {
            next_state = .Attack;
        } else if (self.sprite.noInterrupt()) {
            // do nothing, keep current state and ignore input
        } else {
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
                    next_state = .Walk;
                    self.sprite.direction = direction;
                    var force_magnitude = base_force;
                    switch (direction) {
                        .Up => input_force.y = -1,
                        .Down => input_force.y = 1,
                        .Left => input_force.x = -1,
                        .Right => input_force.x = 1,
                    }

                    if (kb.activeKeysInclude(&[_]_ih.Key{ .LeftShift, .RightShift }, .Or)) {
                        speed_cap *= force_multiplier;
                        force_magnitude *= force_multiplier;
                    }

                    input_force = input_force.scale(force_magnitude);
                    self.body.applyForce(input_force);
                }
            }
        }

        self.body.applySurfaceResistance(input_force, self.surface, dt, stop_speed);
        self.body.applyOrthogonalDrag(input_force, self.surface, dt, stop_speed);
        self.body.applyAcceleration(dt);

        if (next_state != .Attack and !self.sprite.noInterrupt()) {
            if (self.body.velocity.length() > 2.1) next_state = .Run;
            if (input_force.length() == 0 and self.body.velocity.length() > stop_speed) next_state = .Walk;
        }
        if (self.body.velocity.length() > speed_cap) self.body.velocity = self.body.velocity.normalize().scale(speed_cap);

        self.sprite.setState(next_state);
        self.data.pos = self.data.pos.add(self.body.velocity);

        std.debug.print("Applied Force: {d}, {d}\n", .{ input_force.x, input_force.y });
        std.debug.print("Acceleration: {d}, {d}\n", .{ self.body.acceleration.x, self.body.acceleration.y });
        std.debug.print("Velocity: {d}, {d}\n", .{ self.body.velocity.x, self.body.velocity.y });
        std.debug.print("Position: {d}, {d}\n", .{ self.data.pos.x, self.data.pos.y });
    }
};
