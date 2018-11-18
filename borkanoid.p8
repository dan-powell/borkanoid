pico-8 cartridge // http://www.pico-8.com
version 16
__lua__

-- borkanoid - an arkanoid/pinball hybrid thing by dannysomething (dan-powell.uk)

-- todo

-- falling pickups for bonus points
-- score screen
-- refine gfx
-- better sfx!
-- music!

-- basic de-buggery
debug = {}
frame = 0
version = "0.4.1 beta"
lvlselect = {0,0,1,1,0,1}

-- tile grid
grid = {}
grid.w = 8
grid.h = 8

-- actor tables
pickups = {}
balls = {}
paddles = {}

-- core physics values
physics = {}
physics.gravity = 0.2
physics.fx = 0.02
physics.fy = 0.03
physics.vxmax = 2 -- max x velocity
physics.vymax = 5 -- max y velocity
physics.vymax_pos = 10 -- max y velocity


-- config defaults
config = {
    ball = {
        w = 5, -- width
        h = 5, -- height
        x = 0, -- absolute x position
        y = 0, -- absolute y position
        vx = 0, -- x velocity (pixels moved per frame)
        vy = 0, -- y velocity (pixels moved per frame)
        m = 1, -- mass
        e = 0, -- energy
        g = 0.2, -- gravity
        fx = 0.02, -- friction x
        fy = 0.03, -- friction y
        s = 4 -- sprite
    },
    paddle = {
        t = 1, -- type 1 = main, 2 = space
        w = 40, -- width
        h = 8, -- height
        ho = 3, -- height offset (for calculating collisions)
        x = 0, -- absolute x position
        y = 0, -- absolute y position
        vx = 0, -- x velocity (pixels moved per frame)
        fx = 0.7, -- friction
        f = 4, -- force applied when moved
        sw = 5, -- sprite width (in tiles)
        sh = 1, -- sprite height (in tiles)
        d = -1 -- direction (+1 right -1 left)
    },
    pickup = {
        t = 0,
        w = 8, -- width
        h = 8, -- height
        x = 0, -- absolute x position
        y = 0, -- absolute y position
    }
}


-- camera attributes
cam = {
    x = 0,
    y = 0,
    w = 128,
    h = 128,
    b = 0
}
cam.c = flr(cam.h/2)

-- level attributes
levels = {
    {
        title = "level 1",
        next = 2,
        tw = 16, -- width in tiles
        th = 16, -- height in tiles
        w = 128, -- width in pixels
        h = 128, -- height in pixels
        mx = 0, -- map tile x coordinate
        my = 0, -- map tile y coordinate
        b = 4, -- number of bricks (so we know when cleared)
        be = 64, -- ball boost amount
        pc = 50, -- pickup chance %
        paddles = {}
    },
    {
        title = "level 2",
        next = 3,
        tw = 16,
        th = 16,
        w = 128,
        h = 128,
        mx = 0,
        my = 16,
        b = 6,
        be = 64,
        pc = 50,
        paddles = {}
    },
    {
        title = "level 3",
        next = 4,
        tw = 16,
        th = 24,
        w = 128,
        h = 192,
        mx = 0,
        my = 32,
        b = 6,
        be = 128,
        pc = 50,
        paddles = {}
    },
    {
        title = "level 4",
        next = 5,
        tw = 16,
        th = 16,
        w = 128,
        h = 128,
        mx = 16,
        my = 0,
        b = 10,
        be = 64,
        pc = 25,
        paddles = {}
    },
    {
        title = "level 5",
        next = 6,
        tw = 16,
        th = 16,
        w = 128,
        h = 128,
        mx = 16,
        my = 16,
        b = 20,
        be = 64,
        pc = 20,
        paddles = {}
    },
    {
        title = "level 6",
        next = 7,
        tw = 16,
        th = 32,
        w = 128,
        h = 256,
        mx = 16,
        my = 32,
        b = 18,
        be = 128,
        pc = 30,
        paddles = {
            {
                y = 128
            },
        }
    },
    {
        title = "level 7",
        next = 8,
        tw = 16,
        th = 16,
        w = 128,
        h = 128,
        mx = 32,
        my = 0,
        b = 24,
        be = 64,
        pc = 20,
        paddles = {}
    },
    {
        title = "level 8",
        next = 9,
        tw = 16,
        th = 16,
        w = 128,
        h = 128,
        mx = 32,
        my = 16,
        b = 4,
        be = 64,
        pc = 50,
        paddles = {}
    },
    {
        title = "level 9",
        next = 10,
        tw = 16,
        th = 32,
        w = 128,
        h = 256,
        mx = 32,
        my = 32,
        b = 18,
        be = 128,
        pc = 30,
        paddles = {
            {
                y = 128
            },
        }
    },
    {
        title = "level 10",
        next = 0,
        tw = 16,
        th = 48,
        w = 128,
        h = 384,
        mx = 48,
        my = 16,
        b = 12,
        be = 128,
        pc = 30,
        paddles = {
            {
                y = 120
            },
            {
                y = 256
            },
        }
    },
    {
        title = "bonus level",
        next = 0,
        tw = 16,
        th = 64,
        w = 128,
        h = 512,
        mx = 112,
        my = 0,
        b = 118,
        be = 128,
        pc = 2,
        paddles = {
            {
                y = 128
            },
            {
                y = 256
            },
            {
                y = 384
            },
        }
    },
}
level = levels[1]

-- ====================================
-- title
-- ====================================

function init_title()
    printh('title')
    -- set the state of the game
    state = 0
    -- 0 start screen
    -- 1 game
    -- 2 score screen
    -- music(01)
    lvlselect_input = {-1,-1,-1,-1,-1,-1}
end


function update_title()

    if btnp(0) then
        del(lvlselect_input, lvlselect_input[1])
        add(lvlselect_input, 0)
    end
    if btnp(1) then
        del(lvlselect_input, lvlselect_input[1])
        add(lvlselect_input, 1)
    end
    local test = true
    for k, v in pairs(lvlselect_input) do
        if v != lvlselect[k] then
            test = false
        end
    end
    if test then
        init_lvlselect()
    end

    if btnp(5) then
        init_game()
    end
