LevelCreateState = Class{__includes = BaseState}

function LevelCreateState:init()
    self.buttons = {
        Button(
            gTextures['buttons']['hamburger'],
            VIRTUAL_WIDTH - ICON_SIZE, 0, ICON_SIZE, ICON_SIZE,
            function()
                gStateStack:push(FadeInState({r = 255, g = 255, b = 255}, 0.2, function()
                    gStateStack:pop()
                    gStateStack:push(StartState())
                    gStateStack:push(FadeOutState({r = 255, g = 255, b = 255}, 0.2, function()
                    end))
                end))
            end
        ),
    }
    self.level = {['points'] = {}, ['edges'] = {}}

    self.playerTriangle = Triangle(gFonts['medium']:getWidth('Player 1   '), 0, 25, gFonts['medium']:getHeight() - 10)

    gPoints = self.level.points

    local nodeNumbers = {}
    for i = 1, #gPoints do
        table.insert(nodeNumbers, i)
    end

    shiftX = gFonts['medium']:getWidth('Player 1') * 1.25
    scale = (VIRTUAL_WIDTH - shiftX) / VIRTUAL_WIDTH
    shiftY = VIRTUAL_HEIGHT - VIRTUAL_HEIGHT * scale
    translatePoints(gPoints, shiftX, shiftY, scale)

    self.numInStreak = 0
    self.streakStarter = nil
    self.lastPlayer = nil
    self.moveNum = 1

    self.pointLog = {}

    self.numPlayers = 1
    self.players = {}
    for i = 1, self.numPlayers do
        table.insert(self.players, Player(0, {}))
    end
    self.currentPlayer = 1

    self.graph = Graph(nodeNumbers)

    for i, edge in pairs(self.level.edges) do
        self.graph:add_edge(edge[1], edge[2])
    end

    self.cycles = minimum_cycle_basis(self.graph)

    self.selected = nil
end

function LevelCreateState:checkGameOver()
    return false
end

function line_distance(a, b)
    return point_length(a[1], a[2], b[1], b[2])
end

function lies_between(a, c, b)
    if math.abs(line_distance(a, b) + line_distance(b, c) - line_distance(a, c)) < POINT_IN_LINE_SEGMENT_TOLERANCE_VALUE then
        return true
    end
    return false
end

function LevelCreateState:validLine(line1)
    return true
    -- a = gPoints[line1[1]]
    -- c = gPoints[line1[2]]
    --
    -- local midpoint = {(a[1] + c[1]) / 2, (a[2] + c[2]) / 2}
    --
    -- for i, c in pairs(self.cycles) do
    --     v = getVertices(c)
    --     if pointInPolygon(midpoint, v) then
    --         return false
    --     end
    -- end
    --
    -- for i, line2 in pairs(self.graph.edges) do
    --     -- check if the line already exists
    --     if (line1[1] == line2[1] and line1[2] == line2[2]) or (line1[2] == line2[1] and line1[1] == line2[2]) then
    --         return false
    --     end
    --     coordinateLine1 = deepcopy({gPoints[line1[1]], gPoints[line1[2]]})
    --     coordinateLine2 = deepcopy({gPoints[line2[1]], gPoints[line2[2]]})
    --
    --     if lines_intersect(coordinateLine1, coordinateLine2) then
    --         return false
    --     end
    -- end
    --
    -- for i, b in pairs(gPoints) do
    --     if table.contains(line1, i) then
    --         goto continue
    --     end
    --
    --     if lies_between(a, c, b) then
    --         return false
    --     end
    --
    --     ::continue::
    -- end
    --
    -- return true
end

