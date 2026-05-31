const std = @import("std");
const rl = @import("raylib");
const _utils = @import("../utils.zig");

const gravity_acceleration = 9.8;

const SurfaceId = enum {
    None,
    Ground,
    Ice,
    Mud,

    pub fn fromInt(value: i32) SurfaceId {
        return switch (value) {
            0 => .None,
            1 => .Ground,
            2 => .Ice,
            3 => .Mud,
            else => .None,
        };
    }

    pub fn toInt(self: SurfaceId) i32 {
        return @intFromEnum(self);
    }
};

pub const Surface = struct {
    id: SurfaceId,
    static_friction_coefficient: f32,
    kinetic_friction_coefficient: f32,

    pub fn init(id: SurfaceId) Surface {
        var surface = Surface{ .id = .None, .static_friction_coefficient = 0, .kinetic_friction_coefficient = 1 };
        switch (id) {
            .Ground => {
                surface.static_friction_coefficient = 0.8;
                surface.kinetic_friction_coefficient = 0.6;
            },
            .Ice => {
                surface.static_friction_coefficient = 0.1;
                surface.kinetic_friction_coefficient = 0.05;
            },
            .Mud => {
                surface.static_friction_coefficient = 1.2;
                surface.kinetic_friction_coefficient = 1.0;
            },
            else => {},
        }
        return surface;
    }
};

pub const Body = struct {
    mass: f32, // in kg
    velocity: rl.Vector2, // in m/s
    acceleration: rl.Vector2, // in m/s^2

    pub fn applyAcceleration(self: *Body, dt: f32) void {
        self.velocity = self.velocity.add(self.acceleration.scale(dt));
        if (self.velocity.length() < 0.0001) self.velocity = rl.Vector2.zero();
    }

    pub fn applyForce(self: *Body, F: rl.Vector2) void {
        const safe_mass = @max(self.mass, 0.001);
        self.acceleration = self.acceleration.add(F.scale(1.0 / safe_mass));
    }

    pub fn applyOrthogonalDrag(self: *Body, applied_force: rl.Vector2, surface: Surface, dt: f32, stop_speed: f32) void {
        if (applied_force.length() == 0) return;

        const normal_force = self.normalForce(null);
        const harsh_drag_force = surface.static_friction_coefficient * normal_force;
        const harsh_drag_acceleration = harsh_drag_force / @max(self.mass, 0.001);
        const delta_v = harsh_drag_acceleration * dt;

        // When moving on one axis, aggressively decay residual velocity on the orthogonal axis.
        if (applied_force.x != 0 and applied_force.y == 0) {
            const orth_speed = @abs(self.velocity.y);
            if (orth_speed <= stop_speed or orth_speed <= delta_v) {
                self.velocity.y = 0;
                self.acceleration.y = 0;
            } else {
                self.acceleration.y = 0;
                self.velocity.y -= std.math.sign(self.velocity.y) * delta_v;
            }
        } else if (applied_force.y != 0 and applied_force.x == 0) {
            const orth_speed = @abs(self.velocity.x);
            if (orth_speed <= stop_speed or orth_speed <= delta_v) {
                self.velocity.x = 0;
                self.acceleration.x = 0;
            } else {
                self.acceleration.x = 0;
                self.velocity.x -= std.math.sign(self.velocity.x) * delta_v;
            }
        }
    }

    pub fn applySurfaceResistance(self: *Body, applied_force: rl.Vector2, surface: Surface, dt: f32, stop_speed: f32) void {
        const normal_force = self.normalForce(null);
        const applied_force_magnitude = applied_force.length();

        if (self.velocity.length() <= stop_speed) {
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

    pub fn force(self: Body) rl.Vector2 {
        return self.acceleration.scale(self.mass); // F = m * a (N)
    }

    pub fn kineticEnergy(self: Body) f32 {
        return 0.5 * self.mass * self.velocity.length() * self.velocity.length(); // KE = 0.5 * m * v^2 (J)
    }

    pub fn momentum(self: Body) rl.Vector2 {
        return self.velocity.scale(self.mass); // p = m * v (kg*m/s)
    }

    pub fn normalForce(self: Body, deg: ?f32) f32 {
        const _deg = if (deg) |d| d else 0;
        const rad = _utils.degToRad(_deg);
        return self.mass * gravity_acceleration * @cos(rad); // N = m * g * cos(theta) (N)
    }

    pub fn resetAcceleration(self: *Body) void {
        self.acceleration = rl.Vector2.zero();
    }

    pub fn weight(self: Body) f32 {
        return self.mass * gravity_acceleration; // W = m * g (N)
    }
};
