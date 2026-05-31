const std = @import("std");
const rl = @import("raylib");
const _ui = @import("../../_ui/root.zig");
const App = @import("../../root.zig").App;

pub fn drawGameInfo(app: *App) void {
    const spacing: f32 = 16;
    var font = app.ui.font;
    var pos = rl.Vector2.init(spacing, spacing);
    const screen_w = @as(f32, @floatFromInt(rl.getScreenWidth()));
    const screen_h = @as(f32, @floatFromInt(rl.getScreenHeight()));
    _ui.drawRect(.{ .rect = .init(0, 0, screen_w, screen_h), .color = rl.Color.black.alpha(0.8) });

    // Intro Text
    _ui.drawText(.{ .text = "Game Info:", .pos = pos, .color = .white, .font = font });
    if (app.game) |game| {
        var value_buf: [160]u8 = undefined;
        pos.y += font.size + spacing;
        font.size = spacing;
        // State
        const state_title = "Game | State:";
        _ui.drawText(.{ .text = state_title, .pos = pos, .font = font, .color = .white });
        pos.x += _ui.measureText(state_title, font).x + @as(f32, @divFloor(spacing, 2));
        _ui.drawText(.{ .text = game.state.toString(), .pos = pos, .font = font, .color = .white });
        pos.x = spacing;
        pos.y += spacing;

        // Player Name
        const player_name_title = "Player | Name:";
        _ui.drawText(.{ .text = player_name_title, .pos = pos, .font = font, .color = .white });
        pos.x += _ui.measureText(player_name_title, font).x + @as(f32, @divFloor(spacing, 2));
        const player_name_string = game.player.data.name;
        _ui.drawText(.{ .text = &player_name_string, .pos = pos, .font = font, .color = .white });
        pos.x = spacing;
        pos.y += spacing;

        // Player Position
        const player_pos_title = "Player | Position:";
        _ui.drawText(.{ .text = player_pos_title, .pos = pos, .font = font, .color = .white });
        pos.x += _ui.measureText(player_pos_title, font).x + @as(f32, @divFloor(spacing, 2));
        const player_pos_string = std.fmt.bufPrint(&value_buf, "{d}, {d}", .{
            game.player.data.pos.x,
            game.player.data.pos.y,
        }) catch "ERR";
        _ui.drawText(.{ .text = player_pos_string, .pos = pos, .font = font, .color = .white });
        pos.x = spacing;
        pos.y += spacing;

        // Player Play Time
        const play_time_title = "Player | Play Time (s):";
        _ui.drawText(.{ .text = play_time_title, .pos = pos, .font = font, .color = .white });
        pos.x += _ui.measureText(play_time_title, font).x + @as(f32, @divFloor(spacing, 2));
        const play_time_string = std.fmt.bufPrint(
            &value_buf,
            "{d}",
            .{game.player.data.play_time},
        ) catch "ERR";
        _ui.drawText(.{ .text = play_time_string, .pos = pos, .font = font, .color = .white });
        pos.x = spacing;
        pos.y += spacing;

        // Player Max Speed
        const player_max_speed_title = "Player | Max Speed:";
        _ui.drawText(.{ .text = player_max_speed_title, .pos = pos, .font = font, .color = .white });
        pos.x += _ui.measureText(player_max_speed_title, font).x + @as(f32, @divFloor(spacing, 2));
        const player_max_speed_string = std.fmt.bufPrint(
            &value_buf,
            "{d}",
            .{game.player.max_speed},
        ) catch "ERR";
        _ui.drawText(.{ .text = player_max_speed_string, .pos = pos, .font = font, .color = .white });
        pos.x = spacing;
        pos.y += spacing;

        // Player Velocity
        const player_velocity_title = "Player | Velocity:";
        _ui.drawText(.{ .text = player_velocity_title, .pos = pos, .font = font, .color = .white });
        pos.x += _ui.measureText(player_velocity_title, font).x + @as(f32, @divFloor(spacing, 2));
        const player_velocity_string = std.fmt.bufPrint(
            &value_buf,
            "{d}, {d}",
            .{ game.player.body.velocity.x, game.player.body.velocity.y },
        ) catch "ERR";
        _ui.drawText(.{ .text = player_velocity_string, .pos = pos, .font = font, .color = .white });
        pos.x = spacing;
        pos.y += spacing;

        // Player Acceleration
        const player_acceleration_title = "Player | Acceleration:";
        _ui.drawText(.{ .text = player_acceleration_title, .pos = pos, .font = font, .color = .white });
        pos.x += _ui.measureText(player_acceleration_title, font).x + @as(f32, @divFloor(spacing, 2));
        const player_acceleration_string = std.fmt.bufPrint(
            &value_buf,
            "{d}, {d}",
            .{ game.player.body.acceleration.x, game.player.body.acceleration.y },
        ) catch "ERR";
        _ui.drawText(.{ .text = player_acceleration_string, .pos = pos, .font = font, .color = .white });
        pos.x = spacing;
        pos.y += spacing;

        // Player Sprite State
        const player_sprite_state_title = "Player | Sprite State:";
        _ui.drawText(.{ .text = player_sprite_state_title, .pos = pos, .font = font, .color = .white });
        pos.x += _ui.measureText(player_sprite_state_title, font).x + @as(f32, @divFloor(spacing, 2));
        const player_sprite_state_string = std.fmt.bufPrint(&value_buf, "{s}, {s}", .{
            game.player.sprite.state.toString(),
            game.player.sprite.direction.toString(),
        }) catch "ERR";
        _ui.drawText(.{ .text = player_sprite_state_string, .pos = pos, .font = font, .color = .white });
        pos.x = spacing;
        pos.y += spacing;

        // Player Sprite size
        const player_sprite_size_title = "Player | Sprite Size:";
        _ui.drawText(.{ .text = player_sprite_size_title, .pos = pos, .font = font, .color = .white });
        pos.x += _ui.measureText(player_sprite_size_title, font).x + @as(f32, @divFloor(spacing, 2));
        if (game.player.sprite.data.size) |size| {
            const player_sprite_size_string = std.fmt.bufPrint(&value_buf, "{d}x{d}", .{ size[0], size[1] }) catch "ERR";
            _ui.drawText(.{ .text = player_sprite_size_string, .pos = pos, .font = font, .color = .white });
        } else _ui.drawText(.{ .text = "N/A", .pos = pos, .font = font, .color = .white });
        pos.x = spacing;
        pos.y += spacing;

        // Player Sprite Hitbox
        const player_sprite_hitbox_title = "Player | Sprite Hitbox:";
        _ui.drawText(.{ .text = player_sprite_hitbox_title, .pos = pos, .font = font, .color = .white });
        pos.x += _ui.measureText(player_sprite_hitbox_title, font).x + @as(f32, @divFloor(spacing, 2));
        if (game.player.sprite.data.hitbox) |hitbox| {
            const player_sprite_hitbox_string = std.fmt.bufPrint(&value_buf, "{d}x{d} @ {d},{d}", .{
                hitbox[2],
                hitbox[3],
                hitbox[0],
                hitbox[1],
            }) catch "ERR";
            _ui.drawText(.{ .text = player_sprite_hitbox_string, .pos = pos, .font = font, .color = .white });
        } else _ui.drawText(.{ .text = "N/A", .pos = pos, .font = font, .color = .white });
        pos.x = spacing;
        pos.y += spacing;

        // Player Sprite Animation FPS
        const player_sprite_animation_fps_title = "Player | Sprite Animation FPS:";
        _ui.drawText(.{ .text = player_sprite_animation_fps_title, .pos = pos, .font = font, .color = .white });
        pos.x += _ui.measureText(player_sprite_animation_fps_title, font).x + @as(f32, @divFloor(spacing, 2));
        const player_sprite_animation_fps_string = std.fmt.bufPrint(
            &value_buf,
            "{d}",
            .{game.player.sprite.animation.fps},
        ) catch "ERR";
        _ui.drawText(.{ .text = player_sprite_animation_fps_string, .pos = pos, .font = font, .color = .white });
        pos.x = spacing;
        pos.y += spacing;

        // Player Sprite Animation Frame
        const player_sprite_animation_frame_title = "Player | Sprite Animation Frame:";
        _ui.drawText(.{ .text = player_sprite_animation_frame_title, .pos = pos, .font = font, .color = .white });
        pos.x += _ui.measureText(player_sprite_animation_frame_title, font).x + @as(f32, @divFloor(spacing, 2));
        const player_sprite_animation_frame_string = std.fmt.bufPrint(
            &value_buf,
            "{d}",
            .{game.player.sprite.animation.frame},
        ) catch "ERR";
        _ui.drawText(.{ .text = player_sprite_animation_frame_string, .pos = pos, .font = font, .color = .white });
        pos.x = spacing;
        pos.y += spacing;

        // Player Sprite Animation Max Frames
        const player_sprite_animation_max_frames_title = "Player | Sprite Animation Max Frames:";
        _ui.drawText(.{
            .text = player_sprite_animation_max_frames_title,
            .pos = pos,
            .font = font,
            .color = .white,
        });
        pos.x += _ui.measureText(player_sprite_animation_max_frames_title, font).x + @as(f32, @divFloor(spacing, 2));
        const player_sprite_animation_max_frames_string = std.fmt.bufPrint(&value_buf, "{d}", .{
            game.player.sprite.animation.max_frames,
        }) catch "ERR";
        _ui.drawText(.{
            .text = player_sprite_animation_max_frames_string,
            .pos = pos,
            .font = font,
            .color = .white,
        });

        font.size = app.ui.font.size; // reset the font size back to the default - CIX
    }
}
