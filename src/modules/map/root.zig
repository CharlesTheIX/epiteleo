const std = @import("std");
const rl = @import("raylib");
const _ih = @import("../../_ih/root.zig");
const _ui = @import("../../_ui/root.zig");
const Camera = @import("../camera/root.zig").Camera;
const Player = @import("../player/root.zig").Player;
const Selection = @import("./lib/selection.zig").Selection;
const loadData = @import("./lib/data.zig").loadData;

pub const Map = struct {
    selection: Selection = .{},
    allocator: std.mem.Allocator,
    collisions: []const rl.Rectangle = &.{},
    rect: rl.Rectangle = rl.Rectangle.init(0, 0, 0, 0),

    pub fn init(allocator: std.mem.Allocator) Map {
        std.debug.print("Map : Initializing...\n", .{});
        return Map{ .allocator = allocator };
    }

    pub fn deinit(self: *Map) void {
        std.debug.print("Map : Deinitializing...\n", .{});
        self.clearCollisions();
    }

    fn setCollisions(self: *Map, collisions: []const rl.Rectangle) void {
        self.clearCollisions();
        if (collisions.len == 0) return;
        const owned = self.allocator.alloc(rl.Rectangle, collisions.len) catch return;
        @memcpy(owned, collisions);
        self.collisions = owned;
    }

    pub fn applyCollisions(self: Map, plr: *Player) void {
        self.applyBorderCollision(plr);
        plr.applyRectCollisions(&self.collisions);
    }

    fn applyBorderCollision(self: Map, plr: *Player) void {
        var hitbox_rect = plr.sprite.data.hitboxRect(&plr.pos);
        if (hitbox_rect.width == 0 or hitbox_rect.height == 0) return;
        const origin = plr.sprite.data.originVector();
        const hitbox_offset = plr.sprite.data.hitboxOffset();
        hitbox_rect.x -= origin.x;
        hitbox_rect.y -= origin.y;
        if (hitbox_rect.x < self.rect.x) {
            plr.pos.x = self.rect.x + origin.x - hitbox_offset.x;
            if (plr.body.velocity.x < 0) plr.body.velocity.x = 0;
            if (plr.body.acceleration.x < 0) plr.body.acceleration.x = 0;
        }
        if (hitbox_rect.y < self.rect.y) {
            plr.pos.y = self.rect.y + origin.y - hitbox_offset.y;
            if (plr.body.velocity.y < 0) plr.body.velocity.y = 0;
            if (plr.body.acceleration.y < 0) plr.body.acceleration.y = 0;
        }
        if (hitbox_rect.x + hitbox_rect.width > self.rect.width) {
            plr.pos.x = self.rect.width - hitbox_rect.width - hitbox_offset.x + origin.x;
            if (plr.body.velocity.x > 0) plr.body.velocity.x = 0;
            if (plr.body.acceleration.x > 0) plr.body.acceleration.x = 0;
        }
        if (hitbox_rect.y + hitbox_rect.height > self.rect.height) {
            plr.pos.y = self.rect.height - hitbox_rect.height - hitbox_offset.y + origin.y;
            if (plr.body.velocity.y > 0) plr.body.velocity.y = 0;
            if (plr.body.acceleration.y > 0) plr.body.acceleration.y = 0;
        }
    }

    fn clearCollisions(self: *Map) void {
        self.allocator.free(@constCast(self.collisions));
        self.collisions = &.{};
    }

    pub fn draw(self: *Map) void {
        _ui.drawRect(.{ .rect = self.rect, .color = rl.Color.orange.alpha(0.5) });
        _ui.drawGrid(.{ .rect = self.rect, .gap = 32, .color = rl.Color.gray.alpha(0.5) });
        self.drawCollisions();
        self.selection.draw();
    }

    fn drawCollisions(self: *Map) void {
        for (self.collisions) |col| _ui.drawRect(.{ .rect = col, .color = rl.Color.red.alpha(0.5) });
    }

    pub fn load(self: *Map, rect: rl.Rectangle) void {
        std.debug.print("Map : Loading...\n", .{});
        self.rect = rect;
        self.clearCollisions();
        self.selection.reset();
        self.setCollisions(
            &.{.init(32, 64, 96, 64)},
        );
    }

    pub fn update(self: *Map, ih: *_ih.InputHandler, camera: *Camera) void {
        self.selection.update(ih, camera);
    }
};
