-- Script game.ServerScriptService.PetExpeditionServer
local Players = game:GetService('Players')
local RunService = game:GetService('RunService')
local TweenService = game:GetService('TweenService')
local world = workspace:WaitForChild('PetExpeditionDemo')
local states = {}
local function message(player, text)
 local gui = player.PlayerGui:FindFirstChild('ExpeditionHUD')
 if gui then gui.Panel.Objective.Text = text end
end
local function update(player)
 local s = states[player]; if not s then return end
 player:SetAttribute('DemoEgg',s.egg)
 player:SetAttribute('DemoComplete',s.complete)
 player:SetAttribute('DemoMole',s.mole)
 player:SetAttribute('DemoEvolved',s.evolved)
 for i=1,3 do player:SetAttribute('DemoBug'..i,s.collected['Bug'..i] == true) end
 local gui = player.PlayerGui:FindFirstChild('ExpeditionHUD')
 if gui then gui.Panel.Stats.Text = ('Food: %d  •  Frog: %s  •  Mole: %s'):format(s.food,s.evolved and 'EVOLVED' or 'Baby',s.mole and 'Hatched' or 'Not hatched') end
end
local function creature(player, kind)
 local s = states[player]
 if s.pet then s.pet:Destroy() end
 local m = Instance.new('Model'); m.Name = player.Name..'_'..kind
 local function piece(size,offset,color)
  local p=Instance.new('Part'); p.Size=size; p.CFrame=CFrame.new(offset); p.Color=color; p.Anchored=true; p.CanCollide=false; p.CanTouch=false; p.CanQuery=false; p.Parent=m; return p
 end
 local frog = kind == 'Frog'
 local color = frog and Color3.fromRGB(93,195,98) or Color3.fromRGB(129,91,68)
 local scale = s.evolved and frog and 1.5 or 1
 local body=piece(Vector3.new(2.4,1.6,2)*scale,Vector3.zero,color); m.PrimaryPart=body
 for _,x in ipairs({-.8,.8}) do
  piece(Vector3.new(.7,.7,.7)*scale,Vector3.new(x,1,-.7)*scale,Color3.fromRGB(233,243,212))
  piece(Vector3.new(.3,.35,.15)*scale,Vector3.new(x,1,-1.1)*scale,Color3.fromRGB(22,33,28))
  piece(Vector3.new(.8,.4,1.3)*scale,Vector3.new(x,-.6,.2)*scale,color)
 end
 if not frog then piece(Vector3.new(1,.5,.6),Vector3.new(0,.1,-1.25),Color3.fromRGB(240,160,170)) end
 if frog and s.evolved then
  piece(Vector3.new(2.7,.5,1),Vector3.new(0,1.5,.4),Color3.fromRGB(252,205,87))
  piece(Vector3.new(.5,1,.5),Vector3.new(0,2,.4),Color3.fromRGB(252,205,87))
 end
 m.Parent=world; s.pet=m
end
local function objective(player)
 local s=states[player]
 if s.complete then return 'Expedition complete! Your pets unlocked an island and a buried cache. Collect more food or restart Play to try again.' end
 if s.mole then return 'Your mole is ready! Visit the buried food cache near Bug 3 and use Dig cache.' end
 if s.egg then return 'Egg secured! Use the island return pad, then Feed / Hatch at camp.' end
 if s.evolved then return 'Frog evolved! Use the purple island leap pad to reach the mole egg.' end
 return 'Explore the meadow: collect 3 different bugs, then return to camp and feed your frog.'
end
local function setup(player)
 states[player]={food=0, collected={}, evolved=false, egg=false, mole=false, complete=false, busy=false}
 player.RespawnLocation=world.CampSpawn
 local gui=Instance.new('ScreenGui'); gui.Name='ExpeditionHUD'; gui.ResetOnSpawn=false; gui.Parent=player:WaitForChild('PlayerGui')
 local panel=Instance.new('Frame'); panel.Name='Panel'; panel.Size=UDim2.new(.9,0,0,140); panel.Position=UDim2.new(.05,0,0,12); panel.BackgroundColor3=Color3.fromRGB(24,39,43); panel.BackgroundTransparency=.1; panel.Parent=gui
 local corner=Instance.new('UICorner'); corner.CornerRadius=UDim.new(0,12); corner.Parent=panel
 for _,spec in ipairs({{'Title',8,24,'PET EXPEDITION • PLAYABLE EXAMPLE'},{'Stats',36,20,''},{'Objective',65,17,''}}) do
  local t=Instance.new('TextLabel'); t.Name=spec[1]; t.Position=UDim2.new(0,12,0,spec[2]); t.Size=UDim2.new(1,-24,0,spec[1]=='Objective' and 65 or 25); t.BackgroundTransparency=1; t.Font=Enum.Font.GothamBold; t.TextSize=spec[3]; t.TextColor3=Color3.new(1,1,1); t.TextWrapped=true; t.Text=spec[4]; t.Parent=panel
  if spec[1]~='Objective' then t.TextScaled=true; local limit=Instance.new('UITextSizeConstraint'); limit.MaxTextSize=spec[3]; limit.MinTextSize=10; limit.Parent=t end
 end
 creature(player,'Frog'); update(player); message(player,objective(player))
 local function spawned(character)
  local root=character:WaitForChild('HumanoidRootPart'); character:PivotTo(CFrame.new(world.CampSpawn.Position+Vector3.new(0,5,0)))
 end
 player.CharacterAdded:Connect(spawned)
 if player.Character then task.spawn(spawned,player.Character) end
