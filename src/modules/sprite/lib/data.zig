const std = @import("std");
const rl: type = @import("raylib");
const utils = @import("./utils.zig");

const State = utils.State;
const Direction = utils.Direction;
const SpriteType = utils.SpriteType;
const StateOptions = @import("./state_options.zig").StateOptions;

pub const Data = struct {
    size: ?[2]u32 = null,
    hitbox: ?[4]u32 = null,
    run: ?StateOptions = null,
    idle: ?StateOptions = null,
    walk: ?StateOptions = null,
    hurt: ?StateOptions = null,
    dying: ?StateOptions = null,
    attack: ?StateOptions = null,
    direction: Direction = .Down,

    pub fn fpsFromState(self: Data, state: State) ?f32 {
        return switch (state) {
            .Dead => null,
            .Run => if (self.run) |run| @as(f32, @floatFromInt(run.fps)) else null,
            .Idle => if (self.idle) |idle| @as(f32, @floatFromInt(idle.fps)) else null,
            .Walk => if (self.walk) |walk| @as(f32, @floatFromInt(walk.fps)) else null,
            .Hurt => if (self.hurt) |hurt| @as(f32, @floatFromInt(hurt.fps)) else null,
            .Dying => if (self.dying) |dying| @as(f32, @floatFromInt(dying.fps)) else null,
            .Attack => if (self.attack) |attack| @as(f32, @floatFromInt(attack.fps)) else null,
        };
    }

    pub fn load(self: *Data, id: SpriteType, io: *std.Io) void {
        const cwd = std.Io.Dir.cwd();
        const path = id.dataPath();
        const file = cwd.openFile(io.*, path, .{}) catch return;
        defer file.close(io.*);

        var buffer: [1024]u8 = undefined;
        const read_bytes = file.readPositionalAll(io.*, &buffer, 0) catch return;
        const content = buffer[0..read_bytes];
        var content_it = std.mem.splitSequence(u8, content, "\n");

        while (content_it.next()) |line| {
            const trimmed_line = std.mem.trim(u8, line, " \t\r");
            if (trimmed_line.len == 0) continue;
            if (trimmed_line[0] == '#') continue;

            var line_split = std.mem.splitSequence(u8, trimmed_line, ":");
            const key = std.mem.trim(u8, line_split.first(), " \t\r");
            if (line_split.next()) |value| {
                const parsed_value = std.mem.trim(u8, value, " \t\r");
                if (std.mem.eql(u8, key, "hitbox") and self.hitbox == null) self.loadHitbox(parsed_value);
                if (std.mem.eql(u8, key, "dimensions") and self.size == null) self.loadSize(parsed_value);
                if (std.mem.eql(u8, key, "run") and self.run == null) self.run = StateOptions.load(parsed_value);
                if (std.mem.eql(u8, key, "idle") and self.idle == null) self.idle = StateOptions.load(parsed_value);
                if (std.mem.eql(u8, key, "walk") and self.walk == null) self.walk = StateOptions.load(parsed_value);
                if (std.mem.eql(u8, key, "hurt") and self.hurt == null) self.hurt = StateOptions.load(parsed_value);
                if (std.mem.eql(u8, key, "dying") and self.dying == null) self.dying = StateOptions.load(parsed_value);
                if (std.mem.eql(u8, key, "attack") and self.attack == null) self.attack = StateOptions.load(parsed_value);
            }
        }
    }

    fn loadHitbox(self: *Data, value: []const u8) void {
        var new_hitbox = [4]u32{ 0, 0, 0, 0 };
        var array_it = std.mem.splitSequence(u8, value, ",");
        const offset_x = std.fmt.parseInt(u32, array_it.first(), 10) catch null;
        const offset_y = if (array_it.next()) |i| std.fmt.parseInt(u32, i, 10) catch null else null;
        const width = if (array_it.next()) |i| std.fmt.parseInt(u32, i, 10) catch null else null;
        const height = if (array_it.next()) |i| std.fmt.parseInt(u32, i, 10) catch null else null;
        if (offset_x) |x| new_hitbox[0] = x;
        if (width) |w| new_hitbox[2] = w;
        if (height) |h| new_hitbox[3] = h;
        if (offset_y) |y| new_hitbox[1] = y;
        self.hitbox = new_hitbox;
    }

    fn loadSize(self: *Data, value: []const u8) void {
        var new_size = [2]u32{ 0, 0 };
        var array_it = std.mem.splitSequence(u8, value, ",");
        const width = std.fmt.parseInt(u32, array_it.first(), 10) catch null;
        if (width) |w| new_size[0] = w;
        if (array_it.next()) |i| {
            const height = std.fmt.parseInt(u32, i, 10) catch null;
            if (height) |h| new_size[1] = h;
        }
        self.size = new_size;
    }

    pub fn maxFramesFromState(self: Data, state: State) ?u4 {
        return switch (state) {
            .Idle => if (self.idle) |idle| idle.max_frames else null,
            .Walk => if (self.walk) |walk| walk.max_frames else null,
            .Run => if (self.run) |run| run.max_frames else null,
            .Attack => if (self.attack) |attack| attack.max_frames else null,
            .Hurt => if (self.hurt) |hurt| hurt.max_frames else null,
            .Dying => if (self.dying) |dying| dying.max_frames else null,
            .Dead => null,
        };
    }

    pub fn maxVFromState(self: Data, state: State) ?u8 {
        return switch (state) {
            .Idle => if (self.idle) |idle| idle.max_v else null,
            .Walk => if (self.walk) |walk| walk.max_v else null,
            .Run => if (self.run) |run| run.max_v else null,
            .Attack => if (self.attack) |attack| attack.max_v else null,
            .Hurt => if (self.hurt) |hurt| hurt.max_v else null,
            .Dying => if (self.dying) |dying| dying.max_v else null,
            .Dead => null,
        };
    }
};
