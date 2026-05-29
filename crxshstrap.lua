local crxsh = {}
crxsh.VERSION = "1.0"
crxsh.PLACE_IDS = {2227430959, 7184600262, 82866880824588}
crxsh.DATABASE_URL = "https://raw.githubusercontent.com/souloveryall/DataBase.json/refs/heads/main/database.json"

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LP = Players.LocalPlayer

local function runACBypass()
    pcall(function()
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        
        local function findACScript()
            local ok, result = pcall(function()
                return LP:WaitForChild("PlayerScripts", 10)
                    :WaitForChild("PlayerScriptsLoader", 10)
                    :WaitForChild("PlayerModule", 10)
                    :WaitForChild("z", 10)
            end)
            return ok and result
        end
        
        local acScript = findACScript()
        if acScript then
            local cons = getconnections and getconnections(acScript.Changed)
            if cons then
                for _, con in ipairs(cons) do
                    local ok2, info = pcall(function()
                        return debug and debug.getinfo and debug.getinfo(con.Function, "S")
                    end)
                    if ok2 and info and info.source and string.find(info.source, "Anticheat") then
                        con:Disable()
                    end
                end
            end
        end
        
        local remotes = ReplicatedStorage:FindFirstChild("Remotes")
        if remotes then
            local acRemote = remotes:FindFirstChild("CharacterSoundEvent")
            if acRemote then
                local cons = getconnections and getconnections(acRemote.OnClientEvent)
                if cons then
                    for _, con in ipairs(cons) do
                        local ok2, info = pcall(function()
                            return debug and debug.getinfo and debug.getinfo(con.Function, "S")
                        end)
                        if ok2 and info and info.source and info.source:find("PlayerModule") then
                            con:Disable()
                        end
                    end
                end
                
                local mt = getrawmetatable and getrawmetatable(acRemote)
                if mt then
                    local oldNamecall = mt.__namecall
                    mt.__namecall = function(self, ...)
                        local method = getnamecallmethod and getnamecallmethod()
                        if method == "FireServer" and self == acRemote then
                            local args = {...}
                            if type(args[1]) == "userdata" and tostring(args[1]) and 
                               tostring(args[1]):find("\240\159\145") then
                                return
                            end
                            if type(args[1]) == "string" and #args[1] > 50000 then
                                return
                            end
                        end
                        return oldNamecall and oldNamecall(self, ...)
                    end
                end
            end
        end
        
        local oldKick = LP.Kick
        LP.Kick = function(self, msg)
            if msg and (msg:find("FastFlag") or msg:find("detection") or msg:find("Kick")) then
                return
            end
            return oldKick(self, msg)
        end
        
        local gravConn
        gravConn = workspace.ChildAdded:Connect(function(child)
            if child.Name == "GravityTest" and child:IsA("BasePart") then
                task.delay(0.3, function()
                    if child and child.Parent then child:Destroy() end
                end)
            end
        end)
        
        local function hookHumanoid(hum)
            local mt = getrawmetatable and getrawmetatable(hum)
            if not mt then
                mt = getmetatable(hum)
            end
            if not mt then return end
            
            if mt.__index then
                local oldIdx = mt.__index
                local oldNewIdx = mt.__newindex
                
                mt.__index = function(self, key)
                    local ok3, info = pcall(function()
                        return debug and debug.getinfo and debug.getinfo(2, "S")
                    end)
                    local isAC = ok3 and info and info.source and info.source:find("PlayerModule")
                    
                    if isAC then
                        if key == "WalkSpeed" then return 16 end
                        if key == "JumpPower" then return 50 end
                        if key == "HipHeight" then return 0 end
                        if key == "UseJumpPower" then return true end
                        if key == "deepSklaW" then return 16 end
                        if key == "rewoPpmuJ" then return 50 end
                        if key == "thgieHpih" then return 0 end
                    end
                    return oldIdx and oldIdx(self, key)
                end
                
                mt.__newindex = function(self, key, value)
                    local ok3, info = pcall(function()
                        return debug and debug.getinfo and debug.getinfo(2, "S")
                    end)
                    local isAC = ok3 and info and info.source and info.source:find("PlayerModule")
                    
                    if isAC then
                        if key == "WalkSpeed" or key == "deepSklaW" then return end
                        if key == "JumpPower" or key == "rewoPpmuJ" then return end
                        if key == "HipHeight" or key == "thgieHpih" then return end
                        if key == "UseJumpPower" then return end
                    end
                    return oldNewIdx and oldNewIdx(self, key, value)
                end
            end
        end
        
        local char = LP.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                hookHumanoid(hum)
            end
        end
        
        LP.CharacterAdded:Connect(function(c)
            task.wait(1)
            local hum = c:FindFirstChildOfClass("Humanoid")
            if hum then
                hookHumanoid(hum)
            end
        end)
    end)
end

runACBypass()

local VALID_PREFIXES = {
    "FFlag", "DFFlag", "FInt", "DFInt", "FString", "DFString",
    "FVec", "DFVec", "FLog", "DFLog"
}

