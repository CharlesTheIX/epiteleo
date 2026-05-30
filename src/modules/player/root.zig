const std = @import("std");
const Data = @import("./lib/data.zig").Data;

pub const Player = struct {
    data: Data = .{},
    // sprite: Sprite,
    // inventory: Inventory,

    pub fn init() Player {
        return .{};
    }

    pub fn deinit(self: *Player) void {
        _ = self;
    }

    pub fn draw(self: *Player) void {
        _ = self;
    }

    pub fn load(self: *Player, io: *std.Io) void {
        self.data.load(io);
    }

    pub fn save(self: *Player, io: *std.Io) void {
        self.data.save(io);
    }

    pub fn update(self: *Player) void {
        _ = self;
    }
};