end
local function interact(player, target)
 local s=states[player]; if not s or s.busy then return end
 local root=player.Character and player.Character:FindFirstChild('HumanoidRootPart')
 if not root or (root.Position-target.Position).Magnitude>14 then return end
 if target.Name:match('^Bug%d$') then
  if s.collected[target.Name] then message(player,'Already collected this bug. Find a different one!'); return end
  s.collected[target.Name]=true; s.food+=1
 elseif target.Name=='Camp' then
  if s.egg and not s.mole then s.egg=false; s.mole=true; creature(player,'Mole')
  elseif not s.evolved and s.food>=3 then s.food-=3; s.evolved=true; creature(player,'Frog')
  else message(player,objective(player)); return end
 elseif target.Name=='LeapOut' or target.Name=='LeapBack' then
  if not s.evolved then message(player,'Your baby frog cannot cross yet. Collect 3 bugs and feed it at camp.'); return end
  s.busy=true
  local destination=(target.Name=='LeapOut' and world.LeapBack or world.LeapOut).Position+Vector3.new(0,4,0)
  -- A guided pet ability leap, not a permanent player jump-stat upgrade.
  local start=root.CFrame; root.Anchored=true
  local middle=CFrame.new((root.Position+destination)/2+Vector3.new(0,18,0))*start.Rotation
  local a=TweenService:Create(root,TweenInfo.new(.45,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{CFrame=middle}); a:Play(); a.Completed:Wait()
  if root.Parent then local b=TweenService:Create(root,TweenInfo.new(.45,Enum.EasingStyle.Quad,Enum.EasingDirection.In),{CFrame=CFrame.new(destination)*start.Rotation}); b:Play(); b.Completed:Wait(); root.Anchored=false end
  s.busy=false
 elseif target.Name=='IslandEgg' then
  if not s.evolved or s.mole or s.egg then return end
  s.egg=true
 elseif target.Name=='BuriedCache' then
  if not s.mole then message(player,'You can see the reward, but need a mole! Evolve your frog and retrieve the island egg.'); return end
  if s.complete then message(player,'Cache already opened. You earned 5 bonus food!'); return end
  s.complete=true; s.food+=5
 end
 update(player); message(player,objective(player))
end
for _,item in ipairs(world:GetChildren()) do
 local prompt=item:FindFirstChildOfClass('ProximityPrompt')
 if prompt then prompt.Triggered:Connect(function(player) interact(player,item) end) end
end
local elapsed=0
RunService.Heartbeat:Connect(function(dt)
 elapsed+=dt; if elapsed<.05 then return end; elapsed=0
 for player,s in pairs(states) do
  local root=player.Character and player.Character:FindFirstChild('HumanoidRootPart')
  if root then
   if s.pet then s.pet:PivotTo(root.CFrame*CFrame.new(3,-1.8,3)) end
   local pos=root.Position
   if not s.busy and pos.X>14 and pos.X<40 and math.abs(pos.Z-200)<44 and pos.Y<5 then
    player.Character:PivotTo(CFrame.new(world.LeapOut.Position+Vector3.new(0,5,0)))
    message(player,'The river is too wide! Evolve your frog, then use its island leap pad.')
   end
  end
 end
end)
Players.PlayerAdded:Connect(setup)
Players.PlayerRemoving:Connect(function(player) local s=states[player]; if s and s.pet then s.pet:Destroy() end; states[player]=nil end)
for _,player in ipairs(Players:GetPlayers()) do task.spawn(setup,player) end
print('Pet expedition demo ready')
