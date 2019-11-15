GameOverState = Class{__includes = BaseState}

function GameOverState:init(winningPlayer, bestPlayersArea, players)
    self.winningPlayer = winningPlayer
    self.bestPlayersArea = bestPlayersArea
    self.players = players

    self.width = gFonts['medium']:getWidth("Player 1 Wins!") * 1.5

    local y = 10 + gFonts['medium-bigger']:getHeight() + 90
    for i, player in pairs(self.players) do
        y = y + 10 + gFonts['medium']:getHeight() + gFonts['small']:getHeight() + 20
    end

    self.height = y

    self.x = (VIRTUAL_WIDTH - self.width) / 2
    self.y = -self.height
    self.exitable = false
    Timer.tween(1, {
        [self] = {y = (VIRTUAL_HEIGHT - self.height) / 2},
    }):finish(function() self.exitable = true end)
end

function GameOverState:update(dt)
    if self.exitable and (love.keyboard.wasPressed('return') or love.mouse.keysPressed[1]) then
        gStateStack:push(FadeInState({r = 255, g = 255, b = 255}, 0.25, function()
            gStateStack:pop()
            gStateStack:pop()
            gStateStack:push(StartState())
            gStateStack:push(FadeOutState({r = 255, g = 255, b = 255}, 0.5, function() end))
        end))
    end
end

function GameOverState:render()
    love.graphics.setColor(255, 255, 255, 100)
    love.graphics.rectangle('fill', 0, 0, VIRTUAL_WIDTH, VIRTUAL_HEIGHT)
    love.graphics.setColor(245, 245, 245, 255)
    love.graphics.rectangle('fill', self.x, self.y, self.width, self.height, 10)

    self.x = self.x + 10

    love.graphics.setColor(0, 0, 0, 255)
    love.graphics.setFont(gFonts['medium-bigger'])
    love.graphics.printf('Player ' .. tostring(self.winningPlayer) .. ' wins!', self.x, self.y + 10, self.width, 'left')

    local y = self.y + 10 + gFonts['medium-bigger']:getHeight() + 20
    local points = #self.bestPlayersArea == 1 and MOST_AREA_POINTS or TIED_AREA_POINTS
    for i, player in pairs(self.players) do
        love.graphics.setFont(gFonts['medium'])
        love.graphics.printf('Player ' .. tostring(i), self.x, y + 10, self.width, 'left')

        love.graphics.setFont(gFonts['small'])
        if table.contains(bestPlayersArea, i) then
            love.graphics.printf('Points: ' .. tostring(self.players[i].points - points), self.x, y + 10 + gFonts['medium']:getHeight(), self.width, 'left')
            love.graphics.setColor(0, 166, 6)
            xoffset = gFonts['small']:getWidth('Points: ' .. tostring(self.players[i].points - points))
            love.graphics.printf(' + ' .. tostring(points), self.x + xoffset, y + 10 + gFonts['medium']:getHeight(), self.width, 'left')

            love.graphics.setColor(0, 0, 0)
            xoffset = xoffset + gFonts['small']:getWidth(' + ' .. tostring(points))
            love.graphics.printf(' = ' .. tostring(self.players[i].points), self.x + xoffset, y + 10 + gFonts['medium']:getHeight(), self.width, 'left')
        else
            love.graphics.printf('Points: ' .. tostring(self.players[i].points), self.x, y + 10 + gFonts['medium']:getHeight(), self.width, 'left')
        end
        love.graphics.printf('Area: ' .. tostring(self.players[i].pentagonArea), self.x, y + 10 + gFonts['medium']:getHeight() + gFonts['small']:getHeight(), self.width, 'left')
        y = y + 10 + gFonts['medium']:getHeight() + gFonts['small']:getHeight() + 20
    end

    y = y + 20
    love.graphics.printf("Press 'Enter' to return to menu", self.x, y + 20, self.width, 'center')

    self.x = self.x - 10
end
