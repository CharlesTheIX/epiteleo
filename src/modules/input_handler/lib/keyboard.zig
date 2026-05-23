const std = @import("std");
const rl = @import("raylib");
const Key = @import("./key.zig").Key;

pub const Keyboard = struct {
    active_keys: std.AutoHashMap(Key, void),
    key_press_order: std.AutoHashMap(Key, u64),

    pub fn init(allocator: std.mem.Allocator) Keyboard {
        const active_keys = std.AutoHashMap(Key, void).init(allocator);
        const key_pass_order = std.AutoHashMap(Key, u64).init(allocator);
        return Keyboard{ .active_keys = active_keys, .key_press_order = key_pass_order };
    }

    pub fn deinit(self: *Keyboard) void {
        self.active_keys.deinit();
        self.key_press_order.deinit();
    }

    pub fn getActiveKeysInclude(self: Keyboard, keys: []const Key, filter: enum { And, Or }) bool {
        switch (filter) {
            .And => {
                for (keys) |key| {
                    if (!self.active_keys.get(key)) return false;
                }
                return true;
            },
            .Or => {
                for (keys) |key| {
                    if (self.active_keys.get(key)) return true;
                }
                return false;
            },
        }
    }

    pub fn getKeyPressOrderIndex(self: Keyboard, key: Key) ?u64 {
        return self.key_press_order.get(key);
    }

    pub fn getMostRecentlyPressedKey(self: Keyboard) ?Key {
        var most_recent_time: u64 = 0;
        var most_recent_key: ?Key = null;
        const it = self.key_press_order.iterator();
        while (it.next()) |entry| {
            if (entry.value > most_recent_time) {
                most_recent_key = entry.key;
                most_recent_time = entry.value;
            }
        }
        return most_recent_key;
    }

    pub fn update(self: *Keyboard) void {
        for (Key.array()) |key| {
            const is_down = rl.isKeyDown(key.toRL());
            const was_down = self.active_keys.get(key) != null;
            if (is_down) {
                _ = self.active_keys.put(key, {}) catch {};
                if (!was_down) _ = self.key_press_order.put(key, self.key_press_order.count() + 1) catch {};
            } else if (was_down) {
                _ = self.active_keys.remove(key);
                _ = self.key_press_order.remove(key);
            }
        }
    }
};
