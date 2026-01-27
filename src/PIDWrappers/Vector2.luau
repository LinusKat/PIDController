--!strict
local PIDController = require("../../PIDController")

local Wrapper = {}
Wrapper.__index = Wrapper

function Wrapper.new(Kp: number?, Ki: number?, Kd: number?, Min: number?, Max: number?): Wrapper
	local self = setmetatable({}, Wrapper):: self
	self._compound = PIDController.Compound(2, Kp, Ki, Kd, Min, Max)

	return self
end

function Wrapper.Update(self: self, SetPoint: Vector2, ProcessValue: Vector2, dt: number): Vector2
	return Vector2.new(
		self._compound[1]:Update(SetPoint.X, ProcessValue.X, dt),
		self._compound[2]:Update(SetPoint.Y, ProcessValue.Y, dt)
	)
end

function PIDController.SetGains(self: self, Kp: number?, Ki: number?, Kd: number?)
	self._compound[1]:SetGains(Kp, Ki, Kd)
	self._compound[2]:SetGains(Kp, Ki, Kd)
end

function PIDController.GetGains(self: self): (number, number, number)
	return self._compound[1]._gains.Kp, self._compound[1]._gains.Ki, self._compound[1]._gains.Kd
end

function PIDController.SetBounds(self: self, Min: number?, Max: number?)
	self._compound[1]:SetGains(Min, Max)
	self._compound[2]:SetGains(Min, Max)
end

function PIDController.GetBounds(self: self): (number, number)
	return self._compound[1]._bounds.Min, self._compound[1]._bounds.Max
end

function Wrapper.Destroy(self: self)
	table.clear(self)
end

type PIDController = PIDController.PIDController
type Compound = PIDController.Compound

export type Wrapper = {
	_compound: Compound,
} & typeof(Wrapper)
type self = Wrapper

return Wrapper