local function validateFlagName(name)
    if type(name) ~= "string" or #name == 0 then return false end
    for _, prefix in ipairs(VALID_PREFIXES) do
        if name:sub(1, #prefix) == prefix then return true end
    end
    return false
end

local function validateFlagValue(val)
    if type(val) ~= "string" then return false end
    if val == "true" or val == "false" or val == "True" or val == "False" then return true end
    if tonumber(val) ~= nil then return true end
    return #val > 0 and #val < 1000
end

local function setFlag(name, value)
    if type(setfflag) == "function" then
        pcall(function() setfflag(name, tostring(value)) end)
    end
    
    if type(getgenv) == "function" then
        pcall(function()
            if name:sub(1,5) == "FFlag" or name:sub(1,6) == "DFFlag" then
                getgenv()[name] = (value == "true" or value == "True" or value == "1")
            elseif name:sub(1,4) == "FInt" or name:sub(1,5) == "DFInt" then
                getgenv()[name] = tonumber(value) or 0
            else
                getgenv()[name] = value
            end
        end)
    end
    
    pcall(function()
        if name:sub(1,5) == "FFlag" or name:sub(1,6) == "DFFlag" then
            _G[name] = (value == "true" or value == "True" or value == "1")
        elseif name:sub(1,4) == "FInt" or name:sub(1,5) == "DFInt" then
            _G[name] = tonumber(value) or 0
        else
            _G[name] = value
        end
    end)
end

local function injectFlags(flags)
    if type(flags) ~= "table" or next(flags) == nil then
        return false, "No flags to inject"
    end
    local injected = 0
    local failed = 0
    for name, value in pairs(flags) do
        if not validateFlagName(name) then
            failed = failed + 1
        elseif not validateFlagValue(value) then
            failed = failed + 1
        else
            setFlag(name, value)
            injected = injected + 1
        end
    end
    return true, "Injected " .. injected .. " flags (" .. failed .. " failed)"
end

local function setFPS(fps)
    local num = tonumber(fps) or 60
    if num < 1 then num = 1 end
    if num > 360 then num = 360 end
    local flags = {
        FIntTaskSchedulerTargetFps = tostring(num),
        DFIntTaskSchedulerTargetFps = tostring(num)
    }
    return injectFlags(flags)
end

function crxsh.fetchFlags()
    local success, result = pcall(function()
        return HttpService:JSONDecode(game:HttpGet(crxsh.DATABASE_URL))
    end)
    if not success then
        return nil, "Failed to fetch from database"
    end
    return result, nil
end

local Theme = {
    Background = Color3.fromRGB(0, 0, 0),
    Topbar = Color3.fromRGB(8, 8, 8),
    Accent = Color3.fromRGB(255, 255, 255),
    Text = Color3.fromRGB(255, 255, 255),
    TextDim = Color3.fromRGB(180, 180, 180),
    TabActive = Color3.fromRGB(20, 20, 20),
    TabInactive = Color3.fromRGB(5, 5, 5),
    Success = Color3.fromRGB(100, 255, 100),
    Error = Color3.fromRGB(255, 80, 80),
    Warning = Color3.fromRGB(255, 200, 50),
    InputBg = Color3.fromRGB(5, 5, 5),
    Border = Color3.fromRGB(40, 40, 40),
    FpsGood = Color3.fromRGB(100, 255, 100),
    FpsMedium = Color3.fromRGB(255, 200, 50),
    FpsBad = Color3.fromRGB(255, 80, 80),
}

local UI = {}
UI.Windows = {}
UI.FpsCounter = 0
UI.FrameTimes = {}

RunService.RenderStepped:Connect(function(dt)
    table.insert(UI.FrameTimes, dt)
    if #UI.FrameTimes > 60 then table.remove(UI.FrameTimes, 1) end
    local sum = 0
    for _, t in ipairs(UI.FrameTimes) do sum = sum + t end
    local avg = sum / #UI.FrameTimes
    if avg > 0 then
        UI.FpsCounter = math.floor(1 / avg)
    end
end)

function UI:CreateWindow(title)
    local screenSize = Vector2.new(UserInputService:GetMouseLocation().X * 2, UserInputService:GetMouseLocation().Y * 2)
    if screenSize.X == 0 then screenSize = Vector2.new(1920, 1080) end
    
    local w = {
        Title = title or "CRXSH STRAP",
        Elements = {},
        Tabs = {},
        ActiveTab = "HOME",
        Dragging = false,
        HotbarDragging = false,
        DragStart = Vector2.new(0, 0),
        WindowPos = Vector2.new((screenSize.X / 2) - 275, (screenSize.Y / 2) - 250),
        WindowSize = Vector2.new(550, 550),
        HotbarSize = Vector2.new(200, 40),
        Visible = true,
        Minimized = false,
        HotbarMode = false,
        ScreenSize = screenSize,
    }
    
    w.Main = Drawing.new("Square")
    w.Main.Size = w.WindowSize
    w.Main.Position = w.WindowPos
    w.Main.Color = Theme.Background
    w.Main.Filled = true
    w.Main.Thickness = 1
    w.Main.Visible = true
    w.Main.ZIndex = 1000
    
    w.Border = Drawing.new("Square")
    w.Border.Size = w.WindowSize
    w.Border.Position = w.WindowPos
    w.Border.Color = Theme.Border
    w.Border.Filled = false
    w.Border.Thickness = 1
    w.Border.Visible = true
    w.Border.ZIndex = 1001
    
    w.Topbar = Drawing.new("Square")
    w.Topbar.Size = Vector2.new(w.WindowSize.X, 35)
    w.Topbar.Position = w.WindowPos
    w.Topbar.Color = Theme.Topbar
    w.Topbar.Filled = true
    w.Topbar.Visible = true
    w.Topbar.ZIndex = 1002
    
    w.TitleText = Drawing.new("Text")
    w.TitleText.Text = "CRXSH STRAP"
    w.TitleText.Size = 14
    w.TitleText.Position = w.WindowPos + Vector2.new(10, 8)
    w.TitleText.Color = Theme.Accent
    w.TitleText.Center = false
    w.TitleText.Visible = true
    w.TitleText.ZIndex = 1003
    
    w.FpsText = Drawing.new("Text")
    w.FpsText.Text = "FPS: 60"
    w.FpsText.Size = 10
    w.FpsText.Position = w.WindowPos + Vector2.new(w.WindowSize.X - 90, 8)
    w.FpsText.Color = Theme.FpsGood
    w.FpsText.Visible = true
    w.FpsText.ZIndex = 1003
    
    w.CloseBtn = Drawing.new("Text")
    w.CloseBtn.Text = "X"
    w.CloseBtn.Size = 14
    w.CloseBtn.Position = w.WindowPos + Vector2.new(w.WindowSize.X - 20, 8)
    w.CloseBtn.Color = Theme.TextDim
    w.CloseBtn.Visible = true
    w.CloseBtn.ZIndex = 1003
    
    w.MinBtn = Drawing.new("Text")
    w.MinBtn.Text = "_"
    w.MinBtn.Size = 14
    w.MinBtn.Position = w.WindowPos + Vector2.new(w.WindowSize.X - 38, 6)
    w.MinBtn.Color = Theme.TextDim
    w.MinBtn.Visible = true
    w.MinBtn.ZIndex = 1003
    
    w.TabBar = Drawing.new("Square")
    w.TabBar.Size = Vector2.new(w.WindowSize.X - 2, 30)
    w.TabBar.Position = w.WindowPos + Vector2.new(1, 35)
    w.TabBar.Color = Theme.TabInactive
    w.TabBar.Filled = true
    w.TabBar.Visible = true
    w.TabBar.ZIndex = 1002
    
    w.Content = Drawing.new("Square")
    w.Content.Size = Vector2.new(w.WindowSize.X - 2, w.WindowSize.Y - 67)
    w.Content.Position = w.WindowPos + Vector2.new(1, 65)
    w.Content.Color = Theme.Background
    w.Content.Filled = true
    w.Content.Visible = true
    w.Content.ZIndex = 1002
    
    w.StatusBar = Drawing.new("Square")
    w.StatusBar.Size = Vector2.new(w.WindowSize.X - 2, 22)
    w.StatusBar.Position = w.WindowPos + Vector2.new(1, w.WindowSize.Y - 23)
    w.StatusBar.Color = Theme.Topbar
    w.StatusBar.Filled = true
    w.StatusBar.Visible = true
    w.StatusBar.ZIndex = 1002
    
    w.StatusText = Drawing.new("Text")
    w.StatusText.Text = "READY"
    w.StatusText.Size = 10
    w.StatusText.Position = w.WindowPos + Vector2.new(10, w.WindowSize.Y - 19)
    w.StatusText.Color = Theme.Success
    w.StatusText.Visible = true
    w.StatusText.ZIndex = 1003
    
    w.HotbarMain = Drawing.new("Square")
    w.HotbarMain.Size = w.HotbarSize
    w.HotbarMain.Position = w.WindowPos
    w.HotbarMain.Color = Theme.Topbar
    w.HotbarMain.Filled = true
    w.HotbarMain.Thickness = 1
    w.HotbarMain.Visible = false
    w.HotbarMain.ZIndex = 1000
    
    w.HotbarBorder = Drawing.new("Square")
    w.HotbarBorder.Size = w.HotbarSize
    w.HotbarBorder.Position = w.WindowPos
    w.HotbarBorder.Color = Theme.Border
    w.HotbarBorder.Filled = false
    w.HotbarBorder.Thickness = 1
    w.HotbarBorder.Visible = false
    w.HotbarBorder.ZIndex = 1001
    
    w.HotbarText = Drawing.new("Text")
    w.HotbarText.Text = "CRXSH STRAP"
    w.HotbarText.Size = 12
    w.HotbarText.Position = w.WindowPos + Vector2.new(8, 12)
    w.HotbarText.Color = Theme.Accent
    w.HotbarText.Visible = false
    w.HotbarText.ZIndex = 1003
    
    w.HotbarUnminimize = Drawing.new("Text")
    w.HotbarUnminimize.Text = "□"
    w.HotbarUnminimize.Size = 14
    w.HotbarUnminimize.Position = w.WindowPos + Vector2.new(w.HotbarSize.X - 38, 10)
    w.HotbarUnminimize.Color = Theme.TextDim
    w.HotbarUnminimize.Visible = false
    w.HotbarUnminimize.ZIndex = 1003
    
    w.HotbarClose = Drawing.new("Text")
    w.HotbarClose.Text = "X"
    w.HotbarClose.Size = 14
    w.HotbarClose.Position = w.WindowPos + Vector2.new(w.HotbarSize.X - 20, 10)
    w.HotbarClose.Color = Theme.TextDim
    w.HotbarClose.Visible = false
    w.HotbarClose.ZIndex = 1003
    
    RunService.RenderStepped:Connect(function()
        if w.Visible and not w.HotbarMode then
            local fps = UI.FpsCounter
            local fpsColor = fps >= 50 and Theme.FpsGood or (fps >= 30 and Theme.FpsMedium or Theme.FpsBad)
            w.FpsText.Text = "FPS: " .. fps
            w.FpsText.Color = fpsColor
            w.FpsText.Position = w.WindowPos + Vector2.new(w.WindowSize.X - 90, 8)
            w.CloseBtn.Position = w.WindowPos + Vector2.new(w.WindowSize.X - 20, 8)
            w.MinBtn.Position = w.WindowPos + Vector2.new(w.WindowSize.X - 38, 6)
        elseif w.Visible and w.HotbarMode then
            w.HotbarUnminimize.Position = w.WindowPos + Vector2.new(w.HotbarSize.X - 38, 10)
            w.HotbarClose.Position = w.WindowPos + Vector2.new(w.HotbarSize.X - 20, 10)
            w.HotbarText.Position = w.WindowPos + Vector2.new(8, 12)
        end
    end)
    
    RunService.RenderStepped:Connect(function()
        if w.Dragging and not w.Minimized and not w.HotbarMode then
            local mPos = UserInputService:GetMouseLocation()
            w.WindowPos = mPos - w.DragOffset
            w:UpdatePosition()
        elseif w.HotbarDragging and w.Minimized and w.HotbarMode then
            local mPos = UserInputService:GetMouseLocation()
            w.WindowPos = mPos - w.DragOffset
            w:UpdatePosition()
        end
    end)
    
    UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            local mPos = UserInputService:GetMouseLocation()
            local relPos = mPos - w.WindowPos
            
            if w.Visible and not w.HotbarMode then
                if relPos.X > w.WindowSize.X - 25 and relPos.X < w.WindowSize.X - 10 and relPos.Y > 5 and relPos.Y < 25 then
                    w.Visible = false
                    w:SetVisible(false)
                    return
                end
                
                if relPos.X > w.WindowSize.X - 45 and relPos.X < w.WindowSize.X - 28 and relPos.Y > 5 and relPos.Y < 25 then
                    w.Minimized = true
                    w.HotbarMode = true
                    w:SetMinimized(true)
                    return
                end
                
                if relPos.Y > 0 and relPos.Y < 35 then
                    w.Dragging = true
                    w.DragOffset = mPos - w.WindowPos
                    return
                end
                
                if relPos.Y > 35 and relPos.Y < 65 and not w.Minimized then
                    if relPos.X > 5 and relPos.X < 60 then
                        w:SetActiveTab("HOME")
                        return
                    elseif relPos.X > 65 and relPos.X < 120 then
                        w:SetActiveTab("FLAGS")
                        return
                    elseif relPos.X > 125 and relPos.X < 185 then
                        w:SetActiveTab("ABOUT")
                        return
                    end
                end
            elseif w.Visible and w.HotbarMode then
                if relPos.Y > 0 and relPos.Y < 40 then
                    w.HotbarDragging = true
                    w.DragOffset = mPos - w.WindowPos
                    return
                end
                
                if relPos.X > w.HotbarSize.X - 25 and relPos.X < w.HotbarSize.X - 10 and relPos.Y > 5 and relPos.Y < 35 then
                    w.Visible = false
                    w:SetVisible(false)
                    return
                end
                
                if relPos.X > w.HotbarSize.X - 48 and relPos.X < w.HotbarSize.X - 28 and relPos.Y > 5 and relPos.Y < 35 then
                    w.Minimized = false
                    w.HotbarMode = false
                    w:SetMinimized(false)
                    return
                end
            end
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            w.Dragging = false
            w.HotbarDragging = false
        end
    end)
    
    function w:SetVisible(vis)
        self.Visible = vis
        if not self.HotbarMode then
            self.Main.Visible = vis
            self.Border.Visible = vis
            self.Topbar.Visible = vis
            self.TitleText.Visible = vis
            self.FpsText.Visible = vis
            self.CloseBtn.Visible = vis
            self.MinBtn.Visible = vis
            self.TabBar.Visible = vis
            self.Content.Visible = vis
            self.StatusBar.Visible = vis
            self.StatusText.Visible = vis
            self.HotbarMain.Visible = false
            self.HotbarBorder.Visible = false
            self.HotbarText.Visible = false
            self.HotbarUnminimize.Visible = false
            self.HotbarClose.Visible = false
        else
            self.Main.Visible = false
            self.Border.Visible = false
            self.Topbar.Visible = false
            self.TitleText.Visible = false
            self.FpsText.Visible = false
            self.CloseBtn.Visible = false
            self.MinBtn.Visible = false
            self.TabBar.Visible = false
            self.Content.Visible = false
            self.StatusBar.Visible = false
            self.StatusText.Visible = false
            self.HotbarMain.Visible = vis
            self.HotbarBorder.Visible = vis
            self.HotbarText.Visible = vis
            self.HotbarUnminimize.Visible = vis
            self.HotbarClose.Visible = vis
        end
        for _, tab in ipairs(self.Tabs) do
            tab:SetVisible(vis and not self.HotbarMode and tab.Name == self.ActiveTab)
        end
    end
    
    function w:SetMinimized(min)
        self.Minimized = min
        self.HotbarMode = min
        if min then
            self:SetVisible(true)
        else
            self:SetVisible(true)
        end
        self:UpdatePosition()
    end
    
    function w:SetStatus(text, color)
        if not self.HotbarMode then
            self.StatusText.Text = text
            self.StatusText.Color = color or Theme.Success
            task.delay(2, function()
                if self.StatusText and not self.HotbarMode then
                    self.StatusText.Text = "READY"
                    self.StatusText.Color = Theme.Success
                end
            end)
        end
    end
    
    function w:UpdatePosition()
        if self.Minimized and self.HotbarMode then
            self.HotbarMain.Position = self.WindowPos
            self.HotbarMain.Size = self.HotbarSize
            self.HotbarBorder.Position = self.WindowPos
            self.HotbarBorder.Size = self.HotbarSize
            self.HotbarText.Position = self.WindowPos + Vector2.new(8, 12)
            self.HotbarUnminimize.Position = self.WindowPos + Vector2.new(self.HotbarSize.X - 38, 10)
            self.HotbarClose.Position = self.WindowPos + Vector2.new(self.HotbarSize.X - 20, 10)
        else
            self.Main.Position = self.WindowPos
            self.Main.Size = self.WindowSize
            self.Border.Position = self.WindowPos
            self.Border.Size = self.WindowSize
            self.Topbar.Position = self.WindowPos
            self.TitleText.Position = self.WindowPos + Vector2.new(10, 8)
            self.FpsText.Position = self.WindowPos + Vector2.new(self.WindowSize.X - 90, 8)
            self.CloseBtn.Position = self.WindowPos + Vector2.new(self.WindowSize.X - 20, 8)
            self.MinBtn.Position = self.WindowPos + Vector2.new(self.WindowSize.X - 38, 6)
            self.TabBar.Position = self.WindowPos + Vector2.new(1, 35)
            self.Content.Position = self.WindowPos + Vector2.new(1, 65)
            self.Content.Size = Vector2.new(self.WindowSize.X - 2, self.WindowSize.Y - 67)
            self.StatusBar.Position = self.WindowPos + Vector2.new(1, self.WindowSize.Y - 23)
            self.StatusText.Position = self.WindowPos + Vector2.new(10, self.WindowSize.Y - 19)
            
            local tabPositions = {{name="HOME", x=5, w=55}, {name="FLAGS", x=65, w=55}, {name="ABOUT", x=125, w=60}}
            
            for i, tab in ipairs(self.Tabs) do
                local isActive = tab.Name == self.ActiveTab
                tab.Button.Position = self.WindowPos + Vector2.new(tabPositions[i].x, 38)
                tab.Button.Size = Vector2.new(tabPositions[i].w, 26)
                tab.Button.Color = isActive and Theme.TabActive or Theme.TabInactive
                tab.Text.Position = self.WindowPos + Vector2.new(tabPositions[i].x + 8, 43)
                tab.Text.Color = isActive and Theme.Accent or Theme.TextDim
                tab:UpdatePosition(self.WindowPos, self.WindowSize)
            end
        end
    end
    
    function w:AddTab(name)
        local tab = {
            Name = name,
            Window = w,
            Elements = {},
            YOffset = 0,
            ScrollOffset = 0,
            MaxScroll = 0,
        }
        
        tab.Button = Drawing.new("Square")
        tab.Button.Color = Theme.TabInactive
        tab.Button.Filled = true
        tab.Button.Visible = true
        tab.Button.ZIndex = 1003
        
        tab.Text = Drawing.new("Text")
        tab.Text.Text = name
        tab.Text.Size = 11
        tab.Text.Color = Theme.TextDim
        tab.Text.Visible = true
        tab.Text.ZIndex = 1004
        
        tab.Container = Drawing.new("Square")
        tab.Container.Size = Vector2.new(w.WindowSize.X - 4, w.WindowSize.Y - 70)
        tab.Container.Color = Theme.Background
        tab.Container.Filled = true
        tab.Container.Visible = false
        tab.Container.ZIndex = 1003
        
        UserInputService.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseWheel then
                if w.Visible and tab.Name == w.ActiveTab and not w.Minimized then
                    local mPos = UserInputService:GetMouseLocation()
                    local relPos = mPos - w.WindowPos
                    if relPos.X > 1 and relPos.X < w.WindowSize.X - 1 and relPos.Y > 65 and relPos.Y < w.WindowSize.Y - 23 then
                        tab.ScrollOffset = math.clamp(tab.ScrollOffset - (input.Position.Z * 20), 0, math.max(0, tab.MaxScroll))
                        tab:UpdatePosition(w.WindowPos, w.WindowSize)
                    end
                end
            end
        end)
        
        table.insert(w.Tabs, tab)
        if #w.Tabs == 1 then
            w.ActiveTab = name
            tab.Container.Visible = true
            tab.Text.Color = Theme.Accent
            tab.Button.Color = Theme.TabActive
        end
        
        function tab:SetVisible(vis)
            self.Container.Visible = vis and not w.Minimized
            self.Button.Visible = vis
            self.Text.Visible = vis
            for _, el in ipairs(self.Elements) do
                if el.SetVisible then
                    el:SetVisible(vis and not w.Minimized and self.Name == w.ActiveTab)
                end
            end
        end
        
        function tab:UpdatePosition(winPos, winSize)
            local startY = 70 - self.ScrollOffset
            self.Container.Position = winPos + Vector2.new(2, 68)
            local visibleH = winSize.Y - 90
            
            for _, el in ipairs(self.Elements) do
                if el.UpdatePosition then
                    el:UpdatePosition(winPos + Vector2.new(8, startY + el.YOffset))
                end
            end
            
            local lastEl = self.Elements[#self.Elements]
            if lastEl and lastEl.GetHeight then
                self.MaxScroll = math.max(0, (lastEl.YOffset + lastEl:GetHeight() + 10) - visibleH)
            end
        end
        
        function tab:AddLabel(text, color)
            local el = {Type="Label", Text=text, Color=color or Theme.Text, YOffset=self.YOffset}
            el.Obj = Drawing.new("Text")
            el.Obj.Text = text
            el.Obj.Size = 12
            el.Obj.Color = el.Color
            el.Obj.Visible = false
            el.Obj.ZIndex = 1005
            function el:SetVisible(v) self.Obj.Visible = v end
            function el:UpdatePosition(p) self.Obj.Position = p end
            function el:GetHeight() return 16 end
            table.insert(self.Elements, el)
            self.YOffset = self.YOffset + 20
            return el
        end
        
        function tab:AddSmallLabel(text, color)
            local el = {Type="SmallLabel", Text=text, Color=color or Theme.TextDim, YOffset=self.YOffset}
            el.Obj = Drawing.new("Text")
            el.Obj.Text = text
            el.Obj.Size = 10
            el.Obj.Color = el.Color
            el.Obj.Visible = false
            el.Obj.ZIndex = 1005
            function el:SetVisible(v) self.Obj.Visible = v end
            function el:UpdatePosition(p) self.Obj.Position = p end
            function el:GetHeight() return 14 end
            table.insert(self.Elements, el)
            self.YOffset = self.YOffset + 16
            return el
        end
        
        function tab:AddDivider()
            local el = {Type="Divider", YOffset=self.YOffset}
            el.Line = Drawing.new("Line")
            el.Line.From = Vector2.new(0, 0)
            el.Line.To = Vector2.new(520, 0)
            el.Line.Color = Theme.Border
            el.Line.Thickness = 1
            el.Line.Visible = false
            el.Line.ZIndex = 1004
            function el:SetVisible(v) self.Line.Visible = v end
            function el:UpdatePosition(p)
                self.Line.From = p + Vector2.new(0, 5)
                self.Line.To = p + Vector2.new(520, 5)
            end
            function el:GetHeight() return 12 end
            table.insert(self.Elements, el)
            self.YOffset = self.YOffset + 14
            return el
        end
        
        function tab:AddButton(text, callback)
            local el = {Type="Button", Text=text, Callback=callback, YOffset=self.YOffset}
            
            el.Bg = Drawing.new("Square")
            el.Bg.Size = Vector2.new(180, 30)
            el.Bg.Color = Theme.Topbar
            el.Bg.Filled = true
            el.Bg.Visible = false
            el.Bg.ZIndex = 1004
            
            el.Border = Drawing.new("Square")
            el.Border.Size = Vector2.new(180, 30)
            el.Border.Color = Theme.Border
            el.Border.Filled = false
            el.Border.Thickness = 1
            el.Border.Visible = false
            el.Border.ZIndex = 1005
            
            el.Obj = Drawing.new("Text")
            el.Obj.Text = text
            el.Obj.Size = 11
            el.Obj.Color = Theme.Text
            el.Obj.Visible = false
            el.Obj.ZIndex = 1006
            
            UserInputService.InputBegan:Connect(function(input)
                if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and el.Obj.Visible then
                    local mPos = UserInputService:GetMouseLocation()
                    local relPos = mPos - el.Bg.Position
                    if relPos.X > 0 and relPos.X < 180 and relPos.Y > 0 and relPos.Y < 30 then
                        local ok, err = pcall(el.Callback)
                        if not ok then warn("[CRXSH] " .. tostring(err)) end
                    end
                end
            end)
            
            function el:SetVisible(v)
                self.Bg.Visible = v
                self.Border.Visible = v
                self.Obj.Visible = v
            end
            function el:UpdatePosition(p)
                self.Bg.Position = p
                self.Border.Position = p
                self.Obj.Position = p + Vector2.new(10, 7)
            end
            function el:GetHeight() return 32 end
            table.insert(self.Elements, el)
            self.YOffset = self.YOffset + 34
            return el
        end
        
        function tab:AddTextBox(placeholder, callback)
            local el = {
                Type = "TextBox",
                Text = "",
                Placeholder = placeholder,
                Callback = callback,
                YOffset = self.YOffset,
                Focused = false
            }

            el.Bg = Drawing.new("Square")
            el.Bg.Size = Vector2.new(520, 32)
            el.Bg.Color = Theme.InputBg
            el.Bg.Filled = true
            el.Bg.Visible = false
            el.Bg.ZIndex = 1004

            el.Border = Drawing.new("Square")
            el.Border.Size = Vector2.new(520, 32)
            el.Border.Color = Theme.Border
            el.Border.Filled = false
            el.Border.Thickness = 1
            el.Border.Visible = false
            el.Border.ZIndex = 1005

            el.Obj = Drawing.new("Text")
            el.Obj.Text = placeholder
            el.Obj.Size = 11
            el.Obj.Color = Theme.TextDim
            el.Obj.Visible = false
            el.Obj.ZIndex = 1006

            local realBox = Instance.new("TextBox")
            realBox.Size = UDim2.new(0, 520, 0, 32)
            realBox.BackgroundTransparency = 1
            realBox.TextColor3 = Color3.new(1,1,1)
            realBox.TextSize = 12
            realBox.Visible = false
            realBox.ClearTextOnFocus = false
            realBox.MultiLine = false
            realBox.Parent = CoreGui

            UserInputService.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    local mPos = UserInputService:GetMouseLocation()
                    local relPos = mPos - el.Bg.Position

                    if relPos.X > 0 and relPos.X < 520 and relPos.Y > 0 and relPos.Y < 32 then
                        el.Focused = true
                        el.Border.Color = Theme.Accent

                        realBox.Position = UDim2.new(0, el.Bg.Position.X, 0, el.Bg.Position.Y)
                        realBox.Text = el.Text
                        realBox.Visible = true
                        realBox:CaptureFocus()
                    else
                        if el.Focused then
                            el.Focused = false
                            el.Border.Color = Theme.Border

                            el.Text = realBox.Text
                            if #el.Text > 70 then
                                el.Obj.Text = el.Text:sub(1, 70) .. "..."
                            else
                                el.Obj.Text = el.Text
                            end
                            realBox.Visible = false
                            realBox:ReleaseFocus()

                            pcall(el.Callback, el.Text)
                        end
                    end
                end
            end)

            realBox.FocusLost:Connect(function()
                if el.Focused then
                    el.Focused = false
                    el.Border.Color = Theme.Border

                    el.Text = realBox.Text
                    if #el.Text > 70 then
                        el.Obj.Text = el.Text:sub(1, 70) .. "..."
                    else
                        el.Obj.Text = el.Text
                    end
                    realBox.Visible = false

                    pcall(el.Callback, el.Text)
                end
            end)

            function el:SetVisible(v)
                self.Bg.Visible = v
                self.Border.Visible = v
                self.Obj.Visible = v
            end

            function el:UpdatePosition(p)
                el.Bg.Position = p
                el.Border.Position = p
                el.Obj.Position = p + Vector2.new(10, 8)
            end

            function el:GetHeight()
                return 34
            end

            table.insert(self.Elements, el)
            self.YOffset = self.YOffset + 36
            return el
        end
        
        function tab:AddLargeTextBox(placeholder, callback)
            local el = {
                Type = "LargeTextBox",
                Text = "",
                Placeholder = placeholder,
                Callback = callback,
                YOffset = self.YOffset,
                Focused = false
            }

            el.Bg = Drawing.new("Square")
            el.Bg.Size = Vector2.new(520, 120)
            el.Bg.Color = Theme.InputBg
            el.Bg.Filled = true
            el.Bg.Visible = false
            el.Bg.ZIndex = 1004

            el.Border = Drawing.new("Square")
            el.Border.Size = Vector2.new(520, 120)
            el.Border.Color = Theme.Border
            el.Border.Filled = false
            el.Border.Thickness = 1
            el.Border.Visible = false
            el.Border.ZIndex = 1005

            el.Obj = Drawing.new("Text")
            el.Obj.Text = placeholder
            el.Obj.Size = 10
            el.Obj.Color = Theme.TextDim
            el.Obj.Visible = false
            el.Obj.ZIndex = 1006

            local realBox = Instance.new("TextBox")
            realBox.Size = UDim2.new(0, 520, 0, 120)
            realBox.BackgroundTransparency = 1
            realBox.TextColor3 = Color3.new(1,1,1)
            realBox.TextSize = 11
            realBox.Visible = false
            realBox.ClearTextOnFocus = false
            realBox.MultiLine = true
            realBox.TextWrapped = true
            realBox.Parent = CoreGui

            UserInputService.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    local mPos = UserInputService:GetMouseLocation()
                    local relPos = mPos - el.Bg.Position
                    if relPos.X > 0 and relPos.X < 520 and relPos.Y > 0 and relPos.Y < 120 then
                        el.Focused = true
                        el.Border.Color = Theme.Accent
                        realBox.Position = UDim2.new(0, el.Bg.Position.X, 0, el.Bg.Position.Y)
                        realBox.Text = el.Text
                        realBox.Visible = true
                        realBox:CaptureFocus()
                    else
                        if el.Focused then
                            el.Focused = false
                            el.Border.Color = Theme.Border
                            el.Text = realBox.Text
                            local display = el.Text
                            if #display > 200 then
                                display = display:sub(1, 200) .. "..."
                            end
                            if display == "" then
                                el.Obj.Text = el.Placeholder
                                el.Obj.Color = Theme.TextDim
                            else
                                el.Obj.Text = display
                                el.Obj.Color = Theme.Text
                            end
                            realBox.Visible = false
                            realBox:ReleaseFocus()
                            pcall(el.Callback, el.Text)
                        end
                    end
                end
            end)

            realBox.FocusLost:Connect(function()
                if el.Focused then
                    el.Focused = false
                    el.Border.Color = Theme.Border
                    el.Text = realBox.Text
                    local display = el.Text
                    if #display > 200 then
                        display = display:sub(1, 200) .. "..."
                    end
                    if display == "" then
                        el.Obj.Text = el.Placeholder
                        el.Obj.Color = Theme.TextDim
                    else
                        el.Obj.Text = display
                        el.Obj.Color = Theme.Text
                    end
                    realBox.Visible = false
                    pcall(el.Callback, el.Text)
                end
            end)

            function el:SetVisible(v)
                self.Bg.Visible = v
                self.Border.Visible = v
                self.Obj.Visible = v
            end

            function el:UpdatePosition(p)
                self.Bg.Position = p
                self.Border.Position = p
                self.Obj.Position = p + Vector2.new(10, 8)
            end

            function el:GetHeight()
                return 122
            end

            table.insert(self.Elements, el)
            self.YOffset = self.YOffset + 124
            return el
        end
        
        function tab:AddStatusBox()
            local el = {Type="StatusBox", YOffset=self.YOffset}
            
            el.Bg = Drawing.new("Square")
            el.Bg.Size = Vector2.new(520, 35)
            el.Bg.Color = Color3.fromRGB(5, 5, 5)
            el.Bg.Filled = true
            el.Bg.Visible = false
            el.Bg.ZIndex = 1004
            
            el.Border = Drawing.new("Square")
            el.Border.Size = Vector2.new(520, 35)
            el.Border.Color = Theme.Border
            el.Border.Filled = false
            el.Border.Thickness = 1
            el.Border.Visible = false
            el.Border.ZIndex = 1005
            
            el.Obj = Drawing.new("Text")
            el.Obj.Text = "Ready"
            el.Obj.Size = 10
            el.Obj.Color = Theme.Success
            el.Obj.Visible = false
            el.Obj.ZIndex = 1006
            
            function el:SetVisible(v)
                self.Bg.Visible = v
                self.Border.Visible = v
                self.Obj.Visible = v
            end
            function el:UpdatePosition(p)
                self.Bg.Position = p
                self.Border.Position = p
                self.Obj.Position = p + Vector2.new(10, 10)
            end
            function el:GetHeight() return 37 end
            function el:SetText(text, color)
                self.Obj.Text = text
                self.Obj.Color = color or Theme.Success
            end
            function el:Append(text, color)
                local current = self.Obj.Text
                if #current + #text > 150 then
                    self.Obj.Text = text
                else
                    self.Obj.Text = current .. " | " .. text
                end
                if color then self.Obj.Color = color end
            end
            
            table.insert(self.Elements, el)
            self.YOffset = self.YOffset + 39
            return el
        end
        
        w:UpdatePosition()
        return tab
    end
    
    function w:SetActiveTab(name)
        self.ActiveTab = name
        for _, tab in ipairs(self.Tabs) do
            local isActive = tab.Name == name
            tab.Container.Visible = isActive and not self.Minimized
            tab.Text.Color = isActive and Theme.Accent or Theme.TextDim
            tab.Button.Color = isActive and Theme.TabActive or Theme.TabInactive
            for _, el in ipairs(tab.Elements) do
                if el.SetVisible then
                    el:SetVisible(isActive and not self.Minimized)
                end
            end
        end
        self:UpdatePosition()
    end
    
    table.insert(UI.Windows, w)
    w:UpdatePosition()
    return w
