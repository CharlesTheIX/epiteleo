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
        var collision: bool = false;
        var v = rl.Vector2.zero();
        const hitbox = plr.sprite.data.hitboxRect(&v);
        if (hitbox.x + plr.data.pos.x < self.rect.x) {
            collision = true;
            plr.data.pos.x = self.rect.x - hitbox.x;
        }
        if (hitbox.y + plr.data.pos.y < self.rect.y) {
            collision = true;
            plr.data.pos.y = self.rect.y - hitbox.y;
        }
        if (hitbox.x + hitbox.width + plr.data.pos.x > self.rect.width) {
            collision = true;
            plr.data.pos.x = self.rect.width - hitbox.width - hitbox.x;
        }
        if (hitbox.y + hitbox.height + plr.data.pos.y > self.rect.height) {
            collision = true;
            plr.data.pos.y = self.rect.height - hitbox.height - hitbox.y;
        }
        if (collision) {
            plr.body.velocity = .zero();
            plr.body.acceleration = .zero();
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
