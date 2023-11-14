package main

import rl "vendor:raylib"


Timer :: struct {
    active          : bool,
    wait_time       : f64,
    current_time    : f64,
    last_time       : f64
}

// creates animated sprite structure from sprite sheet
// works on sprite sheets with square cells and animation frames
// arranged in order from left to right. see foxy.png for example
Animated_Sprite :: struct {
    size            : f32,
    index           : i32,
    current_frame   : i32,
    frames          : [7]i32,
    fps             : [7]f64,
    timer           : Timer,
    rec             : Rect,
    pos             : Vec2,
    bb              : Rect
}

Sprite :: struct {
    rec : Rect,
    offset : Vec2
}

CreateSpritesFromSheet :: proc(arr: ^[36]Sprite, size : f32, x : int, y : int) {
    index := 0
    for i in 0..<y{
        for j in 0..<x{
            arr[index].rec.x = f32(j) * size
            arr[index].rec.y = f32(i) * size
            arr[index].rec.width = size
            arr[index].rec.height = size
            index += 1
        }
    }

    arr[11].offset = {-10, -10}
    arr[8].offset = {-10, -8}

}

SetupFoxy :: proc(size : f32, ground : f32) -> Animated_Sprite {
    output : Animated_Sprite = {
        size, 0, 0,
        {5, 14, 8, 11, 5, 6, 7},
        {8.0, 8.0, 10.0, 20.0, 10.0, 3.0, 5.0},
        {true, .1, 0.0, 0.0},
        {0, 0, size, size},
        {10, ground - size},
        {18, ground - 11, 16, 10}
    }
    return output
}

// switches to another animation and starts it at frame 0
ChangeAnimation :: proc( sprite : ^Animated_Sprite, index : i32 ) {
    sprite.index = index
    sprite.rec.x = 0
    sprite.rec.y = f32(sprite.index) * sprite.size
    sprite.current_frame = 0
    sprite.timer.wait_time = 1.0 / sprite.fps[index]
    sprite.timer.active = true
}

// stops current animation and sets specific frame
SetFrame :: proc( sprite : ^Animated_Sprite, frame : i32 ) {
    sprite.timer.active = false
    sprite.rec.x = f32(frame) * f32(sprite.size)
}

animate :: enum{
    IDLE,
    SEARCH,
    RUN,
    JUMP,
    SURPRISE,
    SLEEP,
    FLOP
}