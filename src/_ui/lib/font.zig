const rl = @import("raylib");

pub const Font = struct {
    size: i8 = 32,
    loaded: bool = true,
    line_height: i8 = 32,
    custom: ?rl.Font = null,

    pub fn clone(self: *Font) Font {
        if (self.custom) |f| {
            const cloned_font = rl.cloneFont(f);
            return Font{ .size = self.size, .loaded = true, .custom = cloned_font, .line_height = self.line_height };
        } else return Font{ .size = self.size, .loaded = false, .custom = null, .line_height = self.line_height };
    }

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
    const width = @as(f32, @floatFromInt(rl.measureText(text, @as(i32, fnt.line_height))));
    return rl.Vector2.init(width, @as(f32, fnt.size));
}
