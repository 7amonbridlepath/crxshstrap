local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local grayColor = Color3.fromRGB(128, 128, 128)
local grayBallActive = false
local grayBallConnection = nil

local function makeGray(ball)
    for _, part in ipairs(ball:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Color = grayColor
            part.Material = Enum.Material.SmoothPlastic
        end
        if part:IsA("SpecialMesh") or part:IsA("MeshPart") then
            part.TextureId = ""
        end
        if part:IsA("Decal") or part:IsA("Texture") then
            part:Destroy()
        end
    end
end

local function startGrayBall()
    if grayBallConnection then grayBallConnection:Disconnect() end
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj.Name == "Ball" or obj.Name == "Football" or obj.Name == "football" then
            makeGray(obj)
        end
    end
    grayBallConnection = Workspace.DescendantAdded:Connect(function(obj)
        if not grayBallActive then return end
        if obj.Name == "Ball" or obj.Name == "Football" or obj.Name == "football" then
            task.wait()
            makeGray(obj)
            obj.DescendantAdded:Connect(function(part)
                if not grayBallActive then return end
                task.wait()
                if part:IsA("BasePart") then
                    part.Color = grayColor
                    part.Material = Enum.Material.SmoothPlastic
                end
                if part:IsA("Decal") or part:IsA("Texture") then
                    part:Destroy()
                end
            end)
        end
    end)
end

local function stopGrayBall()
    if grayBallConnection then
        grayBallConnection:Disconnect()
        grayBallConnection = nil
    end
end

local function toggleGrayBall()
    grayBallActive = not grayBallActive
    if grayBallActive then startGrayBall() else stopGrayBall() end
    return grayBallActive
end

local function setFPS(fps)
    pcall(function()
        if setfflag then
            setfflag("FFlagDebugFpsCap", tostring(fps))
            setfflag("FFlagFpsCap", tostring(fps))
            setfflag("DFIntFpsCap", tostring(fps))
            setfflag("DFIntTaskSchedulerTargetFps", tostring(fps))
        end
        if setfpscap then setfpscap(fps) end
        if syn and syn.set_fps_cap then syn.set_fps_cap(fps) end
        if set_fps_cap then set_fps_cap(fps) end
        if setfps then setfps(fps) end
    end)
end

local injectedFlags = {}

local function applyFlags(json)
    local ok, data = pcall(HttpService.JSONDecode, HttpService, json)
    if not ok or type(data) ~= "table" then return false, "bad json" end
    for k in pairs(data) do
        if tostring(k):lower():find("humanoid") then
            pcall(function() LocalPlayer:Kick("dont use humanoid flags") end)
            return false, "blocked - humanoid flag"
        end
    end
    local count = 0
    for k, v in pairs(data) do
        if not injectedFlags[k] then
            local orig = nil
            pcall(function() orig = getfflag(k) end)
            injectedFlags[k] = orig ~= nil and orig or "__nil__"
        end
        pcall(function() setfflag(k, tostring(v)); count = count + 1 end)
    end
    return true, "injected " .. count .. " flags"
end

local function revertFlags()
    if next(injectedFlags) == nil then return false, "nothing to revert" end
    local count = 0
    for k, orig in pairs(injectedFlags) do
        if orig == "__nil__" then
            pcall(function() setfflag(k, ""); count = count + 1 end)
        else
            pcall(function() setfflag(k, tostring(orig)); count = count + 1 end)
        end
        injectedFlags[k] = nil
    end
    return true, "reverted " .. count .. " flags"
end

local freezeActive = false
local freezeDuration = 1
local MIN_TIME = 0.1
local MAX_TIME = 6

local function causeFreeze(duration)
    local start = tick()
    while tick() - start < duration do
        for i = 1, 50000 do
            local _ = math.sin(i) * math.cos(i)
        end
    end
end

local function triggerFreeze()
    if freezeActive then return end
    freezeActive = true
    causeFreeze(freezeDuration)
    freezeActive = false
end

-- ========== BLACK & WHITE THEME ==========
local Theme = {
    B = Color3.fromRGB(10, 10, 10),     -- Pure black base
    S = Color3.fromRGB(20, 20, 20),     -- Dark gray surface
    A = Color3.fromRGB(255, 255, 255),  -- White accent
    D = Color3.fromRGB(200, 200, 200),  -- Light gray text
    G = Color3.fromRGB(255, 255, 255),  -- White success
    R = Color3.fromRGB(200, 200, 200),  -- Light gray (was red)
    CodeBg = Color3.fromRGB(15, 15, 15),-- Slightly lighter black for code
}
-- ========================================

if CoreGui:FindFirstChild("CRXSH") then CoreGui.CRXSH:Destroy() end

local sg = Instance.new("ScreenGui")
sg.Name = "CRXSH"
sg.IgnoreGuiInset = true
sg.ResetOnSpawn = false
sg.Parent = CoreGui

local introFrame = Instance.new("Frame", sg)
introFrame.Size = UDim2.new(1, 0, 1, 0)
introFrame.BackgroundColor3 = Theme.B
introFrame.ZIndex = 100

local introText = Instance.new("TextLabel", introFrame)
introText.Size = UDim2.new(1, 0, 0.2, 0)
introText.Position = UDim2.new(0, 0, 0.33, 0)
introText.BackgroundTransparency = 1
introText.Text = "CRXSH STRAP"
introText.Font = Enum.Font.GothamBold
introText.TextColor3 = Theme.A
introText.TextSize = 45
introText.ZIndex = 101

local creditText = Instance.new("TextLabel", introFrame)
creditText.Size = UDim2.new(0, 0, 0, 0)
creditText.BackgroundTransparency = 1
creditText.Text = ""
creditText.ZIndex = 101

local ideaText = Instance.new("TextLabel", introFrame)
ideaText.Size = UDim2.new(0, 0, 0, 0)
ideaText.BackgroundTransparency = 1
ideaText.Text = ""
ideaText.ZIndex = 101

local main = Instance.new("Frame", sg)
main.Size = UDim2.new(0, 560, 0, 420)
main.Position = UDim2.new(0.5, -280, 0.5, -210)
main.BackgroundColor3 = Theme.B
main.BackgroundTransparency = 0.15
main.Visible = false
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 8)