end

function draw_title()
    cls(1)
    spr(64, 16, 16, 12, 2) -- title
    -- spr(16 + (4 * (frame % 3)), 48, 58, 4, 1)
    spr(76, 96, 96, 4, 4) -- bork

    if(not flash) flash=0
    if(frame%(30/2)==0) then
        flash += 1
    end
    -- print(flash, 30, 76, 9)
    if flash%2 == 1 then
        print("press ❎ to start", 30, 40, 9)
    end

    print("instructions:", 2, 64, 15)
    print("destroy all blocks", 2, 72, 10)
    print("move to change bounce angle", 2, 80, 10)
    print("hold ❎ for power shot", 2, 88, 10)
    print(version, 3, 120, 2)
end

-- ====================================
-- game
-- ====================================

function init_game()
    start()
    state = 1
    status = 0
    reset()
end

-- --------------------------
-- game logic
-- --------------------------

function update_game()

    if status == 0 then
        -- start of level
        if btnp(5) then
            launch_ball()
            status = 1
        end
    end

    if status == 2 then
        -- level complete
        if btnp(5) then
            next()
        end
    end

    if status == 3 then
        -- level lost
        if btnp(5) then
            finish()
        end
    end

    if status == 4 then
        -- game won
        if btnp(5) then
            finish()
        end
    end

    if status < 2 then
        -- level in progress
        update_debounce()
        move_actors()
        update_camera()
        check_win()
        if status == 1 then
            check_lost()
        end
    end


end

-- start the game
function start()
    player = {}
    player.lives = 6
    player.score = 0
    player.lvl = 0
    player.bricks = 0
    player.bonus = 0
    player.bounces = 0
end

-- reset balls & paddles
function reset()
    status = 0
    balls = {}
    paddles = {}
    pickups = {}
    paddle = add_paddle(level.h - 8, 1)
    for k,p in pairs(level.paddles) do
        add_paddle(level.paddles[k].y, 2)
    end
end

function next()
    if level.next == 0 then
        init_scores()
    else
        level = levels[level.next]
    end
    player.lvl += 1
    reset()
end

function finish()
    init_scores()
end

-- create a new ball instance
function new_ball()
    local b = {}
    for k, v in pairs(config.ball) do
        b[k] = v
    end
    return b
end

-- add a ball to the game engine
function add_ball(x, y)
    local b = new_ball()
    b.x = x -- starting x position (absolute)
    b.y = y -- starting y position (absolute)
    b.vx = rnd(2) - 1 -- starting x velocity
    b.vy = rnd(3) * -1 -- starting y velocity
    add(balls, b)
    return b
end

function new_paddle()
    local p = {}
    for k, v in pairs(config.paddle) do
        p[k] = v
    end
    return p
end

-- add a ball to the game engine
function add_paddle(y, t)
    local p = new_paddle()
    p.x = flr(level.w/2)
    p.y = y
    p.t = t
    add(paddles, p)
    return p
end

function launch_ball()
    local b = new_ball()
    -- x depends on direction of main paddle
    if paddle.d > 0 then
        b.x = paddle.x + paddle.w - 6
    else
        b.x = paddle.x + 3
    end
    b.y = paddle.y - 3
    b.vx = 0
    b.vy = -2
    add(balls, b)
end

function new_pickup()
    local p = {}
    for k, v in pairs(config.pickup) do
        p[k] = v
    end
    return p
end

function add_pickup(x, y)

    local r = flr(rnd(3));
    if r >= 1 then
        local p = new_pickup()
        p.x = x
        p.y = y
        p.t = r
        add(pickups, p)
    else
        add_ball(x,y)
    end

end

-- check if level win critera achieved
function check_win()
    if level.b <= 0 then
        if level.next == 0 then
            status = 4
        else
            status = 2
        end
    end
end

-- check if lost life criteria achieved
function check_lost()
    if count(balls) <= 0 then
        -- todo lose a life
        player.lives -= 1
        reset()
        if player.lives <= 0 then
            status = 3
        end
    end
end

-- update the camera position
function update_camera()

    local ball = active_ball()
    if ball then
        -- in play, focus on balls
        local y = ball.y - (cam.y+cam.h/2) -- y offset of ball from center of cam
        -- center the camera on the ball, but only if it approaches edges of screen
        if y > 30 or y < -30 then
            cam.y += y/6
        end
    else
        -- no balls, focus on paddle
        cam.y = paddle.y
    end

    -- limit the camera to stop it revealing outside of map
    if cam.y < 0 then
        cam.y = 0
    elseif cam.y > level.h - cam.h then
        cam.y = level.h - cam.h
    end

end

-- return the currently active ball (nearest to bottom of level)
function active_ball()
    if count(balls) > 0 then
        local ball = balls[1]
        for i = 1, count(balls) do
            if balls[i].y > ball.y then
                ball = balls[i]
            end
        end
        return ball
    else
        return false
    end
end

-- update all actors
function move_actors()
    foreach(balls, move_ball)
    foreach(paddles, move_paddle)
    foreach(pickups, move_pickup)
end

-- update position of bat
function move_paddle(p)

    -- create a force acting on the bat
    local f = 0
    if btn(0) then p.vx -= p.f end
    if btn(1) then p.vx += p.f end

    -- apply friction
    p.vx *= p.fx

    -- set the direction
    if p.vx > 1 or p.vx < -1 then
        p.d = p.vx
    end

    -- set new position of bat
    p.x += p.vx

    -- paddle can't leave level edges
    local offset = 0
    if status == 0 then
        offset = 8
    end

    if p.x < offset then
        p.x = offset
        p.vx = 0
    end
    if p.x > level.w - p.w - offset then
        p.x = level.w - p.w - offset
        p.vx = 0
    end
end

