if SERVER then
	AddCSLuaFile ("shared.lua")
	SWEP.Weight = 8
	SWEP.AutoSwitchTo = true
	SWEP.AutoSwitchFrom = true
	
elseif CLIENT then
	SWEP.PrintName = "Parachute"
	SWEP.Slot = 4
	SWEP.SlotPos = 4
	SWEP.DrawAmmo = false
	SWEP.DrawCrosshair = false
	SWEP.SwayScale = 1
	SWEP.BounceWeaponIcon = false
	
end


SWEP.Author = "TheMrFailz"
SWEP.Contact = ""
SWEP.Purpose = ""
SWEP.Instructions = "WARNING! SWITCHING WEAPONS WILL CAUSE YOU TO FALL TO YOUR DEATH!"
 
//The category that you SWep will be shown in, in the Spawn (Q) Menu 
//(This can be anything, GMod will create the categories for you)
SWEP.Category 			= "Parachutes"
--SWEP.Base				= ""
 
SWEP.Spawnable = true -- Whether regular players can see it
SWEP.AdminSpawnable = false -- Whether Admins/Super Admins can see it
 
SWEP.ViewModel 			= "models/weapons/c_arms.mdl"
SWEP.WorldModel 		= "models/thrusters/jetpack.mdl" 
SWEP.UseHands 			= true
SWEP.ViewModelFlip		= false
SWEP.HoldType			= "normal"
SWEP.HoldTypeBackup		= "normal"
SWEP.ViewModelFOV 		= 60
SWEP.LuaFileName		= "fzcss_XM1014"
SWEP.guntext			= ""

SWEP.Primary.Sound			= ""	
SWEP.Primary.Damage			= 38
SWEP.Primary.NumShots		= 6	
SWEP.Primary.Recoil			= 1.00			
SWEP.Primary.Cone			= 8.00
SWEP.Primary.BackupCone		= 9.00	-- BASE CONE OF BULLETS. Should be the same as SWEP.Primary.Cone. Used in the event that the SWEP.Primary.Cone changes.
SWEP.Primary.WalkingCone	= 10.00	-- What the cone of bullets should be when walking forward.
SWEP.Primary.DuckingCone	= 9.500	-- Cone of bullets when ducking
SWEP.Primary.AimingCone		= 7.00	-- The cone for when you're aiming. Realistically speaking cone shouldn't change when aiming buuut... Yeah.
SWEP.Primary.Bump			= 4.000	-- How much the weapon bumps around. Mostly in regards to upwards. Previously I used the recoil but that has it's own place now.
SWEP.Primary.BumpBackup		= 4.00 -- Keep the same as BUMP. Only used after SWEP.Primary.Bump has changed for some reason.
SWEP.Primary.WalkingBump	= 4.000	-- Bump to use while walking. I recommend setting this fairly high as it seems to be less noticable compared to ducking and regular bump.
SWEP.Primary.DuckingBump	= 1.500 -- Bump to use while crouching.
SWEP.Primary.AimingBump		= 1.00 -- THIS should be what you want to change to make ironsights more accurate.
SWEP.Primary.Delay			= 0.5
SWEP.Primary.ClipSize		= 1		
SWEP.Primary.DefaultClip	= 2
SWEP.Primary.Tracer			= 5		
SWEP.Primary.Force			= 3	
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "Battery"	
SWEP.Primary.TakeAmmo		= 1
SWEP.Primary.CanScope		= 0
SWEP.Primary.MaxDistReach	= 500
SWEP.HitDistance			= 40
SWEP.DrawAmmo				= false
local FUWater = 1	-- Fires underwater? (General rule of thumb: Recoil based- Ya. Bolt action - Yes (revolver too). Gas based - IRL Only fires once b/c can't cycle action. But for us, No. 

SWEP.ShowViewModel = true
SWEP.ShowWorldModel = true

local SwingSound = Sound( "weapons/knife/knife_slash1.wav" )
local HitSound = Sound( "weapons/knife/knife_hit3.wav" )
local chargetime = 0
local deploy = 0
local chute = 0
local chutepos = Vector(0,0,0)
local chutetable = {}
--Important stuff for firemode
aut = true
sing = false
--Important stuff over

-- Settings for MOUSE2 attack. Prolly shouldn't touch these as well... This is namely for ironsights.
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

-- IMPORTANT OTHER SETTINGS
SWEP.IronSightsPos = Vector(-14.374, 4.205, -0.408)
SWEP.IronSightsAng = Vector(0, 0, -61.687)
SWEP.CSMuzzleFlashes = true





function SWEP:Initialize()
   util.PrecacheModel( self.ViewModel )
   util.PrecacheModel( self.WorldModel )
   util.PrecacheSound(self.Primary.Sound)
   self:SetWeaponHoldType(self.HoldType)
   self.HoldTypeBackup	= ("knife")
  
end


function SWEP:PrimaryAttack()
	if (self.Weapon:Clip1() == 0) then return end
	--print(self.Owner:IsOnGround())
	
	if self.Owner:IsOnGround() == false and self.Owner:GetVelocity().z < 1 then
		self:TakePrimaryAmmo(1)
		deploy = 1
		chute = 1
		self.Owner:SetVelocity(Vector(0,0,10))
		self.Owner:EmitSound("npc/combine_soldier/zipline_clip1.wav")
		self.Owner:EmitSound("npc/combine_soldier/zipline_hitground1.wav")
		makeachute(self.Owner)
	end
	self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )	
