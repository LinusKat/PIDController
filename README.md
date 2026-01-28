# <span align="left">PIDController</span> <a href="https://github.com/LinusKat/PIDController/releases"><img align="right" src="/public/download.svg" /></a>

## Installation

Download the RBXM/ZIP from [releases](https://github.com/LinusKat/PIDController/releases).

## Usage

Speed Hold Example
```lua
local PIDController = require("@self/PIDController")
local SpeedHoldPID = PIDController.new(10, 0.004, 2, 0, 100)

local ProcessValue = 0 -- Current Speed
local SetPoint = 67 -- Target Speed

local Throttle = SpeedHoldPID:Update(SetPoint, ProcessValue, DeltaTime)

print(Throttle)
```

Vector3 Example
```lua
local Vector3PIDController = require("@self/PIDController/PIDWrappers/Vector3")
local FollowPID = Vector3PIDController.new(10, 0.004, 2, 0, 100)

local ProcessValue = Vector3.zero -- Current Position
local SetPoint = Vector3.new(10, 8, 2) -- Target Position

local Force = FollowPID:Update(SetPoint, ProcessValue, DeltaTime)

print(Force)
```

## API

### PIDController

```lua
PIDController.new(Kp?, Ki?, Kd?, Min?, Max?) -> PIDController
PIDController.Compound(Amount, Kp?, Ki?, Kd?, Min?, Max?) -> {PIDController}

PIDController:Update(SetPoint, ProcessValue, dt) -> number

PIDController:SetGains(Kp?, Ki?, Kd?)
PIDController:GetGains() -> (number, number, number)
PIDController:SetBounds(Min?, Max?)
PIDController:GetBounds() -> (number, number)

PIDController:Reset() -- Resets PID to original state
PIDController:Destroy()
```

### PID Wrappers (Type support such as Vector3 and Vector2)
```lua
PIDWrapper.new(Kp?, Ki?, Kd?, Min?, Max?) -> Wrapper

PIDWrapper:Update(SetPoint, ProcessValue, dt) -> number

PIDWrapper:SetGains(Kp?, Ki?, Kd?)
PIDWrapper:GetGains() -> (number, number, number)
PIDWrapper:SetBounds(Min?, Max?)
PIDWrapper:GetBounds() -> (number, number)

PIDWrapper:Reset() -- Resets PID(s) to original state
PIDWrapper:Destroy()
```

### Tuner
```lua
Tuner.new(PID, Name?, Parent?) -> Tuner -- Creates Tuner Folder which allows u to tune ur PID in realtime
Tuner:Destroy()
```

## ImPlot
Using my Iris addon [ImPlot](https://github.com/LinusKat/ImPlot) we can plot the PID data onto a Iris Widget.

Memory Helper Module
```lua
--!strict
local Memory = {}
Memory.__index = Memory

function Memory.new(MemoryLength: number)
	local self = setmetatable({}, Memory):: self
	self.Memory = {}
	self.MemoryLength = MemoryLength
	
	return self
end

function Memory._clamp_memory(self: self)
	if #self.Memory >= self.MemoryLength then
		table.remove(self.Memory, 1)
		self:_clamp_memory()
	end
end

function Memory.Feed(self: self, Value: any)
	self:_clamp_memory()
	table.insert(self.Memory, Value)
end

function Memory.Destroy(self: self)
	table.clear(self)
end

export type Memory = {
	Memory: {any},
	MemoryLength: number,
} & typeof(Memory)
type self = Memory
return Memory
```
Graph
```lua
local RunService = game:GetService("RunService")

local PIDController = require("@self/PIDController")
local Memory = require("@self/Memory")
local Iris = require("@self/Iris")

local PID = PIDController.new(2, .001, 0.1, 0, 100)
local PIDMemory = {
	Out = Memory.new(2400),
	SetPoint = Memory.new(2400),
	ProcessValue = Memory.new(2400),
}

local Frame = 0

local function Update(dt: number)
	local show_context = Iris.State(true)
	local plots = Iris.State({})

	local set_point = Iris.State(100)
	local process_value = Iris.State(40)

	Iris.Window({"PID Graph"}); do
		Iris.Checkbox({"Show Context"}, {isChecked = show_context})

		Iris.SliderNum({"SetPoint", 1, 0, 100}, {number = set_point})
		Iris.SliderNum({"ProcessValue", 1, 0, 100}, {number = process_value})

		plots:set{{
			Data = PIDMemory.Out.Memory,
			Name = "Throttle",
			GraphStyle = {
				Color = Color3.new(1, 0, 0),
				Thickness = 1,
			},
		}, {
			Data = PIDMemory.SetPoint.Memory,
			Name = "SetPoint",
			GraphStyle = {
				Color = Color3.new(0, 1, 0),
				Thickness = 1,
			},
		}, {
			Data = PIDMemory.ProcessValue.Memory,
			Name = "ProcessValue",
			GraphStyle = {
				Color = Color3.new(0, 0, 1),
				Thickness = 1,
			},
		}}
		
		Iris.ImPlotGraph({
			"Speed Hold PID", { X = "t", Y = "Force", XScale = 1, YScale = .8 }
		}, {
			plots = plots, showDataInformation = show_context
		})
	end; Iris.End()

	local throttle = PID:Update(set_point:get(), process_value:get(), dt)
	PIDMemory.Out:Feed(Vector2.new(Frame, throttle))
	
	PIDMemory.SetPoint:Feed(Vector2.new(Frame, set_point:get()))
	PIDMemory.ProcessValue:Feed(Vector2.new(Frame, process_value:get()))

	Frame += 1
end

Iris.Init()
Iris.UpdateGlobalConfig(Iris.TemplateConfig.sizeClear)

RunService.Heartbeat:Connect(Update)
```