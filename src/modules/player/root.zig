const std = @import("std");
const rl = @import("raylib");
const _ih = @import("../../_ih/root.zig");
const _utils = @import("../../utils.zig");
const Data = @import("./lib/data.zig").Data;
const Timer = @import("../timer/root.zig").Timer;
const Sprite = @import("../sprite/root.zig").Sprite;
const SpriteState = @import("../sprite/lib/utils.zig").State;

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
        const deceleration: f32 = 0.8;
        const stop_epsilon: f32 = 0.01;
        const run_multiplier: f32 = 1.8;
        const kb = ih.keyboard;
        const acceleration_step: f32 = 0.2;
        self.acceleration = rl.Vector2.zero();
        var next_state = SpriteState.Idle;
        if (self.sprite.noInterrupt()) {
            // do nothing, keep current state and ignore input
        } else if (kb.activeKeysInclude(&[_]_ih.Key{.Space}, .Or)) {
            next_state = .Attack;
        } else {
            self.acceleration = rl.Vector2.zero();
            if (kb.activeKeysInclude(&[_]_ih.Key{ .W, .Up }, .Or)) {
                self.acceleration.y -= 1;
                self.sprite.direction = .Up;
            } else if (kb.activeKeysInclude(&[_]_ih.Key{ .S, .Down }, .Or)) {
                self.acceleration.y += 1;
                self.sprite.direction = .Down;
            } else if (kb.activeKeysInclude(&[_]_ih.Key{ .A, .Left }, .Or)) {
                self.acceleration.x -= 1;
                self.sprite.direction = .Left;
            } else if (kb.activeKeysInclude(&[_]_ih.Key{ .D, .Right }, .Or)) {
                self.acceleration.x += 1;
                self.sprite.direction = .Right;
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
        } else {
            self.velocity = self.velocity.scale(deceleration);
            if (self.velocity.length() < stop_epsilon) self.velocity = rl.Vector2.zero();
        }

        if (self.velocity.length() > speed_cap) self.velocity = self.velocity.normalize().scale(speed_cap);
        self.sprite.setState(next_state);
        self.data.pos = self.data.pos.add(self.velocity);
    }
};