-- update position of ball
function move_ball(b)

    -- create a fake ball
    local fake = b
    fake.vx = velocity_x(b.vx, b.m, b.e, b.fx)  -- add a friction coefficient
    fake.vy = velocity_y(b.vy, b.m, b.e, b.fy) -- add a friction coefficient + gravity
    fake.x = b.x
    fake.y = b.y

    -- figure out number of pixels ball will move this frame
    local i = abs(fake.vx) + abs(fake.vy)
    fake.ivx = fake.vx/i
    fake.ivy = fake.vy/i

    -- for each pixel, test if fake will collide, and adjust velocity accordingly
    local lose = false
    local cp = 0
    for x=0,i do

        -- does the ball fall of the bottom of the level?
        if fake.y + fake.h > level.h then
            lose = true
        end

        -- check collisions with map
        local cw = ball_collision(fake)
        if cw == 1 then fake.ivy = abs(fake.ivy) end -- top, bounce down
        if cw == 2 then fake.ivx = abs(fake.ivx) * -1 end -- right, bounce left
        if cw == 3 then fake.ivy = abs(fake.ivy) * -1 end -- bottom, bounce up
        if cw == 4 then fake.ivx = abs(fake.ivx) end -- left, bounce right
        if cw > 0 then
            sfx(0)
        end

        -- check collisions with paddles
        cp = collide_paddle(fake.x + flr(fake.w/2), fake.y + fake.h -1)
        if cp > 0 then
            -- paddles[cp].s = 28
            player.bounces += 1
            if(btn(5)) then
                b.e += level.be
                sfx(2)
            else
                sfx(1)
            end
            fake.ivx = (fake.ivx - fake.ivx/2) + paddles[cp].vx/4 -- x velocity adjustment
            fake.ivy = (abs(fake.ivy) * -1) - 1 - abs(paddles[cp].vx/4)-- y velocity adjustment

        end -- bottom, bounce up

        fake.x += fake.ivx
        fake.y += fake.ivy

    end

    -- bring it all together and update the actual velocity
    b.vx = fake.ivx * i --limit_velocity(fake.ivx * i)
    b.vy = fake.ivy * i

    b.x = fake.x
    b.y = fake.y

    if(b.e > 0) then
        b.e = b.e - (abs(b.vx) + abs(b.vy))
    else
        b.e = 0
    end

    if lose then
        -- remove the ball
        del(balls, b)
        sfx(6)
    end

end

function move_pickup(p)
    p.y += 1

    cp = collide_paddle(p.x + flr(p.w/2), p.y + p.h -1)
    if cp > 0 then
        if p.t == 1 then
            player.lives += 1
        else
            player.score += 1000
        end
        del(pickups, p)
    end

    -- fallen off screen
    if p.y + p.h > level.h then
        del(pickups, p)
    end
end

-- velocity, mass, energy, friction
function velocity_x(v, m, e, f)
    return limit_vx(v)
end

function velocity_y(v, m, e, f)
    if e > 0 then
        return limit_vy(v)
    else
        return limit_vy(v * friction(f) + 0.5)
    end
end

-- velocity, mass, energy, friction
function friction(f)
    return 1 - f
end

-- limit velocity to +/- l
function limit_vx(x)
    if x > 0 then
        return min(x, physics.vxmax)
    elseif x < 0 then
        return max(x, physics.vxmax * -1)
    else
        return 0
    end
end

function limit_vy(y)
    if y > 0 then
        return min(y, physics.vymax)
    elseif y < 0 then
        return max(y, physics.vymax_pos * -1)
    else
        return 0
    end
end

-- check if any side of ball collides with a wall. returns integer depending on side of collision
function ball_collision(b)
    if collide(b.x + flr(b.w/2), b.y) then return 1 end -- 1 top
    if collide(b.x + b.w -1, b.y + flr(b.h/2)) then return 2 end -- 2 right
    if collide(b.x + flr(b.w/2), b.y + b.h -1) then return 3 end -- 3 bottom
    if collide(b.x, b.y + flr(b.h/2)) then return 4 end -- 4 left
    return 0 -- 0 nuffin
end

-- test if position contains a bat. returns the bat number if collisioned
function collide_paddle(x, y)
    for i=1,count(paddles) do
        if x > paddles[i].x and x < paddles[i].x + paddles[i].w and y > paddles[i].y + paddles[i].ho and y < paddles[i].y + paddles[i].h then
            return i
        end
    end
    return 0
end

-- debounce - used in relation tiles
debounce = {}
function set_debounce(x,y,v)
    x += (level.mx * 8)
    y += (level.my * 8)
    local i = flr(x/grid.w) + level.tw * flr(y/grid.h)
    debounce[i] = v
end

function has_debounce(x,y)
    x += (level.mx * 8)
    y += (level.my * 8)
    local i = flr(x/grid.w) + level.tw * flr(y/grid.h)
    local d = debounce[i]
    if d == nil then
        return false
    end
    if d <= 0 then
        return false
    end
    return true
end

-- decrement all debounce values (each frame)
function update_debounce(x,y)
    for k, v in pairs(debounce) do
        debounce[k] -= 1
    end
end

-- collide with a collidable tile
function collide(x, y)
    t=tget(x, y)
    -- test if tile is physical
    if fget(t, 0) then
        -- test if tile is a brick
        if fget(t, 1) then

            -- check if tile has a debounce value
            if has_debounce(x,y) == false then
                if fget(t, 5) then
                    -- 4th brick
                    tset(x, y, t-1)
                    player.score += 25
                    sfx(2)
                elseif fget(t, 4) then
                    -- 3rd brick
                    tset(x, y, t-1)
                    player.score += 50
                    sfx(3)
                elseif fget(t, 3) then
                    -- 2nd brick
                    tset(x, y, t-1)
                    player.score += 75
                    sfx(4)
                elseif fget(t, 2) then
                    -- lightest brick
                    tset(x, y, 0)
                    player.score += 100
                    level.b -= 1
                    player.bricks += 1
                    if ceil(rnd(100)) <= level.pc then
                        add_pickup(x,y)
                        sfx(2)
                    else
                        sfx(5)
                    end
                end
                set_debounce(x,y,4) -- set a debounce on tile
            end
        end
        return true
    else
        return false
    end
end

-- return the tile at a given pixel position
function tget(x, y)
    x += (level.mx * 8)
    y += (level.my * 8)
    return mget(flr(x/grid.w), flr(y/grid.h))
end

