-- Courtesy out Bigfoot71 - https://love2d.org/forums/viewtopic.php?t=94370


local lg = love.graphics
local d = lg.draw

local textObj = lg.newText(
    lg.getFont()
)

return function (text, x, y, ol, ...)

    local r, sx, sy, ox, oy, kx, ky;
    local c1, c2, r1, g1, b1, a1, r2, g2, b2, a2;

    if type(select(1, ...)) == "table" then
        c1, c2, r, sx, sy, ox, oy, kx, ky = ...
    else
        r1, g1, b1, a1, r2, g2, b2, a2, r, sx, sy, ox, oy, kx, ky = ...
    end

    textObj:set(text)
    textObj:setFont(lg.getFont())

    lg.setColor(
        r1 or c1[1],
        g1 or c1[2],
        b1 or c1[3],
        a1 or c1[4]
    )

    local minX = x - ol
    local minY = y - ol
    local maxX = x + ol
    local maxY = y + ol

    for dx = minX, maxX do
        if dx == minX or dx == maxX then
            for dy = minY, maxY do
                d(textObj, dx, dy, r, sx, sy, ox, oy, kx, ky)
            end
        else
            d(textObj, dx, minY, r, sx, sy, ox, oy, kx, ky)
            d(textObj, dx, maxY, r, sx, sy, ox, oy, kx, ky)
        end
    end

    lg.setColor(
        r2 or c2[1],
        g2 or c2[2],
        b2 or c2[3],
        a2 or c2[4]
    )

    d(textObj, x, y, r, sx, sy, ox, oy, kx, ky)

end