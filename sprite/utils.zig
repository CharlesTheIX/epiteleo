const rl: type = @import("raylib");
const Key = @import("../input_handler/lib/keys.zig").Key;

pub const Direction = enum {
    Up,
    Down,
    Left,
    Right,

    pub fn fromRL(key: rl.KeyboardKey) ?Direction {
        return switch (key) {
            .up, .w => .Up,
            .down, .s => .Down,
            .left, .a => .Left,
            .right, .d => .Right,
            else => null,
        };
    }

    pub fn fromKey(key: Key) ?Direction {
        return switch (key) {
            .Up, .W => .Up,
            .Down, .S => .Down,
            .Left, .A => .Left,
            .Right, .D => .Right,
            else => null,
        };
    }

    pub fn toKey(self: Direction) Key {
        return switch (self) {
            .Up => .Up,
            .Down => .Down,
            .Left => .Left,
            .Right => .Right,
        };
    }

    pub fn toTextureRow(self: Direction, state: *State) u32 {
        var multiplier = state.toInt();
        if (state.* == .Dead) multiplier = State.Dying.toInt();
        multiplier *= 4;
        return switch (self) {
            .Down => multiplier + 0,
            .Up => multiplier + 1,
            .Left => multiplier + 2,
            .Right => multiplier + 3,
        };
    }
};

pub const movement_keys: []const Key = &.{ .Up, .Down, .Left, .Right, .W, .A, .S, .D };

pub fn getRectCentre(rect: rl.Rectangle) rl.Vector2 {
    return rl.Vector2.init(rect.x + rect.width / 2, rect.y + rect.height / 2);
}

pub const State = enum {
    Idle,
    Walk,
    Run,
    Attack,
    Hurt,
    Dying,
    Dead,

    pub fn toInt(self: State) u32 {
        return @as(u32, @intFromEnum(self));
    }
};