local dragging = false
local dragStart = nil
local startPos = nil
local isDraggingSlider = false

main.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        if not isDraggingSlider then
            dragging = true
            dragStart = input.Position
            startPos = main.Position
        end
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and not isDraggingSlider and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

local side = Instance.new("Frame", main)
side.Size = UDim2.new(0, 150, 1, 0)
side.BackgroundColor3 = Theme.S
side.BackgroundTransparency = 0.3
side.BorderSizePixel = 0
Instance.new("UICorner", side).CornerRadius = UDim.new(0, 8)

local brand = Instance.new("TextLabel", side)
brand.Text = "CRXSH STRAP"
brand.Font = Enum.Font.GothamBold
brand.TextColor3 = Theme.A
brand.TextSize = 14
brand.Position = UDim2.new(0, 12, 0, 12)
brand.Size = UDim2.new(1, -24, 0, 20)
brand.BackgroundTransparency = 1
brand.TextXAlignment = Enum.TextXAlignment.Left

local profileCard = Instance.new("Frame", side)
profileCard.Size = UDim2.new(1, -16, 0, 48)
profileCard.Position = UDim2.new(0, 8, 1, -56)
profileCard.BackgroundTransparency = 1

local pfpCont = Instance.new("Frame", profileCard)
pfpCont.Size = UDim2.new(0, 36, 0, 36)
pfpCont.Position = UDim2.new(0, 0, 0.5, -18)
pfpCont.BackgroundColor3 = Theme.B
pfpCont.BackgroundTransparency = 0.2
Instance.new("UICorner", pfpCont).CornerRadius = UDim.new(1, 0)

