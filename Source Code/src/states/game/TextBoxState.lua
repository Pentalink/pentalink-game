TextBoxState = Class{__includes = BaseState}

function TextBoxState:init(data)
    -- object data
    self.colors = {
        ['panel'] = {245, 245, 245, 0},
        ['background'] = {255, 255, 255, 0},
        ['text'] = {0, 0, 0, 0}
    }

    Timer.tween(0.25, {
        [self.colors['panel']] = {[4] = 255},
        [self.colors['text']] = {[4] = 255},
        [self.colors['background']] = {[4] = 100}
    })

    -- data about game
    self.data = data

    self.height = 0

    for i, object in pairs(self.data) do
        love.graphics.setFont(object.font)
        if object.value then
            self.height = self.height + object.font:getHeight()
        end
        self.height = self.height + object.font:getHeight() * 1.5
    end

    self.width = VIRTUAL_WIDTH / 4

    self.x = (VIRTUAL_WIDTH - self.width) / 2
    self.y = (VIRTUAL_HEIGHT - self.height) / 2
end

function TextBoxState:update(dt)
    if love.keyboard.wasPressed('escape') then
        Timer.tween(0.25, {
            [self.colors['panel']] = {[4] = 0},
            [self.colors['text']] = {[4] = 0},
            [self.colors['background']] = {[4] = 0}
        }):finish(function() gStateStack:pop() end)
    end
end

function TextBoxState:render()
    -- transluscent background
    love.graphics.setColor(self.colors['background'])
    love.graphics.rectangle('fill', 0, 0, VIRTUAL_WIDTH, VIRTUAL_HEIGHT)

    love.graphics.setColor(self.colors['panel'])
    love.graphics.rectangle('fill', self.x, self.y, self.width, self.height, 10)

    local y = self.y

    for i, object in pairs(self.data) do
        if i == self.highlighted + 1 then
            love.graphics.setColor(200, 0, 0, self.colors['text'][4])
        else
            love.graphics.setColor(self.colors['text'])
        end
        love.graphics.setFont(object.font)
        love.graphics.printf(object.text, self.x, y, self.width, 'center')
        if object.value then
            object.value = object.value == object.randomval and 'random' or object.value
            y = y + object.font:getHeight()
            love.graphics.printf(object.value, self.x, y, self.width, 'center')

            local width = 20

            local x = self.x + (self.width - object.font:getWidth(tostring(object.value))) / 2 - 3 * width
            local v = {x, y + object.font:getHeight() / 2, x + width, y, x + width, y + object.font:getHeight()}
            love.graphics.polygon('fill', v)

            local x = self.x + (self.width + object.font:getWidth(tostring(object.value))) / 2 + 2 * width
            local v = {x + width, y + object.font:getHeight() / 2, x, y, x, y + object.font:getHeight()}
            love.graphics.polygon('fill', v)

            object.value = object.value == 'random' and NUM_LEVELS or object.value
        end

        y = y + object.font:getHeight() * 1.5
    end

    for i, button in pairs(self.buttons) do
        button:render()
    end
end
