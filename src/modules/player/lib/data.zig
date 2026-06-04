const std = @import("std");
const rl = @import("raylib");
const _ah = @import("../../../_ah/root.zig");
const Player = @import("../root.zig").Player;
const nowEpochYearSeconds = @import("../../../utils.zig").nowEpochYearSeconds;

pub fn load(plr: *Player, io: *std.Io) void {
    std.debug.print("Player Data : Loading... \n", .{});
    const cwd = std.Io.Dir.cwd();
    const file = cwd.openFile(io.*, plr.path, .{}) catch return save(plr, io);
    defer file.close(io.*);
    var buffer: [1024]u8 = undefined;
    const read_bytes = file.readPositionalAll(io.*, &buffer, 0) catch return;
    const content = buffer[0..read_bytes];
    var content_it = std.mem.splitSequence(u8, content, "\n");

    while (content_it.next()) |line| {
        const trimmed_line = std.mem.trim(u8, line, " \t\r");
        if (trimmed_line.len == 0) continue;
        if (trimmed_line[0] == '#') continue;
        var line_split = std.mem.splitSequence(u8, trimmed_line, "=");
        const key = std.mem.trim(u8, line_split.first(), " \t\r");
        if (line_split.next()) |value| {
            const parsed_value = std.mem.trim(u8, value, " \t\r");
            if (std.mem.eql(u8, key, "name")) setName(plr, parsed_value);

            if (std.mem.eql(u8, key, "play_time")) {
                const play_time = std.fmt.parseInt(u64, parsed_value, 10) catch plr.play_time;
                plr.play_time = play_time;
            }

            if (std.mem.eql(u8, key, "pos")) {
                var pos_split = std.mem.splitSequence(u8, parsed_value, ",");
                if (pos_split.next()) |x_str| {
                    const x = std.fmt.parseFloat(f32, std.mem.trim(u8, x_str, " \t\r")) catch plr.pos.x;
                    plr.pos.x = x;
                }
                if (pos_split.next()) |y_str| {
                    const y = std.fmt.parseFloat(f32, std.mem.trim(u8, y_str, " \t\r")) catch plr.pos.y;
                    plr.pos.y = y;
                }
            }
        }
    }

    plr.start_time = nowEpochYearSeconds();
}

pub fn save(plr: *Player, io: *std.Io) void {
    std.debug.print("Player Data : Saving... \n", .{});
    setPlayTime(plr, null);
    const cwd = std.Io.Dir.cwd();
    cwd.createDirPath(io.*, ".data") catch {
        return std.debug.print("Error: Failed to save settings data - create directory\n", .{});
    };
    const file = cwd.createFile(io.*, plr.path, .{}) catch {
        return std.debug.print("Error: Failed to save settings data - create file\n", .{});
    };
    defer file.close(io.*);
    var total_len: usize = 0;
    var buffer: [1024]u8 = undefined;
    const n = plr.name[0..(std.mem.indexOfScalar(u8, plr.name[0..], 0) orelse plr.name.len)];
    const name = std.fmt.bufPrint(buffer[total_len..], "name={s}\n", .{n}) catch {
        return std.debug.print("Error: Failed to save settings data - write line\n", .{});
    };
    total_len += name.len;
    file.writePositionalAll(io.*, buffer[0..total_len], 0) catch {
        return std.debug.print("Error: Failed to save settings data - write file\n", .{});
    };

    const play_time = std.fmt.bufPrint(buffer[total_len..], "play_time={d}\n", .{plr.play_time}) catch {
        return std.debug.print("Error: Failed to save settings data - write line\n", .{});
    };
    total_len += play_time.len;
    file.writePositionalAll(io.*, buffer[0..total_len], 0) catch {
        return std.debug.print("Error: Failed to save settings data - write file\n", .{});
    };

    const pos = std.fmt.bufPrint(buffer[total_len..], "pos={d},{d}\n", .{ plr.pos.x, plr.pos.y }) catch {
        return std.debug.print("Error: Failed to save settings data - write line\n", .{});
    };
    total_len += pos.len;
    file.writePositionalAll(io.*, buffer[0..total_len], 0) catch {
        return std.debug.print("Error: Failed to save settings data - write file\n", .{});
    };
}

pub fn setName(plr: *Player, _name: []const u8) void {
    var name = _name;
    if (name.len >= plr.name.len) name = name[0 .. plr.name.len - 1];
    @memset(plr.name[0..], 0);
    @memcpy(plr.name[0..name.len], name);
}

fn setPlayTime(plr: *Player, play_time: ?u64) void {
    if (play_time) |pt| {
        plr.play_time = pt;
        return;
    }
    const now = nowEpochYearSeconds();
    if (plr.start_time == 0) {
        plr.play_time = 0;
        plr.start_time = now;
        return;
    }
    if (now <= plr.start_time) {
        plr.play_time = 0;
        return;
    }
    plr.play_time = @intCast(now - plr.start_time);
}

pub fn saveDataOnThread(ctx: *anyopaque, io: *std.Io, ah: *_ah.AudioHandler) void {
    _ = ah;
    const module: *Player = @ptrCast(@alignCast(ctx));
    module.save(io);
}
