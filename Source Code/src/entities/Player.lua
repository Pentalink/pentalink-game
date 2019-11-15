Player = Class{}

function Player:init(points, shapes)
    self.points = points
    self.shapes = shapes
    self.pentagonArea = 0
end

function shapepoints(c)
    if #c >= 3 and #c <= 7 then
        return POLYGON_POINTS[#c]
    elseif #c >= 8 then
        return -9 - 3 * (#c - 8)
    end
end

function Player:update(shapes)
    for i, c in pairs(shapes) do
        self.pentagonArea = self.pentagonArea + shoelace(points_set(c)) * (PIXEL_AREA_SCALE_FACTOR)
        self.points = self.points + shapepoints(c)
    end
end
