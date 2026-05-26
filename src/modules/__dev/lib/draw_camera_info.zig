const std = @import("std");
const rl = @import("raylib");
const App = @import("../../../root.zig").App;

pub fn drawCameraInfo(app: *App) void {
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
    app.ui.drawText("Camera Info:", padding, null, rl.Color.white);
    padding.y += app.ui.font.size;
    padding.y += 16; // Extra spacing after title

    // Note Text
    app.ui.drawText("Press .Zero (0) to cycle through camera states", padding, 16, rl.Color.white);
    padding.y += 16;
    app.ui.drawText("Press .Nine (9) to toggle snap to canvas", padding, 16, rl.Color.white);
    padding.y += 16;
    padding.y += 16; // Extra spacing after note

    // Camera State
    const state_title = "Camera | State:";
    const state_title_width = app.ui.font.measureText(state_title, 16);
    app.ui.drawText(state_title, padding, 16, rl.Color.white);
    const state_string = app.camera.state.toString();
    padding.x += state_title_width.x + 8;
    app.ui.drawText(state_string, padding, 16, rl.Color.white);
    padding.x = 16;
    padding.y += 16;

    // Snaps to Canvas
    const snap_to_canvas_title = "Camera | Snaps to Canvas:";
    const snap_to_canvas_title_width = app.ui.font.measureText(snap_to_canvas_title, 16);
    app.ui.drawText(snap_to_canvas_title, padding, 16, rl.Color.white);
    const snap_to_canvas_string = if (app.camera.snap_to_canvas) "True" else "False";
    padding.x += snap_to_canvas_title_width.x + 8;
    app.ui.drawText(snap_to_canvas_string, padding, 16, rl.Color.white);
    padding.x = 16;
    padding.y += 16;

    // Camera Zoom
    const camera_zoom_title = "Camera | Zoom:";
    const camera_zoom_title_width = app.ui.font.measureText(camera_zoom_title, 16);
    app.ui.drawText(camera_zoom_title, padding, 16, rl.Color.white);
    const camera_zoom_string = std.fmt.allocPrint(app.allocator, "{d}", .{app.camera.camera.zoom}) catch "";
    padding.x += camera_zoom_title_width.x + 8;
    app.ui.drawText(camera_zoom_string, padding, 16, rl.Color.white);
    padding.x = 16;
    padding.y += 16;

    // Camera Rotation
    const camera_rotation_title = "Camera | Rotation:";
    const camera_rotation_title_width = app.ui.font.measureText(camera_rotation_title, 16);
    app.ui.drawText(camera_rotation_title, padding, 16, rl.Color.white);
    const camera_rotation_string = std.fmt.allocPrint(app.allocator, "{d}", .{app.camera.camera.rotation}) catch "";
    padding.x += camera_rotation_title_width.x + 8;
    app.ui.drawText(camera_rotation_string, padding, 16, rl.Color.white);
    padding.x = 16;
    padding.y += 16;

    // Camera Target
    const camera_target_title = "Camera | Target:";
    const camera_target_title_width = app.ui.font.measureText(camera_target_title, 16);
    app.ui.drawText(camera_target_title, padding, 16, rl.Color.white);
    const camera_target_string = std.fmt.allocPrint(
        app.allocator,
        "({d}, {d})",
        .{ app.camera.camera.target.x, app.camera.camera.target.y },
    ) catch "";
    padding.x += camera_target_title_width.x + 8;
    app.ui.drawText(camera_target_string, padding, 16, rl.Color.white);
    padding.x = 16;
    padding.y += 16;

    // Camera Offset
    const camera_offset_title = "Camera | Offset:";
    const camera_offset_title_width = app.ui.font.measureText(camera_offset_title, 16);
    app.ui.drawText(camera_offset_title, padding, 16, rl.Color.white);
    const camera_offset_string = std.fmt.allocPrint(
        app.allocator,
        "({d}, {d})",
        .{ app.camera.camera.offset.x, app.camera.camera.offset.y },
    ) catch "";
    padding.x += camera_offset_title_width.x + 8;
    app.ui.drawText(camera_offset_string, padding, 16, rl.Color.white);
    padding.x = 16;
    padding.y += 16;

    padding.y += 8; // Extra spacing before zoom info

    // Zoom Min
    const zoom_min_title = "Zoom | Min:";
    const zoom_min_title_width = app.ui.font.measureText(zoom_min_title, 16);
    app.ui.drawText(zoom_min_title, padding, 16, rl.Color.white);
    const zoom_min_string = std.fmt.allocPrint(app.allocator, "{d}", .{app.camera.zoom.min}) catch "";
    padding.x += zoom_min_title_width.x + 8;
    app.ui.drawText(zoom_min_string, padding, 16, rl.Color.white);
    padding.x = 16;
    padding.y += 16;

    // Zoom Max
    const zoom_max_title = "Zoom | Max:";
    const zoom_max_title_width = app.ui.font.measureText(zoom_max_title, 16);
    app.ui.drawText(zoom_max_title, padding, 16, rl.Color.white);
    const zoom_max_string = std.fmt.allocPrint(app.allocator, "{d}", .{app.camera.zoom.max}) catch "";
    padding.x += zoom_max_title_width.x + 8;
    app.ui.drawText(zoom_max_string, padding, 16, rl.Color.white);
    padding.x = 16;
    padding.y += 16;

    // Zoom Speed
    const zoom_speed_title = "Zoom | Speed:";
    const zoom_speed_title_width = app.ui.font.measureText(zoom_speed_title, 16);
    app.ui.drawText(zoom_speed_title, padding, 16, rl.Color.white);
    const zoom_speed_string = std.fmt.allocPrint(app.allocator, "{d}", .{app.camera.zoom.speed}) catch "";
    padding.x += zoom_speed_title_width.x + 8;
    app.ui.drawText(zoom_speed_string, padding, 16, rl.Color.white);
    padding.x = 16;
    padding.y += 16;

    // Zoom Target
    const zoom_target_title = "Zoom | Target:";
    const zoom_target_title_width = app.ui.font.measureText(zoom_target_title, 16);
    app.ui.drawText(zoom_target_title, padding, 16, rl.Color.white);
    const zoom_target_string = std.fmt.allocPrint(app.allocator, "{d}", .{app.camera.zoom.target}) catch "";
    padding.x += zoom_target_title_width.x + 8;
    app.ui.drawText(zoom_target_string, padding, 16, rl.Color.white);
    padding.x = 16;
    padding.y += 16;

    //  Zoom Lerp Speed
    const zoom_lerp_speed_title = "Zoom | Lerp Speed:";
    const zoom_lerp_speed_title_width = app.ui.font.measureText(zoom_lerp_speed_title, 16);
    app.ui.drawText(zoom_lerp_speed_title, padding, 16, rl.Color.white);
    const zoom_lerp_speed_string = std.fmt.allocPrint(app.allocator, "{d}", .{app.camera.zoom.lerp_speed}) catch "";
    padding.x += zoom_lerp_speed_title_width.x + 8;
    app.ui.drawText(zoom_lerp_speed_string, padding, 16, rl.Color.white);
    padding.x = 16;
    padding.y += 16;

    padding.y += 8; // Extra spacing before movement info

    // Movement Lerp Speed
    const movement_lerp_speed_title = "Movement | Lerp Speed:";
    const movement_lerp_speed_title_width = app.ui.font.measureText(movement_lerp_speed_title, 16);
    app.ui.drawText(movement_lerp_speed_title, padding, 16, rl.Color.white);
    const movement_lerp_speed_string = std.fmt.allocPrint(app.allocator, "{d}", .{app.camera.movement.lerp_speed}) catch "";
    padding.x += movement_lerp_speed_title_width.x + 8;
    app.ui.drawText(movement_lerp_speed_string, padding, 16, rl.Color.white);
    padding.x = 16;
    padding.y += 16;

    // Movement Speed
    const movement_speed_title = "Movement | Speed:";
    const movement_speed_title_width = app.ui.font.measureText(movement_speed_title, 16);
    app.ui.drawText(movement_speed_title, padding, 16, rl.Color.white);
    const movement_speed_string = std.fmt.allocPrint(app.allocator, "{d}", .{app.camera.movement.movement_speed}) catch "";
    padding.x += movement_speed_title_width.x + 8;
    app.ui.drawText(movement_speed_string, padding, 16, rl.Color.white);
    padding.x = 16;
    padding.y += 16;

    // Movement Target Position
    const movement_target_position_title = "Movement | Target Position:";
    const movement_target_position_title_width = app.ui.font.measureText(movement_target_position_title, 16);
    app.ui.drawText(movement_target_position_title, padding, 16, rl.Color.white);
    const movement_target_position_string = std.fmt.allocPrint(
        app.allocator,
        "({d}, {d})",
        .{ app.camera.movement.target_position.x, app.camera.movement.target_position.y },
    ) catch "";
    padding.x += movement_target_position_title_width.x + 8;
    app.ui.drawText(movement_target_position_string, padding, 16, rl.Color.white);
    padding.x = 16;
    padding.y += 16;

    // Movement Mouse Pan Start
    const movement_mouse_pan_start_title = "Movement | Mouse Pan Start:";
    const movement_mouse_pan_start_title_width = app.ui.font.measureText(movement_mouse_pan_start_title, 16);
    app.ui.drawText(movement_mouse_pan_start_title, padding, 16, rl.Color.white);
    const movement_mouse_pan_start_string = std.fmt.allocPrint(
        app.allocator,
        "({d}, {d})",
        .{ app.camera.movement.mouse_pan_start.x, app.camera.movement.mouse_pan_start.y },
    ) catch "";
    padding.x += movement_mouse_pan_start_title_width.x + 8;
    app.ui.drawText(movement_mouse_pan_start_string, padding, 16, rl.Color.white);
    padding.x = 16;
    padding.y += 16;

    // Movement Mouse Pan Target
    const movement_mouse_pan_target_title = "Movement | Mouse Pan Target:";
    const movement_mouse_pan_target_title_width = app.ui.font.measureText(movement_mouse_pan_target_title, 16);
    app.ui.drawText(movement_mouse_pan_target_title, padding, 16, rl.Color.white);
    const movement_mouse_pan_target_string = std.fmt.allocPrint(
        app.allocator,
        "({d}, {d})",
        .{ app.camera.movement.mouse_pan_target.x, app.camera.movement.mouse_pan_target.y },
    ) catch "";
    padding.x += movement_mouse_pan_target_title_width.x + 8;
    app.ui.drawText(movement_mouse_pan_target_string, padding, 16, rl.Color.white);
    padding.x = 16;
    padding.y += 16;

    // Movement Mouse Pan Active
    const movement_mouse_pan_active_title = "Movement | Mouse Pan Active:";
    const movement_mouse_pan_active_title_width = app.ui.font.measureText(movement_mouse_pan_active_title, 16);
    app.ui.drawText(movement_mouse_pan_active_title, padding, 16, rl.Color.white);
    const movement_mouse_pan_active_string = if (app.camera.movement.mouse_pan_active) "True" else "False";
    padding.x += movement_mouse_pan_active_title_width.x + 8;
    app.ui.drawText(movement_mouse_pan_active_string, padding, 16, rl.Color.white);
    padding.x = 16;
    padding.y += 16;

    padding.y += 8; // Extra spacing before rotation info

    // Rotation Speed
    const rotation_speed_title = "Rotation | Speed:";
    const rotation_speed_title_width = app.ui.font.measureText(rotation_speed_title, 16);
    app.ui.drawText(rotation_speed_title, padding, 16, rl.Color.white);
    const rotation_speed_string = std.fmt.allocPrint(app.allocator, "{d}", .{app.camera.rotation.speed}) catch "";
    padding.x += rotation_speed_title_width.x + 8;
    app.ui.drawText(rotation_speed_string, padding, 16, rl.Color.white);
    padding.x = 16;
    padding.y += 16;

    // Rotation Target
    const rotation_target_title = "Rotation | Target:";
    const rotation_target_title_width = app.ui.font.measureText(rotation_target_title, 16);
    app.ui.drawText(rotation_target_title, padding, 16, rl.Color.white);
    const rotation_target_string = std.fmt.allocPrint(app.allocator, "{d}", .{app.camera.rotation.target}) catch "";
    padding.x += rotation_target_title_width.x + 8;
    app.ui.drawText(rotation_target_string, padding, 16, rl.Color.white);
    padding.x = 16;
    padding.y += 16;

    // Rotation Lerp Speed
    const rotation_lerp_speed_title = "Rotation | Lerp Speed:";
    const rotation_lerp_speed_title_width = app.ui.font.measureText(rotation_lerp_speed_title, 16);
    app.ui.drawText(rotation_lerp_speed_title, padding, 16, rl.Color.white);
    const rotation_lerp_speed_string = std.fmt.allocPrint(app.allocator, "{d}", .{app.camera.rotation.lerp_speed}) catch "";
    padding.x += rotation_lerp_speed_title_width.x + 8;
    app.ui.drawText(rotation_lerp_speed_string, padding, 16, rl.Color.white);
    padding.x = 16;
    padding.y += 16;

    padding.y += 8; // Extra spacing before follow info
}
