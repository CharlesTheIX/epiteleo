const std = @import("std");
const rl = @import("raylib");
const _utils = @import("../../utils.zig");
const Data = @import("./lib/data.zig").Data;
const _ih = @import("../input_handler/root.zig");
const Sprite = @import("../sprite/root.zig").Sprite;

pub const Player = struct {
    data: Data = .{},
    speed: f32 = 2.0,
    texture: ?rl.Texture2D = null,
    sprite: Sprite = .init(.AnimalBoar, .Right, .Walk),
    // inventory: Inventory,

    pub fn init() Player {
        return .{};
    }

    pub fn deinit(self: *Player) void {
        self.sprite.deinit();
        if (self.texture) |texture| {
            rl.unloadTexture(texture);
            self.texture = null;
        }
    }

    pub fn draw(self: *Player) void {
        self.sprite.draw(&self.data.pos, rl.Color.white);
    }

    pub fn focus(self: *Player) void {
        self.sprite.focalPoint(self.data.pos);
    }

    pub fn load(self: *Player, io: *std.Io) void {
        self.data.load(io);
        std.debug.print("Drawing player load: {any}\n", .{self.texture});
        const img = rl.loadImage("assets/screens/player_screen.png") catch return;
        defer rl.unloadImage(img);
        const texture = rl.loadTextureFromImage(img) catch return;
        self.texture = texture;
        if (self.texture) |*txt| self.sprite.load(txt, io);
    }

    pub fn save(self: *Player, io: *std.Io) void {
        self.data.save(io);
    }

    pub fn update(self: *Player, camera: *rl.Camera2D, ih: *_ih.InputHandler) void {
        self.sprite.update();
        self.updateFromInput(camera, ih);
    }

    fn updateFromInput(self: *Player, camera: *rl.Camera2D, ih: *_ih.InputHandler) void {
        _ = camera;
        var speed = self.speed;
        const kb = ih.keyboard;
        var movement = rl.Vector2.zero();
        if (kb.activeKeysInclude(&[_]_ih.Key{ .LeftShift, .RightShift }, .Or)) speed *= 4;
        if (kb.activeKeysInclude(&[_]_ih.Key{ .W, .Up }, .Or)) movement.y -= 1;
        if (kb.activeKeysInclude(&[_]_ih.Key{ .S, .Down }, .Or)) movement.y += 1;
        if (kb.activeKeysInclude(&[_]_ih.Key{ .A, .Left }, .Or)) movement.x -= 1;
        if (kb.activeKeysInclude(&[_]_ih.Key{ .D, .Right }, .Or)) movement.x += 1;
        if (movement.x == 0 and movement.y == 0) return;
        // movement = _utils.rotateVector(movement, -camera.rotation);
        // movement = movement.scale(speed / camera.zoom);
        self.data.pos = self.data.pos.add(movement);
    }
};
