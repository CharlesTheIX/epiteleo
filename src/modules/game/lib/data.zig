const std = @import("std");
const PlayerData = @import("../player/lib/data.zig").Data;

pub const Data = struct {
    player: ?PlayerData = null,

    pub fn load(self: *Data, io: *std.Io) void {
        if (self.player) |player| player.load(io);
    }

    pub fn save(self: *Data, io: *std.Io) void {
        if (self.player) |player| player.save(io);
    }
};

pub fn saveDataOnThread(ctx: *anyopaque, io: *std.Io) void {
    const module: *Data = @ptrCast(@alignCast(ctx));
    module.save(io);
}
