function GetIntersection(x1, y1, x2, y2, x3, y3, x4, y4)
	local dx1, dy1 = x2 - x1, y2 - y1
	local dx2, dy2 = x4 - x3, y4 - y3

	local den = dx1 * dy2 - dy1 * dx2
	if den == 0 then
		return nil
	end

	local t = ((x3 - x1) * dy2 - (y3 - y1) * dx2) / den
	local u = ((x3 - x1) * dy1 - (y3 - y1) * dx1) / den

	if t >= 0 and t <= 1 and u >= 0 and u <= 1 then
		return {
			x = x1 + t * dx1,
			y = y1 + t * dy1,
			dist = t,
		}
	end
	return nil
end

function love.load()
	love.window.setTitle("spintral")
	love.window.setMode(1280, 720)

	Walls = {
		{ x1 = 200, y1 = 150, x2 = 650, y2 = 120, type = "safe" },
		{ x1 = 650, y1 = 120, x2 = 750, y2 = 250, type = "danger" },
		{ x1 = 750, y1 = 250, x2 = 950, y2 = 250, type = "safe" },
		{ x1 = 950, y1 = 250, x2 = 1000, y2 = 450, type = "safe" },
		{ x1 = 1000, y1 = 450, x2 = 850, y2 = 580, type = "danger" },
		{ x1 = 850, y1 = 580, x2 = 450, y2 = 580, type = "safe" },
		{ x1 = 450, y1 = 580, x2 = 250, y2 = 450, type = "safe" },
		{ x1 = 250, y1 = 450, x2 = 180, y2 = 300, type = "safe" },
		{ x1 = 180, y1 = 300, x2 = 200, y2 = 150, type = "safe" },
	}

	Ball = {
		x = 0,
		y = 0,
		radius = 25,
		angle = 0,
		rotSpeed = 3,
		-- the mouse following thing here
		state = "floating",

		-- the rofds directions for the balls
		markings = { 0, 2 * math.pi / 3, 4 * math.pi / 3 },

		rods = {},
	}

	function DeployRods()
		Ball.rods = {}
		local touchedDanger = false

		for _, relAngle in ipairs(Ball.markings) do
			local absoluteAngle = Ball.angle + relAngle

			local targetX = Ball.x + math.cos(absoluteAngle) * 1500
			local targetY = Ball.y + math.sin(absoluteAngle) * 1500

			local closestHit = nil

			for i = 1, #Walls do
				local wall = Walls[i]

				local hit = GetIntersection(Ball.x, Ball.y, targetX, targetY, wall.x1, wall.y1, wall.x2, wall.y2)
				if hit then
					if not closestHit or hit.dist < closestHit.dist then
						closestHit = hit
						closestHit.wallType = wall.type
					end
				end
			end
			if closestHit then
				table.insert(Ball.rods, { x = closestHit.x, y = closestHit.y })
				if closestHit.wallType == "danger" then
					touchedDanger = true
				end
			end
		end
		if touchedDanger then
			Ball.state = "exploded"
			Ball.rods = {}
		end
	end
end

function love.draw()
	love.graphics.clear(10 / 255, 20 / 255, 100 / 255)
	love.graphics.setLineWidth(4)
	for i = 1, #Walls do
		local wall = Walls[i]
		if wall.type == "danger" then
			love.graphics.setColor(1, 0.8, 0)
		else
			love.graphics.setColor(1, 1, 1)
		end
		love.graphics.line(wall.x1, wall.y1, wall.x2, wall.y2)
	end

	if Ball.state == "attached" then
		love.graphics.setColor(1, 1, 1)
		love.graphics.setLineWidth(4)

		for _, rod in ipairs(Ball.rods) do
			love.graphics.line(Ball.x, Ball.y, rod.x, rod.y)
			love.graphics.circle("fill", rod.x, rod.y, 8)
		end
	end

	if Ball.state ~= "exploded" then
		-- The solid blue
		love.graphics.setColor(0, 0.2, 0.8)
		love.graphics.circle("fill", Ball.x, Ball.y, Ball.radius)

		-- The inner markings
		love.graphics.setColor(1, 1, 1)
		love.graphics.setLineWidth(5)
		for _, relAngle in ipairs(Ball.markings) do
			local absoluteAngle = Ball.angle + relAngle
			local mx = Ball.x + math.cos(absoluteAngle) * Ball.radius
			local my = Ball.y + math.sin(absoluteAngle) * Ball.radius
			love.graphics.line(Ball.x, Ball.y, mx, my)
		end

		-- The outer ring
		love.graphics.setColor(0.5, 0.8, 1)
		love.graphics.setLineWidth(10)
		love.graphics.circle("line", Ball.x, Ball.y, Ball.radius)
	elseif Ball.state == "exploded" then
		love.graphics.setColor(1, 0.3, 0)
		love.graphics.circle("fill", Ball.x, Ball.y, 40)
		love.graphics.setColor(1, 0.8, 0)
		love.graphics.print("BOOM! Hit a danger line!", Ball.x - 60, Ball.y + 50)
	end
end

function love.update(dt)
	if Ball.state == "floating" then
		Ball.angle = Ball.angle + Ball.rotSpeed * dt
		Ball.x = love.mouse.getX()
		Ball.y = love.mouse.getY()
	end
end

function love.mousepressed(_, _, button, _, _)
	if button == 1 and Ball.state == "floating" then
		Ball.state = "attached"
		DeployRods()
	end
end

-- DEBUG THING
function love.keypressed(key)
	if key == "r" then
		Ball.state = "floating"
		Ball.rods = {}
	elseif Ball.state == "floating" then
		if key == "1" then
			Ball.markings = { 0 }
		elseif key == "2" then
			Ball.markings = { 0, math.pi }
		elseif key == "3" then
			Ball.markings = { 0, 2 * math.pi / 3, 4 * math.pi / 3 }
		elseif key == "4" then
			Ball.markings = { 0, math.pi / 2, math.pi, 3 * math.pi / 2 }
		end
	end
end
