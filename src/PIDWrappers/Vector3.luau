--!strict
local PIDController = require(script.Parent.Parent)

local Wrapper = {}
Wrapper.__index = Wrapper

function Wrapper.new(Kp: number?, Ki: number?, Kd: number?, Min: number?, Max: number?): Wrapper
	local self = setmetatable({}:: self, Wrapper)
	self._compound = PIDController.Compound(3, Kp, Ki, Kd, Min, Max)

	return self
end

function Wrapper.Update(self: self, SetPoint: Vector3, ProcessValue: Vector3, dt: number): Vector3
	return Vector3.new(
		self._compound[1]:Update(SetPoint.X, ProcessValue.X, dt),
		self._compound[2]:Update(SetPoint.Y, ProcessValue.Y, dt),
		self._compound[3]:Update(SetPoint.Z, ProcessValue.Z, dt)
	)
end

function Wrapper.SetGains(self: self, Kp: number?, Ki: number?, Kd: number?)
	self._compound[1]:SetGains(Kp, Ki, Kd)
	self._compound[2]:SetGains(Kp, Ki, Kd)
	self._compound[3]:SetGains(Kp, Ki, Kd)
end

function Wrapper.GetGains(self: self): (number, number, number)
	return self._compound[1]._gains.Kp, self._compound[1]._gains.Ki, self._compound[1]._gains.Kd
end

function Wrapper.SetBounds(self: self, Min: number?, Max: number?)
	self._compound[1]:SetGains(Min, Max)
	self._compound[2]:SetGains(Min, Max)
	self._compound[3]:SetGains(Min, Max)
end

function Wrapper.GetBounds(self: self): (number, number)
	return self._compound[1]._bounds.Min, self._compound[1]._bounds.Max
end

function Wrapper.Reset(self: self, Min: number?, Max: number?)
	self._compound[1]:Reset()
	self._compound[2]:Reset()
	self._compound[3]:Reset()
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