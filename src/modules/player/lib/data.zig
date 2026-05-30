const std = @import("std");
const rl = @import("raylib");
const nowEpochYearSeconds = @import("../../../utils.zig").nowEpochYearSeconds;

pub const Data = struct {
    play_time: u64 = 0,
    start_time: i64 = 0,
    pos: rl.Vector2 = .{ .x = 100, .y = 100 },
    path: *const [19:0]u8 = ".data/player_data.z",
    name: [64]u8 = blk: {
        var buf: [64]u8 = [_]u8{0} ** 64;
        @memcpy(buf[0.."Player".len], "Player");
        break :blk buf;
    },

    pub fn load(self: *Data, io: *std.Io) void {
        const cwd = std.Io.Dir.cwd();
        const file = cwd.openFile(io.*, self.path, .{}) catch return self.save(io);
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
                if (std.mem.eql(u8, key, "name")) self.setName(parsed_value);

                if (std.mem.eql(u8, key, "play_time")) {
                    const play_time = std.fmt.parseInt(u64, parsed_value, 10) catch self.play_time;
                    self.play_time = play_time;
                }

                if (std.mem.eql(u8, key, "pos")) {
                    var pos_split = std.mem.splitSequence(u8, parsed_value, ",");
                    if (pos_split.next()) |x_str| {
                        const x = std.fmt.parseFloat(f32, std.mem.trim(u8, x_str, " \t\r")) catch self.pos.x;
                        self.pos.x = x;
                    }
                    if (pos_split.next()) |y_str| {
                        const y = std.fmt.parseFloat(f32, std.mem.trim(u8, y_str, " \t\r")) catch self.pos.y;
                        self.pos.y = y;
                    }
                }
            }
        }

        self.start_time = nowEpochYearSeconds();
    }

    pub fn save(self: *Data, io: *std.Io) void {
        self.setPlayTime(null);
        const cwd = std.Io.Dir.cwd();
        cwd.createDirPath(io.*, ".data") catch {
            return std.debug.print("Error: Failed to save settings data - create directory\n", .{});
        };
        const file = cwd.createFile(io.*, self.path, .{}) catch {
            return std.debug.print("Error: Failed to save settings data - create file\n", .{});
        };
        defer file.close(io.*);
        var total_len: usize = 0;
        var buffer: [1024]u8 = undefined;
        const n = self.name[0..(std.mem.indexOfScalar(u8, self.name[0..], 0) orelse self.name.len)];
        const name = std.fmt.bufPrint(buffer[total_len..], "name={s}\n", .{n}) catch {
            return std.debug.print("Error: Failed to save settings data - write line\n", .{});
        };
        total_len += name.len;
        const play_time = std.fmt.bufPrint(buffer[total_len..], "play_time={d}\n", .{self.play_time}) catch {
            return std.debug.print("Error: Failed to save settings data - write line\n", .{});
        };
        total_len += play_time.len;
        file.writePositionalAll(io.*, buffer[0..total_len], 0) catch {
            return std.debug.print("Error: Failed to save settings data - write file\n", .{});
        };
        const pos = std.fmt.bufPrint(buffer[0..], "pos={d},{d}\n", .{ self.pos.x, self.pos.y }) catch {
            return std.debug.print("Error: Failed to save settings data - write line\n", .{});
        };
        total_len += pos.len;
        file.writePositionalAll(io.*, buffer[total_len .. total_len + pos.len], total_len) catch {
            return std.debug.print("Error: Failed to save settings data - write file\n", .{});
        };
    }

    pub fn setName(self: *Data, _name: []const u8) void {
        var name = _name;
        if (name.len >= self.name.len) name = name[0 .. self.name.len - 1];
        @memset(self.name[0..], 0);
        @memcpy(self.name[0..name.len], name);
    }

    pub fn setPlayTime(self: *Data, play_time: ?u64) void {
        if (play_time) |pt| {
            self.play_time = pt;
            return;
        }
        const now = nowEpochYearSeconds();
        if (self.start_time == 0) {
            self.play_time = 0;
            self.start_time = now;
            return;
        }
        if (now <= self.start_time) {
            self.play_time = 0;
            return;
        }
        self.play_time = @intCast(now - self.start_time);
    }
};

pub fn saveDataOnThread(ctx: *anyopaque, io: *std.Io) void {
    const module: *Data = @ptrCast(@alignCast(ctx));
    module.save(io);
}
