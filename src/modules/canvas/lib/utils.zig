const std = @import("std");
const rl = @import("raylib");

const UI = @import("../../ui/root.zig").UI;
const Canvas = @import("../root.zig").Canvas;
const Camera = @import("../../camera/root.zig").Camera;
const InputHandler = @import("../../input_handler/root.zig").InputHandler;
const rotateVector = @import("../../../lib/utils.zig").rotateVector;

pub fn drawInfo(canvas: *Canvas, ui: *const UI, allocator: std.mem.Allocator, input_handler: *const InputHandler, camera: *const Camera) void {
    // Set initial padding and spacing
    var padding = rl.Vector2.init(16, 16);

    // Background
    ui.drawRect(
        rl.Rectangle.init(
            0,
            0,
            @as(f32, @floatFromInt(rl.getScreenWidth())),
            @as(f32, @floatFromInt(rl.getScreenHeight())),
        ),
        rl.Color.black.alpha(0.8),
    );

    // Intro Text
    ui.drawText("Canvas Info:", padding, null, rl.Color.white);
    padding.y += ui.font.size;
    padding.y += 16; // Extra spacing after title

    // Camera State
    const rect_title = "Canvas | Rectangle:";
    const rect_title_width = ui.font.measureText(rect_title, 16);
    ui.drawText(rect_title, padding, 16, rl.Color.white);
    const rect_string = std.fmt.allocPrint(
        allocator,
        "({d}, {d}, {d}, {d})",
        .{ canvas.rect.x, canvas.rect.y, canvas.rect.width, canvas.rect.height },
    ) catch "";
    padding.x += rect_title_width.x + 8;
    ui.drawText(rect_string, padding, 16, rl.Color.white);
    padding.x = 16;
    padding.y += 16;

    // Mouse Canvas Position
    const mouse_title = "Mouse | Canvas Position:";
    const mouse_title_width = ui.font.measureText(mouse_title, 16);
    const mouse_canvas_pos = translateWindowVectorToCanvasVector(input_handler.mouse.pos, camera);
    ui.drawText(mouse_title, padding, 16, rl.Color.white);
    const mouse_string = std.fmt.allocPrint(
        allocator,
        "({d}, {d})",
        .{ mouse_canvas_pos.x, mouse_canvas_pos.y },
    ) catch "";
    padding.x += mouse_title_width.x + 8;
    ui.drawText(mouse_string, padding, 16, rl.Color.white);
    padding.x = 16;
    padding.y += 16;

    // Selection state
    const selection_title = "Selection | Start:";
    const selection_title_width = ui.font.measureText(selection_title, 16);
    ui.drawText(selection_title, padding, 16, rl.Color.white);
    if (canvas.selection.start) |start| {
        const selection_start_string = std.fmt.allocPrint(allocator, "({d}, {d})", .{ start.x, start.y }) catch "";
        padding.x += selection_title_width.x + 8;
        ui.drawText(selection_start_string, padding, 16, rl.Color.white);
    }
    padding.x = 16;
    padding.y += 16;

    // Selection End
    const selection_end_title = "Selection | End:";
    const selection_end_title_width = ui.font.measureText(selection_end_title, 16);
    ui.drawText(selection_end_title, padding, 16, rl.Color.white);
    if (canvas.selection.end) |end| {
        const selection_end_string = std.fmt.allocPrint(allocator, "({d}, {d})", .{ end.x, end.y }) catch "";
        padding.x += selection_end_title_width.x + 8;
        ui.drawText(selection_end_string, padding, 16, rl.Color.white);
    }
    padding.x = 16;
    padding.y += 16;

    // Selection Rect
    const selection_rect_title = "Selection | Rect:";
    const selection_rect_title_width = ui.font.measureText(selection_rect_title, 16);
    ui.drawText(selection_rect_title, padding, 16, rl.Color.white);
    if (canvas.selection.rect) |rect| {
        const selection_rect_string = std.fmt.allocPrint(
            allocator,
            "({d}, {d}, {d}, {d})",
            .{ rect.x, rect.y, rect.width, rect.height },
        ) catch "";
        padding.x += selection_rect_title_width.x + 8;
        ui.drawText(selection_rect_string, padding, 16, rl.Color.white);
    }
    padding.x = 16;
    padding.y += 16;
}

pub fn translateWindowVectorToCanvasVector(v: rl.Vector2, camera: *const Camera) rl.Vector2 {
    var pos = v.subtract(camera.camera.offset);
    pos = rotateVector(pos, -camera.camera.rotation);
    pos = pos.scale(1.0 / camera.camera.zoom);
    return pos.add(camera.camera.target);
}
