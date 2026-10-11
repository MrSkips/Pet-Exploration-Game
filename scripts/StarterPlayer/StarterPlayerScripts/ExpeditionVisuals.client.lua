-- LocalScript game.StarterPlayer.StarterPlayerScripts.ExpeditionVisuals
local player=game:GetService('Players').LocalPlayer
local world=workspace:WaitForChild('PetExpeditionDemo')
for _,name in ipairs({'Bug1','Bug2','Bug3','BugEyes1','BugEyes2','BugEyes3','IslandEgg','BuriedCache'}) do
 local item=world:WaitForChild(name)
 if name:match('^Bug%d$') or name=='IslandEgg' then item:WaitForChild('ProximityPrompt') end
end
local carried
local function refresh()
 for i=1,3 do
  local used=player:GetAttribute('DemoBug'..i)
  world['Bug'..i].LocalTransparencyModifier=used and 1 or 0
  world['BugEyes'..i].LocalTransparencyModifier=used and 1 or 0
  world['Bug'..i].ProximityPrompt.Enabled=not used
 end
 local egg=player:GetAttribute('DemoEgg')
 local mole=player:GetAttribute('DemoMole')
 world.IslandEgg.LocalTransparencyModifier=(egg or mole) and 1 or 0
 world.IslandEgg.ProximityPrompt.Enabled=not egg and not mole
 if carried then carried:Destroy(); carried=nil end
 if egg then
  local root=player.Character and player.Character:FindFirstChild('HumanoidRootPart')
  if root then
   carried=Instance.new('Part'); carried.Name='CarriedMoleEgg'; carried.Shape=Enum.PartType.Ball; carried.Size=Vector3.new(2,2.8,2); carried.Color=Color3.fromRGB(250,232,175); carried.Material=Enum.Material.SmoothPlastic; carried.CanCollide=false; carried.Massless=true; carried.CFrame=root.CFrame*CFrame.new(0,1,-2); carried.Parent=player.Character
   local weld=Instance.new('WeldConstraint'); weld.Part0=root; weld.Part1=carried; weld.Parent=carried
  end
 end
 local complete=player:GetAttribute('DemoComplete')
 world.BuriedCache.Color=complete and Color3.fromRGB(252,205,87) or Color3.fromRGB(138,100,68)
 local b=world.BuriedCache:FindFirstChildOfClass('BillboardGui')
 if b then b.TextLabel.Text=complete and 'CACHE OPENED!\n+5 food • expedition complete' or 'BURIED CACHE\nHatch a mole to dig here' end
 local sign=world.IslandEgg:FindFirstChildOfClass('BillboardGui')
 if sign then sign.Enabled=not egg and not mole end
end
player.AttributeChanged:Connect(function(name) if name:sub(1,4)=='Demo' then refresh() end end)
player.CharacterAdded:Connect(function(character) character:WaitForChild('HumanoidRootPart'); refresh() end)
refresh()
