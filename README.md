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