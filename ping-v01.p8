pico-8 cartridge // http://www.pico-8.com
version 16
__lua__

debug = {}
debug.fps = 1

physics = {}
physics.gravity = 0.99
physics.damp = 0.995 -- dampening effect. 1 = no damp, 0 = full damp
physics.vclamp = 6 -- max velocity

player = {}
player.x = 58
player.y = 120
player.speed = 3
player.velocity = 0
player.bounce = 2 -- energy from collision

ball = {}
ball.x = 0
ball.y = 112
ball.speed = 0
ball.vx = 3 -- x velocity
ball.vy = 3 -- y velocity
ball.gravity = 0 -- starting gravity effect
ball.damp = 0 -- starting dampening value

spawn = 20
bricks = {}

function player_move()
    player.x += player.vector
    if player.x > 128 then
        player.x = 128
    elseif player.x < 0 then
        player.x = 0
    end
end

function ball_move()

    -- bounce off the walls
    if ball.x > 120 then
        ball.x = 120
        ball.vx =- ball.vx
        sfx(0)
    end
    if ball.x < 0 then
        ball.x = 0
        ball.vx =- ball.vx
        sfx(0)
    end
    if ball.y > 120 then
        ball.y = 120
        ball.vy =- ball.vy
        sfx(0)
    end
    if ball.y < 0 then
        ball.y = 0
        ball.vy =- ball.vy
        sfx(0)
    end

    -- physics
    ball.damp = physics.damp
    ball.damp = physics.damp

    player_collision()
    for brick in all(bricks) do
        brick_collision(brick)
    end

    ball.vx *= ball.damp
    ball.vy *= ball.damp

    -- gravity
    -- if ball.vy > 0 then ball.vy *= physics.gravity end

    -- clamp velocity
    ball.vx = min(ball.vx, physics.vclamp)
    ball.vy = min(ball.vy, physics.vclamp)

    ball.x += ball.vx
    ball.y += min(ball.vy, 128)

end

function player_collision()
    if (ball.x + 8) >= player.x and ball.x <= (player.x + 24) and (ball.y + 8) >= player.y and ball.y <= (player.y + 8) then
        ball.vy =- ball.vy
        ball.damp = player.bounce
        sfx(1)
    end
end

function brick_collision(brick)
    if (ball.x + 8) >= brick.x and ball.x <= (brick.x + 8) and (ball.y + 8) >= brick.y and ball.y <= (brick.y + 8) then
        if (ball.x + 8) >= brick.x and ball.x <= (brick.x + 8) then
            ball.vy =- ball.vy
        end
        if (ball.y + 8) >= brick.y and ball.y <= (brick.y + 8) then
            ball.vx =- ball.vx
        end
        del(bricks, brick)
        sfx(2)
    end
end

function controls()
    if(btn(0)) then
        player.vector = -3
    end
    if(btn(1)) then
        player.vector = 3
    end
    if(btn() == 0) then
        player.vector = 0
    end
    player_move()
end

function _init()

    -- create bricks
    for x=0, spawn do
        local brick = {}
        brick.x = ceil(rnd(15)) * 8
        brick.y = ceil(rnd(8)) * 8
        printh('bx: ' .. brick.x .. ' by: ' .. brick.y)
        brick.sprite = flr(rnd(2)) + 5
        bricks[x] = brick
    end

end

local skip_frames=0
function _update()
    skip_frames += 1
    if skip_frames%debug.fps > 0 then return end
    ball_move()
    controls()
end

function _draw()
    cls()
    spr(1, ball.x, ball.y)
    spr(2, player.x, player.y, 3, 1)

    -- bricks
    for brick in all(bricks) do
        spr(brick.sprite, brick.x, brick.y)
    end

    -- print('y: ' .. ball.y, ball.x + 10, ball.y-14, 3)
    -- print('vy: ' .. ball.vy, ball.x + 10, ball.y-7, 3)
    -- print('gravity: ' .. ball.vy * physics.gravity, ball.x + 10, ball.y, 3)
end
__gfx__
00000000000000000000000000000000000000003bbbbbbb1ccccccc000000000000000000000000000000000000000000000000000000000000000000000000
00000000000dd00000cc777777777777777788003333333b1111111c000000000000000000000000000000000000000000000000000000000000000000000000
0070070000d66d000ccffffffffffffffffff8805333d33b5111d11c000000000000000000000000000000000000000000000000000000000000000000000000
000770000dddd6d00cffffffffffffffffffff8053333d3b51111d1c000000000000000000000000000000000000000000000000000000000000000000000000
0007700005ddddd00cffffffffffffffffffff805333333b5111111c000000000000000000000000000000000000000000000000000000000000000000000000
00700700005dd5000ccffffffffffffffffff8805333333b5111111c000000000000000000000000000000000000000000000000000000000000000000000000
000000000005500000cc666666666666666688005333333351111111000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000005555553355555511000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100003702037000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00100000160503d000000001b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00100000337502b7503075035700317002e7002c7002d7003620031100352002b10033200322001f100307003070030700307003070030700000000000000000000000e000000000000000000000000000000000
