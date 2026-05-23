# EPITELEO

## Camera Movement

The camera has two modes: `Free` and `Follow`.

In `Follow` mode, the camera expects a target position on every frame update. The camera will smoothly move towards this target position, creating a smooth following effect. This is ideal for games where the camera should track a player or an object.

In `Free` mode the camera is updated from keyboard and mouse input.

### Keyboard

- **W / A / S / D**: Move camera target.
- **WASD + LeftShift or RightShift**: Increase movement speed (4x).
- **Minus (-)**: Zoom out.
- **Equal (=)**: Zoom in.
- **LeftBracket ([)** and **RightBracket (])**: Rotate camera.

### Mouse and Trackpad

- **LeftClick + (LeftShift or RightShift) + drag**: Pan camera by dragging.
- **Scroll (when Shift is not held)**: Pan camera.
- **LeftShift + vertical scroll**: Zoom camera.
- **LeftAlt + scroll**: Rotate camera.

### Notes

- Movement, zoom, and rotation are smoothed via lerp-based interpolation.
- Scroll-based zoom currently checks `LeftShift` specifically, while movement-speed and drag-pan modifiers accept either shift key.