end

 
function makeachute(ply)
	if SERVER then
	pararemove()
	local arrowmodel = "models/jessev92/bf2/parachute.mdl"
	local mag2 = ents.Create ("prop_physics");
	mag2:SetModel(arrowmodel)
	--local magpos = Vector(ply:EyePos().x , ply:EyePos().y, (ply:EyePos().z-5))
	mag2:SetPos(ply:GetPos());
	mag2:SetAngles (Angle(0,ply:EyeAngles().y,0));
	--mag:SetModel(self.Magazine)
	mag2:Spawn();
	mag2:SetOwner(ply);
	mag2:SetParent(ply);
	local phys = mag2:GetPhysicsObject();
	if (!IsValid( phys )) then mag2:Remove() return end
	table.insert(chutetable, mag2)
	
	local playerorig = ply
	
	timer.Create("resettera", 1, 180, function()
		if playerorig:Alive() == false then
			pararemove()
		end
	end)
	end
end



function SWEP:SecondaryAttack()
	if chute == 1 then
		pararemove()
		deploy = 0
		chute = 0
		--self.Owner:SetVelocity(Vector(0,0,10))
		self.Owner:EmitSound("npc/combine_soldier/zipline_clip2.wav")
		self.Owner:EmitSound("npc/combine_soldier/zipline_clothing1.wav")
		--self.Weapon:Remove()
	end
	
end

function pararemove()
	for k, v in pairs( chutetable ) do
		if v:IsValid() then
			v:Remove()
		end
	end
end

function SWEP:Think()
	local playerlive = self.Owner
	self.WorldModel 		= "" 
	--print(chargetime)
	self.HoldType = self.Weapon:SetWeaponHoldType(self.Weapon.HoldTypeBackup)
	
	
	if (self.Owner:IsOnGround() or self.Owner:GetVelocity().z > 1) and chute == 1 then
		pararemove()
		chute = 0
		self.Owner:EmitSound("npc/combine_soldier/zipline_clip2.wav")
		self.Owner:EmitSound("npc/combine_soldier/zipline_clothing1.wav")
	end
	
	if self.Owner:IsOnGround() then
		pararemove()
	end
	
	
	if chute == 1 and self.Owner:IsOnGround() == false then
		self.Owner:SetVelocity(self.Owner:GetForward() * 2 + Vector(0,0,math.abs(self.Owner:GetVelocity().z)*.03))
	end
	
	if SERVER then
		self:NextThink( CurTime() + 0.01 )
		return true
	end
	
end


/********************************************************
	SWEP Construction Kit base code
		Created by Clavus
	Available for public use, thread at:
	   facepunch.com/threads/1032378
	   
	   
	DESCRIPTION:
		This script is meant for experienced scripters 
		that KNOW WHAT THEY ARE DOING. Don't come to me 
		with basic Lua questions.
		
		Just copy into your SWEP or SWEP base of choice
		and merge with your own code.
		
		The SWEP.VElements, SWEP.WElements and
		SWEP.ViewModelBoneMods tables are all optional
		and only have to be visible to the client.
********************************************************/

