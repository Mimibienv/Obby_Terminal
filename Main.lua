--// Services
local TweenService=game:GetService"TweenService"
local UserInputService=game:GetService"UserInputService"

--// Instances
local Interface=script.Parent
local Storage=Interface.Parent.Storage
local Content=Interface.Parent.Content
local Window=Interface.Window
local Tabs=Window.Tabs
local Terminal=Window.Terminal

local TabTemplate=Storage.TabTemplate
local AddTabButton=Storage.AddTab
local AddInterface=Storage.AddInterface
local ListElementTemplate=Storage.ListElementTemplate

local AddInterfaceInSelection=false
local ColorPalette={
	FocusedColor=Color3.fromRGB(21, 25, 29);
	HoverColor=Color3.fromRGB(25, 29, 33);
	MinimizedColor=Tabs.BackgroundColor3;
}

local Mouse=game:GetService"Players".LocalPlayer:GetMouse()

--// Load

local function GetNumberOfTabs()
	local TabsNum=0
	for i, v in pairs(Tabs:GetChildren()) do
		if string.sub(v.Name,1,3)=="Tab" then
			TabsNum+=1
		end
	end
	return TabsNum
end

AddTabButton.Parent = Tabs
AddTabButton.Position=UDim2.new(GetNumberOfTabs()*.225, 8+GetNumberOfTabs()*2+2, .9, 0)

--// Script

local activeTabs={}

local function refineTabsTable()
	for i, v in pairs(activeTabs) do
		v.Position=i
	end
end

local function ArrangeTabs()
	for i, v in pairs(activeTabs) do
		v.Tab.Position=UDim2.new((v.Position-1)*v.Tab.Size.X.Scale, 8+(v.Position-1)*2, 1, 0)
	end
	AddTabButton.Position=UDim2.new(GetNumberOfTabs()*.225, 8+GetNumberOfTabs()*2+2, .9, 0)
end

local function Focus(Tab)
	for i, v in pairs(activeTabs) do
		v.Focused=v.Tab==Tab and true or v.Position==Tab and true or false
		v.Page.Parent=v.Focused and Terminal or Content
		if v.Focused==false then
			TweenService:Create(v.Tab.Frame, TweenInfo.new(.1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),{BackgroundColor3=ColorPalette.MinimizedColor}):Play()
			TweenService:Create(v.Tab.Frame.CornerFill, TweenInfo.new(.1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),{BackgroundColor3=ColorPalette.MinimizedColor}):Play()
		else
			TweenService:Create(v.Tab.Frame, TweenInfo.new(.1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),{BackgroundColor3=ColorPalette.FocusedColor}):Play()
			TweenService:Create(v.Tab.Frame.CornerFill, TweenInfo.new(.1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),{BackgroundColor3=ColorPalette.FocusedColor}):Play()
		end
	end
end
local function isFocused(Tab)for i,v in pairs(activeTabs)do if v.Tab==Tab then return v.Focused end end end




local function RemoveTab(Tab)
	for i, v in pairs(activeTabs) do
		if v.Tab==Tab then
			v.Page.Parent=Content
			
			local isBefore,isAfter=false,false
			for _,k in pairs(activeTabs) do
				if k.Position==v.Position-1 then isBefore=true end
				if k.Position==v.Position+1 then isAfter=true end
			end
			if isBefore==true or isAfter==true then
				Focus(isBefore and v.Position-1 or v.Position+1)
			end
			
			table.remove(activeTabs, v.Position)
			Tab:Destroy()
		end
	end
	refineTabsTable()
	ArrangeTabs()
end


local function AddTab(Title, Content)
	if typeof(Title)~="string" or typeof(Content)~="Instance" then return end
	
	local NewTab = TabTemplate:Clone()
	local Frame=NewTab.Frame
	local Close=NewTab.Close
	local CornerFill=Frame.CornerFill
	local TabTitle=Frame.Title
	local Status=Frame.Status
	
	TabTitle.Text=Title
	Status.Text="WORKING"
	NewTab.Name="Tab_"..tostring(GetNumberOfTabs()+1)
	
	NewTab.Position=UDim2.new(GetNumberOfTabs()*NewTab.Size.X.Scale, 8+GetNumberOfTabs()*2, 1, 0)
	NewTab.Parent=Tabs
	
	table.insert(activeTabs,{
		Position=GetNumberOfTabs();
		Tab=NewTab;
		Page=Content;
		Focused=false;
	})
	Focus(NewTab)
	ArrangeTabs()
	
	Frame.MouseEnter:Connect(function()
		TweenService:Create(Frame, TweenInfo.new(.1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),{BackgroundColor3=ColorPalette.HoverColor}):Play()
		TweenService:Create(CornerFill, TweenInfo.new(.1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),{BackgroundColor3=ColorPalette.HoverColor}):Play()
	end)
	Frame.MouseLeave:Connect(function()
		TweenService:Create(Frame, TweenInfo.new(.1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),{BackgroundColor3=isFocused(NewTab) and ColorPalette.FocusedColor or ColorPalette.MinimizedColor}):Play()
		TweenService:Create(CornerFill, TweenInfo.new(.1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),{BackgroundColor3=isFocused(NewTab) and ColorPalette.FocusedColor or ColorPalette.MinimizedColor}):Play()
	end)
	Frame.MouseButton1Click:Connect(function()
		print(NewTab.Name.." Clicked")
		Focus(NewTab)
	end)
	
	Close.MouseButton1Click:Connect(function()
		print(NewTab.Name.." Removed")
		RemoveTab(NewTab)
	end)
end


local function HidePopup()
	AddInterface.Parent=Storage
	for i, v in pairs(AddInterface.ScrollingGui:GetChildren()) do
		if v:IsA("TextButton") then
			v:Destroy()
		end
	end
end

local function ShowPopup()
	AddInterface.Position=UDim2.new(0, Mouse.X, 0, Mouse.Y)
	for i, v in pairs(Content:GetChildren()) do
		if v:IsA("Frame") then
			local NewListElement=ListElementTemplate:Clone()
			NewListElement.Name=v.Name.."_ListElement"
			NewListElement.Title.Text=" • "..v.Name
			NewListElement.Parent=AddInterface.ScrollingGui
			NewListElement.MouseButton1Click:Connect(function()
				AddTab(v.Name, v)
				HidePopup()
			end)
		end
	end
	AddInterface.Parent=Interface
end

AddTabButton.MouseButton1Click:Connect(function()
	ShowPopup()
end)

AddInterface.MouseEnter:Connect(function() AddInterfaceInSelection=true end)
AddInterface.MouseLeave:Connect(function() AddInterfaceInSelection=false end)
UserInputService.InputBegan:Connect(function(Input)
	if AddInterface.Parent==Interface and not AddInterfaceInSelection and Input.UserInputType == 
		Enum.UserInputType.MouseButton1 then
		HidePopup()
	end
end)
