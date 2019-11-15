self.buttons = {
    Button(
        gTextures['exit_button'],
        VIRTUAL_WIDTH - 75, 0, 75, 75,
        function()
            Timer.tween(0.25, {
                [self.colors['panel']] = {[4] = 0},
                [self.colors['text']] = {[4] = 0},
                [self.colors['background']] = {[4] = 0}
            }):finish(function() gStateStack:pop() end)
        end
    ),
}

for i, button in pairs(self.buttons) do
    button:update()
end

for i, button in pairs(self.buttons) do
    button:render()
end