function SWEP:Initialize()

	// other initialize code goes here

	if CLIENT then
	
		// Create a new table for every weapon instance
		self.VElements = table.FullCopy( self.VElements )
		self.WElements = table.FullCopy( self.WElements )
		self.ViewModelBoneMods = table.FullCopy( self.ViewModelBoneMods )

		self:CreateModels(self.VElements) // create viewmodels
		self:CreateModels(self.WElements) // create worldmodels
		
		// init view model bone build function
		if IsValid(self.Owner) then
			local vm = self.Owner:GetViewModel()
			if IsValid(vm) then
				self:ResetBonePositions(vm)
				
				// Init viewmodel visibility
				if (self.ShowViewModel == nil or self.ShowViewModel) then
					vm:SetColor(Color(255,255,255,255))
				else
					// we set the alpha to 1 instead of 0 because else ViewModelDrawn stops being called
					vm:SetColor(Color(255,255,255,1))
					// ^ stopped working in GMod 13 because you have to do Entity:SetRenderMode(1) for translucency to kick in
					// however for some reason the view model resets to render mode 0 every frame so we just apply a debug material to prevent it from drawing
					vm:SetMaterial("Debug/hsv")			
				end
			end
		end
		
	end

end

function SWEP:Holster()
	
	if CLIENT and IsValid(self.Owner) then
		local vm = self.Owner:GetViewModel()
		if IsValid(vm) then
			self:ResetBonePositions(vm)
		end
	end
	
	return true
end

function SWEP:OnRemove()
	self:Holster()
end

