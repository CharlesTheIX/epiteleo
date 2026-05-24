const std = @import("std");
const rl: type = @import("raylib");
const Data = @import("./data.zig").Data;
const State = @import("./utils.zig").State;
const Direction = @import("./utils.zig").Direction;
const Animation = @import("./animation.zig").Animation;
const getRectCentre = @import("./utils.zig").getRectCentre;

pub const Sprite = struct {
    data: Data = .{},
    state: State = .Idle,
    animation: Animation = .{},
    direction: Direction = .Down,
    texture: ?rl.Texture2D = null,

    pub fn init() Sprite {
        return .{};
    }

    pub fn deinit(self: *Sprite) void {
        if (self.texture) |texture| rl.unloadTexture(texture);
        self.texture = null;
    }

    /// METHODS
    pub fn draw(self: *Sprite, pos: *rl.Vector2) void {
        if (self.texture) |texture| {
            if (self.data.size) |size| {
                const width = @as(f32, @floatFromInt(size[0]));
                const height = @as(f32, @floatFromInt(size[1]));
                const x = @as(f32, @floatFromInt(self.animation.frame)) * width;
                const y = @as(f32, @floatFromInt(self.direction.toTextureRow(&self.state))) * height;
                const rect = rl.Rectangle.init(x, y, width, height);
                rl.drawTextureRec(texture, rect, pos.*, rl.Color.white);
            }
        }
    }

    pub fn drawHitbox(self: *Sprite, pos: *rl.Vector2) void {
        if (self.data.hitbox) |hitbox| {
            const width = @as(f32, @floatFromInt(hitbox[2]));
            const height = @as(f32, @floatFromInt(hitbox[3]));
            const x = @as(f32, @floatFromInt(hitbox[0])) + pos.x;
            const y = @as(f32, @floatFromInt(hitbox[1])) + pos.y;
            const rect = rl.Rectangle.init(x, y, width, height);
            rl.drawRectangleRec(rect, rl.Color.red.alpha(0.5));
        }
    }

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

    pub fn load(self: *Sprite, io: *std.Io, data_path: [:0]const u8, texture_path: [:0]const u8, direction: Direction) void {
        self.data.load(data_path, io);
        const image = rl.loadImage(texture_path) catch return;
        defer rl.unloadImage(image);
        const texture = rl.loadTextureFromImage(image) catch return;
        self.texture = texture;
        self.direction = direction;
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
