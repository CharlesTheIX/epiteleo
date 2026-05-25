const std = @import("std");
const rl = @import("raylib");
const utils = @import("./lib/utils.zig");

const State = utils.State;
const Direction = utils.Direction;
const SpriteType = utils.SpriteType;
const Data = @import("./lib/data.zig").Data;
const Animation = @import("./lib/animation.zig").Animation;
const getRectCentre = utils.getRectCentre;

pub const Sprite = struct {
    id: SpriteType,
    data: Data = .{},
    state: State = .Idle,
    direction: Direction,
    animation: Animation = .{},
    texture: ?*rl.Texture2D = null,

    pub fn init(id: SpriteType, direction: ?Direction, state: ?State) Sprite {
        const dir = if (direction) |d| d else .Down;
        const st = if (state) |s| s else .Idle;
        return Sprite{ .id = id, .direction = dir, .state = st };
    }

    pub fn deinit(self: *Sprite) void {
        self.texture = null;
    }

    pub fn draw(self: *Sprite, pos: *rl.Vector2, tint: rl.Color) void {
        if (self.texture) |texture| {
            if (self.data.size) |size| {
                const width = @as(f32, @floatFromInt(size[0]));
                const height = @as(f32, @floatFromInt(size[1]));
                const x = @as(f32, @floatFromInt(self.animation.frame)) * width;
                const y = @as(f32, @floatFromInt(self.direction.toTextureRow(&self.state))) * height;
                const rect = rl.Rectangle.init(x, y, width, height);
                const origin = rl.Vector2.init(width / 2, height / 2);
                const dest = rl.Rectangle.init(pos.x, pos.y, width, height);
                rl.drawTexturePro(texture.*, rect, dest, origin, 0, tint);
            }
        }
    }

    //     pub fn drawHitbox(self: *Sprite, pos: *rl.Vector2) void {
    //     if (self.data.hitbox) |hitbox| {
    //         const width = @as(f32, @floatFromInt(hitbox[2]));
    //         const height = @as(f32, @floatFromInt(hitbox[3]));
    //         const x = @as(f32, @floatFromInt(hitbox[0])) + pos.x;
    //         const y = @as(f32, @floatFromInt(hitbox[1])) + pos.y;
    //         const rect = rl.Rectangle.init(x, y, width, height);
    //         rl.drawRectangleRec(rect, rl.Color.red.alpha(0.5));
    //     }
    // }

    pub fn focalPoint(self: *Sprite, pos: *rl.Vector2) rl.Vector2 {
        if (self.data.size) |size| {
            const rect = rl.Rectangle.init(
                pos.x,
                pos.y,
                @as(f32, @floatFromInt(size[0])),
                @as(f32, @floatFromInt(size[1])),
            );
            return getRectCentre(rect);
        }
        return pos.*;
    }

    pub fn load(self: *Sprite, texture: *rl.Texture2D, io: *std.Io) void {
        self.texture = texture;
        self.data.load(self.id, io);
        self.animation.max_frames = self.data.maxFramesFromState(self.state) orelse 0;
        self.animation.fps = @as(u8, @intFromFloat(self.data.fpsFromState(self.state) orelse 0));
    }

    pub fn noInterrupt(self: *Sprite) bool {
        const in_uninterruptible_state = self.state == .Attack or self.state == .Hurt or self.state == .Dying;
        const uninterruptible = in_uninterruptible_state and !self.animation.finished;
        return uninterruptible or self.state == .Dead;
    }

    pub fn resetState(self: *Sprite) void {
        self.state = .Idle;
        self.animation.frame = 0;
        self.animation.time_elapsed = 0;
        self.animation.finished = false;
        self.animation.max_frames = if (self.data.maxFramesFromState(.Idle)) |count| count else 0;
        self.animation.fps = if (self.data.fpsFromState(self.state)) |fps| @as(u8, @intFromFloat(fps)) else 0;
    }

    pub fn update(self: *Sprite) void {
        if (self.animation.fps <= 0 or self.animation.max_frames <= 0) return;
        const frame_duration = 1.0 / @as(f32, @floatFromInt(self.animation.fps));
        self.animation.time_elapsed += rl.getFrameTime();
        while (self.animation.time_elapsed >= frame_duration) : (self.animation.time_elapsed -= frame_duration) {
            if (self.animation.frame + 1 >= self.animation.max_frames) {
                self.animation.finished = true;
                self.animation.time_elapsed = 0;
                if (self.state != .Dying) self.animation.frame = 0;
                break;
            }
            self.animation.frame += 1;
        }
    }
};