if CLIENT then

	SWEP.vRenderOrder = nil
	function SWEP:ViewModelDrawn()
		
		local vm = self.Owner:GetViewModel()
		if !IsValid(vm) then return end
		
		if (!self.VElements) then return end
		
		self:UpdateBonePositions(vm)

		if (!self.vRenderOrder) then
			
			// we build a render order because sprites need to be drawn after models
			self.vRenderOrder = {}

			for k, v in pairs( self.VElements ) do
				if (v.type == "Model") then
					table.insert(self.vRenderOrder, 1, k)
				elseif (v.type == "Sprite" or v.type == "Quad") then
					table.insert(self.vRenderOrder, k)
				end
			end
			
		end

		for k, name in ipairs( self.vRenderOrder ) do
		
			local v = self.VElements[name]
			if (!v) then self.vRenderOrder = nil break end
			if (v.hide) then continue end
			
			local model = v.modelEnt
			local sprite = v.spriteMaterial
			
			if (!v.bone) then continue end
			
			local pos, ang = self:GetBoneOrientation( self.VElements, v, vm )
			
			if (!pos) then continue end
			
			if (v.type == "Model" and IsValid(model)) then

				model:SetPos(pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z )
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)

				model:SetAngles(ang)
				//model:SetModelScale(v.size)
				local matrix = Matrix()
				matrix:Scale(v.size)
				model:EnableMatrix( "RenderMultiply", matrix )
				
				if (v.material == "") then
					model:SetMaterial("")
				elseif (model:GetMaterial() != v.material) then
					model:SetMaterial( v.material )
				end
				
				if (v.skin and v.skin != model:GetSkin()) then
					model:SetSkin(v.skin)
				end
				
				if (v.bodygroup) then
					for k, v in pairs( v.bodygroup ) do
						if (model:GetBodygroup(k) != v) then
							model:SetBodygroup(k, v)
						end
					end
				end
				
				if (v.surpresslightning) then
					render.SuppressEngineLighting(true)
				end
				
				render.SetColorModulation(v.color.r/255, v.color.g/255, v.color.b/255)
				render.SetBlend(v.color.a/255)
				model:DrawModel()
				render.SetBlend(1)
				render.SetColorModulation(1, 1, 1)
				
				if (v.surpresslightning) then
					render.SuppressEngineLighting(false)
				end
				
			elseif (v.type == "Sprite" and sprite) then
				
				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				render.SetMaterial(sprite)
				render.DrawSprite(drawpos, v.size.x, v.size.y, v.color)
				
			elseif (v.type == "Quad" and v.draw_func) then
				
				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)
				
				cam.Start3D2D(drawpos, ang, v.size)
					v.draw_func( self )
				cam.End3D2D()

			end
			
		end
		
	end

	SWEP.wRenderOrder = nil
	function SWEP:DrawWorldModel()
		
		if (self.ShowWorldModel == nil or self.ShowWorldModel) then
			self:DrawModel()
		end
		
		if (!self.WElements) then return end
		
		if (!self.wRenderOrder) then

			self.wRenderOrder = {}

			for k, v in pairs( self.WElements ) do
				if (v.type == "Model") then
					table.insert(self.wRenderOrder, 1, k)
				elseif (v.type == "Sprite" or v.type == "Quad") then
					table.insert(self.wRenderOrder, k)
				end
			end

		end
		
		if (IsValid(self.Owner)) then
			bone_ent = self.Owner
		else
			// when the weapon is dropped
			bone_ent = self
		end
		
		for k, name in pairs( self.wRenderOrder ) do
		
			local v = self.WElements[name]
			if (!v) then self.wRenderOrder = nil break end
			if (v.hide) then continue end
			
			local pos, ang
			
			if (v.bone) then
				pos, ang = self:GetBoneOrientation( self.WElements, v, bone_ent )
			else
				pos, ang = self:GetBoneOrientation( self.WElements, v, bone_ent, "ValveBiped.Bip01_R_Hand" )
			end
			
			if (!pos) then continue end
			
			local model = v.modelEnt
			local sprite = v.spriteMaterial
			
			if (v.type == "Model" and IsValid(model)) then

				model:SetPos(pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z )
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)

				model:SetAngles(ang)
				//model:SetModelScale(v.size)
				local matrix = Matrix()
				matrix:Scale(v.size)
				model:EnableMatrix( "RenderMultiply", matrix )
				
				if (v.material == "") then
					model:SetMaterial("")
				elseif (model:GetMaterial() != v.material) then
					model:SetMaterial( v.material )
				end
				
				if (v.skin and v.skin != model:GetSkin()) then
					model:SetSkin(v.skin)
				end
				
				if (v.bodygroup) then
					for k, v in pairs( v.bodygroup ) do
						if (model:GetBodygroup(k) != v) then
							model:SetBodygroup(k, v)
						end
					end
				end
				
				if (v.surpresslightning) then
					render.SuppressEngineLighting(true)
				end
				
				render.SetColorModulation(v.color.r/255, v.color.g/255, v.color.b/255)
				render.SetBlend(v.color.a/255)
				model:DrawModel()
				render.SetBlend(1)
				render.SetColorModulation(1, 1, 1)
				
				if (v.surpresslightning) then
					render.SuppressEngineLighting(false)
				end
				
			elseif (v.type == "Sprite" and sprite) then
				
				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				render.SetMaterial(sprite)
				render.DrawSprite(drawpos, v.size.x, v.size.y, v.color)
				
			elseif (v.type == "Quad" and v.draw_func) then
				
				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)
				
				cam.Start3D2D(drawpos, ang, v.size)
					v.draw_func( self )
				cam.End3D2D()

			end
			
		end
		
	end

	function SWEP:GetBoneOrientation( basetab, tab, ent, bone_override )
		
		local bone, pos, ang
		if (tab.rel and tab.rel != "") then
			
			local v = basetab[tab.rel]
			
			if (!v) then return end
			
			// Technically, if there exists an element with the same name as a bone
			// you can get in an infinite loop. Let's just hope nobody's that stupid.
			pos, ang = self:GetBoneOrientation( basetab, v, ent )
			
			if (!pos) then return end
			
			pos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
			ang:RotateAroundAxis(ang:Up(), v.angle.y)
			ang:RotateAroundAxis(ang:Right(), v.angle.p)
			ang:RotateAroundAxis(ang:Forward(), v.angle.r)
				
		else
		
			bone = ent:LookupBone(bone_override or tab.bone)

			if (!bone) then return end
			
			pos, ang = Vector(0,0,0), Angle(0,0,0)
			local m = ent:GetBoneMatrix(bone)
			if (m) then
				pos, ang = m:GetTranslation(), m:GetAngles()
			end
			
			if (IsValid(self.Owner) and self.Owner:IsPlayer() and 
				ent == self.Owner:GetViewModel() and self.ViewModelFlip) then
				ang.r = -ang.r // Fixes mirrored models
			end
		
		end
		
		return pos, ang
	end

	function SWEP:CreateModels( tab )

		if (!tab) then return end

		// Create the clientside models here because Garry says we can't do it in the render hook
		for k, v in pairs( tab ) do
			if (v.type == "Model" and v.model and v.model != "" and (!IsValid(v.modelEnt) or v.createdModel != v.model) and 
					string.find(v.model, ".mdl") and file.Exists (v.model, "GAME") ) then
				
				v.modelEnt = ClientsideModel(v.model, RENDER_GROUP_VIEW_MODEL_OPAQUE)
				if (IsValid(v.modelEnt)) then
					v.modelEnt:SetPos(self:GetPos())
					v.modelEnt:SetAngles(self:GetAngles())
					v.modelEnt:SetParent(self)
					v.modelEnt:SetNoDraw(true)
					v.createdModel = v.model
				else
					v.modelEnt = nil
				end
				
			elseif (v.type == "Sprite" and v.sprite and v.sprite != "" and (!v.spriteMaterial or v.createdSprite != v.sprite) 
				and file.Exists ("materials/"..v.sprite..".vmt", "GAME")) then
				
				local name = v.sprite.."-"
				local params = { ["$basetexture"] = v.sprite }
				// make sure we create a unique name based on the selected options
				local tocheck = { "nocull", "additive", "vertexalpha", "vertexcolor", "ignorez" }
				for i, j in pairs( tocheck ) do
					if (v[j]) then
						params["$"..j] = 1
						name = name.."1"
					else
						name = name.."0"
					end
				end

				v.createdSprite = v.sprite
				v.spriteMaterial = CreateMaterial(name,"UnlitGeneric",params)
				
			end
		end
		
	end
	
	local allbones
	local hasGarryFixedBoneScalingYet = false

	function SWEP:UpdateBonePositions(vm)
		
		if self.ViewModelBoneMods then
			
			if (!vm:GetBoneCount()) then return end
			
			// !! WORKAROUND !! //
			// We need to check all model names :/
			local loopthrough = self.ViewModelBoneMods
			if (!hasGarryFixedBoneScalingYet) then
				allbones = {}
				for i=0, vm:GetBoneCount() do
					local bonename = vm:GetBoneName(i)
					if (self.ViewModelBoneMods[bonename]) then 
						allbones[bonename] = self.ViewModelBoneMods[bonename]
					else
						allbones[bonename] = { 
							scale = Vector(1,1,1),
							pos = Vector(0,0,0),
							angle = Angle(0,0,0)
						}
					end
				end
				
				loopthrough = allbones
			end
			// !! ----------- !! //
			
			for k, v in pairs( loopthrough ) do
				local bone = vm:LookupBone(k)
				if (!bone) then continue end
				
				// !! WORKAROUND !! //
				local s = Vector(v.scale.x,v.scale.y,v.scale.z)
				local p = Vector(v.pos.x,v.pos.y,v.pos.z)
				local ms = Vector(1,1,1)
				if (!hasGarryFixedBoneScalingYet) then
					local cur = vm:GetBoneParent(bone)
					while(cur >= 0) do
						local pscale = loopthrough[vm:GetBoneName(cur)].scale
						ms = ms * pscale
						cur = vm:GetBoneParent(cur)
					end
				end
				
				s = s * ms
				// !! ----------- !! //
				
				if vm:GetManipulateBoneScale(bone) != s then
					vm:ManipulateBoneScale( bone, s )
				end
				if vm:GetManipulateBoneAngles(bone) != v.angle then
					vm:ManipulateBoneAngles( bone, v.angle )
				end
				if vm:GetManipulateBonePosition(bone) != p then
					vm:ManipulateBonePosition( bone, p )
				end
			end
		else
			self:ResetBonePositions(vm)
		end
		   
	end
	 
	function SWEP:ResetBonePositions(vm)
		
		if (!vm:GetBoneCount()) then return end
		for i=0, vm:GetBoneCount() do
			vm:ManipulateBoneScale( i, Vector(1, 1, 1) )
			vm:ManipulateBoneAngles( i, Angle(0, 0, 0) )
			vm:ManipulateBonePosition( i, Vector(0, 0, 0) )
		end
		
	end

	/**************************
		Global utility code
	**************************/

	// Fully copies the table, meaning all tables inside this table are copied too and so on (normal table.Copy copies only their reference).
	// Does not copy entities of course, only copies their reference.
	// WARNING: do not use on tables that contain themselves somewhere down the line or you'll get an infinite loop
	function table.FullCopy( tab )

		if (!tab) then return nil end
		
		local res = {}
		for k, v in pairs( tab ) do
			if (type(v) == "table") then
				res[k] = table.FullCopy(v) // recursion ho!
			elseif (type(v) == "Vector") then
				res[k] = Vector(v.x, v.y, v.z)
			elseif (type(v) == "Angle") then
				res[k] = Angle(v.p, v.y, v.r)
			else
				res[k] = v
			end
		end
		
		return res
		
	end
	
end

