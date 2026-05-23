const rl = @import("raylib");

pub const Font = struct {
    size: i8 = 32,
    loaded: bool = false,
    custom: ?rl.Font = null,

    pub fn deinit(self: *Font) void {
        if (self.loaded) rl.unloadFont(self.custom.?);
    }

    pub fn load(self: *Font) void {
        self.size = 32;
        self.custom = rl.loadFontEx("src/assets/fonts/JetBrains.ttf", @as(i32, self.size), null) catch null;
        if (self.custom == null) return;
        self.loaded = true;
    }

    pub fn measureText(self: Font, text: [:0]const u8) rl.Vector2 {
        if (self.custom) |font| return rl.measureTextEx(font, text, @as(f32, self.size), 0);
        const v = rl.Vector2.init(@floatFromInt(rl.measureText(text, @as(i32, self.size))), @as(f32, self.size));
        return v;
    }
};
