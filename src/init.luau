local Terrain = {}
Terrain.__index = Terrain

function Terrain.new(height: number, width: number, terrainSettings: {})
	local self = setmetatable({}, Terrain)
	self.elevation = {}
	for i=1,height do
		self.elevation[i] = {}
	end
	self.height = height
	self.width = width
	self.scale = 25
	self.terrainSettings = {
		frequency = terrainSettings.frequency or 1,
		octaves = terrainSettings.octaves or 1,
		seed = terrainSettings.seed or 42
	}
	
	self.octaveOffsets = {}
	
	math.randomseed(self.terrainSettings.seed)
	
	for i=1,self.terrainSettings.octaves do
		self.octaveOffsets[i] = Vector2.new(math.random(-100000, 100000), math.random(-100000, 100000))
	end
	
	return self	
end

function Terrain:_noise(x: number, y: number)
	x /= self.scale
	y /= self.scale
	local octaves = self.terrainSettings.octaves
	local frequency = self.terrainSettings.frequency
	local persistance = 0.5
	local lacunarity = 2
	local amplitude = 1
	local noiseHeight = 0
	
	
	for i = 1, octaves do
		local perlinValue = math.noise(
			x * frequency + self.octaveOffsets[i].X,
			y * frequency + self.octaveOffsets[i].Y
		) * 2 - 1

		noiseHeight += perlinValue * amplitude
		
		amplitude *= persistance
		frequency *= lacunarity
	end
	
	
	return noiseHeight
end

local function inverseLerp(a, b, val)
	return (val - a) / (b - a)
end

function Terrain:_generateHeightMap()
	local mx = -math.huge
	local mn = math.huge
	for x=1,self.height do
		for y=1,self.width do
			local noiseHeight = self:_noise(x, y)
			self.elevation[x][y] = noiseHeight
			mx = math.max(mx, noiseHeight)
			mn = math.min(mn, noiseHeight)
		end
	end
	
	for x=1,self.height do
		for y=1,self.width do
			self.elevation[x][y] = inverseLerp(mn, mx, self.elevation[x][y])
		end
	end
end

function Terrain:generate()
	self:_generateHeightMap()
	for i=1,self.height do
		for j=1,self.width do
			local p = Instance.new("Part")
			p.Anchored = true
			p.CanCollide = false
			--self.elevation[i][j]
			local h = self.elevation[i][j]
			p.Position = Vector3.new(i - self.height / 2, 10 + h * 15, j - self.width / 2)
			-- // water
			if h <= 0.35 then
				p.Color = Color3.fromRGB(13, 105, 172)
			elseif h <= 0.38 then
				p.Color = Color3.fromRGB(253, 234, 141)
			elseif h <= 0.7 then
				p.Color = Color3.fromRGB(52, 142, 64)
			elseif h <= 0.75 then
				p.Color = Color3.fromRGB(86, 66, 54)
			else
				p.Color = Color3.fromRGB(255, 255, 255)
			end
			
			--p.Color = Color3.fromRGB(self.elevation[i][j] * 255, self.elevation[i][j] * 255, self.elevation[i][j] * 255)
			p.Size = Vector3.new(1,1,1)
			p.Parent = workspace
			p.TopSurface = Enum.SurfaceType.Smooth
		end
	end
end

return Terrain