local pfp = Instance.new("ImageLabel", pfpCont)
pfp.Size = UDim2.new(1, 0, 1, 0)
pfp.BackgroundTransparency = 1
pfp.Image = "rbxthumb://type=AvatarHeadShot&id=" .. LocalPlayer.UserId .. "&x=150&y=150"
Instance.new("UICorner", pfp).CornerRadius = UDim.new(1, 0)

local metaCont = Instance.new("Frame", profileCard)
metaCont.Size = UDim2.new(1, -44, 1, 0)
metaCont.Position = UDim2.new(0, 44, 0, 0)
metaCont.BackgroundTransparency = 1

local nameLabel = Instance.new("TextLabel", metaCont)
nameLabel.Size = UDim2.new(1, 0, 0, 14)
nameLabel.BackgroundTransparency = 1
nameLabel.Text = LocalPlayer.Name
nameLabel.Font = Enum.Font.GothamBold
nameLabel.TextColor3 = Theme.A
nameLabel.TextSize = 11
nameLabel.TextXAlignment = Enum.TextXAlignment.Left

local idLabel = Instance.new("TextLabel", metaCont)
idLabel.Size = UDim2.new(1, 0, 0, 11)
idLabel.BackgroundTransparency = 1
idLabel.Text = "ID: " .. LocalPlayer.UserId
idLabel.Font = Enum.Font.GothamMedium
idLabel.TextColor3 = Theme.D
idLabel.TextSize = 9
idLabel.TextXAlignment = Enum.TextXAlignment.Left

local ageLabel = Instance.new("TextLabel", metaCont)
ageLabel.Size = UDim2.new(1, 0, 0, 11)
ageLabel.BackgroundTransparency = 1
ageLabel.Text = "Age: " .. LocalPlayer.AccountAge .. "d"
ageLabel.Font = Enum.Font.Gotham
ageLabel.TextColor3 = Theme.D
ageLabel.TextSize = 9
ageLabel.TextXAlignment = Enum.TextXAlignment.Left

local container = Instance.new("Frame", main)
container.Size = UDim2.new(1, -175, 1, -50)
container.Position = UDim2.new(0, 163, 0, 38)
container.BackgroundTransparency = 1

local btnList = Instance.new("ScrollingFrame", side)
btnList.Size = UDim2.new(1, 0, 1, -115)
btnList.Position = UDim2.new(0, 0, 0, 42)
btnList.BackgroundTransparency = 1
btnList.ScrollBarThickness = 0
Instance.new("UIListLayout", btnList).HorizontalAlignment = Enum.HorizontalAlignment.Center

local allBtns = {}
local function createTab(name)
    local btn = Instance.new("TextButton", btnList)
    btn.Size = UDim2.new(0.9, 0, 0, 35)
    btn.BackgroundTransparency = 1
    btn.Text = name
    btn.TextColor3 = Theme.D
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 11
    local page = Instance.new("ScrollingFrame", container)
    page.ScrollBarThickness = 4
    page.ScrollBarImageColor3 = Theme.A
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.Visible = false
    btn.MouseButton1Click:Connect(function()
        for _, v in pairs(container:GetChildren()) do
            if v:IsA("ScrollingFrame") then v.Visible = false end
        end
        for _, b in pairs(allBtns) do b.TextColor3 = Theme.D end
        page.Visible = true
        btn.TextColor3 = Theme.A
    end)
    table.insert(allBtns, btn)
    return page, btn
end

local injectTab, injectBtn = createTab("INJECT")
local ballTab, ballBtn = createTab("BALL")
local fpsTab, fpsBtn = createTab("FPS")
local freezeTab, freezeBtn = createTab("FREEZE")
local aboutTab, aboutBtn = createTab("ABOUT")

