const std = @import("std");
const rl = @import("raylib");
const Click = @import("./click.zig").Click;
const Cursor = @import("./cursor.zig").Cursor;

pub const Mouse = struct {
    cursor: Cursor = .Default,
    active_clicks: std.AutoHashMap(Click, void),
    click_press_order: std.AutoHashMap(Click, u64),

    pub fn init(allocator: std.mem.Allocator) Mouse {
        const active_clicks = std.AutoHashMap(Click, void).init(allocator);
        const click_press_order = std.AutoHashMap(Click, u64).init(allocator);
        return Mouse{ .active_clicks = active_clicks, .click_press_order = click_press_order };
    }

    pub fn deinit(self: *Mouse) void {
        self.active_clicks.deinit();
        self.click_press_order.deinit();
    }

    pub fn getActiveClicksInclude(self: Mouse, clicks: []const Click, filter: enum { And, Or }) bool {
        switch (filter) {
            .And => {
                for (clicks) |click| {
                    if (!self.active_clicks.get(click)) return false;
                }
                return true;
            },
            .Or => {
                for (clicks) |click| {
                    if (self.active_clicks.get(click)) return true;
                }
                return false;
            },
        }
    }

    pub fn getClickPressOrderIndex(self: Mouse, click: Click) ?u64 {
        return self.click_press_order.get(click);
    }

    pub fn getMostRecentlyPressedClick(self: Mouse) ?Click {
        var most_recent_time: u64 = 0;
        var most_recent_click: ?Click = null;
        const it = self.click_press_order.iterator();
        while (it.next()) |entry| {
            if (entry.value > most_recent_time) {
                most_recent_click = entry.key;
                most_recent_time = entry.value;
            }
        }
        return most_recent_click;
    }

    pub fn update(self: *Mouse) void {
        for (Click.array()) |click| {
            const is_down = rl.isMouseButtonDown(click.toRL());
            const was_down = self.active_clicks.get(click) != null;
            if (is_down) {
                _ = self.active_clicks.put(click, {}) catch {};
                if (!was_down) _ = self.click_press_order.put(click, self.click_press_order.count() + 1) catch {};
            } else {
                _ = self.active_clicks.remove(click);
                _ = self.click_press_order.remove(click);
            }
        }
    }
};
