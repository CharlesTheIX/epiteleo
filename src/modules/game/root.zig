const std = @import("std");
const rl = @import("raylib");
const _ui = @import("../../_ui/root.zig");
const _ih = @import("../input_handler/root.zig");
const Timer = @import("../timer/root.zig").Timer;
const Player = @import("../player/root.zig").Player;

pub const Game = struct {
    // map: Map = .{},
    player: Player = .{},
    new_game: bool = false,
    state: State = .Playing,
    fade_in_timer: Timer = .init(0.5),

    pub fn init() Game {
        return .{};
    }

    pub fn deinit(self: *Game) void {
        self.player.deinit();
    }

    pub fn draw(self: *Game) void {
        var alpha: f32 = 1.0;
        if (self.fade_in_timer.is_active) alpha = 1.0 - self.fade_in_timer.value_ms / self.fade_in_timer.initial_value_ms;
        switch (self.state) {
            .Playing => {
                const screen_w = @as(f32, @floatFromInt(rl.getScreenWidth()));
                const screen_h = @as(f32, @floatFromInt(rl.getScreenHeight()));
                _ui.drawRect(.{
                    .color = rl.Color.black.alpha(alpha),
                    .rect = .init(0, 0, screen_w, screen_h),
                });
                // const tint = rl.Color.white.alpha(alpha);
                self.player.draw();
            },
            else => return,
        }
    }

    pub fn load(self: *Game, io: *std.Io) void {
        self.fade_in_timer.is_active = true;
        if (self.new_game) self.player.save(io);
        self.player.load(io);
    }

    pub fn update(self: *Game, camera: *rl.Camera2D, ih: *_ih.InputHandler) void {
        if (self.fade_in_timer.is_active) return self.fade_in_timer.update();
        switch (self.state) {
            .Playing => self.player.update(camera, ih),
            else => return,
        }
    }
};

pub fn loadGameTask(ctx: *anyopaque, io: *std.Io) void {
    const module: *Game = @ptrCast(@alignCast(ctx));
    module.load(io);
}

pub const State = enum {
    Playing,
    Paused,
    Inventory,
    Map,
    Journal,
    Settings,

    pub fn toString(self: State) []const u8 {
        return switch (self) {
            .Playing => "Playing",
            .Paused => "Paused",
            .Inventory => "Inventory",
            .Map => "Map",
            .Journal => "Journal",
            .Settings => "Settings",
        };
    }

    pub fn fromInt(raw: u8) State {
        return switch (raw) {
            0 => .Playing,
            1 => .Paused,
            2 => .Inventory,
            3 => .Map,
            4 => .Journal,
            5 => .Settings,
            else => .Playing,
        };
    }
    pub fn toInt(self: State) u8 {
        return @intFromBool(self);
    }
};
