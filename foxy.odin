package example

import "core:fmt"

import rl "vendor:raylib"



main :: proc() {


    SCALE   :: 4
    WIDTH   :: 300 * SCALE
    HEIGHT  :: 180 * SCALE
    HORIZON :: 120 * SCALE
    FPS     :: 60
    
    TITLE   : cstring : "Foxy Trot"

    debug_index : i32 = 5

    Timer :: struct {
        active          : bool,
        wait_time       : f64,
        current_time    : f64,
        last_time       : f64
    }

    Animated_Sprite :: struct {
        size            : i32,
        scale           : i32,
        index           : i32,
        current_frame   : i32,
        frames          : [7]i32,
        fps             : [7]f64,
        timer           : Timer,
        rec             : rl.Rectangle,
        pos             : rl.Rectangle,
        origin          : rl.Vector2
    }

    ChangeAnimation :: proc( sprite : ^Animated_Sprite, index : i32 ) {
        sprite.index = index
        sprite.rec.x = 0
        sprite.rec.y = f32(sprite.index * sprite.size)
        sprite.current_frame = 0
        sprite.timer.wait_time = 1.0 / sprite.fps[index]
    }
    
    foxy : Animated_Sprite = {
        size = 32, scale = SCALE, index = 0, current_frame = 0
    }
    foxy.frames = {5, 14, 8, 11, 5, 6, 7}
    foxy.fps    = {8.0, 8.0, 10.0, 10.0, 10.0, 3.0, 5.0}
    foxy.timer  = {true, .1, 0.0, 0.0}
    foxy.rec    = {0, f32(foxy.index * foxy.size), f32(foxy.size), f32(foxy.size)}
    foxy.pos    = {32, HORIZON, f32(foxy.size * foxy.scale), f32(foxy.size * foxy.scale)}
    foxy.origin = {0, f32(foxy.size * foxy.scale)}
    

    rl.InitWindow(WIDTH, HEIGHT, TITLE)

    rl.SetTargetFPS(FPS)

    foxy_texture : rl.Texture2D = rl.LoadTexture(".//res//foxy.png")

    ChangeAnimation(&foxy, debug_index)
    debug_index += 1
    debug_index = debug_index % 7
    
    for !rl.WindowShouldClose() {

        if foxy.timer.active {
            foxy.timer.current_time = rl.GetTime() - foxy.timer.last_time
            if foxy.timer.current_time > foxy.timer.wait_time {
                foxy.timer.last_time = rl.GetTime()
                foxy.rec.x = f32(foxy.current_frame) * f32(foxy.size)
                foxy.current_frame += 1
                foxy.current_frame = foxy.current_frame % foxy.frames[foxy.index]
            }
        }

        if rl.IsKeyPressed(rl.KeyboardKey(88)) {
            fmt.println("changing to animation index ", debug_index)
            ChangeAnimation(&foxy, debug_index)
            debug_index += 1
            debug_index = debug_index % 7
        }

        
        rl.BeginDrawing()
        
            rl.ClearBackground(rl.DARKGRAY)
            rl.DrawRectangle(0, 0, WIDTH, HEIGHT, rl.SKYBLUE)
            rl.DrawRectangle(0, HORIZON, WIDTH, HEIGHT, rl.DARKGREEN)
            rl.DrawTexturePro(foxy_texture, foxy.rec, foxy.pos, foxy.origin, 0, rl.WHITE)
            
        rl.EndDrawing()
    }

    rl.CloseWindow()
}