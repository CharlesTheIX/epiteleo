const std = @import("std");
const rl = @import("raylib");
const _data = @import("./lib/data.zig");
const _ih = @import("../../_ih/root.zig");
const _utils = @import("../../utils.zig");
const Timer = @import("../timer/root.zig").Timer;
const Sprite = @import("../sprite/root.zig").Sprite;
const _physics = @import("../../_physics/root.zig");
const _sprite_utils = @import("../sprite/lib/utils.zig");

pub const loadData = _data.load;
pub const saveData = _data.save;
pub const setName = _data.setName;

pub const Player = struct {
    play_time: u64 = 0,
    start_time: i64 = 0,
    max_speed: f32 = 2.0,
    timer: Timer = .init(0.2),
    pos: rl.Vector2 = .zero(),
    texture: ?rl.Texture2D = null,
    surface: _physics.Surface = .init(.Ground),
    path: *const [19:0]u8 = ".data/player_data.z",
    sprite: Sprite = .init(.AnimalBoar, .Right, .Walk),
    body: _physics.Body = .{ .mass = 85.0, .velocity = .zero(), .acceleration = .zero() },
    name: [64]u8 = blk: {
        var buf: [64]u8 = [_]u8{0} ** 64;
        @memcpy(buf[0.."Player".len], "Player");
        break :blk buf;
    },

    pub fn init() Player {
        std.debug.print("Player : Initializing...\n", .{});
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

    pub fn applyRectCollisions(self: *Player, rects: *const []const rl.Rectangle) void {
        var hitbox_rect = self.sprite.data.hitboxRect(&self.pos);
        if (hitbox_rect.width == 0 or hitbox_rect.height == 0) return;
        const origin = self.sprite.data.originVector();
        hitbox_rect.x -= origin.x;
        hitbox_rect.y -= origin.y;
        for (rects.*) |r| {
            const collision_rect = rl.getCollisionRec(hitbox_rect, r);
            if (collision_rect.width > 0 and collision_rect.height > 0) {
                self.body.velocity = self.body.velocity.scale(0);
                self.body.acceleration = self.body.acceleration.scale(0);
                if (self.sprite.direction == .Up) self.pos.y += collision_rect.height;
                if (self.sprite.direction == .Left) self.pos.x += collision_rect.width;
                if (self.sprite.direction == .Down) self.pos.y -= collision_rect.height;
                if (self.sprite.direction == .Right) self.pos.x -= collision_rect.width;
            }
        }
    }

    pub fn draw(self: *Player, tint: ?rl.Color) void {
        const clr = if (tint) |t| t else rl.Color.white;
        self.sprite.draw(&self.pos, clr);
        self.sprite.drawHitbox(&self.pos);
    }

    pub fn focalPoint(self: *Player) void {
        self.sprite.focalPoint(self.pos);
    }

    pub fn load(self: *Player, texture: *?rl.Texture2D, io: *std.Io) void {
        std.debug.print("Player : Loading...\n", .{});
        loadData(self, io);
        if (texture.*) |*txt| self.sprite.load(txt, io);
    }

    pub fn save(self: *Player, io: *std.Io) void {
        std.debug.print("Player : Saving player data...\n", .{});
        saveData(self, io);
    }

    pub fn update(self: *Player, ih: *_ih.InputHandler) void {
        self.updateFromInput(ih);
        self.sprite.update();
    }

    fn updateFromInput(self: *Player, ih: *_ih.InputHandler) void {
        var latest_order: u64 = 0;
        const base_force: f32 = 850;
        const stop_speed: f32 = 0.01;
        var latest_key: ?_ih.Key = null;
        const kb = &ih.keyboard;
        const force_multiplier: f32 = 2.8;
        const dt = rl.getFrameTime();
        var speed_cap: f32 = self.max_speed;
        var input_force = rl.Vector2.zero();
        const speed_cap_curve_deceleration: f32 = 18.0;
        var next_state = _sprite_utils.State.Idle;
        const wants_attack = kb.activeKeysInclude(&[_]_ih.Key{.Space}, .Or);
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
                }
            }
        }
        self.body.applyForce(input_force);
        self.body.applySurfaceResistance(input_force, self.surface, dt, stop_speed);
        self.body.applyOrthogonalDrag(input_force, self.surface, dt, stop_speed);
        self.body.applyAcceleration(dt);
        if (next_state != .Attack and !self.sprite.noInterrupt()) {
            if (self.body.velocity.length() > 2.1) next_state = .Run;
            if (input_force.length() == 0 and self.body.velocity.length() > stop_speed) next_state = .Walk;
        }
        self.sprite.setState(next_state);
        self.body.applySpeedCapCurve(speed_cap, speed_cap_curve_deceleration, dt);
        self.pos = self.pos.add(self.body.velocity);
    }
};