-- ================= INJECT TAB =================
local jsonBox = Instance.new("TextBox", injectTab)
jsonBox.Size = UDim2.new(0.95, 0, 0, 120)
jsonBox.Position = UDim2.new(0.025, 0, 0, 10)
jsonBox.BackgroundColor3 = Theme.CodeBg
jsonBox.TextColor3 = Color3.new(1, 1, 1)
jsonBox.TextSize = 11
jsonBox.MultiLine = true
jsonBox.TextWrapped = true
jsonBox.Text = '{\n    "FFlagDebugSkyGray": true\n}'
jsonBox.ClearTextOnFocus = false
Instance.new("UICorner", jsonBox).CornerRadius = UDim.new(0, 6)

local injectBtnUI = Instance.new("TextButton", injectTab)
injectBtnUI.Size = UDim2.new(0.45, 0, 0, 40)
injectBtnUI.Position = UDim2.new(0.025, 0, 0, 140)
injectBtnUI.BackgroundColor3 = Theme.A
injectBtnUI.TextColor3 = Color3.new(0, 0, 0)
injectBtnUI.Text = "INJECT FLAGS"
injectBtnUI.Font = Enum.Font.GothamBold
injectBtnUI.TextSize = 13
Instance.new("UICorner", injectBtnUI).CornerRadius = UDim.new(0, 6)

local revertBtnUI = Instance.new("TextButton", injectTab)
revertBtnUI.Size = UDim2.new(0.45, 0, 0, 40)
revertBtnUI.Position = UDim2.new(0.525, 0, 0, 140)
revertBtnUI.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
revertBtnUI.TextColor3 = Color3.new(1, 1, 1)
revertBtnUI.Text = "REVERT FLAGS"
revertBtnUI.Font = Enum.Font.GothamBold
revertBtnUI.TextSize = 13
Instance.new("UICorner", revertBtnUI).CornerRadius = UDim.new(0, 6)

local statusLabel = Instance.new("TextLabel", injectTab)
statusLabel.Size = UDim2.new(0.95, 0, 0, 20)
statusLabel.Position = UDim2.new(0.025, 0, 0, 190)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "ready"
statusLabel.TextColor3 = Theme.G
statusLabel.TextSize = 11
statusLabel.Font = Enum.Font.Gotham

local function showStatus(msg, ok)
    statusLabel.Text = msg
    statusLabel.TextColor3 = ok and Theme.G or Theme.R
    task.delay(2, function()
        statusLabel.Text = "ready"
        statusLabel.TextColor3 = Theme.G
    end)
end

injectBtnUI.MouseButton1Click:Connect(function()
    local ok, msg = applyFlags(jsonBox.Text)
    showStatus(msg, ok)
end)

revertBtnUI.MouseButton1Click:Connect(function()
    local ok, msg = revertFlags()
    showStatus(msg, ok)
end)

-- ================= BALL TAB =================
local ballTitleLbl = Instance.new("TextLabel", ballTab)
ballTitleLbl.Size = UDim2.new(0.95, 0, 0, 20)
ballTitleLbl.Position = UDim2.new(0.025, 0, 0, 10)
ballTitleLbl.BackgroundTransparency = 1
ballTitleLbl.Text = "Ball Settings"
ballTitleLbl.TextColor3 = Theme.A
ballTitleLbl.TextSize = 14
ballTitleLbl.Font = Enum.Font.GothamBold

local grayBallBtn = Instance.new("TextButton", ballTab)
grayBallBtn.Size = UDim2.new(0.8, 0, 0, 50)
grayBallBtn.Position = UDim2.new(0.1, 0, 0, 50)
grayBallBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
grayBallBtn.TextColor3 = Color3.new(1, 1, 1)
grayBallBtn.Text = "GRAY BALL: OFF"
grayBallBtn.Font = Enum.Font.GothamBold
grayBallBtn.TextSize = 16
Instance.new("UICorner", grayBallBtn).CornerRadius = UDim.new(0, 8)

