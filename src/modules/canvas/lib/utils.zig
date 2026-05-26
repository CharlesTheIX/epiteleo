const rl = @import("raylib");

const Camera = @import("../../camera/root.zig").Camera;
const rotateVector = @import("../../../lib/utils.zig").rotateVector;

pub fn translateWindowVectorToCanvasVector(v: rl.Vector2, camera: *const Camera) rl.Vector2 {
    var pos = v.subtract(camera.camera.offset);
    pos = rotateVector(pos, -camera.camera.rotation);
    pos = pos.scale(1.0 / camera.camera.zoom);
    return pos.add(camera.camera.target);
}