end

local win = UI:CreateWindow("CRXSH STRAP")

local homeTab = win:AddTab("HOME")
homeTab:AddLabel("CRXSH STRAP", Theme.Accent)
homeTab:AddSmallLabel("fflag injector")
homeTab:AddDivider()

local statusBox = homeTab:AddStatusBox()
statusBox:SetText("ready", Theme.Success)

homeTab:AddDivider()
homeTab:AddLabel("FPS Changer (1-360 FPS)", Theme.Accent)

local fpsInput = homeTab:AddTextBox("Enter FPS (1-360)", function(text)
    local fps = tonumber(text)
    if fps and fps >= 1 and fps <= 360 then
        local success, msg = setFPS(fps)
        if success then
            statusBox:SetText("FPS set to " .. fps, Theme.Success)
            win:SetStatus("FPS set to " .. fps, Theme.Success)
        else
            statusBox:SetText("Failed to set FPS", Theme.Error)
        end
    else
        statusBox:SetText("Invalid FPS (1-360)", Theme.Error)
    end
end)

homeTab:AddButton("23 FPS", function()
    setFPS(23)
    statusBox:SetText("FPS set to 23", Theme.Success)
    win:SetStatus("FPS set to 23", Theme.Success)
end)

homeTab:AddButton("27 FPS", function()
    setFPS(27)
    statusBox:SetText("FPS set to 27", Theme.Success)
    win:SetStatus("FPS set to 27", Theme.Success)
end)