grayBallBtn.MouseButton1Click:Connect(function()
    local on = toggleGrayBall()
    grayBallBtn.BackgroundColor3 = on and Color3.fromRGB(128, 128, 128) or Color3.fromRGB(60, 60, 70)
    grayBallBtn.Text = on and "GRAY BALL: ON" or "GRAY BALL: OFF"
end)

-- ================= FPS TAB =================
local MIN_FPS, MAX_FPS = 20, 360
local currentFPS = 120

local fpsTitleLbl = Instance.new("TextLabel", fpsTab)
fpsTitleLbl.Size = UDim2.new(0.95, 0, 0, 20)
fpsTitleLbl.Position = UDim2.new(0.025, 0, 0, 10)
fpsTitleLbl.BackgroundTransparency = 1
fpsTitleLbl.Text = "FPS Unlocker"
fpsTitleLbl.TextColor3 = Theme.A
fpsTitleLbl.TextSize = 14
fpsTitleLbl.Font = Enum.Font.GothamBold

local fpsDisplay = Instance.new("TextLabel", fpsTab)
fpsDisplay.Size = UDim2.new(0.95, 0, 0, 24)
fpsDisplay.Position = UDim2.new(0.025, 0, 0, 35)
fpsDisplay.BackgroundTransparency = 1
fpsDisplay.Text = "Cap: 120 FPS"
fpsDisplay.TextColor3 = Theme.G
fpsDisplay.TextSize = 16
fpsDisplay.Font = Enum.Font.GothamBold

local sliderTrack = Instance.new("Frame", fpsTab)
sliderTrack.Size = UDim2.new(0.55, 0, 0, 8)
sliderTrack.Position = UDim2.new(0.025, 0, 0, 70)
sliderTrack.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
Instance.new("UICorner", sliderTrack).CornerRadius = UDim.new(1, 0)

local sliderFill = Instance.new("Frame", sliderTrack)
sliderFill.Size = UDim2.new(0.3, 0, 1, 0)
sliderFill.BackgroundColor3 = Theme.A
Instance.new("UICorner", sliderFill).CornerRadius = UDim.new(1, 0)

local sliderKnob = Instance.new("Frame", sliderTrack)
sliderKnob.Size = UDim2.new(0, 16, 0, 16)
sliderKnob.AnchorPoint = Vector2.new(0.5, 0.5)
sliderKnob.Position = UDim2.new(0.3, 0, 0.5, 0)
sliderKnob.BackgroundColor3 = Theme.A
Instance.new("UICorner", sliderKnob).CornerRadius = UDim.new(1, 0)

local fpsInputBox = Instance.new("TextBox", fpsTab)
fpsInputBox.Size = UDim2.new(0.16, 0, 0, 28)
fpsInputBox.Position = UDim2.new(0.6, 0, 0, 62)
fpsInputBox.BackgroundColor3 = Theme.CodeBg
fpsInputBox.TextColor3 = Color3.new(1, 1, 1)
fpsInputBox.Text = "120"
fpsInputBox.TextSize = 12
fpsInputBox.Font = Enum.Font.GothamBold
Instance.new("UICorner", fpsInputBox).CornerRadius = UDim.new(0, 5)

local applyBtn = Instance.new("TextButton", fpsTab)
applyBtn.Size = UDim2.new(0.16, 0, 0, 28)
applyBtn.Position = UDim2.new(0.78, 0, 0, 62)
applyBtn.BackgroundColor3 = Theme.A
applyBtn.TextColor3 = Color3.new(0, 0, 0)
applyBtn.Text = "APPLY"
applyBtn.Font = Enum.Font.GothamBold
applyBtn.TextSize = 11
Instance.new("UICorner", applyBtn).CornerRadius = UDim.new(0, 5)

