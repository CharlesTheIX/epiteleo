const std = @import("std");

pub const Data = struct {
    volume: u8 = 50,
    difficulty: u8 = 1,
    path: *const [16:0]u8 = ".data/settings.z",

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
                if (std.mem.eql(u8, key, "volume")) {
                    var volume = std.fmt.parseInt(u8, parsed_value, 10) catch self.volume;
                    if (volume > 100) volume = 100;
                    self.volume = volume;
                }

                if (std.mem.eql(u8, key, "difficulty")) {
                    var difficulty = std.fmt.parseInt(u8, parsed_value, 10) catch self.difficulty;
                    if (difficulty > 3) difficulty = 3;
                    self.difficulty = difficulty;
                }
            }
        }
    }

    pub fn save(self: *Data, io: *std.Io) void {
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
        const volume = std.fmt.bufPrint(buffer[total_len..], "volume={d}\n", .{self.volume}) catch {
            return std.debug.print("Error: Failed to save settings data - write line\n", .{});
        };
        total_len += volume.len;
        const difficulty = std.fmt.bufPrint(buffer[total_len..], "difficulty={d}\n", .{self.difficulty}) catch {
            return std.debug.print("Error: Failed to save settings data - write line\n", .{});
        };
        total_len += difficulty.len;
        file.writePositionalAll(io.*, buffer[0..total_len], 0) catch {
            return std.debug.print("Error: Failed to save settings data - write file\n", .{});
        };
    }
};

pub fn saveDataOnThread(ctx: *anyopaque, io: *std.Io) void {
    const module: *Data = @ptrCast(@alignCast(ctx));
    module.save(io);
}
