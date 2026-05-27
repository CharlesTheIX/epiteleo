const std = @import("std");
const rl = @import("raylib");
const App = @import("../../../root.zig").App;
const windowVectorToCameraVector = @import("../../../utils.zig").windowVectorToCameraVector;

pub fn drawCanvasInfo(app: *App) void {
    var padding = rl.Vector2.init(16, 16);
    app.ui.drawRect(
        rl.Rectangle.init(
            0,
            0,
            @as(f32, @floatFromInt(rl.getScreenWidth())),
            @as(f32, @floatFromInt(rl.getScreenHeight())),
        ),
        rl.Color.black.alpha(0.8),
    );

    // Intro Text
    app.ui.drawText("Canvas Info:", padding, null, rl.Color.white);
    padding.y += app.ui.font.size;
    padding.y += 16; // Extra spacing after title

    // Camera State
    const rect_title = "Canvas | Rectangle:";
    const rect_title_width = app.ui.font.measureText(rect_title, 16);
    app.ui.drawText(rect_title, padding, 16, rl.Color.white);
    const rect_string = std.fmt.allocPrint(
        app.allocator,
        "({d}, {d}, {d}, {d})",
        .{ app.canvas.rect.x, app.canvas.rect.y, app.canvas.rect.width, app.canvas.rect.height },
    ) catch "";
    padding.x += rect_title_width.x + 8;
    app.ui.drawText(rect_string, padding, 16, rl.Color.white);
    padding.x = 16;
    padding.y += 16;

    // Mouse Canvas Position
    const mouse_title = "Mouse | Canvas Position:";
    const mouse_title_width = app.ui.font.measureText(mouse_title, 16);
    const mouse_canvas_pos = windowVectorToCameraVector(app.input_handler.mouse.pos, &app.camera);
    app.ui.drawText(mouse_title, padding, 16, rl.Color.white);
    const mouse_string = std.fmt.allocPrint(
        app.allocator,
        "({d}, {d})",
        .{ mouse_canvas_pos.x, mouse_canvas_pos.y },
    ) catch "";
    padding.x += mouse_title_width.x + 8;
    app.ui.drawText(mouse_string, padding, 16, rl.Color.white);
    padding.x = 16;
    padding.y += 16;

    // Selection state
    const selection_title = "Selection | Start:";
    const selection_title_width = app.ui.font.measureText(selection_title, 16);
    app.ui.drawText(selection_title, padding, 16, rl.Color.white);
    if (app.canvas.selection.start) |start| {
        const selection_start_string = std.fmt.allocPrint(app.allocator, "({d}, {d})", .{ start.x, start.y }) catch "";
        padding.x += selection_title_width.x + 8;
        app.ui.drawText(selection_start_string, padding, 16, rl.Color.white);
    }
    padding.x = 16;
    padding.y += 16;

    // Selection End
    const selection_end_title = "Selection | End:";
    const selection_end_title_width = app.ui.font.measureText(selection_end_title, 16);
    app.ui.drawText(selection_end_title, padding, 16, rl.Color.white);
    if (app.canvas.selection.end) |end| {
        const selection_end_string = std.fmt.allocPrint(app.allocator, "({d}, {d})", .{ end.x, end.y }) catch "";
        padding.x += selection_end_title_width.x + 8;
        app.ui.drawText(selection_end_string, padding, 16, rl.Color.white);
    }
    padding.x = 16;
    padding.y += 16;

    // Selection Rect
    const selection_rect_title = "Selection | Rect:";
    const selection_rect_title_width = app.ui.font.measureText(selection_rect_title, 16);
    app.ui.drawText(selection_rect_title, padding, 16, rl.Color.white);
    if (app.canvas.selection.rect) |rect| {
        const selection_rect_string = std.fmt.allocPrint(
            app.allocator,
            "({d}, {d}, {d}, {d})",
            .{ rect.x, rect.y, rect.width, rect.height },
        ) catch "";
        padding.x += selection_rect_title_width.x + 8;
        app.ui.drawText(selection_rect_string, padding, 16, rl.Color.white);
    }
    padding.x = 16;
    padding.y += 16;
}