local mainFpsLbl = Instance.new("TextLabel", fpsTab)
mainFpsLbl.Size = UDim2.new(0.95, 0, 0, 16)
mainFpsLbl.Position = UDim2.new(0.025, 0, 0, 105)
mainFpsLbl.BackgroundTransparency = 1
mainFpsLbl.Text = "Main FPS"
mainFpsLbl.TextColor3 = Theme.D
mainFpsLbl.TextSize = 11
mainFpsLbl.Font = Enum.Font.GothamMedium

local presets = {21, 23, 35}
local presetBtns = {}
for i, fps in ipairs(presets) do
    local btn = Instance.new("TextButton", fpsTab)
    btn.Size = UDim2.new(0.18, 0, 0, 32)
    btn.Position = UDim2.new(0.025 + (i-1) * 0.21, 0, 0, 125)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    btn.TextColor3 = Theme.A
    btn.Text = fps .. " FPS"
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    presetBtns[i] = btn
end

local function fpsToAlpha(fps)
    return (fps - MIN_FPS) / (MAX_FPS - MIN_FPS)
end

local function alphaToFPS(alpha)
    return math.floor(MIN_FPS + math.clamp(alpha, 0, 1) * (MAX_FPS - MIN_FPS))
end

local function updateFPSUI(fps)
    local a = fpsToAlpha(fps)
    sliderFill.Size = UDim2.new(a, 0, 1, 0)
    sliderKnob.Position = UDim2.new(a, 0, 0.5, 0)
    fpsInputBox.Text = tostring(fps)
    fpsDisplay.Text = "Cap: " .. fps .. " FPS"
    currentFPS = fps
end

local function setFPSValue(fps)
    fps = math.clamp(fps, MIN_FPS, MAX_FPS)
    updateFPSUI(fps)
    setFPS(fps)
    for i, preset in ipairs(presets) do
        if preset == fps then
            presetBtns[i].BackgroundColor3 = Theme.A
            presetBtns[i].TextColor3 = Color3.new(0, 0, 0)
        else
            presetBtns[i].BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            presetBtns[i].TextColor3 = Theme.A
        end
    end
end

local isDraggingFPS = false

local function beginFPSDrag(input)
    isDraggingFPS = true
    isDraggingSlider = true
    local x = math.clamp((input.Position.X - sliderTrack.AbsolutePosition.X) / sliderTrack.AbsoluteSize.X, 0, 1)
    setFPSValue(alphaToFPS(x))
end

sliderTrack.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        beginFPSDrag(input)
    end
end)

sliderKnob.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        beginFPSDrag(input)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if isDraggingFPS and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local x = math.clamp((input.Position.X - sliderTrack.AbsolutePosition.X) / sliderTrack.AbsoluteSize.X, 0, 1)
        updateFPSUI(alphaToFPS(x))
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        if isDraggingFPS then
            setFPS(currentFPS)
            isDraggingFPS = false
            isDraggingSlider = false
        end
    end
end)

applyBtn.MouseButton1Click:Connect(function()
    local fps = tonumber(fpsInputBox.Text)
    if fps then setFPSValue(fps) else fpsInputBox.Text = tostring(currentFPS) end
end)

for i, fps in ipairs(presets) do
    presetBtns[i].MouseButton1Click:Connect(function()
        setFPSValue(fps)
    end)
end

fpsInputBox.FocusLost:Connect(function()
    local fps = tonumber(fpsInputBox.Text)
    if fps then setFPSValue(fps) else fpsInputBox.Text = tostring(currentFPS) end
end)

-- ================= FREEZE TAB =================
local freezeTitleLbl = Instance.new("TextLabel", freezeTab)
freezeTitleLbl.Size = UDim2.new(0.95, 0, 0, 20)
freezeTitleLbl.Position = UDim2.new(0.025, 0, 0, 10)
freezeTitleLbl.BackgroundTransparency = 1
freezeTitleLbl.Text = "Freeze Settings"
freezeTitleLbl.TextColor3 = Theme.A
freezeTitleLbl.TextSize = 14
freezeTitleLbl.Font = Enum.Font.GothamBold

