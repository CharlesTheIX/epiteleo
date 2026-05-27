const std = @import("std");
const rl = @import("raylib");

pub const Resources = struct {
    texture: ?rl.Texture2D = null,

    pub fn deinit(self: *Resources) void {
        if (self.texture) |texture| {
            rl.unloadTexture(texture);
            self.texture = null;
        }
    }

    pub fn load(self: *Resources) void {
        const img = rl.loadImage("src/assets/screens/intro_screen.png") catch return;
        defer rl.unloadImage(img);
        const texture = rl.loadTextureFromImage(img) catch return;
        self.texture = texture;
    }
};
