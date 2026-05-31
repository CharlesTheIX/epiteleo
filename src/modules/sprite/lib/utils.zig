const std = @import("std");
const rl: type = @import("raylib");
const Key = @import("../../../_ih/root.zig").Key;

pub const Direction = enum {
    Up,
    Down,
    Left,
    Right,

    pub fn fromInt(raw: u32) Direction {
        return switch (raw) {
            0 => .Up,
            1 => .Down,
            2 => .Left,
            3 => .Right,
            else => .Down,
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

    pub fn fromRL(key: rl.KeyboardKey) ?Direction {
        return switch (key) {
            .up, .w => .Up,
            .down, .s => .Down,
            .left, .a => .Left,
            .right, .d => .Right,
            else => null,
        };
    }

    pub fn toInt(self: Direction) u8 {
        return @intFromEnum(self);
    }

    pub fn toKey(self: Direction) Key {
        return switch (self) {
            .Up => .Up,
            .Down => .Down,
            .Left => .Left,
            .Right => .Right,
        };
    }

    pub fn toRL(self: Direction) rl.KeyboardKey {
        return switch (self) {
            .Up => .up,
            .Down => .down,
            .Left => .left,
            .Right => .right,
        };
    }

    pub fn toString(self: Direction) []const u8 {
        return switch (self) {
            .Up => "Up",
            .Down => "Down",
            .Left => "Left",
            .Right => "Right",
        };
    }

    pub fn toTextureRow(self: Direction, state: *State) u8 {
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

pub fn getRectCentre(rect: rl.Rectangle) rl.Vector2 {
    return rl.Vector2.init(rect.x + rect.width / 2, rect.y + rect.height / 2);
}

pub const movement_keys: []const Key = &.{ .Up, .Down, .Left, .Right, .W, .A, .S, .D };

pub const SpriteType = enum {
    AnimalBlackGoose,
    AnimalBoar,
    AnimalBull,
    AnimalCalf,
    AnimalChick,
    AnimalDeer,
    AnimalFox,
    AnimalHare,
    AnimalLamb,
    AnimalPiglet,
    AnimalRooster,
    AnimalSheep,
    AnimalTurkey,

    pub fn fromInt(raw: u8) ?SpriteType {
        return switch (raw) {
            0 => .AnimalBlackGoose,
            1 => .AnimalBoar,
            2 => .AnimalBull,
            3 => .AnimalCalf,
            4 => .AnimalChick,
            5 => .AnimalDeer,
            6 => .AnimalFox,
            7 => .AnimalHare,
            8 => .AnimalLamb,
            9 => .AnimalPiglet,
            10 => .AnimalRooster,
            11 => .AnimalSheep,
            12 => .AnimalTurkey,
            else => null,
        };
    }

    pub fn toInt(self: SpriteType) u8 {
        return @intFromEnum(self);
    }

    pub fn toString(self: SpriteType) []const u8 {
        return switch (self) {
            .AnimalBlackGoose => "AnimalBlackGoose",
            .AnimalBoar => "AnimalBoar",
            .AnimalBull => "AnimalBull",
            .AnimalCalf => "AnimalCalf",
            .AnimalChick => "AnimalChick",
            .AnimalDeer => "AnimalDeer",
            .AnimalFox => "AnimalFox",
            .AnimalHare => "AnimalHare",
            .AnimalLamb => "AnimalLamb",
            .AnimalPiglet => "AnimalPiglet",
            .AnimalRooster => "AnimalRooster",
            .AnimalSheep => "AnimalSheep",
            .AnimalTurkey => "AnimalTurkey",
        };
    }

    pub fn fromString(s: []const u8) ?SpriteType {
        if (std.mem.eql(u8, s, "AnimalBlackGoose")) return .AnimalBlackGoose;
        if (std.mem.eql(u8, s, "AnimalBoar")) return .AnimalBoar;
        if (std.mem.eql(u8, s, "AnimalBull")) return .AnimalBull;
        if (std.mem.eql(u8, s, "AnimalCalf")) return .AnimalCalf;
        if (std.mem.eql(u8, s, "AnimalChick")) return .AnimalChick;
        if (std.mem.eql(u8, s, "AnimalDeer")) return .AnimalDeer;
        if (std.mem.eql(u8, s, "AnimalFox")) return .AnimalFox;
        if (std.mem.eql(u8, s, "AnimalHare")) return .AnimalHare;
        if (std.mem.eql(u8, s, "AnimalLamb")) return .AnimalLamb;
        if (std.mem.eql(u8, s, "AnimalPiglet")) return .AnimalPiglet;
        if (std.mem.eql(u8, s, "AnimalRooster")) return .AnimalRooster;
        if (std.mem.eql(u8, s, "AnimalSheep")) return .AnimalSheep;
        if (std.mem.eql(u8, s, "AnimalTurkey")) return .AnimalTurkey;
        return null;
    }

    pub fn path(self: SpriteType, buffer: *[128]u8, opt: enum { Data, SpriteSheet }) ?[]const u8 {
        const id = self.toString();
        const file_name = switch (opt) {
            .Data => "data.z",
            .SpriteSheet => "spritesheet.png",
        };
        const _path = std.fmt.bufPrint(buffer[0..], "assets/data/sprites/{s}/{s}", .{ id, file_name }) catch return null;
        return _path;
    }
};

pub const State = enum {
    Idle,
    Walk,
    Run,
    Attack,
    Hurt,
    Dying,
    Dead,

    pub fn fromInt(raw: u8) State {
        return switch (raw) {
            0 => .Idle,
            1 => .Walk,
            2 => .Run,
            3 => .Attack,
            4 => .Hurt,
            5 => .Dying,
            6 => .Dead,
            else => .Idle,
        };
    }

    pub fn toInt(self: State) u8 {
        return @intFromEnum(self);
    }

    pub fn toString(self: State) []const u8 {
        return switch (self) {
            .Idle => "Idle",
            .Walk => "Walk",
            .Run => "Run",
            .Attack => "Attack",
            .Hurt => "Hurt",
            .Dying => "Dying",
            .Dead => "Dead",
        };
    }
};
