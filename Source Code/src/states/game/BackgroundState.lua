BackgroundState = Class{__includes = PlayState}

function BackgroundState:init(levelnum)
    local level = generateLevel(levelnum)
    gPoints = level.points

    nodeNumbers = {}
    for i = 1, #gPoints do
        table.insert(nodeNumbers, i)
    end

    self.graph = Graph(nodeNumbers)
    self.rotation = 0
    self.projected = deepcopy(gPoints)
    self.cycles = {}

    self:updateAvailableEdges()
    while #self.availableEdges > 0 do
        edge = self.availableEdges[math.random(1, #self.availableEdges)]
        self.graph:add_edge(edge[1], edge[2])
        self:updateAvailableEdges()
    end
    self.cycles = minimum_cycle_basis(self.graph)

    local colors = {}
    for i = 1, 10 do
        table.insert(colors, {math.random(1, 255), math.random(1, 255), math.random(1, 255), 200})
    end

    self.colorAllocation = {}
    for i, c in pairs(self.cycles) do
        self.colorAllocation[c] = colors[math.random(#colors)]
    end
    self.backgroundColor = colors[math.random(#colors)]
end

function BackgroundState:updateAvailableEdges()
    self.availableEdges = {}
    for n1 = 1, #gPoints do
        for n2 = n1 + 1, #gPoints do
            if n1 ~= n2 and self:validLine({n1, n2}) then
                table.insert(self.availableEdges, {n1, n2})
            end
        end
    end
end

function BackgroundState:update(dt)
    mouseX, mouseY = push:toGame(love.mouse.getX(), love.mouse.getY())
    if mouseX and mouseY then
        self.projected = {}
        for i, point in pairs(gPoints) do
            local vec_x = mouseX - point[1]
            local vec_y = mouseY - point[2]
            local scale = POINT_MOVE_RADIUS / point_length(point[1], point[2], mouseX, mouseY)
            table.insert(self.projected, {point[1] + vec_x * scale, point[2] + vec_y * scale})
        end
    end
    self.rotation = (self.rotation + 0.2 * dt)%(2 * math.pi)
end

function BackgroundState:render(position)
    self.position = position
    love.graphics.translate(VIRTUAL_WIDTH / 2, VIRTUAL_HEIGHT / 2)
    love.graphics.rotate(self.rotation)
    love.graphics.translate(-VIRTUAL_WIDTH / 2, - VIRTUAL_HEIGHT / 2)
    love.graphics.translate(self.position.x, self.position.y)
    love.graphics.clear(255, 255, 255, 255)

    for i, cycle in pairs(self.cycles) do
        love.graphics.setColor(self.colorAllocation[cycle])
        local vertices = getVertices(cycle, self.projected)
        local function polygonStencilFunction()
            if convex then
                love.graphics.polygon('fill', vertices)
            else
                triangles = love.math.triangulate(vertices)
                for i, polygon_triangle in pairs(triangles) do
                    love.graphics.polygon('fill', polygon_triangle)
                end
            end
        end

        love.graphics.stencil(polygonStencilFunction, "replace", 1, false)

        love.graphics.setStencilTest("greater", 0)
        love.graphics.rectangle("fill", 0, 0, VIRTUAL_WIDTH, VIRTUAL_HEIGHT)
        love.graphics.setStencilTest()
    end

    love.graphics.setColor(0, 0, 0)

    shiftX = 100
    shiftY = gFonts['medium']:getHeight()

    for i, line in pairs(self.graph.edges) do
        love.graphics.line(self.projected[line[1]][1], self.projected[line[1]][2], self.projected[line[2]][1], self.projected[line[2]][2])
    end

    for i, point in pairs(self.projected) do
        if self.selected == i then
            love.graphics.setColor(255, 0, 0)
        else
            love.graphics.setColor(0, 0, 0)
        end
        love.graphics.setFont(gFonts['small'])
        love.graphics.circle('fill', point[1], point[2], 5)
    end
    love.graphics.translate(-self.position.x, - self.position.y)
    love.graphics.translate(VIRTUAL_WIDTH / 2, VIRTUAL_HEIGHT / 2)
    love.graphics.rotate(-self.rotation)
    love.graphics.translate(-VIRTUAL_WIDTH / 2, - VIRTUAL_HEIGHT / 2)
end