local freezeSliderBG = Instance.new("Frame", freezeTab)
freezeSliderBG.Size = UDim2.new(0.8, 0, 0, 12)
freezeSliderBG.Position = UDim2.new(0.1, 0, 0, 50)
freezeSliderBG.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
freezeSliderBG.BorderSizePixel = 0
Instance.new("UICorner", freezeSliderBG).CornerRadius = UDim.new(1, 0)

local freezeSliderFill = Instance.new("Frame", freezeSliderBG)
freezeSliderFill.Size = UDim2.new(0.15, 0, 1, 0)
freezeSliderFill.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
freezeSliderFill.BorderSizePixel = 0
Instance.new("UICorner", freezeSliderFill).CornerRadius = UDim.new(1, 0)

local freezeTimeLabel = Instance.new("TextLabel", freezeTab)
freezeTimeLabel.Size = UDim2.new(0.8, 0, 0, 25)
freezeTimeLabel.Position = UDim2.new(0.1, 0, 0, 75)
freezeTimeLabel.BackgroundTransparency = 1
freezeTimeLabel.Font = Enum.Font.GothamBold
freezeTimeLabel.TextScaled = true
freezeTimeLabel.TextColor3 = Theme.A
freezeTimeLabel.Text = "Duration: 1.0s"

local freezeNowBtn = Instance.new("TextButton", freezeTab)
freezeNowBtn.Size = UDim2.new(0.7, 0, 0, 50)
freezeNowBtn.Position = UDim2.new(0.15, 0, 0, 115)
freezeNowBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
freezeNowBtn.BorderSizePixel = 0
freezeNowBtn.Text = "FREEZE NOW"
freezeNowBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
freezeNowBtn.TextSize = 18
freezeNowBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", freezeNowBtn).CornerRadius = UDim.new(0, 8)

local freezeInfo = Instance.new("TextLabel", freezeTab)
freezeInfo.Size = UDim2.new(0.9, 0, 0, 40)
freezeInfo.Position = UDim2.new(0.05, 0, 0, 180)
freezeInfo.BackgroundTransparency = 1
freezeInfo.Text = "Click FREEZE NOW or press Y to freeze\nUse the slider to set freeze duration"
freezeInfo.TextColor3 = Theme.D
freezeInfo.TextSize = 11
freezeInfo.Font = Enum.Font.Gotham
freezeInfo.TextWrapped = true

freezeNowBtn.MouseButton1Click:Connect(function()
    triggerFreeze()
end)

local function updateFreezeSlider(xPos)
    local x = math.clamp((xPos - freezeSliderBG.AbsolutePosition.X) / freezeSliderBG.AbsoluteSize.X, 0, 1)
    freezeSliderFill.Size = UDim2.new(x, 0, 1, 0)
    freezeDuration = math.clamp(MIN_TIME + x * (MAX_TIME - MIN_TIME), MIN_TIME, MAX_TIME)
    freezeTimeLabel.Text = string.format("Duration: %.1fs", freezeDuration)
end

local isDraggingFreeze = false

freezeSliderBG.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isDraggingFreeze = true
        isDraggingSlider = true
        updateFreezeSlider(input.Position.X)
    end
end)

freezeSliderBG.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isDraggingFreeze = false
        isDraggingSlider = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if isDraggingFreeze and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        updateFreezeSlider(input.Position.X)
    end
end)

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.ButtonY then
        triggerFreeze()
    end
end)

-- ================= ABOUT TAB =================
local aboutLine1 = Instance.new("TextLabel", aboutTab)
aboutLine1.Size = UDim2.new(0.95, 0, 0, 25)
aboutLine1.Position = UDim2.new(0.025, 0, 0, 20)
aboutLine1.BackgroundTransparency = 1
aboutLine1.Text = "CRXSH STRAP v1"
aboutLine1.TextColor3 = Theme.A
aboutLine1.TextSize = 16
aboutLine1.Font = Enum.Font.GothamBold
aboutLine1.TextXAlignment = Enum.TextXAlignment.Left

