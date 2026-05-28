const std = @import("std");
const rl = @import("raylib");
const d = @import("./lib/draw.zig");
const fnt = @import("./lib/font.zig");
const i = @import("./lib/components/init.zig");

pub const drawCircle = d.drawCircle;
pub const DrawCircleProps = d.DrawCircleProps;
pub const drawGrid = d.drawGrid;
pub const DrawGridProps = d.DrawGridProps;
pub const drawLine = d.drawLine;
pub const DrawLineProps = d.DrawLineProps;
pub const drawRect = d.drawRect;
pub const DrawRectProps = d.DrawRectProps;
pub const drawText = d.drawText;
pub const DrawTextProps = d.DrawTextProps;
pub const drawTextureRect = d.drawTextureRect;
pub const DrawTextureRectProps = d.DrawTextureRectProps;
pub const Font = fnt.Font;
pub const init_screen_w = i.init_screen_w;
pub const init_screen_h = i.init_screen_h;
pub const initScreenRect = i.initScreenRect;
pub const measureText = fnt.measureText;
pub const strokeRect = d.strokeRect;
pub const StrokeRectProps = d.StrokeRectProps;
pub const TextBox = @import("./lib/components/text_box.zig").TextBox;
pub const TextInput = @import("./lib/components/text_input.zig").TextInput;

pub const UiProps = struct { font: Font = .{} };
pub const Ui = struct {
    font: Font,

    pub fn init(props: UiProps) Ui {
        return .{ .font = props.font };
    }

    pub fn deinit(self: *Ui) void {
        self.font.deinit();
    }

    pub fn load(self: *Ui) void {
        self.font.load();
    }
};
