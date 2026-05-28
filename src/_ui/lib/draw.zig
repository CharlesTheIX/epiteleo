const rl = @import("raylib");
const Font = @import("./font.zig").Font;

pub const DrawCircleProps = struct { radius: f32 = 16, color: rl.Color = .black, center: rl.Vector2 = .zero() };
pub fn drawCircle(props: DrawCircleProps) void {
    return rl.drawCircleV(props.center, props.radius, props.color);
}

pub const DrawGridProps = struct { rect: rl.Rectangle = .init(0, 0, 0, 0), gap: i8 = 16, color: rl.Color = .black };
pub fn drawGrid(props: DrawGridProps) void {
    const cols = @divFloor(@as(i32, @intFromFloat(props.rect.width)), props.gap);
    const rows = @divFloor(@as(i32, @intFromFloat(props.rect.height)), props.gap);
    for (0..@as(usize, @intCast(cols)) + 1) |col| {
        const x = @as(f32, @floatFromInt(@as(i32, @intCast(col)) * props.gap));
        const from = rl.Vector2{ .x = x, .y = 0 };
        const to = rl.Vector2{ .x = x, .y = props.rect.height };
        drawLine(.{ .from = from, .to = to, .color = props.color });
    }
    for (0..@as(usize, @intCast(rows)) + 1) |row| {
        const y = @as(f32, @floatFromInt(@as(i32, @intCast(row)) * props.gap));
        const from = rl.Vector2{ .x = 0, .y = y };
        const to = rl.Vector2{ .x = props.rect.width, .y = y };
        drawLine(.{ .from = from, .to = to, .color = props.color });
    }
    var from = rl.Vector2{ .x = 0, .y = props.rect.height };
    var to = rl.Vector2{ .x = props.rect.width, .y = props.rect.height };
    drawLine(.{ .from = from, .to = to, .color = props.color });
    from = rl.Vector2{ .x = props.rect.width, .y = 0 };
    to = rl.Vector2{ .x = props.rect.width, .y = props.rect.height };
    drawLine(.{ .from = from, .to = to, .color = props.color });
}

pub const DrawLineProps = struct { from: rl.Vector2 = .zero(), to: rl.Vector2 = .zero(), color: rl.Color = .black };
pub fn drawLine(props: DrawLineProps) void {
    const to_x = @as(i32, @intFromFloat(props.to.x));
    const to_y = @as(i32, @intFromFloat(props.to.y));
    const from_x = @as(i32, @intFromFloat(props.from.x));
    const from_y = @as(i32, @intFromFloat(props.from.y));
    rl.drawLine(from_x, from_y, to_x, to_y, props.color);
}

pub const DrawRectProps = struct { rect: rl.Rectangle = .init(0, 0, 0, 0), color: rl.Color = .black };
pub fn drawRect(props: DrawRectProps) void {
    rl.drawRectangleRec(props.rect, props.color);
}

pub const DrawTextProps = struct { font: Font = .{}, text: []const u8, color: rl.Color = .black, pos: rl.Vector2 = .zero() };
pub fn drawText(props: DrawTextProps) void {
    var buffer: [1024]u8 = undefined;
    if (props.text.len + 1 > buffer.len) return;
    @memcpy(buffer[0..props.text.len], props.text);
    buffer[props.text.len] = 0;
    const txt: [:0]const u8 = buffer[0..props.text.len :0];
    if (props.font.custom) |font| return rl.drawTextEx(
        font,
        txt,
        props.pos,
        @floatFromInt(props.font.size),
        0,
        props.color,
    );
    const i_x = @as(i32, @intFromFloat(props.pos.x));
    const i_y = @as(i32, @intFromFloat(props.pos.y));
    rl.drawText(txt, i_x, i_y, props.font.size, props.color);
}

pub const DrawTextureRectProps = struct {
    texture: rl.Texture2D,
    tint: rl.Color = .white,
    pos: rl.Vector2 = .zero(),
    rect: rl.Rectangle = .init(0, 0, 0, 0),
};
pub fn drawTextureRect(props: DrawTextureRectProps) void {
    rl.drawTextureRec(props.texture, props.rect, props.pos, props.tint);
}

pub const StrokeRectProps = struct { rect: rl.Rectangle = .init(0, 0, 0, 0), thickness: i8 = 0, color: rl.Color = .black };
pub fn strokeRect(props: StrokeRectProps) void {
    rl.drawRectangleLinesEx(props.rect, @as(f32, props.thickness), props.color);
}
