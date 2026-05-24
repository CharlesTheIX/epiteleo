const std = @import("std");

pub const StateOptions = struct {
    fps: u8 = 0,
    max_v: u8 = 0,
    cool_down: u16 = 0,
    max_frames: u4 = 0,

    pub fn load(value: []const u8) StateOptions {
        var state_options = StateOptions{};
        var opts_it = std.mem.splitSequence(u8, value, ";");
        while (opts_it.next()) |opt| {
            var opt_split = std.mem.splitSequence(u8, opt, "=");
            const key = std.mem.trim(u8, opt_split.first(), " \t\r");
            if (opt_split.next()) |o| {
                const parsed_value = std.mem.trim(u8, o, " \t\r");
                if (std.mem.eql(u8, key, "fps")) {
                    const fps = std.fmt.parseInt(u8, parsed_value, 10) catch continue;
                    state_options.fps = fps;
                    continue;
                }
                if (std.mem.eql(u8, key, "max_v")) {
                    const max_v = std.fmt.parseInt(u8, parsed_value, 10) catch continue;
                    state_options.max_v = max_v;
                    continue;
                }
                if (std.mem.eql(u8, key, "max_frames")) {
                    const max_frames = std.fmt.parseInt(u4, parsed_value, 10) catch continue;
                    state_options.max_frames = max_frames;
                    continue;
                }
                if (std.mem.eql(u8, key, "cool_down")) {
                    const cool_down = std.fmt.parseInt(u4, parsed_value, 10) catch continue;
                    state_options.cool_down = cool_down;
                    continue;
                }
            }
        }
        return state_options;
    }
};
