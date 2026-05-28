const rl = @import("raylib");

pub const init_screen_h = 540;

pub const init_screen_w = 960;

pub fn initScreenRect() rl.Rectangle {
    const screen_w = @as(f32, @floatFromInt(rl.getScreenWidth()));
    const screen_h = @as(f32, @floatFromInt(rl.getScreenHeight()));
    const screen_c = rl.Vector2.init(screen_w, screen_h).scale(0.5);
    const init_screen_c = rl.Vector2.init(init_screen_w, init_screen_h).scale(0.5);
    return rl.Rectangle{ .width = init_screen_w, .height = init_screen_h, .x = screen_c.x - init_screen_c.x, .y = screen_c.y - init_screen_c.y };
}
