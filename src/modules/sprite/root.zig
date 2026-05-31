const std = @import("std");
const rl = @import("raylib");
const _utils = @import("./lib/utils.zig");
const Data = @import("./lib/data.zig").Data;
const Animation = @import("./lib/animation.zig").Animation;

pub const Sprite = struct {
    data: Data = .{},
    id: _utils.SpriteType,
    animation: Animation = .{},
    state: _utils.State = .Idle,
    direction: _utils.Direction,
    texture: ?*rl.Texture2D = null,

    pub fn init(id: _utils.SpriteType, direction: ?_utils.Direction, state: ?_utils.State) Sprite {
        const dir = if (direction) |d| d else .Down;
        const st = if (state) |s| s else .Idle;
        return Sprite{ .id = id, .direction = dir, .state = st };
    }

    pub fn deinit(self: *Sprite) void {
        self.texture = null;
    }

    pub fn draw(self: *Sprite, pos: *rl.Vector2, tint: rl.Color) void {
        if (self.texture) |texture| {
            if (self.data.size == null) return;
            const size_v = self.data.sizeVector();
            const origin = size_v.scale(0.5);
            const x = @as(f32, @floatFromInt(self.animation.frame)) * size_v.x;
            const y = @as(f32, @floatFromInt(self.direction.toTextureRow(&self.state))) * size_v.y;
            const rect = rl.Rectangle.init(x, y, size_v.x, size_v.y);
            const dest = rl.Rectangle.init(pos.x, pos.y, size_v.x, size_v.y);
            rl.drawTexturePro(texture.*, rect, dest, origin, 0, tint);
        }
    }

    pub fn drawHitbox(self: *Sprite, pos: *rl.Vector2) void {
        if (self.data.hitbox == null) return;
        const hitbox_rect = self.data.hitboxRect(pos);
        rl.drawRectangleRec(hitbox_rect, rl.Color.red.alpha(0.5));
    }

    pub fn focalPoint(self: *Sprite, pos: *rl.Vector2) rl.Vector2 {
        if (self.data.size == null) return;
        const size_v = self.data.sizeVector();
        const rect = rl.Rectangle.init(pos.x, pos.y, size_v.x, size_v.y);
        return _utils.getRectCentre(rect);
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

    pub fn setState(self: *Sprite, new_state: _utils.State) void {
        if (self.noInterrupt()) return;
        if (self.state == new_state) return;
        self.state = new_state;
        self.animation.frame = 0;
        self.animation.time_elapsed = 0;
        self.animation.finished = false;
        self.animation.max_frames = if (self.data.maxFramesFromState(new_state)) |count| count else 0;
        self.animation.fps = if (self.data.fpsFromState(new_state)) |fps| @as(u8, @intFromFloat(fps)) else 0;
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