function validateCycle(cycle)
    cyc_copy = deepcopy(cycle)
    table.insert(cyc_copy, cyc_copy[1])
    table.insert(cyc_copy, cyc_copy[2])

    remove = {}
    for i = 1, #cyc_copy - 2 do
        a = gPoints[cyc_copy[i]]
        b = gPoints[cyc_copy[i + 1]]
        c = gPoints[cyc_copy[i + 2]]
        if lies_between(a, c, b) then
            remove[cyc_copy[i + 1]] = true
        end
    end

    new_cyc = {}
    for i = 1, #cyc_copy - 2 do
        if not remove[cyc_copy[i]] then
            table.insert(new_cyc, cyc_copy[i])
        end
    end

    return new_cyc
end

function LevelCreateState:update(dt)
    for i, button in pairs(self.buttons) do
        button:update()
    end
    mouseX, mouseY = push:toGame(love.mouse.getX(), love.mouse.getY())
    if love.mouse.keysPressed[1] and not self.gameover then
        if self.selected then
            local other = nil
            for i, point in pairs(gPoints) do
                if point_length(mouseX, mouseY, point[1], point[2]) <= POINT_HITBOX then
                    other = i
                end
            end
            if other and self.selected ~= other then
                -- at this point
                if self:validLine({self.selected, other}) then
                    self.graph:add_edge(self.selected, other)

                    local nextCycles = minimum_cycle_basis(self.graph)

                    for i, c in pairs(nextCycles) do
                        nextCycles[i] = validateCycle(c)
                    end

                    local newCycles = getNewCycles(nextCycles, self.cycles)

                    local pentagonExists = false
                    for i, c in pairs(newCycles) do
                        table.insert(self.cycles, c)
                        if #c == 5 then
                            pentagonExists = true
                        end
                        sign = (shapepoints(c) and shapepoints(c) > 0) and '+' or ''
                        table.insert(self.pointLog, {
                            ['move'] = self.moveNum,
                            ['player'] = self.currentPlayer,
                            ['points'] = shapepoints(c) or 0
                        })
                    end

                    if pentagonExists then
                        if self.numInStreak == 0 then
                            self.streakStarter = self.lastPlayer
                        end
                        self.numInStreak = self.numInStreak + 1
                    elseif STREAK_POINTS[self.numInStreak] then
                        self.players[self.streakStarter].points = self.players[self.streakStarter].points + STREAK_POINTS[self.numInStreak]
                        self.numInStreak = 0
                        self.streakStarter = nil
                    end

                    self.players[self.currentPlayer]:update(newCycles)

                    self.lastPlayer = self.currentPlayer
                    self.currentPlayer = math.max((self.currentPlayer + 1)%(self.numPlayers + 1), 1)
                    self.moveNum = self.moveNum + 1
                    local h = (self.currentPlayer - 1) * gFonts['medium']:getHeight() + (2 * (self.currentPlayer - 1)) * gFonts['small']:getHeight()
                    Timer.tween(0.5, {
                        [self.playerTriangle] = {y = h}
                    })
                    self.gameOver = self:checkGameOver()
                    if self.gameOver then
                        if self.numInStreak > 0 then
                            self.players[self.streakStarter].points = self.players[self.streakStarter].points + (STREAK_POINTS[self.numInStreak] or 0)
                            self.numInStreak = 0
                            self.streakStarter = nil
                        end

                        bestArea = 0
                        bestPlayersArea = {}

                        for i, player in pairs(self.players) do
                            if player.pentagonArea > bestArea then
                                bestArea = player.pentagonArea
                                bestPlayersArea = {i, }
                            elseif player.pentagonArea == bestArea then
                                table.insert(bestPlayersArea, i)
                            end
                        end

                        local points = #bestPlayersArea == 1 and MOST_AREA_POINTS or TIED_AREA_POINTS
                        for i, player in pairs(bestPlayersArea) do
                            self.players[player].points = self.players[player].points + points
                        end

                        bestPlayer = nil
                        bestScore = 0

                        for i, player in pairs(self.players) do
                            if not bestPlayer or player.points > bestScore then
                                bestPlayer = i
                                bestScore = player.points
                            end
                        end


                        gStateStack:push(GameOverState(bestPlayer, bestPlayersArea, self.players))
                    end
                else
                    gSounds['deny-connection']:play()
                    -- graphics to show line and then fade it out
                end
            end
            self.selected = nil
        else
            for i, point in pairs(gPoints) do
                if point_length(mouseX, mouseY, point[1], point[2]) <= POINT_HITBOX then
                    self.selected = i
                end
            end
            if not self.selected then
                table.insert(gPoints, {mouseX, mouseY})
                self.graph:add_node(#gPoints)
            end
        end
    end
end

function LevelCreateState:render()
    love.graphics.clear(255, 255, 255, 255)
    self.playerTriangle:render()

    for i, cycle in pairs(self.cycles) do
        if #cycle == 5 then
            love.graphics.setColor(255, 0, 0, 200)
        else
            love.graphics.setColor(14, 66, 171, 200)
        end
        local vertices = getVertices(cycle)
        if convex then
            love.graphics.polygon('fill', vertices)
        else
            triangles = love.math.triangulate(vertices)
            for i, polygon_triangle in pairs(triangles) do
                love.graphics.polygon('fill', polygon_triangle)
            end
        end
    end

    love.graphics.setColor(0, 0, 0)

    shiftY = gFonts['medium']:getHeight()

    for i, line in pairs(self.graph.edges) do
        love.graphics.line(gPoints[line[1]][1], gPoints[line[1]][2], gPoints[line[2]][1], gPoints[line[2]][2])
    end

    for i, point in pairs(gPoints) do
        if self.selected == i then
            love.graphics.setColor(255, 0, 0)
        else
            love.graphics.setColor(0, 0, 0)
        end
        love.graphics.setFont(gFonts['small'])
        -- love.graphics.print(tostring(i), point[1], point[2])
        love.graphics.circle('fill', point[1], point[2], 5)
    end

    love.graphics.setColor(0, 0, 0)
    love.graphics.setFont(gFonts['medium-bigger'])
    if self.gameOver then
        love.graphics.printf("Game over.", 0, 0, VIRTUAL_WIDTH, 'center')
    else
        love.graphics.printf("Player " .. tostring(self.currentPlayer) .. "'s turn!", 0, 0, VIRTUAL_WIDTH, 'center')
    end
    for i = 1, self.numPlayers do
        local h = (i - 1) * gFonts['medium']:getHeight() + (2 * (i - 1)) * gFonts['small']:getHeight()
        love.graphics.setFont(gFonts['medium'])
        love.graphics.printf("Player " .. tostring(i), 0, h, shiftX)

        love.graphics.setFont(gFonts['small'])
        love.graphics.printf("Points: " .. tostring(self.players[i].points), 0, h + gFonts['medium']:getHeight(), shiftX)
        love.graphics.printf("Area: " .. tostring(math.floor(self.players[i].pentagonArea, 0)), 0, h + gFonts['medium']:getHeight() + gFonts['small']:getHeight(), shiftX)
    end

    local y = self.numPlayers * gFonts['medium']:getHeight() + (2 * self.numPlayers) * gFonts['small']:getHeight() + 20
    love.graphics.setFont(gFonts['small'])
    headings = {'move', 'player', 'points'}
    headingsX = {}
    local x = 0
    for i, heading in pairs(headings) do
        love.graphics.printf(heading, x, y, VIRTUAL_WIDTH)
        headingsX[heading] = x
        x = x + gFonts['small']:getWidth(heading) + 10
    end

    y = y + gFonts['small']:getHeight()
    for i = #self.pointLog, 1, - 1 do
        message = self.pointLog[i]
        for i, heading in pairs(headings) do
            love.graphics.printf(message[heading], headingsX[heading], y, gFonts['small']:getWidth(heading), 'center')
        end
        y = y + gFonts['small']:getHeight()
    end

    for i, button in pairs(self.buttons) do
        button:render()
    end
end
