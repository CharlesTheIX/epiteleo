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
        _ = self;
        rl.drawCircleV(center, radius, color);
    }

    pub fn drawGrid(self: UI, rect: rl.Rectangle, gap: i8, color: ?rl.Color) void {
        const clr = if (color) |c| c else rl.Color.black.alpha(0.8);
        const cols = @divFloor(@as(i32, @intFromFloat(rect.width)), gap);
        const rows = @divFloor(@as(i32, @intFromFloat(rect.height)), gap);
        for (0..@as(usize, @intCast(cols)) + 1) |col| {
            const x = @as(f32, @floatFromInt(@as(i32, @intCast(col)) * gap));
            const from = rl.Vector2{ .x = x, .y = 0 };
            const to = rl.Vector2{ .x = x, .y = rect.height };
            self.drawLine(from, to, clr);
        }
        for (0..@as(usize, @intCast(rows)) + 1) |row| {
            const y = @as(f32, @floatFromInt(@as(i32, @intCast(row)) * gap));
            const from = rl.Vector2{ .x = 0, .y = y };
            const to = rl.Vector2{ .x = rect.width, .y = y };
            self.drawLine(from, to, clr);
        }
        var from = rl.Vector2{ .x = 0, .y = rect.height };
        var to = rl.Vector2{ .x = rect.width, .y = rect.height };
        self.drawLine(from, to, clr);
        from = rl.Vector2{ .x = rect.width, .y = 0 };
        to = rl.Vector2{ .x = rect.width, .y = rect.height };
        self.drawLine(from, to, clr);
    }

    pub fn drawLine(self: UI, from: rl.Vector2, to: rl.Vector2, color: rl.Color) void {
        _ = self;
        const to_x = @as(i32, @intFromFloat(to.x));
        const to_y = @as(i32, @intFromFloat(to.y));
        const from_x = @as(i32, @intFromFloat(from.x));
        const from_y = @as(i32, @intFromFloat(from.y));
        rl.drawLine(from_x, from_y, to_x, to_y, color);
    }

    pub fn drawRect(self: UI, rect: rl.Rectangle, color: rl.Color) void {
        _ = self;
        rl.drawRectangleRec(rect, color);
    }

    pub fn drawText(self: UI, text: []const u8, pos: rl.Vector2, font_size: ?i32, color: ?rl.Color) void {
        var buffer: [1024]u8 = undefined;
        if (text.len + 1 > buffer.len) return;
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
        _ = self;
        const clr = if (color) |c| c else rl.Color.white;
        rl.drawTextureRec(texture, src_rect, pos, clr);
    }

    pub fn defaultRect(self: *UI) rl.Rectangle {
        _ = self;
        const rect_w = 960;
        const rect_h = 540;
        const window_w = rl.getScreenWidth();
        const window_h = rl.getScreenHeight();
        const rect_c = rl.Vector2.init(@as(f32, rect_w), @as(f32, rect_h)).scale(0.5);
        const window_c = rl.Vector2.init(@as(f32, @floatFromInt(window_w)), @as(f32, @floatFromInt(window_h))).scale(0.5);
        return rl.Rectangle{
            .width = @as(f32, rect_w),
            .height = @as(f32, rect_h),
            .x = window_c.x - rect_c.x,
            .y = window_c.y - rect_c.y,
        };
    }

    pub fn load(self: *UI) void {
        self.font.load();
    }
};