-- set the tile at a given pixel position
function tset(x, y, v)
    x += (level.mx * 8)
    y += (level.my * 8)
    return mset(flr(x/grid.w), flr(y/grid.h), v)
end

-- --------------------------
-- game drawing
-- --------------------------

function draw_game()
    cls(0)
    map(level.mx,level.my,0,0,level.tw,level.th)
    draw_actors()
    -- print(stat(0), 9, cam.y + cam.h - 16, 7) -- debug memory
    -- print(stat(1), 9, cam.y + cam.h - 8, 7) -- debug cpu
    camera(0, cam.y)
    draw_ui()
    if status == 0 then
        print('❎ to launch', cam.x + flr(cam.w/2) - 24, cam.y + flr(cam.h/2) + 30, 9)
    end
    if status == 2 then
        print('level complete', cam.x + flr(cam.w/2) - 26, cam.y + flr(cam.h/2) + 20, 12)
        print('❎ for next level', cam.x + flr(cam.w/2) - 32, cam.y + flr(cam.h/2) + 30, 9)
    end
    if status == 3 then
        print('you lost :(', cam.x + flr(cam.w/2) - 20, cam.y + flr(cam.h/2) + 20, 8)
        print('❎ for scores', cam.x + flr(cam.w/2) - 28, cam.y + flr(cam.h/2) + 30, 9)
    end
    if status == 4 then
        print('you win!', cam.x + flr(cam.w/2) - 16, cam.y + flr(cam.h/2) + 20, 3)
        print('❎ for scores', cam.x + flr(cam.w/2) - 28, cam.y + flr(cam.h/2) + 30, 9)
    end
end

function draw_actors()
    foreach(balls, draw_ball)
    foreach(paddles, draw_paddle)
    foreach(pickups, draw_pickup)
end

function draw_ball(b)
    spr(b.s, b.x, b.y)
end

function draw_ui()
    -- draw lives
    for i = 1, min(player.lives,6) do
        spr(5, cam.x + cam.w - 9 - (i*8), cam.y + 9)
    end

    if player.lives - 6 > 0 then
        print('+' .. player.lives - 6, cam.x + cam.w - 68, cam.y + 9, 8)
    end

    -- draw score
    print(player.score, cam.x + 9, cam.y + 9, 9)
end

function draw_paddle_marker(p)

    local y = cam.y + cam.h - 12
    spr(1, p.x, y, 1, 1) -- start
    for i=1, p.sw - 2 do
        spr(2, p.x + i * grid.w, y, 1, 1) -- middle
    end
    spr(3, p.x + p.w - grid.w, y, 1, 1) -- end

end


-- draw the main paddle
function draw_paddle_1(p)
    -- loop walking animation

    local m = {30,31,30}

    -- set sprite depending on direction
    local l = 16
    local r = 24
    local lm = {17, 18}
    local rm = {25, 26}
    if p.d > 0 then
        l = 27
        r = 20
        lm = {28, 29}
        rm = {21, 22}
    end

    -- animation loop
    if(not loop) loop=1
    if p.vx < -1 or p.vx > 1 then
        if(frame%(30/15)==0) then
            loop += 1
        end
        if loop > count(lm) then loop = 1 end
        spr(lm[loop], p.x, p.y, 1, 1) -- start
        spr(rm[loop], p.x + p.w - grid.w, p.y, 1, 1) -- end
    else
        spr(l, p.x, p.y, 1, 1) -- start
        spr(r, p.x + p.w - grid.w, p.y, 1, 1) -- end
    end

    for i=1, p.sw - 2 do
        spr(m[i-1%count(m)+1], p.x + i * grid.w, p.y, 1, 1) -- middle
    end

end

-- draw the space dog
function draw_paddle_2(p)
    local l = 9
    local m = {10,11,11}
    local r = 12
    if p.d > 0 then
        l = 13
        m = {11,11,14}
        r = 15
    end
    spr(l, p.x, p.y, 1, 1) -- start
    for i=1, p.sw - 2 do
        spr(m[i-1%count(m)+1], p.x + i * grid.w, p.y, 1, 1) -- middle
    end
    spr(r, p.x + p.w - grid.w, p.y, 1, 1) -- end
end


function draw_paddle(p)

    -- draw a marker for the bat if off the bottom of the cam
    if p.y > cam.y + cam.h - grid.h then
        draw_paddle_marker(p)
    end

    if p.t == 2 then
        draw_paddle_2(p)
    else
        draw_paddle_1(p)
    end

    if status == 0 and p.d > 0 then
        spr(config.ball.s, paddle.x + paddle.w - 2, paddle.y + 3)
    end

    -- add a ball to doggo if start of level
    if status == 0 and p.d < 0 then
        spr(config.ball.s, paddle.x - 3, paddle.y + 3)
    end

end

function draw_pickup(p)
    if p.t == 1 then
        s = {5,6}
    else
        s = {7,8}
    end

    if(not a) a=1
    if(frame%(8)==0) then
        a += 1
    end
    if a > count(s) then a = 1 end
    spr(s[a], p.x, p.y, 1, 1) -- start

end

-- ====================================
-- lose
-- ====================================

function init_scores()
    state = 2
end

function update_scores()
    if btnp(5) then
        run()
    end
end

function draw_scores()
    if player.lives > 0 then
        cls(3)
        print("good jorb", 48, 24, 11)
    else
        cls(2)
        print("try again next time", 24, 24, 11)
    end
    camera(0,0)
    spr(76, 96, 96, 4, 4) -- bork

    print("score: " .. player.score, 48, 32, 7)
    print("levels: " .. player.lvl, 48, 48, 7)
    print("bricks: " .. player.bricks, 48, 56, 7)
    print("bounces: " .. player.bounces, 48, 64, 7)
    print("lives left: " .. player.lives, 48, 72, 7)
    print("❎ to try again", 24, 96, 9)
end

-- ====================================
-- lose
-- ====================================

function init_lvlselect()
    state = 3
    select = 1
end

function update_lvlselect()
    if btnp(0) and select > 1 then
        select -= 1
    end

    if btnp(1) and select < count(levels) then
        select += 1
    end

    if btnp(5) then
        level = levels[select]
        init_game()
    end
