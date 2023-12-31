package main

import "core:fmt"

import rl "vendor:raylib"

Color   :: rl.Color
Rect    :: rl.Rectangle
Music   :: rl.Music
Vec2    :: rl.Vector2

GRASS :: Color{109, 162, 62, 255}

main :: proc() {

    SCALE   :: 4
    WIDTH   :: 300
    HEIGHT  :: 180
    HORIZON :: 120
    FPS     :: 60

    viewport : rl.Camera2D = {
        Vec2{0.0, 0.0},
        Vec2{0.0, 0.0},
        0, SCALE
        }

    delta   : f32 
    game_speed : f32 = 80

    show_collision_box := true

    obstacle : Rect = {0, 120 - 8, 10, 10}
    obs_offset : Vec2

    foxy_hit := false

    falling := false
    jumping := false
    GRAVITY : f32 : 0.4
    JUMP_STR : f32 : 6
    fall_speed : f32 = 0
    
    TITLE   : cstring : "Foxy Trot"

    foxy := SetupFoxy(32.0, HORIZON)

    obstacles := [36]Sprite{}
    CreateSpritesFromSheet(&obstacles, 32.0, 9, 4)

    rl.InitWindow(WIDTH * SCALE, HEIGHT * SCALE, TITLE)
    rl.SetTargetFPS(FPS)
    //rl.SetWindowState(rl.ConfigFlags{rl.ConfigFlag.WINDOW_UNDECORATED})

    foxy_texture : rl.Texture2D = rl.LoadTexture(".//res//foxy.png")
    obs_texture : rl.Texture2D = rl.LoadTexture(".//res//obstacles.png")

    ChangeAnimation(&foxy, i32(animate.RUN))

    active_camera := viewport

    obs_index := 11
    obs_offset.y = obstacle.y + obstacles[obs_index].offset.y

    for !rl.WindowShouldClose() {
        delta = rl.GetFrameTime()

        obstacle.x -= 2 * game_speed * delta
        obs_offset.x = obstacle.x + obstacles[obs_index].offset.x
        
        if obstacle.x <= 0 - obstacle.width {
            obstacle.x = WIDTH
        }

        if foxy.timer.active {
            foxy.timer.current_time = rl.GetTime() - foxy.timer.last_time
            if foxy.timer.current_time > foxy.timer.wait_time {
                foxy.timer.last_time = rl.GetTime()
                foxy.rec.x = f32(foxy.current_frame) * f32(foxy.size)
                foxy.current_frame += 1
                foxy.current_frame = foxy.current_frame % foxy.frames[foxy.index]
            }
        }
        
        if falling {
            if foxy.pos.y < HORIZON - foxy.size - fall_speed{ // include fall speed so foxy doesn't land beneath the ground 
                fall_speed += GRAVITY
                foxy.pos.y += fall_speed
                foxy.bb.y = foxy.pos.y + 21
            } else {
                fall_speed = 0
                foxy.pos.y = HORIZON - foxy.size
                foxy.bb.y = foxy.pos.y + 21
                falling = false
                ChangeAnimation(&foxy, i32(animate.RUN))
                
            }
        }

        if rl.IsKeyPressed(rl.KeyboardKey.SPACE) & !falling{
            jumping = true
            falling = true
            ChangeAnimation(&foxy, i32(animate.JUMP))
            SetFrame(&foxy, 3)
        }

        if rl.IsKeyPressed(rl.KeyboardKey.X){
            show_collision_box = !show_collision_box
        }

        if rl.IsKeyPressed(rl.KeyboardKey.B){
            obs_index += 1
            if obs_index >= 36 {
                obs_index = 0
            }
            fmt.println("obstacle index: ", obs_index)
            obs_offset.y = obstacle.y + obstacles[obs_index].offset.y
        }


        if jumping {
            foxy.pos.y -= JUMP_STR
            foxy.bb.y = foxy.pos.y + 22
            if fall_speed > JUMP_STR {
                jumping = false
                fall_speed = 0
                SetFrame(&foxy, 5)
            }

        }

        if rl.CheckCollisionRecs (foxy.bb, obstacle) {
            foxy_hit = true
        } else {
            foxy_hit = false
        }

        rl.BeginDrawing()
        rl.BeginMode2D(active_camera) 
        rl.ClearBackground(rl.DARKGRAY)

        rl.DrawRectangle(0, 0, WIDTH, HEIGHT, rl.SKYBLUE)
        rl.DrawRectangle(0, HORIZON, WIDTH, HEIGHT - HORIZON, GRASS)
        rl.DrawTextureRec(foxy_texture, foxy.rec, foxy.pos, rl.WHITE)

        rl.DrawTextureRec(obs_texture, obstacles[obs_index].rec, obs_offset , rl.WHITE)

        if show_collision_box {
            rl.DrawRectangleRec(foxy.bb, Color{210,200,100,200})
            rl.DrawRectangleRec(obstacle, Color{100, 100, 100, 200})
        }

        if foxy_hit {
            rl.DrawText("Hit", i32(foxy.pos.x), HORIZON, 15, rl.BLACK)
        }
            
        rl.EndMode2D()
        rl.EndDrawing()
    }

    rl.CloseWindow()
}