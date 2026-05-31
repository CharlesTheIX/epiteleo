const std = @import("std");
const rl = @import("raylib");

pub const Resources = struct {
    texture: ?rl.Texture2D = null,

    pub fn deinit(self: *Resources) void {
        std.debug.print("Intro Resources : Deinitializing...\n", .{});
        if (self.texture) |texture| {
            rl.unloadTexture(texture);
            self.texture = null;
        }
    }

    pub fn load(self: *Resources) void {
        std.debug.print("Intro Resources : Loading resources...\n", .{});
        if (self.texture) |texture| {
            rl.unloadTexture(texture);
            self.texture = null;
        }
        const img = rl.loadImage("assets/screens/intro_screen.png") catch return;
        defer rl.unloadImage(img);
        const texture = rl.loadTextureFromImage(img) catch return;
        self.texture = texture;
    }
};
