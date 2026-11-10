-- Modern, type-checked Luau speed hook engine with Visual UI Toggle Button

-- Services
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local PostSim: RBXScriptSignal = RunService.PostSimulation

-- Active State Configuration
getgenv().SpeedEngineEnabled = true

-- Modern hookfunction wrapper check
local hookfunction = hookfunction or (hookmetamethod and function(f, h) return hookfunction(f, h) end)

if not hookfunction then
    warn("[Speed Engine] Executor does not support 'hookfunction'. Patch aborted.")
    return
end

-- Faster, type-safe yields using PostSimulation
local function fastYield(): number
    return PostSim:Wait()
end

-- Inline wrapper to safely spawn functions without redundant closure creation
local function immediateSpawn(duration: number?, func: (...any) -> (), ...: any): thread?
    if type(func) == "function" then
        return task.spawn(func, ...)
    end
    return nil
end

-- ==========================================
-- 1. PATCH HOOKS WITH TOGGLE ROUTING
-- ==========================================

local originalTaskWait: (...any) -> number
originalTaskWait = hookfunction(task.wait, function(duration: number?): number
    if getgenv().SpeedEngineEnabled then
        return fastYield()
    else
        return originalTaskWait(duration)
    end
end)

local originalTaskDelay: (...any) -> thread
originalTaskDelay = hookfunction(task.delay, function(duration: number?, func: (...any) -> (), ...: any): thread?
    if getgenv().SpeedEngineEnabled then
        return immediateSpawn(duration, func, ...)
    else
        return originalTaskDelay(duration, func, ...)
    end
end)

local originalWait
if getgenv and getgenv().wait then
    originalWait = hookfunction(getgenv().wait, function(duration: number?): number
        if getgenv().SpeedEngineEnabled then
            return fastYield()
        else
            return originalWait(duration)
        end
    end)
end

local originalDelay
if getgenv and getgenv().delay then
    originalDelay = hookfunction(getgenv().delay, function(duration: number?, func: (...any) -> (), ...: any): thread?
        if getgenv().SpeedEngineEnabled then
            return immediateSpawn(duration, func, ...)
        else
            return originalDelay(duration, func, ...)
        end
    end)
end

local originalSpawn
if getgenv and getgenv().spawn then
    originalSpawn = hookfunction(getgenv().spawn, function(func: (...any) -> (), ...: any): thread?
        if getgenv().SpeedEngineEnabled then
            return immediateSpawn(0, func, ...)
        else
            return originalSpawn(func, ...)
        end
    end)
end

-- ==========================================
-- 2. GUI INTERACTIVE TOGGLE GENERATION
-- ==========================================

-- Destroy existing UI if re-executed to prevent clutter
local existingGui = CoreGui:FindFirstChild("SpeedEngineUI")
if existingGui then existingGui:Destroy() end

-- Container Elements
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local ToggleButton = Instance.new("TextButton")
local UICorner = Instance.new("UICorner")
local UIEnhance = Instance.new("UICorner")

ScreenGui.Name = "SpeedEngineUI"
ScreenGui.Parent = CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Background Frame
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.05, 0, 0.4, 0)
MainFrame.Size = UDim2.new(0, 160, 0, 50)
MainFrame.Active = true

UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

-- Interactive Toggle Button
ToggleButton.Name = "ToggleButton"
ToggleButton.Parent = MainFrame
ToggleButton.BackgroundColor3 = Color3.fromRGB(46, 204, 113) -- Active Green
ToggleButton.Size = UDim2.new(1, -10, 1, -10)
ToggleButton.Position = UDim2.new(0, 5, 0, 5)
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.Text = "NO COOL DOWN: ON"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextSize = 14.000

UIEnhance.CornerRadius = UDim.new(0, 6)
UIEnhance.Parent = ToggleButton

-- Dragging Logic Functionality
local dragging, dragInput, dragStart, startPos
local function update(input)
    local delta = input.Position - dragStart
    MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)

MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then update(input) end
end)

-- Click Button State Toggle Function
ToggleButton.MouseButton1Click:Connect(function()
    getgenv().SpeedEngineEnabled = not getgenv().SpeedEngineEnabled
    if getgenv().SpeedEngineEnabled then
        ToggleButton.Text = "NO COOL DOWN: ON"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(46, 204, 113) -- Vibrant Green
    else
        ToggleButton.Text = "NO COOL DOWN: OFF"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(231, 76, 60) -- Vibrant Red
    end
end)

print("⚡ MODERN MAX-SPEED ENGINE WITH DRAGGABLE UI TOGGLE LOADED ⚡")
