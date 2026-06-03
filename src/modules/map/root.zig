const std = @import("std");
const rl = @import("raylib");
const _ih = @import("../../_ih/root.zig");
const _ui = @import("../../_ui/root.zig");
const Camera = @import("../camera/root.zig").Camera;
const Player = @import("../player/root.zig").Player;
const Selection = @import("./lib/selection.zig").Selection;

pub const Map = struct {
    selection: Selection = .{},
    rect: rl.Rectangle = rl.Rectangle.init(0, 0, 0, 0),

    pub fn init() Map {
        return Map{};
    }

    pub fn deinit(self: *Map) void {
        std.debug.print("Map : Deinitializing...\n", .{});
        _ = self;
    }

    pub fn applyCollisions(self: Map, plr: *Player) void {
        if (plr.sprite.data.hitbox) |hb| {
            const origin = plr.sprite.data.sizeVector().scale(0.5);
            const rect = plr.sprite.data.hitboxRect(&plr.data.pos);
            const offset = rl.Vector2.init(@as(f32, @floatFromInt(hb[0])), @as(f32, @floatFromInt(hb[1])));
            if (rect.x - origin.x < self.rect.x) {
                plr.data.pos.x = self.rect.x + origin.x - offset.x;
                if (plr.body.velocity.x < 0) plr.body.velocity.x = 0;
                if (plr.body.acceleration.x < 0) plr.body.acceleration.x = 0;
            }
            if (rect.y - origin.y < self.rect.y) {
                plr.data.pos.y = self.rect.y + origin.y - offset.y;
                if (plr.body.velocity.y < 0) plr.body.velocity.y = 0;
                if (plr.body.acceleration.y < 0) plr.body.acceleration.y = 0;
            }
            if (rect.x + rect.width - origin.x > self.rect.width) {
                plr.data.pos.x = self.rect.width - rect.width - offset.x + origin.x;
                if (plr.body.velocity.x > 0) plr.body.velocity.x = 0;
                if (plr.body.acceleration.x > 0) plr.body.acceleration.x = 0;
            }
            if (rect.y + rect.height - origin.y > self.rect.height) {
                plr.data.pos.y = self.rect.height - rect.height - offset.y + origin.y;
                if (plr.body.velocity.y > 0) plr.body.velocity.y = 0;
                if (plr.body.acceleration.y > 0) plr.body.acceleration.y = 0;
            }
        }
    }

    pub fn draw(self: *Map) void {
        _ui.drawRect(.{ .rect = self.rect, .color = rl.Color.orange.alpha(0.5) });
        _ui.drawGrid(.{ .rect = self.rect, .gap = 32, .color = rl.Color.gray.alpha(0.5) });
        self.selection.draw();
    }

    pub fn load(self: *Map, rect: rl.Rectangle) void {
        std.debug.print("Map : Loading map...\n", .{});
        self.selection.reset();
        self.rect = rect;
    }

    pub fn update(self: *Map, ih: *_ih.InputHandler, camera: *Camera) void {
        self.selection.update(ih, camera);
    }
};
