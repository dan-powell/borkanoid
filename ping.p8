pico-8 cartridge // http://www.pico-8.com
version 16
__lua__

-- ping - an arkanoid/pinball hybrid thing by dannysomething (dan-powell.uk)

-- basic de-buggary
debug = {}
debug.frame_skip = 1

-- core physics values
physics = {}
physics.gravity = 0.06
physics.friction = 0.01
physics.vmax = 8 -- max velocity
physics.vmin = 1 -- min velocity

-- Grid
grid = {}
grid.w = 8
grid.h = 8

-- actors
spawn = 30
bricks = {}
balls = {}


-- title

function init_title()
    mode = 0
    init_game()
end

local title_x = 0
function update_title()
    if btn(4) then
        init_game()
    end
end

local frame = 0
function draw_title()
    cls()
    spr(64, 16, 48, 12, 3) -- title
    spr(2, 52, 64, 3, 1) -- paddle
    frame += 1
    if frame%8 == 0 or frame%8 == 1 or frame%8 == 2 then
    else
        print("press start", 42, 76)
    end
end

-- game

function create_ball()
    local b = {}
    b.w = 6
    b.h = 6
    b.x = 64 - b.w/2
    b.y = 64 - b.w/2
    b.vx = rnd(16) - 8 -- x velocity
    b.vy = rnd(16) - 8 -- y velocity
    return b
end

function init_game()
    printh('game start')
    mode = 1

    ball = create_ball()

end

local skip=0
function update_game()
    skip += 1
    if skip%debug.frame_skip > 0 then return end

    ball_move()

end

function draw_game()
    cls(4)
    map(0,0,0,0,16,16)
    spr(1, ball.x, ball.y)
end


function bounce(a)
    a.vx = rnd(6) - 3
    a.vy = rnd(6) - 3
end

function ball_move()

    ball.vx *= 0.999
    ball.vy *= 0.999


        fx = ball.x + ball.vx



        fy = ball.y + ball.vy

    -- top
    if(solid_area(fx + (ball.w/2) -1, fy, 2, 1)) then
        printh('collide top')
        ball.vy = abs(ball.vy)
    end
    -- left
    if(solid_area(fx, fy + (ball.h/2) -1, 1, 2)) then
        printh('collide right')
        ball.vx = abs(ball.vx)
    end
    -- bottom
    if(solid_area(fx + (ball.w/2) -1, fy + ball.h -1, 2, 1)) then
        printh('collide bottom')
        ball.vy = abs(ball.vy) * -1
    end
    -- right
    if(solid_area(fx + ball.w -1, fy + (ball.h/2) -1, 1, 2)) then
        printh('collide left')
        ball.vx = abs(ball.vx) * -1
    end

    ball.x += ball.vx
    ball.y += ball.vy

end


function solid(x, y)
    v=tget(x, y)
    return fget(v, 1)
end

-- Return the tile for a given pixel
function tget(x, y)
    return mget(flr(x/grid.w), flr(y/grid.h))
end

-- solid_area
-- check if a rectangle overlaps
-- with an area
--(this version only works for
--actors less than one tile big)
function solid_area(x,y,w,h)
    -- Check top-left, top-right, bottom-right, bottom-left
    return
        solid(x,y) or
        solid(x+w,y) or
        solid(x+w,y+h) or
        solid(x,y+h)
end


-- lose

function init_lose()
    mode = 2
    print("you lose", 48, 76)
    print("press start to try again", 18, 84)
end

function update_lose()
    if btn(4) then
        init_game()
    end
end

function draw_lose()

end

-- core functions

function _init()
    init_title() -- does title things.
end

function _update()
    if (mode == 0) then --title screen mode
        update_title()
    elseif (mode == 1) then
        update_game()
    else
        update_lose()
    end
end

function _draw()
    if (mode == 0) then
        draw_title()
    elseif (mode == 1) then
        draw_game()
    else
        draw_lose()
    end
