const std = @import("std");
const rl: type = @import("raylib");
const _utils = @import("./utils.zig");
const Map = @import("../root.zig").Map;

pub fn loadData(map: *Map, id: _utils.MapType, io: *std.Io) void {
    _ = map;
    var path_buffer: [128]u8 = undefined;
    const path = id.path(&path_buffer, .Data) orelse return;
    const cwd = std.Io.Dir.cwd();
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

        // var line_split = std.mem.splitSequence(u8, trimmed_line, ":");
        // const key = std.mem.trim(u8, line_split.first(), " \t\r");
        // if (line_split.next()) |value| {
        // const parsed_value = std.mem.trim(u8, value, " \t\r");
        // if (std.mem.eql(u8, key, "hitbox") and self.hitbox == null) self.loadHitbox(parsed_value);
        // if (std.mem.eql(u8, key, "dimensions") and self.size == null) self.loadSize(parsed_value);
        // if (std.mem.eql(u8, key, "run") and self.run == null) self.run = StateOptions.load(parsed_value);
        // if (std.mem.eql(u8, key, "idle") and self.idle == null) self.idle = StateOptions.load(parsed_value);
        // if (std.mem.eql(u8, key, "walk") and self.walk == null) self.walk = StateOptions.load(parsed_value);
        // if (std.mem.eql(u8, key, "hurt") and self.hurt == null) self.hurt = StateOptions.load(parsed_value);
        // if (std.mem.eql(u8, key, "dying") and self.dying == null) self.dying = StateOptions.load(parsed_value);
        // if (std.mem.eql(u8, key, "attack") and self.attack == null) self.attack = StateOptions.load(parsed_value);
        // }
    }
}
