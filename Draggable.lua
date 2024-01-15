local module = {}
local UserInputService = game:GetService"UserInputService"
local runService = game:GetService"RunService"

function module:MakeDraggable(gui)

	local dragging,dragInput,dragStart,startPos

	local function Lerp(a, b, m)
		return a+(b-a)*m
	end;

	local lastMousePos,lastGoalPos
	local DRAG_SPEED = 10
	
	local function Update(dt)
		if not startPos then return end;
		if not dragging and lastGoalPos then
			gui.Position = UDim2.new(startPos.X.Scale, Lerp(gui.Position.X.Offset, lastGoalPos.X.Offset, dt * DRAG_SPEED), startPos.Y.Scale, Lerp(gui.Position.Y.Offset, lastGoalPos.Y.Offset, dt * DRAG_SPEED))
			return 
		end;

		local delta=(lastMousePos - UserInputService:GetMouseLocation())
		local xGoal=(startPos.X.Offset-delta.X);
		local yGoal=(startPos.Y.Offset-delta.Y);
		lastGoalPos=UDim2.new(startPos.X.Scale, xGoal, startPos.Y.Scale, yGoal)
		gui.Position=UDim2.new(startPos.X.Scale, Lerp(gui.Position.X.Offset, xGoal, dt * DRAG_SPEED), startPos.Y.Scale, Lerp(gui.Position.Y.Offset, yGoal, dt * DRAG_SPEED))
	end

	gui.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = gui.Position
			lastMousePos = UserInputService:GetMouseLocation()

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	gui.InputChanged:Connect(function(input)
		if input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch then
			dragInput=input
		end
	end)

	runService.Heartbeat:Connect(Update)
end

return module