homeTab:AddButton("35 FPS", function()
    setFPS(35)
    statusBox:SetText("FPS set to 35", Theme.Success)
    win:SetStatus("FPS set to 35", Theme.Success)
end)

homeTab:AddButton("60 FPS", function()
    setFPS(60)
    statusBox:SetText("FPS set to 60", Theme.Success)
    win:SetStatus("FPS set to 60", Theme.Success)
end)

homeTab:AddButton("120 FPS", function()
    setFPS(120)
    statusBox:SetText("FPS set to 120", Theme.Success)
    win:SetStatus("FPS set to 120", Theme.Success)
end)

homeTab:AddButton("240 FPS", function()
    setFPS(240)
    statusBox:SetText("FPS set to 240", Theme.Success)
    win:SetStatus("FPS set to 240", Theme.Success)
end)

homeTab:AddDivider()

homeTab:AddButton("inject all", function()
    statusBox:SetText("fetching...", Theme.Warning)
    win:SetStatus("fetching...", Theme.Warning)
    
    local flags, err = crxsh.fetchFlags()
    if not flags then
        statusBox:SetText("fetch failed", Theme.Error)
        win:SetStatus("fetch failed", Theme.Error)
        return
    end
    
    local valid = {}
    local invalid = {}
    for k, v in pairs(flags) do
        if validateFlagName(k) and validateFlagValue(v) then
            valid[k] = v
        else
            table.insert(invalid, k)
        end
    end
    
    if #invalid > 0 then
        statusBox:Append(#invalid .. " invalid", Theme.Warning)
    end
    
    if next(valid) == nil then
        statusBox:SetText("no valid flags", Theme.Error)
        return
    end
    
    local final = {}
    for k, v in pairs(valid) do final[k] = v end
    
    local FF3_OVERRIDES = {
        ["DFIntMaxAltitudePDStickHipHeightPercent"] = "-200",
        ["DFIntHipHeightClamp"] = "-48",
        ["FIntJumpHeightMultiplier"] = "100",
        ["FFlagForceRegularJumpHeight"] = "True",
        ["FFlagStompLagCorrection"] = "True",
        ["FFlagJumpHeightOverride"] = "False",
        ["FFlagDebugDisableFFlagOverride"] = "True",
        ["FFlagDebugDisableRemoteFFlagFetch"] = "True",
        ["FFlagDebugForceLocalSettings"] = "True",
        ["FFlagDebugPersistClientSettings"] = "True",
        ["DFIntTaskSchedulerTargetFps"] = "30",
        ["FFlagPreferLowLatencyRendering"] = "True",
        ["FFlagSmoothJoin"] = "True",
    }
    for k, v in pairs(FF3_OVERRIDES) do final[k] = v end
    
    local success, msg = injectFlags(final)
    if success then
        local count = 0
        for _ in pairs(final) do count = count + 1 end
        statusBox:SetText("injected " .. count .. " flags", Theme.Success)
        win:SetStatus("injected", Theme.Success)
    else
        statusBox:SetText("failed", Theme.Error)
        win:SetStatus("failed", Theme.Error)
    end
end)

homeTab:AddButton("inject database", function()
    statusBox:SetText("fetching...", Theme.Warning)
    local flags, err = crxsh.fetchFlags()
    if not flags then
        statusBox:SetText("fetch failed", Theme.Error)
        return
    end
    local valid = {}
    for k, v in pairs(flags) do
        if validateFlagName(k) and validateFlagValue(v) then
            valid[k] = v
        end
    end
    if next(valid) == nil then
        statusBox:SetText("no valid flags", Theme.Error)
        return
    end
    local success, msg = injectFlags(valid)
    if success then
        local count = 0; for _ in pairs(valid) do count = count + 1 end
        statusBox:SetText("injected " .. count .. " flags", Theme.Success)
    else
        statusBox:SetText("failed", Theme.Error)
    end
end)

homeTab:AddButton("test db", function()
    statusBox:SetText("testing...", Theme.Warning)
    local flags, err = crxsh.fetchFlags()
    if flags then
        local count = 0; for _ in pairs(flags) do count = count + 1 end
        statusBox:SetText("ok - " .. count .. " flags", Theme.Success)
    else
        statusBox:SetText("failed", Theme.Error)
    end
end)

local flagsTab = win:AddTab("FLAGS")

flagsTab:AddLabel("paste flags", Theme.Accent)
flagsTab:AddSmallLabel("format: FlagName Value")
flagsTab:AddSmallLabel("example: FFlagSmoothJoin True")
flagsTab:AddDivider()

local flagInput = flagsTab:AddTextBox("Paste FFlags here", function(text)
    local parsed = {}
    for line in text:gmatch("[^\r\n]+") do
        local name, value = line:match("^(%S+)%s+(.+)$")
        if name and value then
            parsed[name] = value
        end
    end
    local ok, msg = injectFlags(parsed)
    statusBox:SetText(msg, ok and Theme.Success or Theme.Error)
    win:SetStatus(msg, ok and Theme.Success or Theme.Error)
end)

local jsonInput = flagsTab:AddLargeTextBox('{"FFlagExample":"True"}', function(text)
    if #text < 5 then
        statusBox:SetText("json too short", Theme.Error)
        return
    end
    
    local success, parsed = pcall(HttpService.JSONDecode, HttpService, text)
    if not success then
        statusBox:SetText("invalid json", Theme.Error)
        win:SetStatus("invalid json", Theme.Error)
        return
    end
    
    local valid = {}
    local invalid = {}
    for k, v in pairs(parsed) do
        if validateFlagName(k) and validateFlagValue(v) then
            valid[k] = v
        else
            table.insert(invalid, k)
        end
    end
    
    if #invalid > 0 then
        statusBox:SetText("invalid flags (" .. #invalid .. ")", Theme.Error)
        win:SetStatus(#invalid .. " invalid", Theme.Error)
    end
    
    local count = 0; for _ in pairs(valid) do count = count + 1 end
    if count > 0 then
        local s2, m2 = injectFlags(valid)
        if s2 then
            statusBox:SetText("injected " .. count .. " flags", Theme.Success)
        else
            statusBox:SetText("failed", Theme.Error)
        end
    end
end)

flagsTab:AddSmallLabel("ctrl+enter to inject", Theme.TextDim)
flagsTab:AddButton("inject json", function()
    if #jsonInput.Text < 5 then statusBox:SetText("no json", Theme.Error) return end
    
    local success, parsed = pcall(HttpService.JSONDecode, HttpService, jsonInput.Text)
    if not success then statusBox:SetText("invalid json", Theme.Error) return end
    
    local valid = {}
    local invalid = {}
    for k, v in pairs(parsed) do
        if validateFlagName(k) and validateFlagValue(v) then
            valid[k] = v
        else
            table.insert(invalid, k)
        end
    end
    
    if #invalid > 0 then
        statusBox:SetText("invalid: " .. #invalid, Theme.Error)
    end
    
    local count = 0; for _ in pairs(valid) do count = count + 1 end
    if count > 0 then
        local s, m = injectFlags(valid)
        if s then
            statusBox:SetText("injected " .. count .. " flags", Theme.Success)
        else
            statusBox:SetText("failed", Theme.Error)
        end
    else
        statusBox:SetText("no valid flags", Theme.Error)
    end
end)

local aboutTab = win:AddTab("ABOUT")
aboutTab:AddLabel("CRXSH STRAP", Theme.Accent)
aboutTab:AddSmallLabel("fflag injector")
aboutTab:AddSmallLabel("dm @7amonbridlepath for any errors")

win:UpdatePosition()

return true