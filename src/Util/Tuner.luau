--!strict
local PIDController = require(script.Parent.Parent)
local Vector2 = require(script.Parent.Parent.PIDWrappers.Vector2)
local Vector3 = require(script.Parent.Parent.PIDWrappers.Vector3)

local Tuner = {}
Tuner.__index = Tuner

function Tuner.new(PID: ExpectedType, name: string?, parent: Instance?): Tuner
	local self = setmetatable({}:: self, Tuner)
	
	self.Folder = Instance.new("Folder")
	self.Folder.Parent = parent
	self.Folder.Name = name or "PID_Tuner"
	
	self:_initialize(PID)
	
	return self
end

function Tuner._bind_pid_controller(self: self, PIDController: PIDController)
	local folder = self.Folder
	
	local Kp, Ki, Kd = PIDController:GetGains()
	folder:SetAttribute("Kp", Kp)
	folder:SetAttribute("Ki", Ki)
	folder:SetAttribute("Kd", Kd)
	
	local Min, Max = PIDController:GetBounds()
	folder:SetAttribute("Min", Min)
	folder:SetAttribute("Max", Max)
	
	folder.AttributeChanged:Connect(function()
		PIDController:SetGains(
			folder:GetAttribute("Kp"):: number,
			folder:GetAttribute("Ki"):: number,
			folder:GetAttribute("Kd"):: number
		)
		
		PIDController:SetBounds(
			folder:GetAttribute("Min"):: number,
			folder:GetAttribute("Max"):: number
		)
	end)
end

function Tuner._initialize(self: self, PID: ExpectedType | any)
	if not PID._compound then
		self:_bind_pid_controller(PID:: PIDController)
	elseif PID._compound then
		self:_initialize(PID._compound)
	elseif typeof(PID) == "table" then
		for _, PID in ipairs(PID) do
			self:_initialize(PID)
		end
	end
end

function Tuner.Destroy(self: self)
	if self.Folder then
		self.Folder:Destroy()
	end
	
	table.clear(self)
end

type PIDController = PIDController.PIDController
type Compound = PIDController.Compound
type Vector3PID = Vector3.Wrapper
type Vector2PID = Vector2.Wrapper

type ExpectedType = PIDController | Compound | Vector3PID | Vector2PID

export type Tuner = {
	Folder: Folder,
} & typeof(Tuner)
type self = Tuner

return Tuner