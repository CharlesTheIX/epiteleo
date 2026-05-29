const std = @import("std");
const rl = @import("raylib");
const _ui = @import("../../_ui/root.zig");
const App = @import("../../root.zig").App;

pub fn drawCameraInfo(app: *App) void {
    const spacing: f32 = 16;
    var font = app.ui.font;
    var pos = rl.Vector2.init(spacing, spacing);
    const screen_w = @as(f32, @floatFromInt(rl.getScreenWidth()));
    const screen_h = @as(f32, @floatFromInt(rl.getScreenHeight()));
    _ui.drawRect(.{ .rect = .init(0, 0, screen_w, screen_h), .color = rl.Color.black.alpha(0.8) });

    // Intro Text
    _ui.drawText(.{ .text = "Camera Info:", .pos = pos, .color = .white, .font = font });
    pos.y += font.size;

    pos.y += spacing;
    font.size = spacing;

    // Note Text
    _ui.drawText(.{
        .font = font,
        .pos = pos,
        .color = .white,
        .text = "Press .Zero (0) to cycle through camera states",
    });
    _ui.drawText(.{
        .text = "Press .Zero (0) to cycle through camera states",
        .pos = pos,
        .font = font,
        .color = .white,
    });
    pos.y += spacing;
    _ui.drawText(.{
        .text = "Press .Nine (9) to toggle snap to canvas",
        .pos = pos,
        .font = font,
        .color = .white,
    });
    pos.y += spacing * 2;

    // Camera State
    const state_title = "Camera | State:";
    const state_title_width = _ui.measureText(state_title, font);
    _ui.drawText(.{ .text = state_title, .pos = pos, .font = font, .color = .white });
    const state_string = app.camera.state.toString();
    pos.x += state_title_width.x + @as(f32, @divFloor(spacing, 2));
    _ui.drawText(.{ .text = state_string, .pos = pos, .font = font, .color = .white });
    pos.x = spacing;
    pos.y += spacing;

    // Snaps to Canvas
    const snap_to_canvas_title = "Camera | Snaps to Canvas:";
    const snap_to_canvas_title_width = _ui.measureText(snap_to_canvas_title, font);
    _ui.drawText(.{ .text = snap_to_canvas_title, .pos = pos, .font = font, .color = .white });
    const snap_to_canvas_string = if (app.camera.snap_to_canvas) "True" else "False";
    pos.x += snap_to_canvas_title_width.x + @as(f32, @divFloor(spacing, 2));
    _ui.drawText(.{ .text = snap_to_canvas_string, .pos = pos, .font = font, .color = .white });
    pos.x = spacing;
    pos.y += spacing;

    // Camera Zoom
    const camera_zoom_title = "Camera | Zoom:";
    const camera_zoom_title_width = _ui.measureText(camera_zoom_title, font);
    _ui.drawText(.{ .text = camera_zoom_title, .pos = pos, .font = font, .color = .white });
    const camera_zoom_string = std.fmt.allocPrint(app.allocator, "{d}", .{app.camera.camera.zoom}) catch "";
    pos.x += camera_zoom_title_width.x + @as(f32, @divFloor(spacing, 2));
    _ui.drawText(.{ .text = camera_zoom_string, .pos = pos, .font = font, .color = .white });
    pos.x = spacing;
    pos.y += spacing;

    // Camera Rotation
    const camera_rotation_title = "Camera | Rotation:";
    const camera_rotation_title_width = _ui.measureText(camera_rotation_title, font);
    _ui.drawText(.{ .text = camera_rotation_title, .pos = pos, .font = font, .color = .white });
    const camera_rotation_string = std.fmt.allocPrint(app.allocator, "{d}", .{app.camera.camera.rotation}) catch "";
    pos.x += camera_rotation_title_width.x + @as(f32, @divFloor(spacing, 2));
    _ui.drawText(.{ .text = camera_rotation_string, .pos = pos, .font = font, .color = .white });
    pos.x = spacing;
    pos.y += spacing;

    // Camera Target
    const camera_target_title = "Camera | Target:";
    const camera_target_title_width = _ui.measureText(camera_target_title, font);
    _ui.drawText(.{ .text = camera_target_title, .pos = pos, .font = font, .color = .white });
    const camera_target_string = std.fmt.allocPrint(
        app.allocator,
        "({d}, {d})",
        .{ app.camera.camera.target.x, app.camera.camera.target.y },
    ) catch "";
    pos.x += camera_target_title_width.x + @as(f32, @divFloor(spacing, 2));
    _ui.drawText(.{ .text = camera_target_string, .pos = pos, .font = font, .color = .white });
    pos.x = spacing;
    pos.y += spacing;

    // Camera Offset
    const camera_offset_title = "Camera | Offset:";
    const camera_offset_title_width = _ui.measureText(camera_offset_title, font);
    _ui.drawText(.{ .text = camera_offset_title, .pos = pos, .font = font, .color = .white });
    const camera_offset_string = std.fmt.allocPrint(
        app.allocator,
        "({d}, {d})",
        .{ app.camera.camera.offset.x, app.camera.camera.offset.y },
    ) catch "";
    pos.x += camera_offset_title_width.x + @as(f32, @divFloor(spacing, 2));
    _ui.drawText(.{ .text = camera_offset_string, .pos = pos, .font = font, .color = .white });
    pos.x = spacing;
    pos.y += spacing;

    pos.y += @as(f32, @divFloor(spacing, 2));

    // Zoom Min
    const zoom_min_title = "Zoom | Min:";
    const zoom_min_title_width = _ui.measureText(zoom_min_title, font);
    _ui.drawText(.{ .text = zoom_min_title, .pos = pos, .font = font, .color = .white });
    const zoom_min_string = std.fmt.allocPrint(app.allocator, "{d}", .{app.camera.zoom.min}) catch "";
    pos.x += zoom_min_title_width.x + @as(f32, @divFloor(spacing, 2));
    _ui.drawText(.{ .text = zoom_min_string, .pos = pos, .font = font, .color = .white });
    pos.x = spacing;
    pos.y += spacing;

    // Zoom Max
    const zoom_max_title = "Zoom | Max:";
    const zoom_max_title_width = _ui.measureText(zoom_max_title, font);
    _ui.drawText(.{ .text = zoom_max_title, .pos = pos, .font = font, .color = .white });
    const zoom_max_string = std.fmt.allocPrint(app.allocator, "{d}", .{app.camera.zoom.max}) catch "";
    pos.x += zoom_max_title_width.x + @as(f32, @divFloor(spacing, 2));
    _ui.drawText(.{ .text = zoom_max_string, .pos = pos, .font = font, .color = .white });
    pos.x = spacing;
    pos.y += spacing;

    // Zoom Speed
    const zoom_speed_title = "Zoom | Speed:";
    const zoom_speed_title_width = _ui.measureText(zoom_speed_title, font);
    _ui.drawText(.{ .text = zoom_speed_title, .pos = pos, .font = font, .color = .white });
    const zoom_speed_string = std.fmt.allocPrint(app.allocator, "{d}", .{app.camera.zoom.speed}) catch "";
    pos.x += zoom_speed_title_width.x + @as(f32, @divFloor(spacing, 2));
    _ui.drawText(.{ .text = zoom_speed_string, .pos = pos, .font = font, .color = .white });
    pos.x = spacing;
    pos.y += spacing;

    // Zoom Target
    const zoom_target_title = "Zoom | Target:";
    const zoom_target_title_width = _ui.measureText(zoom_target_title, font);
    _ui.drawText(.{ .text = zoom_target_title, .pos = pos, .font = font, .color = .white });
    const zoom_target_string = std.fmt.allocPrint(app.allocator, "{d}", .{app.camera.zoom.target}) catch "";
    pos.x += zoom_target_title_width.x + @as(f32, @divFloor(spacing, 2));
    _ui.drawText(.{ .text = zoom_target_string, .pos = pos, .font = font, .color = .white });
    pos.x = spacing;
    pos.y += spacing;

    //  Zoom Lerp Speed
    const zoom_lerp_speed_title = "Zoom | Lerp Speed:";
    const zoom_lerp_speed_title_width = _ui.measureText(zoom_lerp_speed_title, font);
    _ui.drawText(.{ .text = zoom_lerp_speed_title, .pos = pos, .font = font, .color = .white });
    const zoom_lerp_speed_string = std.fmt.allocPrint(app.allocator, "{d}", .{app.camera.zoom.lerp_speed}) catch "";
    pos.x += zoom_lerp_speed_title_width.x + @as(f32, @divFloor(spacing, 2));
    _ui.drawText(.{ .text = zoom_lerp_speed_string, .pos = pos, .font = font, .color = .white });
    pos.x = spacing;
    pos.y += spacing;

    pos.y += @as(f32, @divFloor(spacing, 2));

    // Movement Lerp Speed
    const movement_lerp_speed_title = "Movement | Lerp Speed:";
    const movement_lerp_speed_title_width = _ui.measureText(movement_lerp_speed_title, font);
    _ui.drawText(.{ .text = movement_lerp_speed_title, .pos = pos, .font = font, .color = .white });
    const movement_lerp_speed_string = std.fmt.allocPrint(app.allocator, "{d}", .{app.camera.movement.lerp_speed}) catch "";
    pos.x += movement_lerp_speed_title_width.x + @as(f32, @divFloor(spacing, 2));
    _ui.drawText(.{ .text = movement_lerp_speed_string, .pos = pos, .font = font, .color = .white });
    pos.x = spacing;
    pos.y += spacing;

    // Movement Speed
    const movement_speed_title = "Movement | Speed:";
    const movement_speed_title_width = _ui.measureText(movement_speed_title, font);
    _ui.drawText(.{ .text = movement_speed_title, .pos = pos, .font = font, .color = .white });
    const movement_speed_string = std.fmt.allocPrint(app.allocator, "{d}", .{app.camera.movement.movement_speed}) catch "";
    pos.x += movement_speed_title_width.x + @as(f32, @divFloor(spacing, 2));
    _ui.drawText(.{ .text = movement_speed_string, .pos = pos, .font = font, .color = .white });
    pos.x = spacing;
    pos.y += spacing;

    // Movement Target Position
    const movement_target_position_title = "Movement | Target Position:";
    const movement_target_position_title_width = _ui.measureText(movement_target_position_title, font);
    _ui.drawText(.{ .text = movement_target_position_title, .pos = pos, .font = font, .color = .white });
    const movement_target_position_string = std.fmt.allocPrint(
        app.allocator,
        "({d}, {d})",
        .{ app.camera.movement.target_position.x, app.camera.movement.target_position.y },
    ) catch "";
    pos.x += movement_target_position_title_width.x + @as(f32, @divFloor(spacing, 2));
    _ui.drawText(.{ .text = movement_target_position_string, .pos = pos, .font = font, .color = .white });
    pos.x = spacing;
    pos.y += spacing;

    // Movement Mouse Pan Start
    const movement_mouse_pan_start_title = "Movement | Mouse Pan Start:";
    const movement_mouse_pan_start_title_width = _ui.measureText(movement_mouse_pan_start_title, font);
    _ui.drawText(.{ .text = movement_mouse_pan_start_title, .pos = pos, .font = font, .color = .white });
    const movement_mouse_pan_start_string = std.fmt.allocPrint(
        app.allocator,
        "({d}, {d})",
        .{ app.camera.movement.mouse_pan_start.x, app.camera.movement.mouse_pan_start.y },
    ) catch "";
    pos.x += movement_mouse_pan_start_title_width.x + @as(f32, @divFloor(spacing, 2));
    _ui.drawText(.{ .text = movement_mouse_pan_start_string, .pos = pos, .font = font, .color = .white });
    pos.x = spacing;
    pos.y += spacing;

    // Movement Mouse Pan Target
    const movement_mouse_pan_target_title = "Movement | Mouse Pan Target:";
    const movement_mouse_pan_target_title_width = _ui.measureText(movement_mouse_pan_target_title, font);
    _ui.drawText(.{ .text = movement_mouse_pan_target_title, .pos = pos, .font = font, .color = .white });
    const movement_mouse_pan_target_string = std.fmt.allocPrint(
        app.allocator,
        "({d}, {d})",
        .{ app.camera.movement.mouse_pan_target.x, app.camera.movement.mouse_pan_target.y },
    ) catch "";
    pos.x += movement_mouse_pan_target_title_width.x + @as(f32, @divFloor(spacing, 2));
    _ui.drawText(.{ .text = movement_mouse_pan_target_string, .pos = pos, .font = font, .color = .white });
    pos.x = spacing;
    pos.y += spacing;

    // Movement Mouse Pan Active
    const movement_mouse_pan_active_title = "Movement | Mouse Pan Active:";
    const movement_mouse_pan_active_title_width = _ui.measureText(movement_mouse_pan_active_title, font);
    _ui.drawText(.{ .text = movement_mouse_pan_active_title, .pos = pos, .font = font, .color = .white });
    const movement_mouse_pan_active_string = if (app.camera.movement.mouse_pan_active) "True" else "False";
    pos.x += movement_mouse_pan_active_title_width.x + @as(f32, @divFloor(spacing, 2));
    _ui.drawText(.{ .text = movement_mouse_pan_active_string, .pos = pos, .font = font, .color = .white });
    pos.x = spacing;
    pos.y += spacing;

    pos.y += @as(f32, @divFloor(spacing, 2));

    // Rotation Speed
    const rotation_speed_title = "Rotation | Speed:";
    const rotation_speed_title_width = _ui.measureText(rotation_speed_title, font);
    _ui.drawText(.{ .text = rotation_speed_title, .pos = pos, .font = font, .color = .white });
    const rotation_speed_string = std.fmt.allocPrint(app.allocator, "{d}", .{app.camera.rotation.speed}) catch "";
    pos.x += rotation_speed_title_width.x + @as(f32, @divFloor(spacing, 2));
    _ui.drawText(.{ .text = rotation_speed_string, .pos = pos, .font = font, .color = .white });
    pos.x = spacing;
    pos.y += spacing;

    // Rotation Target
    const rotation_target_title = "Rotation | Target:";
    const rotation_target_title_width = _ui.measureText(rotation_target_title, font);
    _ui.drawText(.{ .text = rotation_target_title, .pos = pos, .font = font, .color = .white });
    const rotation_target_string = std.fmt.allocPrint(app.allocator, "{d}", .{app.camera.rotation.target}) catch "";
    pos.x += rotation_target_title_width.x + @as(f32, @divFloor(spacing, 2));
    _ui.drawText(.{ .text = rotation_target_string, .pos = pos, .font = font, .color = .white });
    pos.x = spacing;
    pos.y += spacing;

    // Rotation Lerp Speed
    const rotation_lerp_speed_title = "Rotation | Lerp Speed:";
    const rotation_lerp_speed_title_width = _ui.measureText(rotation_lerp_speed_title, font);
    _ui.drawText(.{ .text = rotation_lerp_speed_title, .pos = pos, .font = font, .color = .white });
    const rotation_lerp_speed_string = std.fmt.allocPrint(app.allocator, "{d}", .{app.camera.rotation.lerp_speed}) catch "";
    pos.x += rotation_lerp_speed_title_width.x + @as(f32, @divFloor(spacing, 2));
    _ui.drawText(.{ .text = rotation_lerp_speed_string, .pos = pos, .font = font, .color = .white });
    pos.x = spacing;
    pos.y += spacing;

    font.size = 32;
}