local aboutLine2 = Instance.new("TextLabel", aboutTab)
aboutLine2.Size = UDim2.new(0.95, 0, 0, 20)
aboutLine2.Position = UDim2.new(0.025, 0, 0, 50)
aboutLine2.BackgroundTransparency = 1
aboutLine2.Text = "dm @7amonbridlepath on discord"
aboutLine2.TextColor3 = Theme.D
aboutLine2.TextSize = 12
aboutLine2.Font = Enum.Font.Gotham
aboutLine2.TextXAlignment = Enum.TextXAlignment.Left

local aboutLine3 = Instance.new("TextLabel", aboutTab)
aboutLine3.Size = UDim2.new(0.95, 0, 0, 20)
aboutLine3.Position = UDim2.new(0.025, 0, 0, 75)
aboutLine3.BackgroundTransparency = 1
aboutLine3.Text = ""
aboutLine3.TextColor3 = Theme.G
aboutLine3.TextSize = 12
aboutLine3.Font = Enum.Font.Gotham
aboutLine3.TextXAlignment = Enum.TextXAlignment.Left

-- ================= CONTROLS =================
local ctrl = Instance.new("Frame", sg)
ctrl.Size = UDim2.new(0, 70, 0, 30)
ctrl.BackgroundTransparency = 1
ctrl.Visible = false

local exitBtn = Instance.new("TextButton", ctrl)
exitBtn.Size = UDim2.new(0, 30, 0, 30)
exitBtn.Position = UDim2.new(0.5, 3, 0, 0)
exitBtn.BackgroundTransparency = 1
exitBtn.Text = "X"
exitBtn.TextColor3 = Theme.A
exitBtn.TextSize = 18
exitBtn.Font = Enum.Font.GothamBold
exitBtn.MouseButton1Click:Connect(function() sg:Destroy() end)

local dashBtn = Instance.new("TextButton", ctrl)
dashBtn.Size = UDim2.new(0, 30, 0, 30)
dashBtn.Position = UDim2.new(0, -3, 0, 0)
dashBtn.BackgroundTransparency = 1
dashBtn.Text = "-"
dashBtn.TextColor3 = Theme.A
dashBtn.TextSize = 26
dashBtn.Font = Enum.Font.GothamBold

dashBtn.MouseButton1Click:Connect(function()
    main.Visible = not main.Visible
    if main.Visible then
        ctrl.Parent = main
        ctrl.Position = UDim2.new(1, -75, 0, 4)
    else
        ctrl.Parent = sg
        ctrl.Position = UDim2.new(1, -110, 0, 15)
    end
end)

-- ================= INTRO ANIMATION =================
task.spawn(function()
    task.wait(2.2)
    TweenService:Create(introText, TweenInfo.new(0.8), {TextTransparency = 1}):Play()
    TweenService:Create(creditText, TweenInfo.new(0.8), {TextTransparency = 1}):Play()
    TweenService:Create(ideaText, TweenInfo.new(0.8), {TextTransparency = 1}):Play()
    local fade = TweenService:Create(introFrame, TweenInfo.new(0.8), {BackgroundTransparency = 1})
    fade:Play()
    fade.Completed:Wait()
    introFrame:Destroy()
    for _, v in pairs(container:GetChildren()) do
        if v:IsA("ScrollingFrame") then v.Visible = false end
    end
    injectTab.Visible = true
    injectBtn.TextColor3 = Theme.A
    ctrl.Parent = main
    ctrl.Position = UDim2.new(1, -75, 0, 4)
    ctrl.Visible = true
    main.Visible = true
    setFPSValue(120)
end)

print("crxshstrap loaded")
