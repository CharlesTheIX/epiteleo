const std = @import("std");
const rl = @import("raylib");
const Sprite = @import("../../sprite/root.zig").Sprite;

pub const Resources = struct {
    texture: ?rl.Texture2D = null,
    sprite: Sprite = .init(.AnimalBoar, .Right, .Walk),

    pub fn deinit(self: *Resources) void {
        self.sprite.deinit();
        if (self.texture) |texture| {
            rl.unloadTexture(texture);
            self.texture = null;
        }
    }

    pub fn load(self: *Resources, io: *std.Io) void {
        const img = rl.loadImage("src/assets/screens/loading_screen.png") catch return;
        defer rl.unloadImage(img);
        const texture = rl.loadTextureFromImage(img) catch return;
        self.texture = texture;
        if (self.texture) |*txt| self.sprite.load(txt, io);
    }
};