end
__gfx__
0000000000dd00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000d66d00000117777777777777777220000cc7777777777777777220000117777777777777777880000cc700000000000000788000000000000000000
00700700dddd6d00011ffffffffffffffffff2200ccffffffffffffffffff220011ffffffffffffffffff8800ccff77777777777777ff8800000000000000000
00077000dddddd0001ffffffffffffffffffff200cffffffffffffffffffff2001ffffffffffffffffffff800cffffffffffffffffffff800000000000000000
0007700005dd500001ffffffffffffffffffff200cffffffffffffffffffff2001ffffffffffffffffffff800cffffffffffffffffffff800000000000000000
0070070000550000011ffffffffffffffffff2200ccffffffffffffffffff220011ffffffffffffffffff8800ccffffffffffffffffff8800000000000000000
000000000000000000116666666666666666220000cc6666666666666666220000116666666666666666880000cc666666666666666688000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00800e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
088ee8e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
088888e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
08888880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00288800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00022000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3bbbbbbb1ccccccc9aaaaaaa2eeeeeee1ddddddd0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3333333b1111111c9999999a2222222e1000000d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5333d33b5111d11c5999d99a5222d22e1000000d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
53333d3b51111d1c59999d9a52222d2e1000000d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5333333b5111111c5999999a5222222e1000000d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5333333b5111111c5999999a5222222e1000000d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
533333335111111159999999522222221000000d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
55555533555555115555559955555522111111110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0aaaaaaaa00000aaa0000000aaaaa00000aa0000aa0000000aaa0000000aaaa00000aa0000aaaaa0000aa00aaaa0000000000000000000000000000000000000
09999999a00009999a00000099999aa0009a00099a0000009999a000000999a000009a00009999a00009a009999a000000000000000000000000000000000000
09900000000009909a0000009900999a009a0099900000009909a0000009999a00009a000999099a0009a0099099a00000000000000000000000000000000000
09a000000000999099a000009a00009a009a00990000000999099a000009909a00009a000990009a0009a009a0099a0000000000000000000000000000000000
09a000000000990009a000009a00009a009a09990000000990009a000009a099a0009a0099900099a009a009a0009a0000000000000000000000000000000000
0999aaa000099900099a00009a00009a0099999000000099900099a00009a009a0009a0099000009a009a009a0009a0000000000000000000000000000000000
099999a000099000009a00009a009999009999a000000099000009a00009a0099a009a0099000009a009a009a0009a0000000000000000000000000000000000
09900000009990000099a00099aa9990009999a0000009990000099a0009a0009a009a009a000009a009a009a0009a0000000000000000000000000000000000
09a0000000990aaaaa09a000999990000099099a00000990aaaaa09a0009a00099a09a0099a00099a009a009a0009a0000000000000000000000000000000000
09a000000999099999099a0099099a00009a009a0000999099999099a009a00009a09a0009a000990009a009a0099a0000000000000000000000000000000000
09a000000990000000009a009a0099a0009a0099a000990000000009a009a000099a9a00099a09990009a009a099900000000000000000000000000000000000
09a000000990000000009a009a00099a009a00099a00990000000009a009a00000999a000099a9900009a0099a99000000000000000000000000000000000000
09a0000009900000000099009a00009a009a000099009900000000099009a00000999a0000999990000990099990000000000000000000000000000000000000
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
2424242424242424242424242424242400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2400000000000000000000000000002400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2400000000000000000000000000002400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2400000024242424000000000000002400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2400000024000000000000000000002400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2400000024000000000000000000002400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2400000000000000000024000000002400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2400000000000000000024000000002400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2411111124111111111124242411112400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2400000000110000000000000000002400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2400000000000000000000000000002400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2400000000000000000000000000002400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2400000000000000000000000000002400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2400000000000000000000000000002400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2400000000000000000000000000002400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2424242424242424242424242424242400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2424242424242424242424242424242400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100003702037000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00100000160503d000000001b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00100000337502b7503075035700317002e7002c7002d7003620031100352002b10033200322001f100307003070030700307003070030700000000000000000000000e000000000000000000000000000000000
0010000018450184501845000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001d6001760019600226001b60000000000000000000000
