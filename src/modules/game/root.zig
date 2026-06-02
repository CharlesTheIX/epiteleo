const std = @import("std");
const rl = @import("raylib");
const _ah = @import("../../_ah/root.zig");
const _ih = @import("../../_ih/root.zig");
const _ui = @import("../../_ui/root.zig");
const Map = @import("../map/root.zig").Map;
// const Npc = @import("../npc/root.zig").Npc;
// const Item  = @import("../item/root.zig").Item;
// const Quest = @import("../quest/root.zig").Quest;
const Timer = @import("../timer/root.zig").Timer;
// const Enemy = @import("../enemy/root.zig").Enemy;
const Player = @import("../player/root.zig").Player;

pub const Game = struct {
    map: Map = .init(),
    player: Player = .{},
    new_game: bool = false,
    state: State = .Playing,
    // npcs: []Npc = &[_]Npc{},
    // items: []Item = &[_]Item{},
    // quests: []Quest = &[_]Quest{},
    // enemies: []Enemy = &[_]Enemy{},
    fade_in_timer: Timer = .init(0.5),

    pub fn init() Game {
        return .{};
    }

    pub fn deinit(self: *Game) void {
        std.debug.print("Game : Deinitializing...\n", .{});
        self.player.deinit();
    }

    pub fn draw(self: *Game) void {
        var alpha: f32 = 1.0;
        if (self.fade_in_timer.is_active) alpha = 1.0 - self.fade_in_timer.value_ms / self.fade_in_timer.initial_value_ms;
        switch (self.state) {
            .Playing => {
                const tint = rl.Color.white.alpha(alpha);
                self.map.draw();
                self.player.draw(tint);
            },
            else => return,
        }
    }

    pub fn load(self: *Game, io: *std.Io) void {
        std.debug.print("Game : Loading game data...\n", .{});
        self.fade_in_timer.is_active = true;
        if (self.new_game) self.player.save(io);
        if (self.player.texture) |texture| {
            rl.unloadTexture(texture);
            self.player.texture = null;
        }
        const img = rl.loadImage("assets/data/screens/player_screen.png") catch return;
        const texture = rl.loadTextureFromImage(img) catch return;
        defer rl.unloadImage(img);
        self.player.texture = texture;
        self.player.load(&self.player.texture, io);
        const screen_w = @as(f32, @floatFromInt(rl.getScreenWidth()));
        const screen_h = @as(f32, @floatFromInt(rl.getScreenHeight()));
        self.map.rect = rl.Rectangle.init(0, 0, screen_w * 2, screen_h * 2);
    }

    pub fn resize(self: *Game) void {
        _ = self;
    }

    pub fn update(self: *Game, ih: *_ih.InputHandler) void {
        if (self.fade_in_timer.is_active) return self.fade_in_timer.update();
        switch (self.state) {
            .Playing => {
                self.player.update(ih);
                self.map.applyCollisions(&self.player);
            },
            else => return,
        }
    }
};

pub fn loadGameTask(ctx: *anyopaque, io: *std.Io, ah: *_ah.AudioHandler) void {
    _ = ah;
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
