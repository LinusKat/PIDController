--!strict
local huge = math.huge

local PIDController = {}
PIDController.__index = PIDController

function PIDController.new(Kp: number?, Ki: number?, Kd: number?, Min: number?, Max: number?): PIDController	
	local self = setmetatable({}, PIDController):: self
	self._gains = {
		Kp = Kp or 1;
		Ki = Ki or 0.001;
		Kd = Kd or 0.5;
	}
	self._bounds = NumberRange.new(Min or -huge, Max or huge)
	
	self._integrator_on = true
	self._integral = 0
	self._previous_error = 0
	
	return self
end

function PIDController.Compound(Amount: number, Kp: number?, Ki: number?, Kd: number?, Min: number?, Max: number?): Compound
	local compound = {}
	for _ = 1, Amount do
		table.insert(compound, PIDController.new(Kp, Ki, Kd, Min, Max))
	end
	return compound
end

function PIDController.Update(self: self, SetPoint: number, ProcessValue: number, dt: number): number
	local error = SetPoint - ProcessValue

	local pOut = self._gains.Kp * error

	local iOut = 0
	if self._integrator_on then
		self._integral += error * dt
		iOut = self._gains.Ki * self._integral
	end

	local dOut = self._gains.Kd * (error - self._previous_error) / dt

	local rawOutput = pOut + iOut + dOut
	local output = math.clamp(rawOutput, self._bounds.Min, self._bounds.Max)

	self._integrator_on = 
		not (rawOutput ~= output and math.sign(rawOutput) == math.sign(error))

	self._previous_error = error
	return output
end

function PIDController.SetGains(self: self, Kp: number?, Ki: number?, Kd: number?)
	self._gains = {
		Kp = Kp or 1,
		Ki = Ki or 0.001,
		Kd = Kd or 0.5,
	}
end

function PIDController.GetGains(self: self): (number, number, number)
	return self._gains.Kp, self._gains.Ki, self._gains.Kd
end

function PIDController.SetBounds(self: self, Min: number?, Max: number?)
	self._bounds = NumberRange.new(Min or -huge, Max or huge)
end

function PIDController.GetBounds(self: self): (number, number)
	return self._bounds.Min, self._bounds.Max
end

function PIDController.Reset(self: self)
	self._integrator_on = true
	self._integral = 0
	self._previous_error = 0
end

function PIDController.Destroy(self: self)
	table.clear(self)
end

export type PIDArgsVararg = (number | number | number | number | number)
export type Compound = {[number]: PIDController}

export type PIDController = {
	_gains: {
		Kp: number,
		Ki: number,
		Kd: number,
	},
	_bounds: NumberRange,

	_integrator_on: boolean,
	_integral: number,
	_previous_error: number,
} & typeof(PIDController)
type self = PIDController

return PIDController