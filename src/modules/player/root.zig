const std = @import("std");
const rl = @import("raylib");
const _ih = @import("../../_ih/root.zig");
const _utils = @import("../../utils.zig");
const Data = @import("./lib/data.zig").Data;
const Timer = @import("../timer/root.zig").Timer;
const Sprite = @import("../sprite/root.zig").Sprite;
const _sprite_utils = @import("../sprite/lib/utils.zig");

const gravity_acceleration = 9.8;

const Surface = struct {
    static_friction_coefficient: f32,
    kinetic_friction_coefficient: f32,
};

const Body = struct {
    mass: f32, // in kg
    velocity: rl.Vector2, // in m/s
    acceleration: rl.Vector2, // in m/s^2

    pub fn momentum(self: Body) rl.Vector2 {
        return self.velocity.scale(self.mass); // p = m * v (kg*m/s)
    }

    pub fn kineticEnergy(self: Body) f32 {
        return 0.5 * self.mass * self.velocity.length() * self.velocity.length(); // KE = 0.5 * m * v^2 (J)
    }

    pub fn force(self: Body) rl.Vector2 {
        return self.acceleration.scale(self.mass); // F = m * a (N)
    }

    pub fn weight(self: Body) f32 {
        return self.mass * gravity_acceleration; // W = m * g (N)
    }

    pub fn normalForce(self: Body, deg: ?f32) f32 {
        const _deg = if (deg) |d| d else 0;
        const rad = _utils.degToRad(_deg);
        return self.mass * gravity_acceleration * @cos(rad); // N = m * g * cos(theta) (N)
    }

    pub fn resetAcceleration(self: *Body) void {
        self.acceleration = rl.Vector2.zero();
    }

    pub fn applyForce(self: *Body, F: rl.Vector2) void {
        const safe_mass = @max(self.mass, 0.001);
        self.acceleration = self.acceleration.add(F.scale(1.0 / safe_mass));
    }

    pub fn applySurfaceResistance(self: *Body, applied_force: rl.Vector2, surface: Surface, dt: f32, stop_speed: f32) void {
        const speed = self.velocity.length();
        const normal_force = self.normalForce(null);
        const applied_force_magnitude = applied_force.length();

        if (speed <= stop_speed) {
            const max_static_friction = surface.static_friction_coefficient * normal_force;
            if (applied_force_magnitude <= max_static_friction) {
                self.velocity = rl.Vector2.zero();
                self.acceleration = rl.Vector2.zero();
                return;
            }
            if (applied_force_magnitude > 0) {
                const static_friction_force = applied_force.normalize().scale(-max_static_friction);
                self.applyForce(static_friction_force);
            }
            return;
        }

        const kinetic_friction_force = surface.kinetic_friction_coefficient * normal_force;
        const friction_impulse = kinetic_friction_force * dt;
        if (applied_force_magnitude == 0 and friction_impulse >= self.momentum().length()) {
            self.velocity = rl.Vector2.zero();
            self.acceleration = rl.Vector2.zero();
            return;
        }

        const friction_force = self.velocity.normalize().scale(-kinetic_friction_force);
        self.applyForce(friction_force);
    }

    pub fn integrate(self: *Body, dt: f32) void {
        self.velocity = self.velocity.add(self.acceleration.scale(dt));
        if (self.velocity.length() < 0.0001) self.velocity = rl.Vector2.zero();
    }
};

const Friction = struct {
    static: f32 = 0.9,
    dynamic: f32 = 0.8,
};

pub const Player = struct {
    data: Data = .{},
    max_speed: f32 = 2.0,
    timer: Timer = .init(0.2),
    texture: ?rl.Texture2D = null,
    body: Body = .{ .mass = 100.0, .velocity = rl.Vector2.zero(), .acceleration = rl.Vector2.zero() },
    sprite: Sprite = .init(.AnimalBoar, .Right, .Walk),
    surface: Surface = .{ .static_friction_coefficient = 0.9, .kinetic_friction_coefficient = 0.8 },

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
        var speed_cap: f32 = self.max_speed;
        var input_force = rl.Vector2.zero();
        var next_state = _sprite_utils.State.Idle;

        self.body.resetAcceleration();

        if (self.sprite.noInterrupt()) {
            // do nothing, keep current state and ignore input
        } else if (kb.activeKeysInclude(&[_]_ih.Key{.Space}, .Or)) {
            next_state = .Attack;
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
        self.body.integrate(dt);

        if (self.body.velocity.length() > 2.1) next_state = .Run;
        if (input_force.length() == 0 and self.body.velocity.length() > stop_speed) next_state = .Walk;
        if (self.body.velocity.length() > speed_cap) self.body.velocity = self.body.velocity.normalize().scale(speed_cap);

        self.sprite.setState(next_state);
        self.data.pos = self.data.pos.add(self.body.velocity);

        std.debug.print("Applied Force: {d}, {d}\n", .{ input_force.x, input_force.y });
        std.debug.print("Acceleration: {d}, {d}\n", .{ self.body.acceleration.x, self.body.acceleration.y });
        std.debug.print("Velocity: {d}, {d}\n", .{ self.body.velocity.x, self.body.velocity.y });
        std.debug.print("Position: {d}, {d}\n", .{ self.data.pos.x, self.data.pos.y });
    }
};