end

function draw_lvlselect()
    cls(0)
    print("level select", 48, 32, 7)
    print(select, 48, 48, 7)
end

-- ====================================
-- state management
-- ====================================

function _init()
    init_title() -- does title things.
end

function _update()
    frame += 1
    if (state == 0) then --title screen state
        update_title()
    elseif (state == 1) then
        update_game()
    elseif (state == 2) then
        update_scores()
    elseif (state == 3) then
        update_lvlselect()
    end
end

function _draw()
    if (state == 0) then
        draw_title()
    elseif (state == 1) then
        draw_game()
    elseif (state == 2) then
        draw_scores()
    elseif (state == 3) then
        draw_lvlselect()
    end
end
__gfx__
00000000700000000000000000000007007000000ee0ee000ff0ff00000005700770000000777700000000000000000000000000000000000000000000777700
0000000077555555555555555555557707b70000888888e0eeeeeef00000056766700000070000700055fe8000000000000000000000000008ef550007000070
000000007000000000000000000000073bbb7000288888e02eeeeef00000666755670000600909070555e802000000000000000000000000208e555060909007
0000000000000000000000000000000003b300000288880002eeee00000666000066700060c4c4070070000000000000000000099000000000000700604c4c07
000000000000000000000000000000000030000000282000002e2000006660000006660069444447447444444444444445777704407777544444474464444497
00000000000000000000000000000000000000000002000000020000766600000000666706444464447444444444444457777744447777754444474446444460
00000000000000000000000000000000000000000000000000000000666000000000066700666604000000000000000000070700007070000000000040666600
00000000000000000000000000000000000000000000000000000000055000000000055000000202000000000000000000020200002020000000000020200000
00900900009009000090090000900900009009000090090000900900009009000000000000000000000000000000000000000000000000000000000000000000
04444400044444000444440004444400004444400044444000444440004444400000000000000000000000000000000000000000000000000000000000000000
9c4c44009c4c44009c4c44009c4c44000044c4c90044c4c90044c4c90044c4c90000000900000009000000099000000090000000900000000000000000000000
444444244444442444444424000044244244444442444444424444444244000044444404444444044444440440444444404444444044444444dddd4444444444
0444424404444244044442440444424444244440442444404424444044244440444444444444444444444444444444444444444444444444444dd444444dd444
00022444000224440002244400022444444220004442200044422000444220004444440044444400444444000044444400444444004444444444444444dddd44
00604040006090400060409000604040040406000409060009040600040406000004040000040900000904000040400000409000009040000000000000000000
00009090000000900000900000009090090900000900000000090000090400000009090000090000000009000090900000900000000090000000000000000000
45556666666655544444444466666666666666666666666666665554455566664555666666665554444444444444444444444444444444444444444445566554
45556666666655545555555566666666666666666666666666666555555666664555666666665554455555555555555445555555555555544555555445566554
45556666666655545555555566666666666666666666666666666655556666664555566666655554455555555555555445555555555555544555555445566554
45556666666655545555555566666666666666666666666666666665566666664555556666555554455555555555555445566666666665544556655445566554
45556666666655546666666655555555666666655666666666666666666666664555555555555554455555666655555445566666666665544556655445566554
45556666666655546666666655555555666666555566666666666666666666664555555555555554455556666665555445555555555555544556655445555554
45556666666655546666666655555555666665555556666666666666666666664555555555555554455566666666555445555555555555544556655445555554
45556666666655546666666644444444666655544555666666666666666666664444444444444444455566666666555444444444444444444556655444444444
0bbbbbb00aaaaaa009999990066666600cccccc0011111100ffffff00eeeeee00888888002222220000000000000000066666666202020204000000550000004
bbbb66bbaaaa77aa9999aa9966667766cccc66cc1111cc11ffff77ffeeee77ee8888ee882222ee22000000000000000066666666000000004000000000000004
bbbbb66baaaaa77a99999aa966666776ccccc66c11111cc1fffff77feeeee77e88888ee822222ee2000000000000000066666666000000004000000550000004
bbbbbb6baaaaaa7a999999a966666676cccccc6c111111c1ffffff7feeeeee7e888888e8222222e2000000000000000066666666000000004000000000000004
b3bbbbbba9aaaaaa9499999965666666c1cccccc15111111f5ffffffe2eeeeee8288888821222222000000000000000066666666000000004000000550000004
b33bbbbba99aaaaa9449999965566666c11ccccc15511111f55fffffe22eeeee8228888821122222000000000000000066666666000000004000000000000004
bb33bbbbaa99aaaa9944999966556666cc11cccc11551111ff55ffffee22eeee8822888822112222000000000000000066666666000000004000000550000004
0bbbbbb00aaaaaa009999990066666600cccccc0011111100ffffff00eeeeee00888888002222220000000000000000066666666020202024000000000000004
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000aaaaa000000aaaaa0000aaaaa00000aa0000aa0000000aaa0000000aaaa00000aa0000aaaaa0000aa00aaaa0000000000000000990000000000000000000
000099999a000009999a000099999aa0009a00099a0000009999a000000999a000009a00009999a00009a009999a000000000000009999000000000000999000
0000990099a000999099a0009900999a009a0099900000009909a0000009999a00009a000999099a0009a0099099a00000000000099999000000000009999000
00009a0009a000990009a0009a00009a009a00990000000999099a000009909a00009a000990009a0009a009a0099a0000000000099999900000000999999000
00009a0099a0099900099a009a00009a009a09990000000990009a000009a099a0009a0099900099a009a009a0009a0000000000099999900000009999999000
00009a099900099000009a009a00009a0099999000000099900099a00009a009a0009a0099000009a009a009a0009a0000000000099999444444449999999000
000099a99000099000009a009a009999009999a000000099000009a00009a0099a009a0099000009a009a009a0009a0000000000099444444444444499990000
000099999a0009a000009a0099aa9990009999a0000009990000099a0009a0009a009a009a000009a009a009a0009a0000000000004444444444444499990000
0000990099a0099a00099a00999990000099099a00000990aaaaa09a0009a00099a09a0099a00099a009a009a0009a00000000000444444c4444444449990000
00009a0009a0009a0009900099099a00009a009a0000999099999099a009a00009a09a0009a000990009a009a0099a000999000444c444ccc444444444990000
00009a0099a00099a09990009a0099a0009a0099a000990000000009a009a000099a9a00099a09990009a009a0999000999990444ccc444c4444444444400000
000099aa990000099a9900009a00099a009a00099a00990000000009a009a00000999a000099a9900009a0099a9900009999994444c444444444444444400000
0000999990000009999900009a00009a009a000099009900000000099009a00000999a0000999990000990099990000099999444444444444444404444400000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000009994444444444444444004444400000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000444444444444444000004444400000
0000000000000000000000000000005500000000000005550000000000d000000000000000000000000000000000000000004444444400000000004444400000
0000000000000000000d000005555555550555500555555000000000006000000000000505500000055555500001100000000000000000008888844444422000
00000d00000000000000000000055555555000000055550000000000d666d0000055555500555555550550000011110000000000000888888888444444222000
000000000d0000000000000000000000000000000005500000000d00006000000000555555000000000000002111111200000000088e88844444444444222444
0000000000000000000000000000000555000555000000000000ddd000d00000555555550000555500000000222222220000000008888ee44444444422222444
00000000000000d00000000005500055555555555550000000000d000000000000055550555555505555555500111100000000008888ee444444442222244444
0000000000000000000000d00000555555500000055550000000000000000000000000550000050000505550000110000000000488eee4444444422222444444
00000000000000000000000000055500000000000000000000000000000000000000000000000000000000000000000000000004444444444442222224444444
0000000000000000000000010d000000000000000000000000000000000000000000000000000000000000000000000000000000444444444222222444444444
000000000000000000000000d6d00000000000000000000000000000000000000000000000600000000000000000000000000000000000000222224444444444
0d00000000000000000000000d000000000000000000000000006660066600000006600006666600000070000020000000000000000000066600044444444444
00000000000000000000000000000000010000000000000006660066660066660666066666006660000000000000000000000000000000066600044444444444
00000200000d00000000000000000000000000000000000000000000060660006660666066666666000000000000000000000000000000066600044444404444
00000000000000000000000000000000000000000000000000666600066600000066660006666600000000000000000000000000000000000000044444404444
000000000000010000d0000000000000000000000000100000006000000000000000000000000000000000000000000000000000000000000000044444000444
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000044444000444
423232323232323232323232323232524232323232323232323232323232325242323232323232323232323232323252b20000000000570000260000000000a2
120000000000570000260000000000021200000000005700002600000000000212000000000057000026000000000002e34040404040404040404040404040f3
12000000000000000000000000000002120000000000000000000026000000021200000000070000000000000000000212000000000700000000000000000002
120000000007000000000000000000021200000000070000000000000000000212000000000700000000000000000002b20000000000000000000000000000a2
120000364656000000000000007600021200000026000047b7004700007600021200570000000000070000000000000212005753000053000753000053000002
12005700000000000700000057000002120057000000000007000000570000021200570000000000070000005700000212000000000000000000000000000002
1216000000000000008696a600000002121600000000000000000000000000021200000000000057000000b7000000021200000000000057000000b700000002
1200000000000057000000b7000000021200000000000057000000b7000000021200000000000057000000b70000000212000000000000000000000000000002
120000b7000000000000000000000002120000230303230000230303230000021200000026864656000000000000000212000000268646560000000000000002
12000000260000000000000000000002120000002600000000000000000000021200000026000000000000000000000212000000000000000000000000000002
1200000000530000000053000000000212000000470000004700270000000002120000000000000057572600b7000002120000000000000057572600b7000002
120000000000000057572600b7000002120000000000000057572600b7000002120000000000000057572600b700000212939393939393939393939393939302
12000000000000000000000027000002120000000000000000000000270000021200005700000000000000000000000212000057000000000000000000000002
12000057000000000000000000000002120000570000000000000000000000021200005700000000000000000000000212535353535353535353535353535302
12007600b700000000002700000000021200760000b70000000027000000000212000000b7000000b70000000000000212000000b7000000b700000000000002
12000000b7000000b70000000000000212000000b7000000b70000000000000212000000b7000000b70000000000000212232323232323232323232323232302
12000027000000270000000000000002120000270000c727000000000000000212000000000000003696a6000000000212000000000000003696a60000000002
12000000000000000000000000000002120000000000000000000000000000021200000000000000000000000000000212030303030303030303030303030302
120000000000000000b7000000160002120000003646560000470000001600021256005757260000000026000000000212560057572600000000260000000002
12000057572600000000260000000002120000575726000000002600000000021200005757260000000026000000000212000000000000000000000000000002
1200270000000016000000160000000212002700000000000000b700000000021200009393939393939393939300000212000000000000000000b70000000002
12000000000000000000b7000000000212000000000000000000b7000000000212000000000000000000b7000000000212000000000000000000000000000002
12000000000000160000b700000000021200000000000000b700008696a600021200000000000000b7000057000000021200000000000000b700005700000002
1200000000000000b7000057000000021200000000000000b7000057000000021200000000000000b70000570000000212000000000000000000000000000002
12000037b700000000000000a700000212000000b70000470000000000000002120000570000b70000000000b7000002120000570000b70000000000b7000002
120000570000b70000000000b7000002120000570000b70000000000b7000002120000570000b70000000000b700000212000000000000000000000000000002
12000000000000470000b7000000000212b700000000000000b70057000000021200b7260000000000000000000000021200b726000000000000000000000002
1200b7260000000000000000000000021200b7260000000000000000000000021200b72600000000000000000000000212000000000000000000000000000002
12000000470000000000001627000002120000000000b70000000000270000021200000000005700000000005700000212000000000057000000000057000002
12000000000057000000000057000002120000000000570000000000570000021200000000005700000000005700000212000000000000000000000000000002
12000000000016000000000000000002920000b70000000000005700000000829200000000570000002600000000008292000000005700000026000000000082
12000000005700000026000000000002120000000057000000260000000000021200000000570000002600000000000292000000000000000000000000000082
12000000000000000000000000000002e3d3d3d3d3d3d3d3d3d3d3d3d3d3d3f3e3d3d3d3d3d3d3d3d3d3d3d3d3d3d3f3e3d3d3d3d3d3d3d3d3d3d3d3d3d3d3f3
12000057000000b7000000000000000212000057000000b7000000000000000212000057000000b70000000000000002e34040404040404040404040404040f3
12000003000000030300000003000002b20000000000005700000000000000a22222222222b200000000a22222222222b20000570000000000000057000000a2
120000570000000000000057000000021200005700000000000000570000000212000057000000000000005700000002b20000000000000000000000000000a2
120000070000000000000016160000021200000300b703570603005703000002c3c3c3c3c3120303030302c3c3c3c3c3120000000000005700b7000000000002
120000000000005700b7000000000002120000000000005700b7000000000002120000000000005700b700000000000212000303030000000000000303030002
12000007000047004700000000000002120000000006000600000006000000024232323232920303030382323232325212000023000023570023000023000002
120000260000265700b7000000000002120000260000265700b7000000000002120000260000265700b700000000000212000393030000000000000393030002
1200000047000000002600470000000212b700000303000303000303000600021200000000000057570000002600000212000000000000575757000026000002
12000000000000575757000026000002120000000000005757570000260000021200000000000057575700002600000212000303030000030300000303030002
12000000000007000000004700000002120047000000000000000000000000021200000000000000000000000000000212000000000000000000000000000002
12000000000000000000000000000002120000000000000000000000000000021200000000000000000000000000000212000000000000030300000000000002
920000000000000000000047000000821200004700b700004700470000b70002120000b7b70000000000260000000002120000b7b70000000000260000000002
120000b7b70000000000260000000002120000b7b70000000000260000000002120000b7b7000000000026000000000212000000000000030300000000000002
e30000000000000000000000000000f312000000000000a70000b70000000002120000b75700000057b7000000000002120000b75700000057b7000000000002
120000b75700000057b7000000000002120000b75700000057b7000000000002120000b75700000057b700000000000212000000000053535353000000000002
00000000000000000000000000000000120000b70000000000470000b70047021200000000000000000000260000000212000000000000000000002600000002
12000000000000000000002600000002120000000000000000000026000000021200000000000000000000260000000212000000000000000000000000000002
00000000000000000000000000000000120000000000470000000000003700021200264700002600000026000000000212002647000026000000260000000002
12002647000026000000260000000002120026470000260000002600000000021200264700002600000026000000000212002323000000000000000023230002
000000000000000000000000000000001200b7000000000000000000000000021200000000000000b7000000000000021200000000000000b700000000000002
1200000000000000b7000000000000021200000000000000b7000000000000021200000000000000b70000000000000212002323232323232323232323230002
000000000000000000000000000000001200b7b7001700001700b700000000021200000000000047000000000000000212000000000000470000000000000002
12000000000000470000000000000002120000000000004700000000000000021200000000000047000000000000000212000000000000000000000000000002
000000000000000000000000000000001200000000000000b7001700000000021200004700004747000000470000000212000047000047470000004700000002
12000047000047470000004700000002120000470000474700000047000000021200004700004747000000470000000212000000000000000000000000000002
0000000000000000000000000000000012000000000000b70000000000000002120000b7000000000000000000000002120000b7000000000000000000000002
120000b7000000000000000000000002120000b7000000000000000000000002120000b700000000000000000000000212000000000000000000000000000002
00000000000000000000000000000000920000000000000000000000000000829200000000000047000000000000008292000000000000470000000000000082
12000000000000470000000000000002120000000000004700000000000000021200000000000047000000000000000292000000000000000000000000000082
00000000000000000000000000000000e30000000000000000000000c70000f3e30000000000000000000000000000f3e30000000000000000000000000000f3
120000000000000000000000000000021200000000000000000000000000000212000000000000000000000000000002e30000000000000000000000000000f3
__gff__
00000000000000000000000000000000000000000000000000000000000000000101010101010101010101010101010107070b070b13070b132301010100010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
2423232323232323232323232323232524232323232323232323232323232325242323232323232323232323232323252423232323232323232323232323232524232323232323232323232323232325242323232323232323232323232323252423232323232323232323232323232524232323232323232323232323232325
2100620000000000006100006000002021000000000062000000000074000020210000000000007400000000000000202100000000000074000000000000002021000000000000000000000000000020210000000000000000000000000000202100000000000000000000000000002021000000000000000000000000000020
2100000000000000007b000071000020210062000000000000740000000000202100000000007b0074000074006700202100000000007b00000000740067002021000063646500000000000000670020210000636465000000000000006700202100006364650000000000000067002021000000000000000000000000000020
2100000000000067000000000000002021000000000000000061610000007420216100747b0000000000000000000020216100747b0000000000000000000020216100000000006b0068696a00000020216100000000006b0068696a00000020216100000000006b0068696a0000002021000035353500000000353535000020
210000710000000000007b000000002021000039393900000000393939000020210000000072000000710000000000202100000000720000007100000000002021000000007200000071000000000020210000000072000000710000000000202100000000720000007100000000002021000035393500000000353935000020
2100006100600071007000000000002021000000000000740000000074000020210000000000710000000067000000202100000000007100000000670000002021000000000071000000006700000020210000000000710000000067000000202100000000007100000000670000002021000035353500000000353535000020
2100303000000000000000003030002021000000000000007000000000000020210000000000000071000072720000202100000000000000710000727200002021000000000000007100007272000020210000000000000071000072720000202100000000000000710000727200002021000000000000000000000000000020
2100000000000062000000000000002021007500000076000074000075000020210067003939393939393939000000202100670000000000000000000000002021006700000000000000720000000020210067000000000000007200000000202100670000000000000072000000002021000032323200000000323232000020
2100000000007400000062000000002021000000007500000070000000000020210000003232323232323232000000202100000000000000000000000000002021000076770000720072000000000020210000767700007200720000000000202100007677000072007200000000002021000032303232323232323032000020
210000007b000000700000007b00002021000073003535000035357470000020210000003030303030303030006100202100000000000000000000000061002021000000000000000071000000610020210000000000000000710000006100202100000000000000007100000061002021000032303030303030303032000020
2100620060000000000000006200002021000070000000000000000000747020210072007b0000007200000000000020210072007b0000007200000000000020210072007b0000007200000000000020210072007b0000007200000000000020210072007b000000720000000000002021000032323232323232323232000020
2100000000600061007461000000002021000000000073007070000000700020210000000000000000000062000000202100000000000000000000620000002021000000000000000000000000000020210000000000000000000000000000202100000000000000000000000000002021000000000000000000000000000020
21000000007b00000000000000000020210000000000000000000000000000202100000071007b7b6200000000007b202100000071007b7b6200000000007b2021000000710000000000000000000020210000007100000000000000000000202100000071000000000000000000002021000000000000000000000000000020
21000000007b0000000000000000002021000000000000000000000000000020210000000000000000000000000000202100000000000000000000000000002021000000000000787900007000000020210000000000007879000070000000202100000000000078790000700000002021000000000000000000000000000020
2900000000000000000000000000002829000000000000000000000000000028290000000000000000000000000000282900000000000000000000000000002821000000720000000000000071000020210000007200000000000000710000202100000072000000000000007100002021000000000000000000000000000020
3e00000000000000000000000000003f3e00000000000000000000000000003f3e00000000000000000000000000003f3e00000000000000000000000000003f21000000000071000070000000000020210000000000710000700000000000202100000000007100007000000000002029000000000000000000000000000028
2423232323232323232323232323232524232323232323232323232323232325242323232323232524232323232323252423232323232323232323232323232521007b0000000071000000000000002021007b0000000071000000000000002021007b000000007100000000000000203e04040404040404040404040404043f
210000000000000000000000000000202100000000000000000000000000002021000000007100202100000000000020210000000071000000000000000000202100000000710000000000000000002021000000007100000000000000000020210000000071000000000000000000202b00002a22222222222222222b00002a
2100327100007b007a00717b0032002021000000720000000074000000000020210039000039002021003961613900202100000000750000000000616100002021000000007500000000006161000020210000000075000000000061610000202100000000750000000000616100002021000020242323232323232521000020
2100000000000073000000000000002021000000007461000061000000747420210000000000002021000000000000202100003900003900733900003900002021000075000000007300000000000020210000750000000073000000000000202100007500000000730000000000002021000020210000000000002021000020
2100710030300000000030300000002021000000353535000035353500000020210000000000002021787900000000202100000000000076777879000000002021000000000000750000000000000020210000000000007500000000000000202100000000000075000000000000002021000020210000000000002021000020
21000000000071007b0000000067002021000000302e300000302e307400002021006465000000202100007b7500002021006465000000750000007b7500002021006465000000750000007b7500002021006465000000750000007b7500002021006465000000750000007b75000020210000202100121e1e17002021000020
210000740000000000007b000000002021000000302f300070302f3000000020210000000000002829000000000000202100000000000000000000000000002021000000000000000000000000000020210000000000000000000000000000202100000000000000000000000000002021000020262222222222222721000020
21000000000000006200000000000020210075003030300000303030750000202100007b0000006869000075000000202100007b0000006869000075000000202100007b0000006869000075000000202100007b0000006869000075000000202100007b00000068690000750000002021000020242323252423232521000020
21007400007b0000000000740000602021000000007500000000000000000020210000750062000000000000007300202100007500620000000000000073002021000075006200000000000000730020210000750062000000000000007300202100007500620000000000000073002021000020213030202130302021000020
2100000000000062000000000000002021000073007000000000007a70000020210000000000000000000000000000202100000000000000000000000000002021000000000000000000000000000020210000000000000000000000000000202100000000000000000000000000002021000020213232202132322021000020
2100710000000000000000006000002021000070000000000000000000707020217876797675000061620000007b0020217876797675000061620000007b0020210000000075000061620000007b0020210000000075000061620000007b0020210000000075000061620000007b002021000020213535202135352021000020
21000000710000717b600000000000202100000000007300707000000070002021007b0000750000000000006864652021007b0000750000000000006864652021007b0000750000000000000000002021007b0000750000000000000000002021007b0000750000000000000000002021000028290000282900002829000020
2100000000000060000000000000002021000000007400000000000000000020210075000000006200000000006200202100750000000062000000000062002021007500000000620000000000620020210075000000006200000000006200202100750000000062000000000062002021000000000000000000000000000020
2100000000000060000000000000002021000000000000000074000000000020210000000062000000000075000000202100000000620000000000750000002021000000006200000000007500000020210000000062000000000075000000202100000000620000000000750000002021000000000000000000000000000020
2900000000000000007100000000002829007400000000000000000000000028290000000000000000000000000000282900000000000000000000000000002821000000000000000000000000000020210000000000000000000000000000202100000000000000000000000000002021000000000000000000000000000020
3e00000000000000000000000000003f3e00000000000000000000000000003f3e00000000000000000000000000003f3e3d3d3d3d3d3d3d3d3d3d3d3d3d3d3f21000000620000750000000000000020210000006200007500000000000000202100000062000075000000000000002029000000000000000000000000000028
__sfx__
000100003e05037000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00100000052500725001200091002950029500295002a500172002b500000002c5000c50009500095000a5000a5000e500135000f500135002f500315002c50025500195000e5000000000000000000000000000
0010000013450283002310035700317002e7002c7002d7003620031100352002b10033200322001f100307003070030700307003070030700000000000000000000000e000000000000000000000000000000000
001000001c450184001840000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001d6001760019600226001b60000000000000000000000
001000002845000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000003145000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000600001a4500a250062500f10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000800001105011050010000000014000000000b000110501105012000000002b000000000a00011050110501200013000000000f000100001105011050000000000014000000000000011050110500000000000
00100000000003b0500000000000000000000000000000002805023050280503805031050000002b0500000000000000000000023050000003005000000000000000000000000000000000000000000000000000
001000000000000000000001335013350000000000000000000000000022350223500000000000000000000000000000000000000000000000000000000303502935035350000001f35000000000002635000000
__music__
00 41424344
02 0a0b0c44
