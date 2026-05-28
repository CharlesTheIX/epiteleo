const rl = @import("raylib");

pub const Font = struct {
    size: i8 = 32,
    loaded: bool = true,
    custom: ?rl.Font = null,

    pub fn deinit(self: *Font) void {
        if (self.loaded) rl.unloadFont(self.custom.?);
    }

    pub fn load(self: *Font) void {
        self.loaded = false;
        self.custom = rl.loadFontEx("assets/fonts/JetBrains.ttf", @as(i32, self.size), null) catch null;
        if (self.custom == null) return;
        self.loaded = true;
    }
};

pub fn measureText(text: [:0]const u8, font: ?Font) rl.Vector2 {
    const fnt: Font = if (font) |f| f else .{};
    if (fnt.custom) |f| return rl.measureTextEx(f, text, fnt.size, 0);
    const width = @as(f32, @floatFromInt(rl.measureText(text, @as(i32, fnt.size))));
    return rl.Vector2.init(width, @as(f32, fnt.size));
}
