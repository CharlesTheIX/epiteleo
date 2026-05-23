const rl = @import("raylib");
const Font = @import("./lib/font.zig").Font;

pub const UI = struct {
    font: Font = .{},

    pub fn init() UI {
        return UI{};
    }

    pub fn deinit(self: *UI) void {
        self.font.deinit();
    }

    pub fn drawCircle(self: UI, center: rl.Vector2, radius: f32, color: rl.Color) void {
        _ = self; // Avoid unused parameter warning
        rl.drawCircleV(center, radius, color);
    }

    pub fn drawRect(self: UI, rect: rl.Rectangle, color: rl.Color) void {
        _ = self; // Avoid unused parameter warning
        rl.drawRectangleRec(rect, color);
    }

    pub fn drawText(self: UI, text: []const u8, pos: rl.Vector2, font_size: ?i32, color: ?rl.Color) void {
        var buffer: [1024]u8 = undefined;
        if (text.len + 1 > buffer.len) return; // Avoid overflow
        const size = if (font_size) |s| s else @as(i32, self.font.size);
        const clr = if (color) |c| c else rl.Color.black;
        @memcpy(buffer[0..text.len], text);
        buffer[text.len] = 0;
        const txt: [:0]const u8 = buffer[0..text.len :0];
        if (self.font.custom) |font| {
            return rl.drawTextEx(font, txt, pos, @floatFromInt(size), 0, clr);
        }
        rl.drawText(txt, @as(i32, @intFromFloat(pos.x)), @as(i32, @intFromFloat(pos.y)), size, clr);
    }

    pub fn drawTexture(self: UI, texture: rl.Texture2D, src_rect: rl.Rectangle, pos: rl.Vector2, color: ?rl.Color) void {
        _ = self; // Avoid unused parameter warning
        const clr = if (color) |c| c else rl.Color.white;
        rl.drawTextureRec(texture, src_rect, pos, clr);
    }

    pub fn load(self: *UI) void {
        self.font.load();
    }
};
