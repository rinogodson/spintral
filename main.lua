function love.load()
	love.window.setTitle("spintral")
	love.window.setMode(1280, 720)

	Walls = {
		{ x = 200, y = 150 },
		{ x = 650, y = 120 },
		{ x = 750, y = 250 },
		{ x = 950, y = 250 },
		{ x = 1000, y = 450 },
		{ x = 850, y = 580 },
		{ x = 450, y = 580 },
		{ x = 250, y = 450 },
		{ x = 180, y = 300 },
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

	function DeployRods()
		Ball.rods = {}

		for _, relAngle in ipairs(Ball.markings) do
			local absoluteAngle = Ball.angle + relAngle

			local targetX = Ball.x + math.cos(absoluteAngle) * 1500
			local targetY = Ball.y + math.sin(absoluteAngle) * 1500

			local closestHit = nil

			for i = 1, #Walls do
				local p1 = Walls[i]
				local p2 = Walls[i % #Walls + 1]

				local hit = GetIntersection(Ball.x, Ball.y, targetX, targetY, p1.x, p1.y, p2.x, p2.y)
				if hit then
					if not closestHit or hit.dist < closestHit.dist then
						closestHit = hit
					end
				end
			end
			if closestHit then
				table.insert(Ball.rods, { x = closestHit.x, y = closestHit.y })
			end
		end
	end
end

function love.draw()
	love.graphics.clear(10 / 255, 20 / 255, 45 / 255)
	love.graphics.setColor(1, 1, 1)
	love.graphics.setLineWidth(4)
	for i = 1, #Walls do
		local p1 = Walls[i]
		local p2 = Walls[i % #Walls + 1]
		love.graphics.line(p1.x, p1.y, p2.x, p2.y)
	end

	-- balls here, after the walls. balls and walls, what a rhyme!
	love.graphics.setColor(1, 1, 0)
	love.graphics.setLineWidth(3)
	for _, relAngle in ipairs(Ball.markings) do
		local absoluteAngle = Ball.angle + relAngle

		local mx = Ball.x + math.cos(absoluteAngle) * Ball.radius
		local my = Ball.y + math.sin(absoluteAngle) * Ball.radius

		love.graphics.line(Ball.x, Ball.y, mx, my)
	end

	if Ball.state == "attached" then
		love.graphics.setColor(1, 1, 1)
		love.graphics.setLineWidth(4)

		for _, rod in ipairs(Ball.rods) do
			love.graphics.line(Ball.x, Ball.y, rod.x, rod.y)

			love.graphics.setColor(1, 1, 1)
			love.graphics.circle("fill", rod.x, rod.y, 10)
			love.graphics.setColor(1, 1, 1)
		end
	end
end

function love.update(dt)
	if Ball.state == "floating" then
		Ball.angle = Ball.angle + Ball.rotSpeed * dt
		Ball.x = love.mouse.getX()
		Ball.y = love.mouse.getY()
	end
end

function love.mousepressed(button)
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
