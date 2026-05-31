const std = @import("std");
const _ah = @import("../../_ah/root.zig");
const PlayerData = @import("../player/lib/data.zig").Data;

pub const Data = struct {
    player: ?PlayerData = null,

    pub fn load(self: *Data, io: *std.Io) void {
        std.debug.print("Game Data : Loading game data...\n", .{});
        if (self.player) |player| player.load(io);
    }

    pub fn save(self: *Data, io: *std.Io) void {
        std.debug.print("Game Data : Saving game data...\n", .{});
        if (self.player) |player| player.save(io);
    }
};

pub fn saveDataOnThread(ctx: *anyopaque, io: *std.Io, ah: *_ah.AudioHandler) void {
    _ = ah;
    const module: *Data = @ptrCast(@alignCast(ctx));
    module.save(io);
}
