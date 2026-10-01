--[[
  Unlimited Storage Vault — shared helpers (vault + commercial fridge)
]]

USV = USV or {}

USV.MOD = "[UnlimitedStorageVault] "
USV.FLAG = "USV_Unlimited"
USV.AUTH_FLAG = "USV_Auth"
USV.WEIGHTLESS_FLAG = "USV_Weightless"
USV.CARRY_TOKEN = "USV_CarryToken"
USV.OWNER_FLAG = "USV_OwnerId"
USV.KIND_FLAG = "USV_Kind"
USV.APPLIED_FLAG = "USV_Applied"
USV.APPEARANCE_FLAG = "USV_Appearance"
USV._preservingMove = false
USV._carryPacks = USV._carryPacks or {}
USV._carryTokenSeq = USV._carryTokenSeq or 0
USV.POS_X = "USV_X"
USV.POS_Y = "USV_Y"
USV.POS_Z = "USV_Z"
USV.MODDATA_KEY = "UnlimitedStorageVault"
USV.CAPACITY = 999999 -- UI / Lua capacity (Java setCapacity hard-caps at 100)
USV.JAVA_CAPACITY_MAX = 100 -- B42 ItemContainer.setCapacity refuses above this
USV.SKIP_WEIGHT_CALC = false -- show real contents weight in UI (e.g. 129 / 999999)
USV.MOVEABLE_CARRY_WEIGHT = 1 -- inventory weight when carrying vault/fridge (contents ignored)

USV.KINDS = {
	vault = {
		id = "vault",
		entity = "USV_InfiniteVault",
		playerFlag = "USV_OwnsVault",
		worldNameKey = "IGUI_USV_WorldName",
		containerNameKey = "IGUI_USV_ContainerName",
		alreadyOwnedKey = "IGUI_USV_AlreadyOwned",
		alreadyOwnedFallback = "You already own the maximum number of Unlimited Storage vaults (%d per player).",
		safehouseFullKey = "IGUI_USV_SafehouseFull",
		safehouseFullFallback = "This safehouse already has the maximum number of Unlimited Storage vaults (%d per safehouse).",
		needSafehouseKey = "IGUI_USV_NeedSafehouse",
		needSafehouseFallback = "Unlimited Storage can only be placed inside a safehouse you belong to.",
		worldNameFallback = "∞ Unlimited Storage",
		containerNameFallback = "∞ Unlimited Storage",
		highlight = { r = 1.0, g = 0.82, b = 0.15, a = 1.0 }, -- gold marker (LineDrawer)
		sprites = {
			-- Current build sprites (white file cabinet; unique vs Hammertime)
			["location_business_office_generic_01_32"] = true,
			["location_business_office_generic_01_33"] = true,
			["location_business_office_generic_01_34"] = true,
			["location_business_office_generic_01_35"] = true,
			-- Legacy military locker sprites (already-placed objects only)
			["location_military_generic_01_8"] = true,
			["location_military_generic_01_22"] = true,
			["location_military_generic_01_23"] = true,
			["location_military_generic_01_30"] = true,
			["location_military_generic_01_31"] = true,
		},
	},
	fridge = {
		id = "fridge",
		entity = "USV_InfiniteFridge",
		playerFlag = "USV_OwnsFridge",
		worldNameKey = "IGUI_USV_FridgeWorldName",
		containerNameKey = "IGUI_USV_FridgeContainerName",
		alreadyOwnedKey = "IGUI_USV_FridgeAlreadyOwned",
		alreadyOwnedFallback = "You already own the maximum number of Unlimited Commercial Fridges (%d per player).",
		safehouseFullKey = "IGUI_USV_FridgeSafehouseFull",
		safehouseFullFallback = "This safehouse already has the maximum number of Unlimited Commercial Fridges (%d per safehouse).",
		needSafehouseKey = "IGUI_USV_FridgeNeedSafehouse",
		needSafehouseFallback = "Unlimited Commercial Fridge can only be placed inside a safehouse you belong to.",
		worldNameFallback = "∞ Unlimited Commercial Fridge",
		containerNameFallback = "∞ Unlimited Fridge",
		highlight = { r = 0.35, g = 0.95, b = 0.40, a = 1.0 }, -- emerald marker (avoids vanilla cyan outline)
		sprites = {
			["appliances_refrigeration_01_40"] = true,
			["appliances_refrigeration_01_41"] = true,
			["appliances_refrigeration_01_42"] = true,
			["appliances_refrigeration_01_43"] = true,
		},
	},
}

-- Runtime visual skins (1-tile, 4-facing). Not used in entity SpriteConfig so
-- Hammertime / other tile-claim mods cannot collide at world load.
-- faces: S, E, N, W
USV.APPEARANCES = {
	vault = {
		{
			id = "fileCabinet",
			nameKey = "IGUI_USV_App_FileCabinet",
			nameFallback = "White File Cabinet",
			faces = {
				S = "location_business_office_generic_01_32",
				E = "location_business_office_generic_01_33",
				N = "location_business_office_generic_01_34",
				W = "location_business_office_generic_01_35",
			},
		},
		{
			id = "metalLocker",
			nameKey = "IGUI_USV_App_MetalLocker",
			nameFallback = "Metal Locker",
			faces = {
				S = "furniture_storage_02_0",
				E = "furniture_storage_02_1",
				N = "furniture_storage_02_2",
				W = "furniture_storage_02_3",
			},
		},
		{
			id = "militaryLocker",
			nameKey = "IGUI_USV_App_MilitaryLocker",
			nameFallback = "Military Locker",
			faces = {
				S = "location_military_generic_01_22",
				E = "location_military_generic_01_23",
				N = "location_military_generic_01_30",
				W = "location_military_generic_01_31",
			},
		},
		{
			id = "whiteDrawers",
			nameKey = "IGUI_USV_App_WhiteDrawers",
			nameFallback = "White Drawers",
			faces = {
				S = "furniture_storage_01_9",
				E = "furniture_storage_01_8",
				N = "furniture_storage_01_11",
				W = "furniture_storage_01_10",
			},
		},
		{
			id = "darkDrawers",
			nameKey = "IGUI_USV_App_DarkDrawers",
			nameFallback = "Dark Drawers",
			faces = {
				S = "furniture_storage_01_33",
				E = "furniture_storage_01_32",
				N = "furniture_storage_01_35",
				W = "furniture_storage_01_34",
			},
		},
		{
			id = "oakDrawers",
			nameKey = "IGUI_USV_App_OakDrawers",
			nameFallback = "Oak Drawers",
			faces = {
				S = "furniture_storage_01_13",
				E = "furniture_storage_01_12",
				N = "furniture_storage_01_15",
				W = "furniture_storage_01_14",
			},
		},
	},
	fridge = {
		{
			id = "whiteIndustrial",
			nameKey = "IGUI_USV_App_WhiteIndustrialFridge",
			nameFallback = "White Industrial Fridge",
			faces = {
				S = "appliances_refrigeration_01_40",
				E = "appliances_refrigeration_01_41",
				N = "appliances_refrigeration_01_42",
				W = "appliances_refrigeration_01_43",
			},
		},
		{
			id = "white",
			nameKey = "IGUI_USV_App_WhiteFridge",
			nameFallback = "White Fridge",
			faces = {
				S = "appliances_refrigeration_01_0",
				E = "appliances_refrigeration_01_1",
				N = "appliances_refrigeration_01_2",
				W = "appliances_refrigeration_01_3",
			},
		},
		{
			id = "blue",
			nameKey = "IGUI_USV_App_BlueFridge",
			nameFallback = "Blue Fridge",
			faces = {
				S = "appliances_refrigeration_01_4",
				E = "appliances_refrigeration_01_5",
				N = "appliances_refrigeration_01_6",
				W = "appliances_refrigeration_01_7",
			},
		},
		{
			id = "steel",
			nameKey = "IGUI_USV_App_SteelFridge",
			nameFallback = "Steel Fridge",
			faces = {
				S = "appliances_refrigeration_01_8",
				E = "appliances_refrigeration_01_9",
				N = "appliances_refrigeration_01_10",
				W = "appliances_refrigeration_01_11",
			},
		},
		{
			id = "green",
			nameKey = "IGUI_USV_App_GreenFridge",
			nameFallback = "Green Fridge",
			faces = {
				S = "appliances_refrigeration_01_12",
				E = "appliances_refrigeration_01_13",
				N = "appliances_refrigeration_01_14",
				W = "appliances_refrigeration_01_15",
			},
		},
		{
			id = "plain",
			nameKey = "IGUI_USV_App_PlainFridge",
			nameFallback = "Plain Fridge",
			faces = {
				S = "appliances_refrigeration_01_28",
				E = "appliances_refrigeration_01_29",
				N = "appliances_refrigeration_01_30",
				W = "appliances_refrigeration_01_31",
			},
		},
		{
			id = "red",
			nameKey = "IGUI_USV_App_RedFridge",
			nameFallback = "Red Fridge",
			faces = {
				S = "appliances_refrigeration_01_32",
				E = "appliances_refrigeration_01_33",
				N = "appliances_refrigeration_01_34",
				W = "appliances_refrigeration_01_35",
			},
		},
	},
}

USV.DEFAULT_APPEARANCE = {
	vault = "fileCabinet",
	fridge = "whiteIndustrial",
}

-- Backward-compatible aliases
USV.ENTITY_NAME = USV.KINDS.vault.entity
USV.PLAYER_OWNED_FLAG = USV.KINDS.vault.playerFlag
USV.SPRITE = "location_business_office_generic_01_32"
USV.SPRITES = USV.KINDS.vault.sprites
USV.HIGHLIGHT = USV.KINDS.vault.highlight

local unlimitedContainerCache = setmetatable({}, { __mode = "k" })
-- Applied USV parents/containers (weak keys; IsoObjects stay alive in-world).
local unlimitedParentRegistry = setmetatable({}, { __mode = "k" })
local unlimitedContainerRegistry = setmetatable({}, { __mode = "k" })
local spriteToKind = {}
local appearanceBySprite = {}

function USV.rebuildSpriteKindMap()
	spriteToKind = {}
	appearanceBySprite = {}
	for kindId, def in pairs(USV.KINDS) do
		for spriteName, _ in pairs(def.sprites) do
			spriteToKind[spriteName] = kindId
		end
	end
	for kindId, list in pairs(USV.APPEARANCES or {}) do
		local def = USV.KINDS[kindId]
		if def and type(list) == "table" then
			for i = 1, #list do
				local app = list[i]
				if app and app.faces then
					for _, spriteName in pairs(app.faces) do
						if type(spriteName) == "string" then
							spriteToKind[spriteName] = kindId
							def.sprites[spriteName] = true
							appearanceBySprite[spriteName] = app.id
						end
					end
				end
			end
		end
	end
end

USV.rebuildSpriteKindMap()

local function placementEquals(a, b)
	return a and b and a.x == b.x and a.y == b.y and a.z == b.z
end

--- Legacy ownerPlacement was a single {x,y,z,carried?} per owner.
local function isLegacyOwnerSeal(entry)
	return type(entry) == "table" and type(entry.x) == "number"
end

function USV.getSandboxInt(key, fallback)
	local root = SandboxVars and SandboxVars.UnlimitedStorageVault
	if root and type(root[key]) == "number" then
		return math.floor(root[key])
	end
	return fallback
end

--- 0 = unlimited.
function USV.getMaxPerPlayer()
	local n = USV.getSandboxInt("MaxPerPlayer", 1)
	if n < 0 then
		return 0
	end
	return n
end

--- 0 = unlimited.
function USV.getMaxPerSafehouse()
	local n = USV.getSandboxInt("MaxPerSafehouse", 1)
	if n < 0 then
		return 0
	end
	return n
end

function USV.ensureOwnerPlacementList(store, kind, ownerId)
	if not store or not kind or not ownerId then
		return nil
	end
	store.ownerPlacement = store.ownerPlacement or {}
	store.ownerPlacement[kind] = store.ownerPlacement[kind] or {}
	local cur = store.ownerPlacement[kind][ownerId]
	if cur == nil then
		store.ownerPlacement[kind][ownerId] = {}
		return store.ownerPlacement[kind][ownerId]
	end
	if isLegacyOwnerSeal(cur) then
		store.ownerPlacement[kind][ownerId] = { cur }
		return store.ownerPlacement[kind][ownerId]
	end
	return cur
end

function USV.log(_msg)
	-- No-op: informational logs are disabled (hot-path string work + console I/O).
end

function USV.logError(msg)
	print(USV.MOD .. tostring(msg))
end

function USV.getKindDef(kind)
	return kind and USV.KINDS[kind] or nil
end

function USV.getAppearances(kind)
	return (kind and USV.APPEARANCES and USV.APPEARANCES[kind]) or nil
end

function USV.getAppearanceDef(kind, appearanceId)
	local list = USV.getAppearances(kind)
	if not list then
		return nil
	end
	if not appearanceId then
		appearanceId = USV.DEFAULT_APPEARANCE and USV.DEFAULT_APPEARANCE[kind]
	end
	for i = 1, #list do
		if list[i] and list[i].id == appearanceId then
			return list[i]
		end
	end
	return list[1]
end

function USV.appearanceLabel(app)
	if not app then
		return ""
	end
	local name = getText and getText(app.nameKey) or nil
	if not name or name == "" or (app.nameKey and string.find(name, "IGUI_USV_", 1, true)) then
		name = app.nameFallback or app.id
	end
	return name
end

function USV.getSpriteFacing(obj)
	if not obj or not obj.getSprite then
		return "S"
	end
	local facing = nil
	pcall(function()
		local spr = obj:getSprite()
		local props = spr and spr.getProperties and spr:getProperties() or nil
		if props and props.has and props:has("Facing") and props.get then
			facing = props:get("Facing")
		end
	end)
	if facing == "S" or facing == "E" or facing == "N" or facing == "W" then
		return facing
	end
	local spriteName = USV.getSpriteNameFast(obj)
	if spriteName and appearanceBySprite then
		local kind = USV.resolveSpriteKind(spriteName)
		local list = USV.getAppearances(kind)
		if list then
			for i = 1, #list do
				local faces = list[i] and list[i].faces
				if faces then
					for dir, name in pairs(faces) do
						if name == spriteName then
							return dir
						end
					end
				end
			end
		end
	end
	return "S"
end

function USV.getObjectAppearanceId(obj)
	if not obj or not obj.getModData then
		return nil
	end
	local md = obj:getModData()
	if md and type(md[USV.APPEARANCE_FLAG]) == "string" then
		return md[USV.APPEARANCE_FLAG]
	end
	local spriteName = USV.getSpriteNameFast(obj)
	return spriteName and appearanceBySprite[spriteName] or nil
end

function USV.playerCanCustomize(player, obj)
	if not player or not obj then
		return false
	end
	if not USV.isLegitimateUSVObject(obj) then
		return false
	end
	local ownerId = nil
	pcall(function()
		local md = obj.getModData and obj:getModData() or nil
		ownerId = md and md[USV.OWNER_FLAG] or nil
	end)
	local playerId = USV.getOwnerId(player)
	if ownerId and playerId and ownerId == playerId then
		return true
	end
	local kind = USV.getObjectKind(obj)
	if kind and playerId and USV.playerOwns(kind, player) then
		local live = USV.getLiveCoords(obj)
		if live and USV.ownerHasSealAt(kind, playerId, live) then
			return true
		end
	end
	return false
end

function USV.applyAppearance(obj, appearanceId, transmit)
	if not obj then
		return false
	end
	local kind = USV.getObjectKind(obj) or USV.resolveSpriteKind(USV.getSpriteNameFast(obj))
	local app = USV.getAppearanceDef(kind, appearanceId)
	if not app or not app.faces then
		return false
	end
	local facing = USV.getSpriteFacing(obj)
	local spriteName = app.faces[facing] or app.faces.S
	if not spriteName then
		return false
	end
	local ok = pcall(function()
		if obj.setSpriteFromName then
			obj:setSpriteFromName(spriteName)
		elseif obj.setSprite and getSprite then
			obj:setSprite(getSprite(spriteName))
		end
	end)
	if not ok then
		USV.logError("applyAppearance: failed to set sprite " .. tostring(spriteName))
		return false
	end
	if obj.getModData then
		local md = obj:getModData()
		if md then
			md[USV.APPEARANCE_FLAG] = app.id
			md[USV.KIND_FLAG] = kind
			md[USV.FLAG] = true
		end
	end
	if transmit then
		if USV.isAuthoritative() then
			pcall(function()
				if obj.transmitUpdatedSpriteToClients then
					obj:transmitUpdatedSpriteToClients()
				end
			end)
			USV.transmitObjectModData(obj)
		end
	end
	USV.applyObject(obj, true, kind)
	return true
end

function USV.requestAppearance(player, obj, appearanceId)
	if not player or not obj or not appearanceId then
		return false
	end
	if not USV.playerCanCustomize(player, obj) then
		return false
	end
	if isClient and isClient() and not (isServer and isServer()) then
		local coords = USV.getLiveCoords(obj)
		if not coords or not sendClientCommand then
			return false
		end
		sendClientCommand(player, "USV", "SetAppearance", {
			x = coords.x,
			y = coords.y,
			z = coords.z,
			appearanceId = appearanceId,
		})
		return true
	end
	return USV.applyAppearance(obj, appearanceId, true)
end

function USV.onChooseAppearance(obj, player, appearanceId)
	USV.requestAppearance(player, obj, appearanceId)
end

function USV.invalidateContainerCache(container)
	if container then
		unlimitedContainerCache[container] = nil
		unlimitedContainerRegistry[container] = nil
	end
end

function USV.rememberUnlimitedParent(obj)
	if obj then
		unlimitedParentRegistry[obj] = true
	end
end

function USV.rememberUnlimitedContainer(container, isUnlimited)
	if not container then
		return
	end
	if isUnlimited then
		unlimitedContainerCache[container] = true
		unlimitedContainerRegistry[container] = true
		local ok, parent = pcall(function()
			return container.getParent and container:getParent() or nil
		end)
		if ok and parent then
			unlimitedParentRegistry[parent] = true
		end
	else
		unlimitedContainerCache[container] = nil
		unlimitedContainerRegistry[container] = nil
	end
end

function USV.getStore()
	if not ModData or not ModData.getOrCreate then
		return nil
	end
	local store = ModData.getOrCreate(USV.MODDATA_KEY)
	store.ownersByKind = store.ownersByKind or {}
	store.placements = store.placements or {}
	store.ownerPlacement = store.ownerPlacement or {}
	-- Migrate legacy flat owners table -> vault kind
	if store.owners and type(store.owners) == "table" then
		store.ownersByKind.vault = store.ownersByKind.vault or {}
		for id, v in pairs(store.owners) do
			if v then
				store.ownersByKind.vault[id] = true
			end
		end
		store.owners = nil
	end
	for kindId, _ in pairs(USV.KINDS) do
		store.ownersByKind[kindId] = store.ownersByKind[kindId] or {}
		store.placements[kindId] = store.placements[kindId] or {}
		store.ownerPlacement[kindId] = store.ownerPlacement[kindId] or {}
		local byOwner = store.ownerPlacement[kindId]
		for ownerId, entry in pairs(byOwner) do
			if isLegacyOwnerSeal(entry) then
				byOwner[ownerId] = { entry }
			end
		end
	end
	return store
end

--- True on dedicated/listen server or singleplayer (not a pure multiplayer client).
function USV.isAuthoritative()
	if isServer and isServer() then
		return true
	end
	if isClient and isClient() then
		return false
	end
	return true -- singleplayer
end

--- Server-only secret (never written to synced ModData).
function USV.getServerSecret()
	if not USV.isAuthoritative() then
		return nil
	end
	if type(USV._serverSecret) == "string" and USV._serverSecret ~= "" then
		return USV._serverSecret
	end
	local seed = tostring(os.time()) .. ":" .. tostring(ZombRand and ZombRand(1, 2000000000) or 42)
	USV._serverSecret = "usv:" .. seed
	return USV._serverSecret
end

--- Lua 5.1 / Kahlua compatible hash (no bitwise ~ which is Lua 5.3+ only).
local function simpleHash(str)
	local h = 2166136261
	for i = 1, #str do
		-- FNV-1a style without XOR: mix with multiply + add
		h = (h * 16777619 + string.byte(str, i)) % 2147483647
	end
	return tostring(h)
end

function USV.makeAuthToken(obj, ownerId, kind, coords)
	if not USV.isAuthoritative() then
		return nil
	end
	local secret = USV.getServerSecret()
	if not secret or not ownerId or not kind then
		return nil
	end
	coords = coords or USV.getLiveCoords(obj) or USV.getObjectCoords(obj)
	if not coords then
		return nil
	end
	local raw = table.concat({
		secret,
		tostring(ownerId),
		tostring(kind),
		tostring(coords.x),
		tostring(coords.y),
		tostring(coords.z),
	}, "|")
	return simpleHash(raw)
end

function USV.verifyAuthToken(obj)
	if not obj or not obj.getModData then
		return false
	end
	if not USV.isAuthoritative() then
		-- Clients cannot verify server secret; use placement registry instead.
		return false
	end
	local md = obj:getModData()
	if not md or type(md[USV.AUTH_FLAG]) ~= "string" then
		return false
	end
	local kind = md[USV.KIND_FLAG] or "vault"
	local ownerId = md[USV.OWNER_FLAG]
	local expected = USV.makeAuthToken(obj, ownerId, kind, USV.getLiveCoords(obj))
	return expected ~= nil and md[USV.AUTH_FLAG] == expected
end

--- Soft legitimacy for capacity/UI: USV sprite + any prior USV signal.
--- (Strict ownerPlacement trust is only for ownership seal / anti-dupe, not capacity.)
function USV.objectNameLooksUSV(obj)
	if not obj or not obj.getName then
		return false
	end
	local ok, name = pcall(function()
		return obj:getName()
	end)
	if not ok or not name then
		return false
	end
	local s = tostring(name)
	return string.find(s, "∞", 1, true) ~= nil
		or string.find(s, "Unlimited", 1, true) ~= nil
		or string.find(s, "無限", 1, true) ~= nil
end

function USV.isUSVSpriteObject(obj)
	return USV.resolveSpriteKind(USV.getSpriteNameFast(obj)) ~= nil
end

--- Capacity / transfer bypass: correct sprite family (incl. tile-pack prefixes) + USV marker.
function USV.isLegitimateUSVObject(obj)
	if not obj then
		return false
	end
	if unlimitedParentRegistry[obj] then
		return true
	end
	-- Name is enough to recover after sprite remaps / stripped flags.
	if USV.objectNameLooksUSV(obj) then
		return true
	end
	if not USV.isUSVSpriteObject(obj) then
		return false
	end
	if USV.isFlaggedObject(obj) then
		return true
	end
	local md = obj.getModData and obj:getModData() or nil
	if md and (md[USV.KIND_FLAG] ~= nil or md[USV.OWNER_FLAG] ~= nil or md[USV.AUTH_FLAG] ~= nil) then
		return true
	end
	if USV.isRegisteredPlacementObject(obj) then
		return true
	end
	if USV.isTrustedUSVObject(obj) then
		return true
	end
	return false
end

--- Strict trust: correct sprite + FLAG + registered owner + live coords match that owner's sealed placement
--- (or a valid server auth token). Used for ownership seal / relocate — not capacity gates.
function USV.isTrustedUSVObject(obj)
	if not obj then
		return false
	end
	local sprite = USV.getSpriteNameFast(obj)
	local kindFromSprite = USV.resolveSpriteKind(sprite)
	if not kindFromSprite and not USV.objectNameLooksUSV(obj) then
		return false
	end
	if not USV.isFlaggedObject(obj) then
		return false
	end
	local md = obj.getModData and obj:getModData() or nil
	local kind = (md and md[USV.KIND_FLAG]) or kindFromSprite or "vault"
	if not USV.getKindDef(kind) then
		return false
	end
	local ownerId = md and md[USV.OWNER_FLAG]
	local store = USV.getStore()
	local live = USV.getLiveCoords(obj)

	-- Primary: this owner's sealed placement matches the live tile (synced ModData).
	if ownerId and live and USV.ownerHasSealAt(kind, ownerId, live) then
		if store and store.ownersByKind and store.ownersByKind[kind] and store.ownersByKind[kind][ownerId] then
			return true
		end
	end

	-- Fallback: legacy placements list (pre-ownerPlacement saves) matched by live tile.
	if USV.isRegisteredPlacementObject(obj) then
		return true
	end

	if USV.isAuthoritative() and USV.verifyAuthToken(obj) then
		return true
	end
	return false
end

--- True if this owner has a sealed placement at live coords (list or legacy single).
function USV.ownerHasSealAt(kind, ownerId, live)
	if not kind or not ownerId or not live then
		return false
	end
	local store = USV.getStore()
	local entry = store and store.ownerPlacement and store.ownerPlacement[kind] and store.ownerPlacement[kind][ownerId]
	if not entry then
		return false
	end
	if isLegacyOwnerSeal(entry) then
		return placementEquals(entry, live)
	end
	for i = 1, #entry do
		if placementEquals(entry[i], live) then
			return true
		end
	end
	return false
end

local function ownerObjectStillAt(sealed, ownerId, kind, ignoreObj)
	if not sealed or sealed.carried then
		return false
	end
	local cell = getCell and getCell() or nil
	local oldSq = cell and cell:getGridSquare(sealed.x, sealed.y, sealed.z or 0) or nil
	if not oldSq then
		-- Unloaded: treat as still present so we do not steal that slot.
		return true
	end
	if not oldSq.getObjects then
		return false
	end
	local objects = oldSq:getObjects()
	if not objects then
		return false
	end
	for i = 0, objects:size() - 1 do
		local other = objects:get(i)
		if other and other ~= ignoreObj and USV.isFlaggedObject(other) then
			local omd = other.getModData and other:getModData() or nil
			if omd and omd[USV.OWNER_FLAG] == ownerId and (omd[USV.KIND_FLAG] or "vault") == kind then
				return true
			end
		end
	end
	return false
end

--- Relocate a carried/stale seal to this object, or add a new seal when under the sandbox cap.
function USV.tryRelocateOwnerPlacement(obj, kind)
	if not USV.isAuthoritative() or not obj or not obj.getModData then
		return false
	end
	local md = obj:getModData()
	kind = kind or md[USV.KIND_FLAG] or USV.resolveSpriteKind(USV.getSpriteNameFast(obj)) or "vault"
	local ownerId = md[USV.OWNER_FLAG]
	local live = USV.getLiveCoords(obj)
	local store = USV.getStore()
	if not ownerId or not live or not store then
		return false
	end
	if not (store.ownersByKind and store.ownersByKind[kind] and store.ownersByKind[kind][ownerId]) then
		return false
	end
	local list = USV.ensureOwnerPlacementList(store, kind, ownerId)
	if not list then
		return false
	end
	for i = 1, #list do
		if placementEquals(list[i], live) then
			return true
		end
	end
	for i = 1, #list do
		if list[i] and list[i].carried then
			list[i] = { x = live.x, y = live.y, z = live.z }
			USV.registerPlacement(kind, obj, false)
			USV.transmitStore()
			return true
		end
	end
	for i = 1, #list do
		local sealed = list[i]
		if sealed and not sealed.carried and not ownerObjectStillAt(sealed, ownerId, kind, obj) then
			local plist = store.placements and store.placements[kind]
			if plist then
				for j = #plist, 1, -1 do
					if placementEquals(plist[j], sealed) then
						table.remove(plist, j)
					end
				end
			end
			list[i] = { x = live.x, y = live.y, z = live.z }
			USV.registerPlacement(kind, obj, false)
			USV.transmitStore()
			return true
		end
	end
	-- All existing seals still live: new build, or a duplicate. Allow add under cap (0 = unlimited).
	local maxP = USV.getMaxPerPlayer()
	if maxP > 0 and #list >= maxP then
		return false
	end
	list[#list + 1] = { x = live.x, y = live.y, z = live.z }
	USV.registerPlacement(kind, obj, false)
	USV.transmitStore()
	return true
end

--- True if object is a registered owner's USV that can be sealed/relocated on this tile.
function USV.canBootstrapTrusted(obj)
	if not USV.isAuthoritative() or not obj or not USV.isFlaggedObject(obj) then
		return false
	end
	local sprite = USV.getSpriteNameFast(obj)
	local kindFromSprite = USV.resolveSpriteKind(sprite)
	if not kindFromSprite and not USV.objectNameLooksUSV(obj) then
		return false
	end
	local md = obj:getModData()
	local kind = (md and md[USV.KIND_FLAG]) or kindFromSprite or "vault"
	local ownerId = md and md[USV.OWNER_FLAG]
	local store = USV.getStore()
	if not ownerId or not store or not store.ownersByKind or not store.ownersByKind[kind] then
		return false
	end
	return store.ownersByKind[kind][ownerId] == true
end

--- Seal live coords for this owner + re-issue auth (authoritative only).
function USV.authorizeObject(obj, kind)
	if not USV.isAuthoritative() or not obj or not obj.getModData then
		return false
	end
	local md = obj:getModData()
	kind = kind or md[USV.KIND_FLAG] or USV.getObjectKind(obj) or "vault"
	local ownerId = md[USV.OWNER_FLAG]
	if not ownerId then
		return false
	end
	local store = USV.getStore()
	if not (store and store.ownersByKind and store.ownersByKind[kind] and store.ownersByKind[kind][ownerId]) then
		return false
	end
	md[USV.FLAG] = true
	md[USV.KIND_FLAG] = kind
	if not USV.tryRelocateOwnerPlacement(obj, kind) then
		return false
	end
	local coords = USV.rememberObjectCoords(obj)
	md[USV.AUTH_FLAG] = USV.makeAuthToken(obj, ownerId, kind, coords)
	USV.transmitObjectModData(obj)
	return true
end

--- Remove forged USV ModData from world objects (authoritative only).
function USV.stripUntrustedFlags(obj)
	if not USV.isAuthoritative() or not obj or not obj.getModData then
		return false
	end
	if USV.isTrustedUSVObject(obj) then
		return false
	end
	if not USV.isFlaggedObject(obj) and not (obj.getModData and obj:getModData()[USV.KIND_FLAG]) then
		return false
	end
	local md = obj:getModData()
	md[USV.FLAG] = nil
	md[USV.AUTH_FLAG] = nil
	md[USV.KIND_FLAG] = nil
	md[USV.OWNER_FLAG] = nil
	md[USV.APPLIED_FLAG] = nil
	md[USV.WEIGHTLESS_FLAG] = nil
	md[USV.APPEARANCE_FLAG] = nil
	unlimitedParentRegistry[obj] = nil
	USV.transmitObjectModData(obj)
	return true
end

function USV.getSafeHouseAt(square)
	if not square or not SafeHouse then
		return nil
	end
	if SafeHouse.getSafeHouse then
		local ok, sh = pcall(function()
			return SafeHouse.getSafeHouse(square)
		end)
		if ok and sh then
			return sh
		end
	end
	-- Some builds return the SafeHouse object from isSafeHouse (see ISDestroyCursor).
	if SafeHouse.isSafeHouse then
		local ok, sh = pcall(function()
			return SafeHouse.isSafeHouse(square, nil, true)
		end)
		if ok and sh and sh.getX then
			return sh
		end
	end
	if SafeHouse.getSafehouseList then
		local ok, list = pcall(function()
			return SafeHouse.getSafehouseList()
		end)
		if ok and list and list.size then
			local x, y = square:getX(), square:getY()
			for i = 0, list:size() - 1 do
				local candidate = list:get(i)
				if candidate and USV.pointInSafehouse(candidate, x, y) then
					return candidate
				end
			end
		end
	end
	return nil
end

--- True only in real multiplayer sessions (not SP host / listen quirks).
function USV.requiresSafehouseRules()
	if type(isMultiplayer) == "function" then
		local ok, mp = pcall(isMultiplayer)
		if ok then
			return mp and true or false
		end
	end
	return false
end

function USV.playerAllowedInSafehouse(sh, player, square)
	if not player then
		return false
	end
	if square and SafeHouse and SafeHouse.isSafehouseAllowLoot then
		local ok, allowed = pcall(function()
			return SafeHouse.isSafehouseAllowLoot(square, player)
		end)
		if ok and allowed then
			return true
		end
	end
	if not sh then
		return false
	end
	if sh.playerAllowed then
		local ok, allowed = pcall(function()
			return sh:playerAllowed(player)
		end)
		if ok and allowed then
			return true
		end
		local name = nil
		pcall(function()
			name = player.getUsername and player:getUsername() or nil
		end)
		if name then
			ok, allowed = pcall(function()
				return sh:playerAllowed(name)
			end)
			if ok and allowed then
				return true
			end
		end
	end
	local username = nil
	pcall(function()
		username = player.getUsername and player:getUsername() or nil
	end)
	if not username or username == "" then
		return false
	end
	local owner = nil
	pcall(function()
		owner = sh.getOwner and sh:getOwner() or nil
	end)
	if owner and owner == username then
		return true
	end
	local members = nil
	pcall(function()
		members = sh.getPlayers and sh:getPlayers() or nil
	end)
	if members and members.contains then
		local ok, has = pcall(function()
			return members:contains(username)
		end)
		if ok and has then
			return true
		end
	end
	return false
end

function USV.pointInSafehouse(sh, x, y)
	if not sh or x == nil or y == nil then
		return false
	end
	if sh.containsLocation then
		local ok, inside = pcall(function()
			return sh:containsLocation(x, y)
		end)
		if ok then
			return inside and true or false
		end
	end
	if sh.getX and sh.getX2 and sh.getY and sh.getY2 then
		local x1, x2 = sh:getX(), sh:getX2()
		local y1, y2 = sh:getY(), sh:getY2()
		return x >= x1 and x < x2 and y >= y1 and y < y2
	end
	return false
end

--- Live tile coords only (never trust ModData POS — clients can forge those).
function USV.getLiveCoords(obj)
	if not obj or not obj.getSquare then
		return nil
	end
	local ok, sq = pcall(function()
		return obj:getSquare()
	end)
	if not ok or not sq then
		return nil
	end
	if not (sq.getX and sq.getY) then
		return nil
	end
	return {
		x = sq:getX(),
		y = sq:getY(),
		z = (sq.getZ and sq:getZ()) or 0,
	}
end

function USV.getObjectCoords(obj)
	if not obj then
		return nil
	end
	-- Prefer live square; ModData POS is a cache for carry/restore only.
	local live = USV.getLiveCoords(obj)
	if live then
		return live
	end
	if obj.getModData then
		local md = obj:getModData()
		if md and type(md[USV.POS_X]) == "number" and type(md[USV.POS_Y]) == "number" then
			return {
				x = md[USV.POS_X],
				y = md[USV.POS_Y],
				z = type(md[USV.POS_Z]) == "number" and md[USV.POS_Z] or 0,
			}
		end
	end
	if not obj.getSquare then
		return nil
	end
	local ok, sq = pcall(function()
		return obj:getSquare()
	end)
	if not ok or not sq then
		return nil
	end
	return {
		x = sq:getX(),
		y = sq:getY(),
		z = sq:getZ(),
	}
end

function USV.rememberObjectCoords(obj)
	local coords = USV.getObjectCoords(obj)
	if not coords or not obj or not obj.getModData then
		return coords
	end
	local md = obj:getModData()
	if not md then
		return coords
	end
	md[USV.POS_X] = coords.x
	md[USV.POS_Y] = coords.y
	md[USV.POS_Z] = coords.z
	return coords
end

function USV.registerPlacement(kind, obj, transmit)
	-- Only server/SP may mutate the placement registry (synced ModData).
	if not USV.isAuthoritative() then
		return
	end
	if not USV.getKindDef(kind) or not obj then
		return
	end
	local coords = USV.rememberObjectCoords(obj)
	if not coords then
		return
	end
	local store = USV.getStore()
	if not store then
		return
	end
	store.placements = store.placements or {}
	store.placements[kind] = store.placements[kind] or {}
	local list = store.placements[kind]
	for i = 1, #list do
		if placementEquals(list[i], coords) then
			return
		end
	end
	list[#list + 1] = { x = coords.x, y = coords.y, z = coords.z }
	if transmit ~= false then
		USV.transmitStore()
	end
end

function USV.unregisterPlacement(kind, obj)
	if not USV.isAuthoritative() then
		return
	end
	local coords = USV.getLiveCoords(obj) or USV.getObjectCoords(obj)
	if not coords then
		return
	end
	local store = USV.getStore()
	if not store or not store.placements or not store.placements[kind] then
		return
	end
	local list = store.placements[kind]
	for i = #list, 1, -1 do
		if placementEquals(list[i], coords) then
			table.remove(list, i)
		end
	end
	USV.transmitStore()
end

function USV.squareHasKindObject(square, kind)
	if not square or not square.getObjects or not USV.getKindDef(kind) then
		return false
	end
	local objects = square:getObjects()
	if not objects or not objects.size then
		return false
	end
	for i = 0, objects:size() - 1 do
		local obj = objects:get(i)
		if obj then
			local okind = USV.getObjectKind(obj) or USV.resolveSpriteKind(USV.getSpriteNameFast(obj))
			if okind == kind and (USV.isFlaggedObject(obj) or USV.isLegitimateUSVObject(obj) or USV.objectNameLooksUSV(obj)) then
				return true
			end
		end
	end
	return false
end

function USV.countSafehouseKind(sh, kind, onlyLoaded)
	if not sh or not USV.getKindDef(kind) then
		return 0
	end
	local store = USV.getStore()
	local list = store and store.placements and store.placements[kind]
	if not list then
		return 0
	end
	local n = 0
	local cell = getCell and getCell() or nil
	for i = 1, #list do
		local p = list[i]
		if p and USV.pointInSafehouse(sh, p.x, p.y) then
			local sq = cell and cell:getGridSquare(p.x, p.y, p.z or 0) or nil
			if onlyLoaded then
				if sq and USV.squareHasKindObject(sq, kind) then
					n = n + 1
				end
			elseif not sq then
				n = n + 1
			elseif USV.squareHasKindObject(sq, kind) then
				n = n + 1
			end
		end
	end
	return n
end

function USV.safehouseHasKind(sh, kind)
	return USV.countSafehouseKind(sh, kind) > 0
end

function USV.countCarryingKind(kind, player)
	if not player or not player.getInventory or not USV.getKindDef(kind) then
		return 0
	end
	local n = 0
	local function scan(container, depth)
		if not container or depth > 6 then
			return
		end
		local items = nil
		pcall(function()
			items = container.getItems and container:getItems() or nil
		end)
		if not items or not items.size then
			return
		end
		for i = 0, items:size() - 1 do
			local item = items:get(i)
			if item and USV.isUSVFurnitureItem(item) then
				local ok, md = pcall(function()
					return item.getModData and item:getModData() or nil
				end)
				local itemKind = (ok and md and md[USV.KIND_FLAG]) or "vault"
				if itemKind == kind then
					n = n + 1
				end
			end
			local sub = nil
			pcall(function()
				sub = item and item.getInventory and item:getInventory() or nil
			end)
			if sub then
				scan(sub, depth + 1)
			end
		end
	end
	scan(player:getInventory(), 0)
	return n
end

function USV.playerIsCarryingKind(kind, player)
	return USV.countCarryingKind(kind, player) > 0
end

--- Live world seals + carried furniture of this kind (no double-count of carried seals).
--- onlyLoaded: ignore unloaded-chunk seals (placement validation).
function USV.countPlayerKind(kind, player, onlyLoaded)
	if not player or not USV.getKindDef(kind) then
		return 0
	end
	local carriedItems = USV.countCarryingKind(kind, player)
	local ownerId = USV.getOwnerId(player)
	local store = USV.getStore()
	if not ownerId or not store then
		return carriedItems
	end
	local entry = store.ownerPlacement and store.ownerPlacement[kind] and store.ownerPlacement[kind][ownerId]
	if not entry then
		return carriedItems
	end
	local list = entry
	if isLegacyOwnerSeal(entry) then
		list = { entry }
	end
	local world = 0
	local carriedSeals = 0
	local cell = getCell and getCell() or nil
	for i = 1, #list do
		local p = list[i]
		if p then
			if p.carried then
				carriedSeals = carriedSeals + 1
			else
				local sq = cell and cell:getGridSquare(p.x, p.y, p.z or 0) or nil
				if onlyLoaded then
					if sq and USV.squareHasKindObject(sq, kind) then
						world = world + 1
					end
				elseif not sq then
					world = world + 1
				elseif USV.squareHasKindObject(sq, kind) then
					world = world + 1
				end
			end
		end
	end
	local carried = carriedItems
	if carriedSeals > carried then
		carried = carriedSeals
	end
	return world + carried
end

--- True if this player still has a live world object or is carrying that kind.
function USV.playerHasLiveKind(kind, player)
	return USV.countPlayerKind(kind, player) > 0
end

function USV.markOwnerCarrying(kind, ownerId, coords)
	if not USV.isAuthoritative() or not ownerId or not USV.getKindDef(kind) then
		return
	end
	local store = USV.getStore()
	if not store then
		return
	end
	local list = USV.ensureOwnerPlacementList(store, kind, ownerId)
	if not list then
		return
	end
	local replaced = false
	if coords then
		for i = 1, #list do
			if placementEquals(list[i], coords) then
				list[i] = { x = -1, y = -1, z = 0, carried = true }
				replaced = true
				break
			end
		end
	end
	if not replaced then
		if #list == 1 and list[1] and not list[1].carried then
			list[1] = { x = -1, y = -1, z = 0, carried = true }
		else
			list[#list + 1] = { x = -1, y = -1, z = 0, carried = true }
		end
	end
	USV.transmitStore()
end

function USV.pruneStalePlacements(kind)
	if not USV.isAuthoritative() or not USV.getKindDef(kind) then
		return
	end
	local store = USV.getStore()
	local list = store and store.placements and store.placements[kind]
	if not list then
		return
	end
	local cell = getCell and getCell() or nil
	local changed = false
	for i = #list, 1, -1 do
		local p = list[i]
		if p then
			local sq = cell and cell:getGridSquare(p.x, p.y, p.z or 0) or nil
			if sq and not USV.squareHasKindObject(sq, kind) then
				table.remove(list, i)
				changed = true
			end
		end
	end
	if changed then
		USV.transmitStore()
	end
end

function USV.reconcilePlayerKind(kind, player)
	if not USV.isAuthoritative() or not player or not USV.getKindDef(kind) then
		return
	end
	if not USV.playerOwns(kind, player) then
		return
	end
	if USV.playerHasLiveKind(kind, player) then
		return
	end
	local ownerId = USV.getOwnerId(player)
	if ownerId then
		USV.releaseOwnerId(kind, ownerId)
	end
end

--- Returns ok, reason ("owned" | "safehouse" | "needSafehouse" | nil)
--- relocating: true when moving an already-owned USV (pickup/place), so the per-player cap is skipped.
function USV.canPlaceKind(kind, player, square, relocating)
	if USV.isAuthoritative() then
		USV.pruneStalePlacements(kind)
		if not relocating then
			USV.reconcilePlayerKind(kind, player)
		end
	end
	if not relocating then
		local maxP = USV.getMaxPerPlayer()
		if maxP > 0 and USV.countPlayerKind(kind, player, true) >= maxP then
			return false, "owned"
		end
	end
	local sh = nil
	if USV.requiresSafehouseRules() then
		if not square or not player then
			return false, "needSafehouse"
		end
		if not USV.playerAllowedInSafehouse(nil, player, square) then
			return false, "needSafehouse"
		end
		sh = USV.getSafeHouseAt(square)
		if not sh and SafeHouse and SafeHouse.hasSafehouse then
			pcall(function()
				sh = SafeHouse.hasSafehouse(player)
			end)
		end
	elseif square then
		sh = USV.getSafeHouseAt(square)
	end
	if sh then
		local maxS = USV.getMaxPerSafehouse()
		if maxS > 0 then
			local count = USV.countSafehouseKind(sh, kind, true)
			if relocating and USV.playerIsCarryingKind(kind, player) then
				count = math.max(0, count - 1)
			end
			if count >= maxS then
				return false, "safehouse"
			end
		end
	end
	return true, nil
end

function USV.playerBelowBuildLimit(kind, player)
	local maxP = USV.getMaxPerPlayer()
	if maxP <= 0 then
		return true
	end
	return USV.countPlayerKind(kind, player) < maxP
end

function USV.transmitStore()
	if ModData and ModData.transmit then
		pcall(function()
			ModData.transmit(USV.MODDATA_KEY)
		end)
	end
end

function USV.getOwnerId(player)
	if not player then
		return nil
	end
	if player.getSteamID then
		local ok, sid = pcall(function()
			return player:getSteamID()
		end)
		if ok and sid ~= nil then
			local s = tostring(sid)
			if s ~= "" and s ~= "0" and s ~= "nil" then
				return "steam:" .. s
			end
		end
	end
	if player.getUsername then
		local ok, name = pcall(function()
			return player:getUsername()
		end)
		if ok and name and tostring(name) ~= "" then
			return "user:" .. tostring(name)
		end
	end
	if player.getDisplayName then
		local ok, name = pcall(function()
			return player:getDisplayName()
		end)
		if ok and name and tostring(name) ~= "" then
			return "name:" .. tostring(name)
		end
	end
	return nil
end

function USV.playerOwns(kind, player)
	local def = USV.getKindDef(kind)
	if not def or not player then
		return false
	end
	local id = USV.getOwnerId(player)
	if not id then
		return false
	end
	local store = USV.getStore()
	if store and store.ownersByKind and store.ownersByKind[kind] and store.ownersByKind[kind][id] then
		return true
	end
	-- Player ModData flag is a cache only. After dismantle it can linger in MP
	-- and must not keep blocking rebuild once the store record is gone.
	return false
end

function USV.playerOwnsVault(player)
	return USV.playerOwns("vault", player)
end

function USV.playerOwnsFridge(player)
	return USV.playerOwns("fridge", player)
end

function USV.setPlayerOwnedFlag(kind, player, owned)
	local def = USV.getKindDef(kind)
	if not def or not player or not player.getModData then
		return
	end
	local md = player:getModData()
	md[def.playerFlag] = owned and true or nil
	if player.transmitModData then
		pcall(function()
			player:transmitModData()
		end)
	end
end

function USV.findOnlinePlayerByOwnerId(ownerId)
	if not ownerId or not getOnlinePlayers then
		return nil
	end
	local ok, players = pcall(getOnlinePlayers)
	if not ok or not players or not players.size then
		return nil
	end
	for i = 0, players:size() - 1 do
		local p = players:get(i)
		if USV.getOwnerId(p) == ownerId then
			return p
		end
	end
	return nil
end

function USV.claim(kind, player, obj)
	-- Only server/SP may authorize ownership (prevents client ModData forgery).
	if not USV.isAuthoritative() then
		return false
	end
	local def = USV.getKindDef(kind)
	local id = USV.getOwnerId(player)
	if not def or not id or not obj then
		return false
	end
	local sprite = USV.getSpriteNameFast(obj)
	local spriteKind = USV.resolveSpriteKind(sprite)
	if spriteKind ~= kind then
		-- Allow kind mismatch only if sprite maps to this kind family
		if not spriteKind then
			USV.logError("claim rejected: invalid sprite " .. tostring(sprite))
			return false
		end
		kind = spriteKind
		def = USV.getKindDef(kind)
		if not def then
			return false
		end
	end
	local store = USV.getStore()
	if store then
		store.ownersByKind[kind] = store.ownersByKind[kind] or {}
		store.ownersByKind[kind][id] = true
		USV.transmitStore()
	end
	USV.setPlayerOwnedFlag(kind, player, true)
	local md = obj:getModData()
	md[USV.FLAG] = true
	md[USV.OWNER_FLAG] = id
	md[USV.KIND_FLAG] = kind
	if not md[USV.APPEARANCE_FLAG] then
		md[USV.APPEARANCE_FLAG] = (USV.DEFAULT_APPEARANCE and USV.DEFAULT_APPEARANCE[kind]) or nil
	end
	if not USV.authorizeObject(obj, kind) then
		USV.logError("claim: authorizeObject failed for " .. tostring(id))
		return false
	end
	USV.rememberUnlimitedParent(obj)
	return true
end

function USV.claimVault(player, obj)
	return USV.claim("vault", player, obj)
end

function USV.releaseOwnerPlacementAt(kind, ownerId, coords)
	if not ownerId or not USV.getKindDef(kind) then
		return
	end
	if not USV.isAuthoritative() then
		return
	end
	local store = USV.getStore()
	if not store then
		return
	end
	local list = USV.ensureOwnerPlacementList(store, kind, ownerId)
	if list and coords then
		for i = #list, 1, -1 do
			if placementEquals(list[i], coords) then
				table.remove(list, i)
			end
		end
	end
	if (not list or #list == 0) then
		USV.releaseOwnerId(kind, ownerId)
		return
	end
	USV.transmitStore()
end

function USV.releaseOwnerId(kind, ownerId)
	if not ownerId then
		return
	end
	local def = USV.getKindDef(kind)
	if USV.isAuthoritative() then
		local store = USV.getStore()
		if store and store.ownersByKind and store.ownersByKind[kind] then
			store.ownersByKind[kind][ownerId] = nil
		end
		if store and store.ownerPlacement and store.ownerPlacement[kind] then
			local sealed = store.ownerPlacement[kind][ownerId]
			store.ownerPlacement[kind][ownerId] = nil
			if sealed and store.placements and store.placements[kind] then
				local plist = store.placements[kind]
				local function removeMatching(entry)
					if not entry then
						return
					end
					for i = #plist, 1, -1 do
						if placementEquals(plist[i], entry) then
							table.remove(plist, i)
						end
					end
				end
				if isLegacyOwnerSeal(sealed) then
					removeMatching(sealed)
				else
					for i = 1, #sealed do
						removeMatching(sealed[i])
					end
				end
			end
		end
		if store then
			USV.transmitStore()
		end
	end
	local online = USV.findOnlinePlayerByOwnerId(ownerId)
	if online and def then
		USV.setPlayerOwnedFlag(kind, online, false)
	end
	if getNumActivePlayers then
		for i = 0, getNumActivePlayers() - 1 do
			local p = getSpecificPlayer(i)
			if USV.getOwnerId(p) == ownerId and def then
				USV.setPlayerOwnedFlag(kind, p, false)
			end
		end
	elseif getSpecificPlayer and def then
		local p = getSpecificPlayer(0)
		if USV.getOwnerId(p) == ownerId then
			USV.setPlayerOwnedFlag(kind, p, false)
		end
	end
end

function USV.getObjectKind(obj)
	if not obj or not obj.getModData then
		return nil
	end
	local md = obj:getModData()
	if md and md[USV.KIND_FLAG] and USV.KINDS[md[USV.KIND_FLAG]] then
		return md[USV.KIND_FLAG]
	end
	-- Legacy vault objects (flagged but no kind)
	if md and md[USV.FLAG] == true then
		return "vault"
	end
	local sprite = USV.getSpriteNameFast(obj)
	return USV.resolveSpriteKind(sprite)
end

function USV.releaseObject(obj)
	if not obj or not obj.getModData then
		return
	end
	local md = obj:getModData()
	if not md then
		return
	end
	local kind = md[USV.KIND_FLAG] or USV.resolveSpriteKind(USV.getSpriteNameFast(obj)) or "vault"
	local ownerId = md[USV.OWNER_FLAG]
	local coords = USV.getLiveCoords(obj) or USV.getObjectCoords(obj)
	USV.unregisterPlacement(kind, obj)
	md[USV.FLAG] = nil
	md[USV.AUTH_FLAG] = nil
	md[USV.OWNER_FLAG] = nil
	md[USV.KIND_FLAG] = nil
	md[USV.APPLIED_FLAG] = nil
	md[USV.APPEARANCE_FLAG] = nil
	md[USV.POS_X] = nil
	md[USV.POS_Y] = nil
	md[USV.POS_Z] = nil
	if obj.getContainerCount then
		local count = obj:getContainerCount() or 0
		for i = 0, count - 1 do
			local c = obj:getContainerByIndex(i)
			if c then
				USV.rememberUnlimitedContainer(c, false)
				if c.getModData then
					local cmd = c:getModData()
					if cmd then
						cmd[USV.FLAG] = nil
					end
				end
			end
		end
	end
	USV.releaseOwnerPlacementAt(kind, ownerId, coords)
end

function USV.releaseVaultObject(obj)
	USV.releaseObject(obj)
end

function USV.shouldReleaseOnRemove(obj)
	if not obj then
		return false
	end
	if USV.isPreservingMove() then
		return false
	end
	if USV.isFlaggedObject(obj) then
		return true
	end
	local md = obj.getModData and obj:getModData() or nil
	if md and (md[USV.OWNER_FLAG] or md[USV.KIND_FLAG] or md[USV.AUTH_FLAG]) then
		return true
	end
	if USV.isRegisteredPlacementObject(obj) then
		return true
	end
	return false
end

--- Dismantle / scrap / destroy (not pickup). Always release ownership + placement.
function USV.onWorldObjectRemoved(obj, reason)
	if not obj then
		return
	end
	if USV.isPreservingMove() then
		return
	end
	if not USV.shouldReleaseOnRemove(obj) then
		return
	end
	USV.clearAllContents(obj)
	USV.releaseObject(obj)
end

function USV.isFlaggedObject(obj)
	if not obj or not obj.getModData then
		return false
	end
	local md = obj:getModData()
	return md ~= nil and md[USV.FLAG] == true
end

function USV.isUSVMoveableItem(item)
	if not item or not item.getModData then
		return false
	end
	local ok, md = pcall(function()
		return item:getModData()
	end)
	if not ok or not md then
		return false
	end
	return md[USV.FLAG] == true or md[USV.WEIGHTLESS_FLAG] == true or md[USV.KIND_FLAG] ~= nil
end

--- True for a picked-up USV vault/fridge furniture item (not ordinary loot).
function USV.isUSVFurnitureItem(item)
	if not item then
		return false
	end
	if not (instanceof and instanceof(item, "InventoryItem")) then
		return false
	end
	if USV.isUSVMoveableItem(item) then
		return true
	end
	local sprite = nil
	pcall(function()
		sprite = item.getWorldSprite and item:getWorldSprite() or nil
	end)
	if sprite and USV.resolveSpriteKind(tostring(sprite)) then
		-- Only treat as USV furniture when it also carries USV markers (vanilla
		-- industrial fridges share the same sprite family).
		return USV.isUSVMoveableItem(item)
	end
	return false
end

--- Fixed carry weight for a picked-up USV vault/fridge (furniture; contents not counted).
function USV.makeMoveableWeightless(item)
	if not item then
		return
	end
	local w = USV.MOVEABLE_CARRY_WEIGHT or 1
	pcall(function()
		if item.getModData then
			local md = item:getModData()
			if md then
				md[USV.WEIGHTLESS_FLAG] = true
				if md[USV.FLAG] ~= true then
					md[USV.FLAG] = true
				end
			end
		end
		if item.setCustomWeight then
			item:setCustomWeight(true)
		end
		if item.setActualWeight then
			item:setActualWeight(w)
		end
		if item.setWeight then
			item:setWeight(w)
		end
	end)
end

function USV.beginPreserveMove()
	USV._preservingMove = true
end

function USV.endPreserveMove()
	USV._preservingMove = false
end

function USV.isPreservingMove()
	return USV._preservingMove == true
end

function USV.newCarryToken()
	USV._carryTokenSeq = (USV._carryTokenSeq or 0) + 1
	return "usv_" .. tostring(USV._carryTokenSeq) .. "_" .. tostring(os.time())
end

function USV.containerIsCharacterInventory(container)
	if not container then
		return false
	end
	local parent = nil
	pcall(function()
		parent = container.getParent and container:getParent() or nil
	end)
	if parent and instanceof and instanceof(parent, "IsoGameCharacter") then
		return true
	end
	local t = ""
	pcall(function()
		t = container.getType and tostring(container:getType() or "") or ""
	end)
	if t == "inventorymale" or t == "inventoryfemale" then
		return true
	end
	return false
end

--- InventoryItem:getContainer() is the PARENT inventory holding the item (player bag, etc.).
--- IsoObject:getContainer() is the object's own first container.
function USV.isOwnItemContainer(entity, container)
	if not entity or not container then
		return false
	end
	if USV.containerIsCharacterInventory(container) then
		return false
	end
	if instanceof and instanceof(entity, "InventoryItem") then
		local parent = nil
		pcall(function()
			parent = entity.getContainer and entity:getContainer() or nil
		end)
		if parent and parent == container then
			return false
		end
		local hasSelf = false
		pcall(function()
			hasSelf = container.contains and container:contains(entity) or false
		end)
		if hasSelf then
			return false
		end
	end
	return true
end

function USV.collectContainers(entity)
	local containers = {}
	if not entity then
		return containers
	end
	local isItem = instanceof and instanceof(entity, "InventoryItem")
	pcall(function()
		if entity.getContainerCount then
			local n = entity:getContainerCount() or 0
			for i = 0, n - 1 do
				local c = entity:getContainerByIndex(i)
				if c and USV.isOwnItemContainer(entity, c) then
					containers[#containers + 1] = c
				end
			end
		end
		if #containers == 0 and entity.getItemContainer then
			local c = entity:getItemContainer()
			if c and USV.isOwnItemContainer(entity, c) then
				containers[#containers + 1] = c
			end
		end
		-- Never use InventoryItem:getContainer() — that is the parent (player) inventory.
		if (not isItem) and #containers == 0 and entity.getContainer then
			local c = entity:getContainer()
			if c and USV.isOwnItemContainer(entity, c) then
				containers[#containers + 1] = c
			end
		end
		if entity.getInventory and instanceof and instanceof(entity, "InventoryContainer") then
			local c = entity:getInventory()
			if c and USV.isOwnItemContainer(entity, c) then
				local dup = false
				for i = 1, #containers do
					if containers[i] == c then
						dup = true
						break
					end
				end
				if not dup then
					containers[#containers + 1] = c
				end
			end
		end
	end)
	return containers
end

--- Detach items from world object containers (keep InventoryItem refs; do not destroy).
function USV.harvestContainerItems(obj)
	local packs = {}
	local containers = USV.collectContainers(obj)
	for index, cont in ipairs(containers) do
		if not USV.containerIsCharacterInventory(cont) then
			local pack = {
				index = index - 1,
				type = "",
				items = {},
			}
			pcall(function()
				if cont.getType then
					pack.type = tostring(cont:getType() or "")
				end
			end)
			local list = {}
			pcall(function()
				local items = cont:getItems()
				if items then
					for j = 0, items:size() - 1 do
						list[#list + 1] = items:get(j)
					end
				end
			end)
			for _, invItem in ipairs(list) do
				if invItem and invItem ~= obj then
					-- Nested USV furniture is a pickup/place dupe; delete, do not preserve.
					local nestedFurniture = USV.isUSVFurnitureItem(invItem)
					pcall(function()
						if cont.DoRemoveItem then
							cont:DoRemoveItem(invItem)
						elseif cont.Remove then
							cont:Remove(invItem)
						end
					end)
					if not nestedFurniture then
						pack.items[#pack.items + 1] = invItem
					end
				end
			end
			packs[#packs + 1] = pack
		end
	end
	return packs
end

function USV.findPackContainer(containers, pack)
	if not containers or #containers == 0 or not pack then
		return nil
	end
	if pack.type and pack.type ~= "" then
		for _, c in ipairs(containers) do
			local ok, t = pcall(function()
				return c.getType and tostring(c:getType() or "") or ""
			end)
			if ok and t == pack.type then
				return c
			end
		end
	end
	if pack.index ~= nil and containers[pack.index + 1] then
		return containers[pack.index + 1]
	end
	return containers[1]
end

function USV.depositContainerItems(entity, packs)
	if not entity or not packs then
		return 0
	end
	local containers = USV.collectContainers(entity)
	if #containers == 0 then
		return 0
	end
	local deposited = 0
	for _, pack in ipairs(packs) do
		local cont = USV.findPackContainer(containers, pack)
		if cont and (not USV.containerIsCharacterInventory(cont)) and pack.items then
			local remain = {}
			for _, invItem in ipairs(pack.items) do
				if invItem and (not USV.isUSVFurnitureItem(invItem)) then
					local added = false
					pcall(function()
						if cont.AddItem then
							cont:AddItem(invItem)
							added = true
						end
						if added and sendAddItemToContainer then
							sendAddItemToContainer(cont, invItem)
						end
					end)
					if added then
						deposited = deposited + 1
					else
						remain[#remain + 1] = invItem
					end
				end
			end
			pack.items = remain
			USV.invalidateContainerCache(cont)
		end
	end
	return deposited
end

--- Remove nested USV furniture items that were duplicated into vault/fridge containers.
function USV.purgeNestedFurnitureItems(obj)
	if not obj then
		return 0
	end
	local removed = 0
	local containers = USV.collectContainers(obj)
	for _, cont in ipairs(containers) do
		if cont and not USV.containerIsCharacterInventory(cont) then
			local list = {}
			pcall(function()
				local items = cont.getItems and cont:getItems() or nil
				if items then
					for j = 0, items:size() - 1 do
						list[#list + 1] = items:get(j)
					end
				end
			end)
			for _, invItem in ipairs(list) do
				if USV.isUSVFurnitureItem(invItem) then
					pcall(function()
						if cont.DoRemoveItem then
							cont:DoRemoveItem(invItem)
						elseif cont.Remove then
							cont:Remove(invItem)
						end
					end)
					removed = removed + 1
				end
			end
			if removed > 0 then
				USV.invalidateContainerCache(cont)
			end
		end
	end
	if removed > 0 then
	end
	return removed
end

function USV.storeCarryPacks(item, packs)
	if not item or not packs then
		return nil
	end
	local token = USV.newCarryToken()
	USV._carryPacks[token] = packs
	pcall(function()
		local md = item:getModData()
		if md then
			md[USV.CARRY_TOKEN] = token
			md[USV.FLAG] = true
			md[USV.WEIGHTLESS_FLAG] = true
		end
	end)
	-- Prefer keeping items inside the moveable's own containers (TransferComponents).
	USV.depositContainerItems(item, packs)
	local left = 0
	for _, pack in ipairs(packs) do
		left = left + (pack.items and #pack.items or 0)
	end
	if left == 0 then
		-- All items live on the moveable; token still used as a marker.
		USV._carryPacks[token] = packs
	end
	return token
end

function USV.takeCarryPacks(item)
	if not item or not item.getModData then
		return nil
	end
	local ok, md = pcall(function()
		return item:getModData()
	end)
	if not ok or not md then
		return USV.harvestContainerItems(item)
	end
	local token = md[USV.CARRY_TOKEN]
	local packsLimbo = token and USV._carryPacks[token] or nil
	if token then
		USV._carryPacks[token] = nil
		md[USV.CARRY_TOKEN] = nil
	end
	-- Items may already sit in moveable containers after TransferComponents / deposit.
	local packsOnItem = USV.harvestContainerItems(item)
	local function countItems(packs)
		local n = 0
		if not packs then
			return 0
		end
		for _, pack in ipairs(packs) do
			n = n + (pack.items and #pack.items or 0)
		end
		return n
	end
	local onItem = countItems(packsOnItem)
	local onLimbo = countItems(packsLimbo)
	if onItem > 0 and onLimbo > 0 then
		for _, pack in ipairs(packsLimbo) do
			if pack.items and #pack.items > 0 then
				packsOnItem[#packsOnItem + 1] = pack
			end
		end
		return packsOnItem
	end
	if onItem > 0 then
		return packsOnItem
	end
	return packsLimbo
end

function USV.isRegisteredPlacementObject(obj)
	-- Match against live tile only so forged ModData POS cannot spoof placement.
	local coords = USV.getLiveCoords(obj)
	if not coords then
		return false
	end
	local store = USV.getStore()
	if not store or not store.placements then
		return false
	end
	for _, list in pairs(store.placements) do
		if type(list) == "table" then
			for i = 1, #list do
				if placementEquals(list[i], coords) then
					return true
				end
			end
		end
	end
	return false
end

--- True when carry item belongs to a registered owner (not forged inventory ModData).
function USV.isAuthorizedCarryItem(item)
	if not item or not item.getModData then
		return false
	end
	local ok, md = pcall(function()
		return item:getModData()
	end)
	if not ok or not md or md[USV.FLAG] ~= true then
		return false
	end
	local kind = md[USV.KIND_FLAG] or "vault"
	local ownerId = md[USV.OWNER_FLAG]
	if not ownerId then
		return false
	end
	local store = USV.getStore()
	if not store or not store.ownersByKind or not store.ownersByKind[kind] then
		return false
	end
	return store.ownersByKind[kind][ownerId] == true
end

--- Broad check for USV moveable items (weightless in inventory; holds packed contents).
function USV.isUSVCarryItem(item)
	if not item then
		return false
	end
	if item.getModData then
		local ok, md = pcall(function()
			return item:getModData()
		end)
		if ok and md then
			if md[USV.FLAG] == true or md[USV.WEIGHTLESS_FLAG] == true or md[USV.CARRY_TOKEN] ~= nil or md[USV.KIND_FLAG] ~= nil then
				return true
			end
		end
	end
	if USV.isAuthorizedCarryItem(item) then
		return true
	end
	-- No world-sprite fallback: vanilla fridge/locker items share USV appearance sprites.
	return false
end

--- True if an in-world object or sprite is a USV furniture item (eligible for empty-bypass pickup).
function USV.isUSVMoveableObject(obj, spriteName)
	-- Sprite alone is not enough: appearance sprites include vanilla fridges/lockers.
	if obj then
		return USV.isLegitimateUSVObject(obj) or USV.isFlaggedObject(obj)
	end
	return false
end

function USV.parentLooksLikeUSV(parent)
	return USV.isLegitimateUSVObject(parent)
end

function USV.isUnlimitedContainer(container)
	if not container then
		return false
	end
	-- Fast path from prior successful apply.
	if unlimitedContainerRegistry[container] or unlimitedContainerCache[container] == true then
		USV.ensureContainerCapacity(container)
		return true
	end

	-- B42: ItemContainer.getModData()/getCustomName() NPE when native getParent() is null.
	local nativeParent = nil
	if container.getParent then
		local ok, p = pcall(function()
			return container:getParent()
		end)
		if ok then
			nativeParent = p
		end
	end
	local parent = nativeParent
	if not parent then
		parent = USV.resolveContainerParent(container)
	end

	-- Container custom name (∞ / Unlimited / 無限) — works even when parent sprite is remapped.
	if nativeParent then
		local okN, cname = pcall(function()
			return container.getCustomName and container:getCustomName() or nil
		end)
		if okN and cname then
			local s = tostring(cname)
			if string.find(s, "∞", 1, true) or string.find(s, "Unlimited", 1, true) or string.find(s, "無限", 1, true) then
				if parent then
					USV.rememberUnlimitedParent(parent)
				end
				USV.rememberUnlimitedContainer(container, true)
				USV.ensureContainerCapacity(container)
				return true
			end
		end
		local okM, md = pcall(function()
			return container.getModData and container:getModData() or nil
		end)
		if okM and md and md[USV.FLAG] == true then
			if parent then
				USV.rememberUnlimitedParent(parent)
			end
			USV.rememberUnlimitedContainer(container, true)
			USV.ensureContainerCapacity(container)
			return true
		end
	end

	if not parent then
		return false
	end

	-- Capacity bypass: USV sprite family + any legitimacy signal (not sealed-owner only).
	if USV.isLegitimateUSVObject(parent) then
		USV.rememberUnlimitedParent(parent)
		USV.rememberUnlimitedContainer(container, true)
		USV.ensureContainerCapacity(container)
		return true
	end

	return false
end

--- Find IsoObject that owns this ItemContainer (parent can be nil on some B42 paths).
function USV.resolveContainerParent(container)
	if not container then
		return nil
	end
	local parent = nil
	if container.getParent then
		local ok, p = pcall(function()
			return container:getParent()
		end)
		if ok and p then
			return p
		end
	end
	if not container.getSourceGrid then
		return nil
	end
	local ok = pcall(function()
		local sq = container:getSourceGrid()
		if not sq or not sq.getObjects then
			return
		end
		local objects = sq:getObjects()
		if not objects then
			return
		end
		for i = 0, objects:size() - 1 do
			local obj = objects:get(i)
			if obj and USV.isVaultSprite(USV.getSpriteNameFast(obj)) then
				local count = obj.getContainerCount and obj:getContainerCount() or 0
				for ci = 0, count - 1 do
					if obj:getContainerByIndex(ci) == container then
						parent = obj
						return
					end
				end
				if obj.getItemContainer and obj:getItemContainer() == container then
					parent = obj
					return
				end
				if USV.isFlaggedObject(obj) then
					parent = obj
					return
				end
			end
		end
	end)
	if not ok then
		return nil
	end
	return parent
end

--- Java hard-caps setCapacity at 100; UI capacity comes from getCapacity hooks (USV.CAPACITY).
--- Over-full containers (weight > 100) must use DoAddItemBlind — never rely on Java capacity checks.
function USV.ensureContainerCapacity(container)
	if not container then
		return
	end
	pcall(function()
		if container.setCapacity then
			container:setCapacity(USV.JAVA_CAPACITY_MAX or 100)
		end
	end)
end

function USV.isVaultSprite(name)
	return USV.resolveSpriteKind(name) ~= nil
end

function USV.getSpriteNameFast(obj)
	if not obj or not obj.getSprite then
		return nil
	end
	local spr = obj:getSprite()
	if not spr or not spr.getName then
		return nil
	end
	return spr:getName()
end

--- Tile packs (e.g. Optimal) may prefix sprites: ct_oac_location_business_office_generic_01_33
function USV.resolveSpriteKind(spriteName)
	if not spriteName then
		return nil
	end
	local name = tostring(spriteName)
	if spriteToKind[name] then
		return spriteToKind[name]
	end
	for sprite, kind in pairs(spriteToKind) do
		local n = #sprite
		if #name >= n and name:sub(-n) == sprite then
			return kind
		end
	end
	return nil
end

function USV.applyObjectName(obj, kind)
	if not obj or not obj.setName then
		return
	end
	local def = USV.getKindDef(kind) or USV.KINDS.vault
	local name = getText(def.worldNameKey)
	if not name or name == "" or string.find(name, "IGUI_USV_", 1, true) then
		name = def.worldNameFallback
	end
	if obj.getName and obj:getName() == name then
		return
	end
	obj:setName(name)
end

function USV.makeInvulnerable(obj)
	if not obj then
		return
	end
	if obj.setIsThumpable then
		pcall(function()
			obj:setIsThumpable(false)
		end)
	end
	if obj.setMaxHealth then
		pcall(function()
			obj:setMaxHealth(100000)
		end)
	end
	if obj.setHealth then
		pcall(function()
			obj:setHealth(100000)
		end)
	end
	if obj.setThumpDmg then
		pcall(function()
			obj:setThumpDmg(100000)
		end)
	end
end

--- Only server/SP should push object ModData (client transmit causes ObjectModData / ReceiveContainerModData NPEs).
function USV.transmitObjectModData(obj)
	if not USV.isAuthoritative() or not obj or not obj.transmitModData then
		return
	end
	pcall(function()
		obj:transmitModData()
	end)
end

function USV.markObject(obj, kind)
	if not obj or not obj.getModData then
		return
	end
	-- Clients must not write/transmit world ModData during scan/apply.
	if not USV.isAuthoritative() then
		return
	end
	local md = obj:getModData()
	md[USV.FLAG] = true
	md[USV.KIND_FLAG] = kind or md[USV.KIND_FLAG] or "vault"
	USV.transmitObjectModData(obj)
end

function USV.applyContainer(container, kind)
	if not container then
		return
	end
	local def = USV.getKindDef(kind) or USV.KINDS.vault
	-- Do NOT write ItemContainer ModData — B42 MP ReceiveContainerModData NPE when container ID is unresolved.
	USV.rememberUnlimitedContainer(container, true)
	USV.ensureContainerCapacity(container)
	if container.setExplored then
		pcall(function()
			container:setExplored(true)
		end)
	end
	-- Custom name only on authoritative (setCustomName syncs container data to server).
	if not USV.isAuthoritative() then
		return
	end
	local hasParent = false
	pcall(function()
		hasParent = container.getParent and container:getParent() ~= nil
	end)
	if hasParent and container.setCustomName then
		pcall(function()
			local name = getText(def.containerNameKey)
			if not name or name == "" or string.find(name, "IGUI_USV_", 1, true) then
				name = def.containerNameFallback
			end
			if not (container.getCustomName and container:getCustomName() == name) then
				container:setCustomName(name)
			end
		end)
	end
end

function USV.warmContainerCache(obj, kind)
	if not obj or not obj.getContainerCount then
		return
	end
	local count = obj:getContainerCount() or 0
	for i = 0, count - 1 do
		local c = obj:getContainerByIndex(i)
		if c then
			-- Re-apply capacity every warm: game may reset to tile ContainerCapacity.
			USV.applyContainer(c, kind)
		end
	end
	if count <= 0 and obj.getItemContainer then
		local c = obj:getItemContainer()
		if c then
			USV.applyContainer(c, kind)
		end
	end
end

function USV.applyObject(obj, force, kind)
	if not obj then
		return false
	end
	kind = kind or USV.getObjectKind(obj) or USV.resolveSpriteKind(USV.getSpriteNameFast(obj)) or "vault"

	-- Capacity apply for any legitimate USV sprite object (do NOT strip on failure).
	if not USV.isLegitimateUSVObject(obj) and not force then
		return false
	end

	USV.rememberUnlimitedParent(obj)

	-- Drop duplicated furniture items that ended up inside the vault/fridge.
	if USV.isAuthoritative() then
		pcall(function()
			USV.purgeNestedFurnitureItems(obj)
		end)
	end

	-- Client: local capacity/registry only — never write/transmit world or container ModData.
	if not USV.isAuthoritative() then
		USV.warmContainerCache(obj, kind)
		return true
	end

	-- Best-effort seal for owners (anti-dupe); never block capacity if this fails.
	local md0 = obj.getModData and obj:getModData() or nil
	if md0 and md0[USV.OWNER_FLAG] and USV.canBootstrapTrusted(obj) then
		pcall(function()
			USV.authorizeObject(obj, kind)
		end)
	end

	local md = obj.getModData and obj:getModData() or nil
	if (not force) and md and md[USV.APPLIED_FLAG] == true and md[USV.FLAG] == true then
		USV.warmContainerCache(obj, kind)
		return true
	end
	USV.markObject(obj, kind)
	USV.makeInvulnerable(obj)
	USV.applyObjectName(obj, kind)
	local count = 0
	if obj.getContainerCount then
		count = obj:getContainerCount() or 0
	end
	if count <= 0 then
		if obj.getItemContainer then
			local c = obj:getItemContainer()
			if c then
				USV.applyContainer(c, kind)
				if md then
					md[USV.APPLIED_FLAG] = true
					USV.transmitObjectModData(obj)
				end
				return true
			end
		end
		return false
	end
	for i = 0, count - 1 do
		local c = obj:getContainerByIndex(i)
		if c then
			USV.applyContainer(c, kind)
		end
	end
	if md then
		md[USV.APPLIED_FLAG] = true
		USV.transmitObjectModData(obj)
	end
	return true
end

function USV.scanSquare(square)
	if not square or not square.getObjects then
		return
	end
	local objects = square:getObjects()
	if not objects or not objects.size then
		return
	end
	for i = 0, objects:size() - 1 do
		local obj = objects:get(i)
		local kind = USV.resolveSpriteKind(USV.getSpriteNameFast(obj))
		if not kind and USV.isLegitimateUSVObject(obj) then
			kind = USV.getObjectKind(obj) or "vault"
		end
		if kind and USV.isLegitimateUSVObject(obj) then
			USV.applyObject(obj, true, kind)
		end
	end
end

function USV.getBuildCursorKind(cursor)
	if not cursor then
		return nil
	end
	local function matchName(name)
		if not name then
			return nil
		end
		local s = tostring(name)
		for kindId, def in pairs(USV.KINDS) do
			if string.find(s, def.entity, 1, true) then
				return kindId
			end
		end
		return nil
	end
	local kind = matchName(cursor.name)
	if kind then
		return kind
	end
	local info = cursor.objectInfo
	if not info then
		return nil
	end
	if info.getName then
		local ok, name = pcall(function()
			return info:getName()
		end)
		if ok then
			kind = matchName(name)
			if kind then
				return kind
			end
		end
	end
	if info.getScript then
		local ok, script = pcall(function()
			return info:getScript()
		end)
		if ok and script and script.getParent then
			local okP, parent = pcall(function()
				return script:getParent()
			end)
			if okP and parent and parent.getName then
				local okN, pname = pcall(function()
					return parent:getName()
				end)
				if okN then
					return matchName(pname)
				end
			end
		end
	end
	return nil
end

function USV.isUSVBuildCursor(cursor)
	return USV.getBuildCursorKind(cursor) ~= nil
end

function USV.removeBuiltObject(thumpable)
	if not thumpable then
		return
	end
	local sq = nil
	if thumpable.getSquare then
		local ok, s = pcall(function()
			return thumpable:getSquare()
		end)
		if ok then
			sq = s
		end
	end
	if thumpable.removeFromWorld then
		pcall(function()
			thumpable:removeFromWorld()
		end)
	end
	if thumpable.removeFromSquare then
		pcall(function()
			thumpable:removeFromSquare()
		end)
	end
	if sq and sq.transmitRemoveItemFromSquare then
		pcall(function()
			sq:transmitRemoveItemFromSquare(thumpable)
		end)
	end
	if thumpable.setSquare then
		pcall(function()
			thumpable:setSquare(nil)
		end)
	end
end

function USV.notifyAlreadyOwned(character, kind)
	if not character then
		return
	end
	local def = USV.getKindDef(kind) or USV.KINDS.vault
	local limit = USV.getMaxPerPlayer()
	local msg = getText(def.alreadyOwnedKey, tostring(limit))
	if not msg or string.find(msg, "IGUI_USV_", 1, true) then
		msg = string.format(def.alreadyOwnedFallback, limit)
	end
	if character.setHaloNote then
		pcall(function()
			character:setHaloNote(msg, 255, 80, 80, 400)
		end)
	elseif character.Say then
		pcall(function()
			character:Say(msg)
		end)
	end
end

function USV.notifySafehouseFull(character, kind)
	if not character then
		return
	end
	local def = USV.getKindDef(kind) or USV.KINDS.vault
	local limit = USV.getMaxPerSafehouse()
	local msg = getText(def.safehouseFullKey, tostring(limit))
	if not msg or string.find(msg, "IGUI_USV_", 1, true) then
		msg = string.format(def.safehouseFullFallback, limit)
	end
	if character.setHaloNote then
		pcall(function()
			character:setHaloNote(msg, 255, 80, 80, 400)
		end)
	elseif character.Say then
		pcall(function()
			character:Say(msg)
		end)
	end
end

function USV.notifyNeedSafehouse(character, kind)
	if not character then
		return
	end
	local def = USV.getKindDef(kind) or USV.KINDS.vault
	local msg = getText(def.needSafehouseKey)
	if not msg or string.find(msg, "IGUI_USV_", 1, true) then
		msg = def.needSafehouseFallback
	end
	if character.setHaloNote then
		pcall(function()
			character:setHaloNote(msg, 255, 80, 80, 400)
		end)
	elseif character.Say then
		pcall(function()
			character:Say(msg)
		end)
	end
end

function USV.notifyPlaceBlocked(character, kind, reason)
	if reason == "needSafehouse" then
		USV.notifyNeedSafehouse(character, kind)
	elseif reason == "safehouse" then
		USV.notifySafehouseFull(character, kind)
	else
		USV.notifyAlreadyOwned(character, kind)
	end
end

function USV.playerKnowsRecipe(player, recipeName)
	if not player or not recipeName then
		return false
	end
	if player.isRecipeActuallyKnown then
		local ok, known = pcall(function()
			return player:isRecipeActuallyKnown(recipeName)
		end)
		if ok and known then
			return true
		end
	end
	if player.isRecipeKnown then
		local ok, known = pcall(function()
			return player:isRecipeKnown(recipeName)
		end)
		if ok and known then
			return true
		end
	end
	return false
end

function USV_CanAddToMenu(param)
	if param and param.shouldShowAll then
		return true
	end
	if not param or not param.player then
		return true
	end
	if not USV.playerKnowsRecipe(param.player, "USV_InfiniteVault") then
		return false
	end
	return USV.playerBelowBuildLimit("vault", param.player)
end

function USV_CanAddToMenuFridge(param)
	if param and param.shouldShowAll then
		return true
	end
	if not param or not param.player then
		return true
	end
	if not USV.playerKnowsRecipe(param.player, "USV_InfiniteFridge") then
		return false
	end
	return USV.playerBelowBuildLimit("fridge", param.player)
end

function USV.installCapacityHooks()
	if rawget(_G, "UnlimitedStorageVault_CapacityHooksInstalled") then
		return
	end
	if not ItemContainer or not ItemContainer.class or not __classmetatables then
		USV.logError("ItemContainer metatable missing; capacity hooks skipped")
		return
	end
	local mt = __classmetatables[ItemContainer.class]
	if not mt or type(mt.__index) ~= "table" then
		USV.logError("ItemContainer.__index missing; capacity hooks skipped")
		return
	end

	local index = mt.__index
	local oldGetCapacity = index.getCapacity
	local oldGetEffectiveCapacity = index.getEffectiveCapacity
	local oldGetMaxWeight = index.getMaxWeight
	local oldHasRoomFor = index.hasRoomFor
	local oldGetCapacityWeight = index.getCapacityWeight
	local oldGetContentsWeight = index.getContentsWeight
	local oldGetWeight = index.getWeight
	local oldGetAvailableWeightCapacity = index.getAvailableWeightCapacity
	local oldGetFreeCapacity = index.getFreeCapacity
	local oldAddItem = index.AddItem
	local oldDoAddItem = index.DoAddItem
	local oldDoAddItemBlind = index.DoAddItemBlind
	local oldIsItemAllowed = index.isItemAllowed
	-- Keep raw Blind adder for forced transfers (bypasses Java capacity).
	USV._rawDoAddItemBlind = oldDoAddItemBlind
	USV._rawDoAddItem = oldDoAddItem
	USV._rawAddItem = oldAddItem

	local function isUnlimitedSafe(container)
		local ok, unlimited = pcall(USV.isUnlimitedContainer, container)
		return ok and unlimited
	end

	if type(oldGetCapacity) == "function" then
		index.getCapacity = function(self, ...)
			if isUnlimitedSafe(self) then
				return USV.CAPACITY
			end
			return oldGetCapacity(self, ...)
		end
	end
	if type(oldGetEffectiveCapacity) == "function" then
		index.getEffectiveCapacity = function(self, ...)
			if isUnlimitedSafe(self) then
				return USV.CAPACITY
			end
			return oldGetEffectiveCapacity(self, ...)
		end
	end
	if type(oldGetMaxWeight) == "function" then
		index.getMaxWeight = function(self, ...)
			if isUnlimitedSafe(self) then
				return USV.CAPACITY
			end
			return oldGetMaxWeight(self, ...)
		end
	end
	if type(oldHasRoomFor) == "function" then
		index.hasRoomFor = function(self, ...)
			if isUnlimitedSafe(self) then
				USV.ensureContainerCapacity(self)
				return true
			end
			return oldHasRoomFor(self, ...)
		end
	end
	if type(oldGetAvailableWeightCapacity) == "function" then
		index.getAvailableWeightCapacity = function(self, ...)
			if isUnlimitedSafe(self) then
				USV.ensureContainerCapacity(self)
				local used = 0
				if type(oldGetCapacityWeight) == "function" then
					local ok, w = pcall(oldGetCapacityWeight, self)
					if ok and type(w) == "number" then
						used = w
					end
				end
				local free = USV.CAPACITY - used
				if free < 0 then
					free = 0
				end
				return free
			end
			return oldGetAvailableWeightCapacity(self, ...)
		end
	end
	if type(oldGetFreeCapacity) == "function" then
		index.getFreeCapacity = function(self, ...)
			if isUnlimitedSafe(self) then
				USV.ensureContainerCapacity(self)
				local used = 0
				if type(oldGetCapacityWeight) == "function" then
					local ok, w = pcall(oldGetCapacityWeight, self)
					if ok and type(w) == "number" then
						used = w
					end
				end
				local free = USV.CAPACITY - used
				if free < 0 then
					free = 0
				end
				return free
			end
			return oldGetFreeCapacity(self, ...)
		end
	end
	-- Contents weight is left to vanilla so the UI shows e.g. 129.86 / 999999.
	-- Capacity / hasRoomFor / AddItem still enforce the high cap + bypass.

	-- Java AddItem checks Capacity (hard-capped at 100) vs real weight; USV often already exceeds 100.
	-- Always route InventoryItem adds through DoAddItemBlind for USV.
	if type(oldAddItem) == "function" then
		index.AddItem = function(self, first, ...)
			if isUnlimitedSafe(self) then
				USV.ensureContainerCapacity(self)
				local argc = select("#", ...)
				if first ~= nil and type(first) ~= "string" and argc == 0 and type(oldDoAddItemBlind) == "function" then
					local ok, result = pcall(oldDoAddItemBlind, self, first)
					if ok then
						return result
					end
				end
			end
			return oldAddItem(self, first, ...)
		end
	end
	if type(oldDoAddItem) == "function" then
		index.DoAddItem = function(self, first, ...)
			if isUnlimitedSafe(self) and first ~= nil and type(oldDoAddItemBlind) == "function" then
				USV.ensureContainerCapacity(self)
				local ok, result = pcall(oldDoAddItemBlind, self, first)
				if ok then
					return result
				end
			end
			return oldDoAddItem(self, first, ...)
		end
	end
	if type(oldDoAddItemBlind) == "function" then
		index.DoAddItemBlind = function(self, first, ...)
			if isUnlimitedSafe(self) then
				USV.ensureContainerCapacity(self)
			end
			return oldDoAddItemBlind(self, first, ...)
		end
	end
	if type(oldIsItemAllowed) == "function" then
		index.isItemAllowed = function(self, item, ...)
			if isUnlimitedSafe(self) then
				USV.ensureContainerCapacity(self)
				if USV.isUSVFurnitureItem(item) then
					return false
				end
			end
			return oldIsItemAllowed(self, item, ...)
		end
	end

	UnlimitedStorageVault_CapacityHooksInstalled = true
end

--- Pack a container reference for MP BlindTransfer (Java ItemTransaction rejects over-cap containers).
function USV.packContainerRef(container, character)
	if not container then
		return nil
	end
	if character and character.getInventory and container == character:getInventory() then
		return { kind = "player" }
	end
	local containing = nil
	pcall(function()
		containing = container.getContainingItem and container:getContainingItem() or nil
	end)
	if containing and containing.getID then
		return { kind = "bag", itemID = containing:getID() }
	end
	local parent = nil
	pcall(function()
		parent = container.getParent and container:getParent() or nil
	end)
	local sq = nil
	pcall(function()
		sq = container.getSourceGrid and container:getSourceGrid() or nil
	end)
	if not sq and parent and parent.getSquare then
		pcall(function()
			sq = parent:getSquare()
		end)
	end
	if not sq and parent and instanceof and instanceof(parent, "IsoGridSquare") then
		sq = parent
	end
	if not sq and container.getSquare then
		pcall(function()
			sq = container:getSquare()
		end)
	end
	if not sq and character and character.getSquare then
		pcall(function()
			sq = character:getSquare()
		end)
	end
	if not sq then
		return nil
	end
	local ctype = container.getType and container:getType() or ""
	if ctype == "floor" or (parent == nil and sq) then
		return {
			kind = "floor",
			x = sq:getX(),
			y = sq:getY(),
			z = sq:getZ(),
			type = "floor",
			index = 0,
		}
	end
	local index = 0
	if parent and parent.getContainerCount then
		local count = parent:getContainerCount() or 0
		for i = 0, count - 1 do
			if parent:getContainerByIndex(i) == container then
				index = i
				break
			end
		end
	end
	return {
		kind = "world",
		x = sq:getX(),
		y = sq:getY(),
		z = sq:getZ(),
		type = ctype,
		index = index,
	}
end

function USV.resolveContainerRef(ref, character)
	if not ref or not ref.kind then
		return nil
	end
	if ref.kind == "player" then
		return character and character.getInventory and character:getInventory() or nil
	end
	if ref.kind == "bag" and ref.itemID and character and character.getInventory then
		local inv = character:getInventory()
		local item = nil
		pcall(function()
			if inv.getItemById then
				item = inv:getItemById(ref.itemID)
			end
		end)
		if not item and inv.getItems then
			local items = inv:getItems()
			if items then
				for i = 0, items:size() - 1 do
					local it = items:get(i)
					if it and it.getID and it:getID() == ref.itemID then
						item = it
						break
					end
				end
			end
		end
		if item and item.getInventory then
			return item:getInventory()
		end
		return nil
	end
	if (ref.kind == "floor" or ref.type == "floor") and ref.x ~= nil and getCell then
		local sq = getCell():getGridSquare(ref.x, ref.y, ref.z or 0)
		if sq and sq.getFloorContainer then
			local fc = sq:getFloorContainer()
			if fc then
				return fc
			end
		end
	end
	if ref.kind == "world" and ref.x ~= nil and getCell then
		local sq = getCell():getGridSquare(ref.x, ref.y, ref.z or 0)
		if not sq then
			return nil
		end
		if ref.type == "floor" and sq.getFloorContainer then
			local fc = sq:getFloorContainer()
			if fc then
				return fc
			end
		end
		if sq.getObjects then
			local objects = sq:getObjects()
			if objects then
				for i = 0, objects:size() - 1 do
					local obj = objects:get(i)
					if obj and obj.getContainerCount then
						local count = obj:getContainerCount() or 0
						if count > 0 then
							local idx = ref.index or 0
							local c = obj:getContainerByIndex(idx)
							if c then
								local ctype = c.getType and c:getType() or ""
								if not ref.type or ref.type == "" or ctype == ref.type then
									return c
								end
							end
							for ci = 0, count - 1 do
								local c2 = obj:getContainerByIndex(ci)
								if c2 and c2.getType and c2:getType() == ref.type then
									return c2
								end
							end
						end
					elseif obj and obj.getItemContainer then
						local c = obj:getItemContainer()
						if c then
							local ctype = c.getType and c:getType() or ""
							if not ref.type or ref.type == "" or ctype == ref.type then
								return c
							end
						end
					end
				end
			end
		end
		if sq.getFloorContainer then
			return sq:getFloorContainer()
		end
		return nil
	end
	return nil
end

--- Server/SP Blind transfer — bypasses Java capacity hard-cap (100).
function USV.doBlindTransfer(character, item, srcContainer, destContainer)
	if not item or not destContainer then
		return false
	end
	if not USV.isUnlimitedContainer(destContainer) then
		return false
	end
	if USV.isUSVFurnitureItem(item) then
		return false
	end
	USV.ensureContainerCapacity(destContainer)
	local srcType = srcContainer and srcContainer.getType and srcContainer:getType() or ""
	if srcType == "TradeUI" then
		return false
	end
	if destContainer.isItemAllowed and not destContainer:isItemAllowed(item) then
		return false
	end
	local containsItem = false
	if srcContainer then
		pcall(function()
			containsItem = srcContainer:contains(item)
		end)
	end
	if not containsItem and srcType ~= "floor" and not (item.getWorldItem and item:getWorldItem() ~= nil) then
		return false
	end

	-- Handle floor world inventory object removal
	local worldItem = nil
	pcall(function()
		worldItem = item.getWorldItem and item:getWorldItem() or nil
	end)
	local sq = nil
	if worldItem then
		pcall(function()
			sq = worldItem.getSquare and worldItem:getSquare() or nil
		end)
	end
	if not sq and srcContainer and srcContainer.getSourceGrid then
		pcall(function()
			sq = srcContainer:getSourceGrid()
		end)
	end
	if not sq and srcContainer and srcContainer.getSquare then
		pcall(function()
			sq = srcContainer:getSquare()
		end)
	end
	if not sq and srcContainer and srcContainer.getParent then
		pcall(function()
			local p = srcContainer:getParent()
			if p and p.getSquare then
				sq = p:getSquare()
			elseif p and instanceof and instanceof(p, "IsoGridSquare") then
				sq = p
			end
		end)
	end
	if not sq and character and character.getSquare then
		pcall(function()
			sq = character:getSquare()
		end)
	end

	if worldItem and sq then
		if isServer and isServer() and sq.transmitRemoveItemFromSquare then
			pcall(function()
				sq:transmitRemoveItemFromSquare(worldItem)
			end)
		end
		if sq.removeWorldObject then
			pcall(function()
				sq:removeWorldObject(worldItem)
			end)
		end
		if worldItem.removeFromSquare then
			pcall(function()
				worldItem:removeFromSquare()
			end)
		end
	end
	if item.setWorldItem then
		pcall(function()
			item:setWorldItem(nil)
		end)
	end

	if srcContainer and srcType ~= "floor" then
		pcall(function()
			srcContainer:DoRemoveItem(item)
		end)
		if isServer and isServer() and sendRemoveItemFromContainer then
			pcall(function()
				sendRemoveItemFromContainer(srcContainer, item)
			end)
		end
	elseif sq and sq.getFloorContainer and sq:getFloorContainer() then
		pcall(function()
			sq:getFloorContainer():DoRemoveItem(item)
		end)
	end

	local added = false
	if type(USV._rawDoAddItemBlind) == "function" then
		local ok, res = pcall(USV._rawDoAddItemBlind, destContainer, item)
		added = ok and res ~= nil
	end
	if not added then
		pcall(function()
			destContainer:DoAddItemBlind(item)
			added = true
		end)
	end
	if isServer and isServer() and added and sendAddItemToContainer then
		pcall(function()
			sendAddItemToContainer(destContainer, item)
		end)
	end
	pcall(function()
		if srcContainer and srcContainer.setDrawDirty then
			srcContainer:setDrawDirty(true)
			srcContainer:setHasBeenLooted(true)
		end
		if destContainer.setDrawDirty then
			destContainer:setDrawDirty(true)
		end
	end)
	if ISInventoryPage then
		ISInventoryPage.renderDirty = true
	end
	return added
end

function USV.packBlindTransferArgs(character, item, srcContainer, destContainer)
	if not item or not item.getID then
		return nil
	end
	return {
		itemID = item:getID(),
		src = USV.packContainerRef(srcContainer, character),
		dest = USV.packContainerRef(destContainer, character),
	}
end

--- Client MP: request server BlindTransfer.
--- Dedicated clients must NOT move the item locally — that causes "Dupe item ID"
--- when sendAddItemToContainer sync arrives. Listen-server host applies locally.
function USV.clientBlindTransferNow(character, item, srcContainer, destContainer, action)
	if not character or not item or not srcContainer or not destContainer then
		return false
	end
	if not USV.isUnlimitedContainer(destContainer) then
		return false
	end
	if USV.isUSVFurnitureItem(item) then
		return false
	end
	local itemID = nil
	pcall(function()
		itemID = item.getID and item:getID() or nil
	end)
	if action and itemID ~= nil then
		action.usvSentIDs = action.usvSentIDs or {}
		if action.usvSentIDs[itemID] then
			return true
		end
		action.usvSentIDs[itemID] = true
	end
	local args = USV.packBlindTransferArgs(character, item, srcContainer, destContainer)
	if args and sendClientCommand then
		sendClientCommand(character, "USV", "BlindTransfer", args)
	end
	-- Host / SP authority shares world objects with the client view.
	if isServer and isServer() then
		return USV.doBlindTransfer(character, item, srcContainer, destContainer)
	end
	return true
end

--- Vanilla-like transfer validation for USV destinations (no weight / item-count caps).
function USV.transferIsValidUnlimited(self)
	if not self.item or not self.destContainer then
		return false
	end
	if not self.srcContainer then
		local wi = self.item.getWorldItem and self.item:getWorldItem() or nil
		local sq = wi and wi.getSquare and wi:getSquare() or (self.character and self.character.getSquare and self.character:getSquare() or nil)
		if sq and sq.getFloorContainer then
			self.srcContainer = sq:getFloorContainer()
		end
	end
	if not self.srcContainer then
		return false
	end
	USV.ensureContainerCapacity(self.destContainer)
	self.dontAdd = false
	local srcType = self.srcContainer.getType and self.srcContainer:getType() or ""
	local containsItem = false
	pcall(function()
		containsItem = self.srcContainer:contains(self.item)
	end)
	if not containsItem then
		if srcType == "floor" or (self.item.getWorldItem and self.item:getWorldItem() ~= nil) then
			containsItem = true
		end
	end
	if not containsItem then
		self.dontAdd = true
		return true
	end
	if isClient and isClient() then
		-- Skip ItemNumbersLimitPerContainer and hasRoomFor (Java cap is 100; weight may already exceed it).
		-- Also skip isItemTransactionConsistent — we use BlindTransfer instead of ItemTransaction.
		return true
	end
	if self.destContainer.isExistYet and self.srcContainer.isExistYet then
		if (not self.destContainer:isExistYet()) or (not self.srcContainer:isExistYet()) then
			return false
		end
	end
	if self.isAlreadyTransferred and self:isAlreadyTransferred(self.item) then
		return true
	end
	if ISTradingUI and ISTradingUI.instance and ISTradingUI.instance:isVisible() then
		return false
	end
	if self.srcContainer == self.destContainer then
		return false
	end
	if self.item.isFavorite and self.item:isFavorite()
		and self.destContainer.isInCharacterInventory
		and not self.destContainer:isInCharacterInventory(self.character) then
		return false
	end
	if self.srcContainer.isRemoveItemAllowed and not self.srcContainer:isRemoveItemAllowed(self.item) then
		return false
	end
	if self.destContainer.isItemAllowed and not self.destContainer:isItemAllowed(self.item) then
		return false
	end
	if self.destContainer.isInside and self.destContainer:isInside(self.item) then
		return false
	end
	return true
end

function USV.installTransferHooks()
	-- Auto-resolve srcContainer for floor items in ISInventoryTransferUtil
	if ISInventoryTransferUtil and type(ISInventoryTransferUtil.newInventoryTransferAction) == "function"
		and not ISInventoryTransferUtil._USV_Wrapped then
		local prevUtil = ISInventoryTransferUtil.newInventoryTransferAction
		ISInventoryTransferUtil.newInventoryTransferAction = function(character, item, srcContainer, destContainer, time)
			local src = srcContainer
			if not src and item then
				local wi = item.getWorldItem and item:getWorldItem() or nil
				local sq = wi and wi.getSquare and wi:getSquare() or (character and character.getSquare and character:getSquare() or nil)
				if sq and sq.getFloorContainer then
					src = sq:getFloorContainer()
				end
			end
			return prevUtil(character, item, src, destContainer, time)
		end
		ISInventoryTransferUtil._USV_Wrapped = true
	end

	-- Auto-resolve srcContainer for floor items in ISInventoryTransferAction.new
	if ISInventoryTransferAction and type(ISInventoryTransferAction.new) == "function"
		and not ISInventoryTransferAction._USV_NewWrapped then
		local prevNewAction = ISInventoryTransferAction.new
		ISInventoryTransferAction.new = function(self, character, item, srcContainer, destContainer, time)
			local src = srcContainer
			if not src and item then
				local wi = item.getWorldItem and item:getWorldItem() or nil
				local sq = wi and wi.getSquare and wi:getSquare() or (character and character.getSquare and character:getSquare() or nil)
				if sq and sq.getFloorContainer then
					src = sq:getFloorContainer()
				end
			end
			return prevNewAction(self, character, item, src, destContainer, time)
		end
		ISInventoryTransferAction._USV_NewWrapped = true
	end

	-- Re-wrap whatever is currently installed (other mods may replace isValid).
	if ISInventoryTransferAction and type(ISInventoryTransferAction.isValid) == "function" then
		if not ISInventoryTransferAction._USV_IsValidWrapped then
			local prev = ISInventoryTransferAction.isValid
			ISInventoryTransferAction.isValid = function(self)
				if self and self.destContainer and USV.isUnlimitedContainer(self.destContainer) then
					USV.ensureContainerCapacity(self.destContainer)
					return USV.transferIsValidUnlimited(self)
				end
				return prev(self)
			end
			ISInventoryTransferAction._USV_IsValidWrapped = true
		end
	end
	-- MP client: Java ItemTransaction rejects when capacityWeight > 100. Use BlindTransfer command instead.
	if ISInventoryTransferAction and type(ISInventoryTransferAction.start) == "function" then
		if not ISInventoryTransferAction._USV_StartWrapped then
			local prevStart = ISInventoryTransferAction.start
			ISInventoryTransferAction.start = function(self)
				if isClient and isClient() and self and self.destContainer and USV.isUnlimitedContainer(self.destContainer)
					and self.item and self.srcContainer and self.character then
					if self.isAlreadyTransferred and self:isAlreadyTransferred(self.item) then
						self.selectedContainer = nil
						if self.action and self.action.setTime then
							self.action:setTime(0)
						end
						return
					end
					if self.dontAdd then
						self.selectedContainer = nil
						if self.action and self.action.setTime then
							self.action:setTime(0)
						end
						return
					end
					-- Do not BlindTransfer here: perform() runs checkQueueList() first and drains the full bulk queue.
					self.usvBlindDone = true
					self.started = true
					self.transactionId = -1 -- never 0: update() treats unknown ids as rejected
					pcall(function()
						if self.playSourceContainerOpenSound then
							self:playSourceContainerOpenSound()
						end
						if self.playDestContainerOpenSound then
							self:playDestContainerOpenSound()
						end
						if self.startActionAnim then
							self:startActionAnim()
						end
					end)
					if self.action then
						if self.action.setWaitForFinished then
							self.action:setWaitForFinished(false)
						end
						if self.action.setTime then
							self.action:setTime(1)
						end
					end
					return
				end
				return prevStart(self)
			end
			ISInventoryTransferAction._USV_StartWrapped = true
		end
	end
	-- Complete BlindTransfer actions without waiting on ItemTransaction (id 0/-1 would forceStop).
	if ISInventoryTransferAction and type(ISInventoryTransferAction.update) == "function" then
		if not ISInventoryTransferAction._USV_UpdateWrapped then
			local prevUpdate = ISInventoryTransferAction.update
			ISInventoryTransferAction.update = function(self)
				if self and self.destContainer and USV.isUnlimitedContainer(self.destContainer) then
					if self.usvBlindDone and isClient and isClient() then
						if not self.usvBlindForced then
							self.usvBlindForced = true
							pcall(function()
								self:forceComplete()
							end)
						end
						return
					end
					-- In SP / non-client: prevent vanilla from forceStop() on floor items when contains() is false.
					local srcType = self.srcContainer and self.srcContainer.getType and self.srcContainer:getType() or ""
					if srcType == "floor" or (self.item and self.item.getWorldItem and self.item:getWorldItem() ~= nil) then
						if self.selectedContainer then
							if self.selectedContainer:getParent() and not self.character:isSittingOnFurniture() then
								self.character:faceThisObject(self.selectedContainer:getParent())
							end
							if self.character:shouldBeTurning() and getPlayerLoot then
								getPlayerLoot(self.character:getPlayerNum()):setForceSelectedContainer(self.selectedContainer)
							end
							if getPlayerLoot then
								getPlayerLoot(self.character:getPlayerNum()):selectButtonForContainer(self.selectedContainer)
							end
						end
						if self.item and self.item.setJobDelta and self.action and self.action.getJobDelta then
							self.item:setJobDelta(self.action:getJobDelta())
						end
						if self.character and self.character.setMetabolicTarget then
							self.character:setMetabolicTarget(Metabolics.LightWork)
						end
						return
					end
				end
				return prevUpdate(self)
			end
			ISInventoryTransferAction._USV_UpdateWrapped = true
		end
	end
	-- Drain the full merged queue in one perform (vanilla continues via ItemTransaction; we cannot).
	if ISInventoryTransferAction and type(ISInventoryTransferAction.perform) == "function" then
		if not ISInventoryTransferAction._USV_PerformWrapped then
			local prevPerform = ISInventoryTransferAction.perform
			ISInventoryTransferAction.perform = function(self)
				if not (isClient and isClient() and self and self.usvBlindDone
					and self.destContainer and USV.isUnlimitedContainer(self.destContainer)) then
					return prevPerform(self)
				end
				self:checkQueueList()
				if self.item and self.item.setJobDelta then
					self.item:setJobDelta(0.0)
				end
				if self.selectedContainer then
					getPlayerLoot(self.character:getPlayerNum()):selectButtonForContainer(self.selectedContainer)
				end
				-- Transfer every queued item now (multi-select / merged same-type batches).
				while self.queueList and #self.queueList > 0 do
					local queuedItem = table.remove(self.queueList, 1)
					if queuedItem and queuedItem.items then
						for _, item in ipairs(queuedItem.items) do
							self.item = item
							if self:isValid() then
								local srcType = self.srcContainer and self.srcContainer.getType and self.srcContainer:getType() or ""
								local hasItem = self.srcContainer and self.srcContainer:contains(item)
								if not hasItem and (srcType == "floor" or (item.getWorldItem and item:getWorldItem() ~= nil)) then
									hasItem = true
								end
								if hasItem then
									USV.clientBlindTransferNow(self.character, item, self.srcContainer, self.destContainer, self)
								end
								if self.playTransferCompleteSound then
									pcall(function()
										self:playTransferCompleteSound(item)
									end)
								end
							else
								self.queueList = {}
								break
							end
						end
					end
				end
				if self.playSourceContainerCloseSound then
					self:playSourceContainerCloseSound()
				end
				if self.playDestContainerCloseSound then
					self:playDestContainerCloseSound()
				end
				if self.stopLoopingSound then
					self:stopLoopingSound()
				end
				if self.action then
					if self.action.stopTimedActionAnim then
						self.action:stopTimedActionAnim()
					end
					if self.action.setLoopedAction then
						self.action:setLoopedAction(false)
					end
					if self.action.setWaitForFinished then
						self.action:setWaitForFinished(false)
					end
				end
				if self.onCompleteFunc then
					local args = self.onCompleteArgs
					self.onCompleteFunc(args[1], args[2], args[3], args[4], args[5], args[6], args[7], args[8])
				end
				-- Do NOT call ISBaseTimedAction.perform(self): Bandits wraps it and fires
				-- OnTimedActionPerform → BanditActionInterceptor, which NPEs on fridge/freezer
				-- when square:getBuilding() is nil (outdoor / no building def).
				pcall(function()
					ISTimedActionQueue.getTimedActionQueue(self.character):onCompleted(self)
				end)
				pcall(function()
					if ISLogSystem and ISLogSystem.logAction then
						ISLogSystem.logAction(self)
					end
				end)
				pcall(function()
					if self.character and self.character.setIsFarming then
						self.character:setIsFarming(false)
					end
				end)
				self.started = false
				if ISInventoryPage then
					ISInventoryPage.renderDirty = true
				end
			end
			ISInventoryTransferAction._USV_PerformWrapped = true
		end
	end
	-- Host/SP: force Blind add when completing a transfer into USV (Java capacity max 100).
	if ISInventoryTransferAction and type(ISInventoryTransferAction.transferItem) == "function" then
		if not ISInventoryTransferAction._USV_TransferItemWrapped then
			local prevTI = ISInventoryTransferAction.transferItem
			ISInventoryTransferAction.transferItem = function(self, item)
				if self and self.usvBlindDone then
					if self.playTransferCompleteSound then
						pcall(function()
							self:playTransferCompleteSound(item)
						end)
					end
					return
				end
				if self and self.destContainer and USV.isUnlimitedContainer(self.destContainer)
					and not (isClient and isClient()) then
					USV.doBlindTransfer(self.character, item, self.srcContainer, self.destContainer)
					return
				end
				return prevTI(self, item)
			end
			ISInventoryTransferAction._USV_TransferItemWrapped = true
		end
	end
	if ISTransferAction and type(ISTransferAction.transferItem) == "function" then
		if not ISTransferAction._USV_TransferWrapped then
			local prevTransfer = ISTransferAction.transferItem
			ISTransferAction.transferItem = function(self, character, item, srcContainer, destContainer, dropSquare)
				if not (destContainer and item and USV.isUnlimitedContainer(destContainer)) then
					return prevTransfer(self, character, item, srcContainer, destContainer, dropSquare)
				end
				-- Trade paths keep vanilla.
				local destType = destContainer.getType and destContainer:getType() or ""
				local srcType = srcContainer and srcContainer.getType and srcContainer:getType() or ""
				if destType == "TradeUI" or srcType == "TradeUI" then
					USV.ensureContainerCapacity(destContainer)
					return prevTransfer(self, character, item, srcContainer, destContainer, dropSquare)
				end
				USV.ensureContainerCapacity(destContainer)
				-- If transferring from floor/world item, remove world item first
				local worldItem = nil
				if item.getWorldItem then
					pcall(function()
						worldItem = item:getWorldItem()
					end)
				end
				if worldItem then
					local sq = nil
					pcall(function()
						sq = worldItem.getSquare and worldItem:getSquare() or nil
					end)
					if not sq and srcContainer and srcContainer.getSourceGrid then
						pcall(function()
							sq = srcContainer:getSourceGrid()
						end)
					end
					if sq then
						if isServer and isServer() and sq.transmitRemoveItemFromSquare then
							pcall(function()
								sq:transmitRemoveItemFromSquare(worldItem)
							end)
						end
						if sq.removeWorldObject then
							pcall(function()
								sq:removeWorldObject(worldItem)
							end)
						end
						if worldItem.removeFromSquare then
							pcall(function()
								worldItem:removeFromSquare()
							end)
						end
					end
					if item.setWorldItem then
						pcall(function()
							item:setWorldItem(nil)
						end)
					end
				end
				if srcContainer and srcType ~= "TradeUI" then
					pcall(function()
						srcContainer:DoRemoveItem(item)
					end)
					if isServer and isServer() and sendRemoveItemFromContainer then
						pcall(function()
							sendRemoveItemFromContainer(srcContainer, item)
						end)
					end
				end
				local added = nil
				if type(USV._rawDoAddItemBlind) == "function" then
					local ok, res = pcall(USV._rawDoAddItemBlind, destContainer, item)
					if ok then
						added = res
					end
				end
				if not added then
					pcall(function()
						destContainer:DoAddItemBlind(item)
						added = item
					end)
				end
				if isServer and isServer() and added and sendAddItemToContainer then
					pcall(function()
						sendAddItemToContainer(destContainer, item)
					end)
				end
				if character and character.getInventory and character:getInventory() ~= destContainer then
					pcall(function()
						ISTransferAction:removeItemOnCharacter(character, item)
					end)
				end
				pcall(function()
					if srcContainer and srcContainer.setDrawDirty then
						srcContainer:setDrawDirty(true)
						srcContainer:setHasBeenLooted(true)
					end
					if destContainer.setDrawDirty then
						destContainer:setDrawDirty(true)
					end
				end)
				if ISInventoryPage then
					ISInventoryPage.renderDirty = true
				end
				return added or item
			end
			ISTransferAction._USV_TransferWrapped = true
		end
	end
	if type(javaTransferItems) == "function" and not rawget(_G, "UnlimitedStorageVault_JavaTransferHooked") then
		local prevJava = javaTransferItems
		javaTransferItems = function(character, item, srcContainer, destContainer)
			local dest = destContainer
			if dest and instanceof and instanceof(dest, "InventoryContainer") and dest.getInventory then
				dest = dest:getInventory()
			end
			if dest and USV.isUnlimitedContainer(dest) then
				USV.ensureContainerCapacity(dest)
				-- Bypass vanilla getCapacity/hasRoomFor gate (Java field may be 100 while weight > 100).
				if ISTimedActionQueue and ISInventoryTransferAction then
					ISTimedActionQueue.add(ISInventoryTransferAction:new(character, item, srcContainer, dest, 10))
					return
				end
			end
			return prevJava(character, item, srcContainer, destContainer)
		end
		UnlimitedStorageVault_JavaTransferHooked = true
	end
	if ISInventoryPaneContextMenu and type(ISInventoryPaneContextMenu.hasRoomForAny) == "function" then
		if not ISInventoryPaneContextMenu._USV_HasRoomForAnyWrapped then
			local prevRoom = ISInventoryPaneContextMenu.hasRoomForAny
			ISInventoryPaneContextMenu.hasRoomForAny = function(playerObj, container, items)
				local dest = container
				if dest and instanceof and instanceof(dest, "InventoryContainer") and dest.getInventory then
					dest = dest:getInventory()
				end
				if dest and USV.isUnlimitedContainer(dest) then
					USV.ensureContainerCapacity(dest)
					return true
				end
				return prevRoom(playerObj, container, items)
			end
			ISInventoryPaneContextMenu._USV_HasRoomForAnyWrapped = true
		end
	end
	if ISInventoryPane and type(ISInventoryPane.canPutIn) == "function" and not ISInventoryPane._USV_CanPutInWrapped then
		local prevCanPutIn = ISInventoryPane.canPutIn
		ISInventoryPane.canPutIn = function(self)
			if self.inventory and USV.isUnlimitedContainer(self.inventory) then
				USV.ensureContainerCapacity(self.inventory)
				local playerObj = getSpecificPlayer(self.player)
				local dragging = ISInventoryPane.getActualItems(ISMouseDrag.dragging)
				if not dragging or #dragging == 0 then
					return true
				end
				for _, v in ipairs(dragging) do
					local itemOK = true
					if v.isFavorite and v:isFavorite() and not self.inventory:isInCharacterInventory(playerObj) then
						itemOK = false
					end
					if self.inventory.isInside and self.inventory:isInside(v) then
						itemOK = false
					end
					if v.getContainer and v:getContainer() == self.inventory then
						itemOK = false
					end
					if self.inventory.isItemAllowed and not self.inventory:isItemAllowed(v) then
						itemOK = false
					end
					if itemOK then
						return true
					end
				end
				return false
			end
			return prevCanPutIn(self)
		end
		ISInventoryPane._USV_CanPutInWrapped = true
	end
	if ISInventoryPage and type(ISInventoryPage.canPutIn) == "function" and not ISInventoryPage._USV_CanPutInWrapped then
		local prevPageCanPutIn = ISInventoryPage.canPutIn
		ISInventoryPage.canPutIn = function(self)
			local container = self.mouseOverButton and self.mouseOverButton.inventory or nil
			if container and USV.isUnlimitedContainer(container) then
				USV.ensureContainerCapacity(container)
				local playerObj = getSpecificPlayer(self.player)
				local dragging = ISInventoryPane.getActualItems(ISMouseDrag.dragging)
				if not dragging or #dragging == 0 then
					return true
				end
				for _, item in ipairs(dragging) do
					local itemOK = true
					if item.isFavorite and item:isFavorite() and not container:isInCharacterInventory(playerObj) then
						itemOK = false
					end
					if container.isInside and container:isInside(item) then
						itemOK = false
					end
					if item.getContainer and item:getContainer() == container then
						itemOK = false
					end
					if container.isItemAllowed and not container:isItemAllowed(item) then
						itemOK = false
					end
					if itemOK then
						return true
					end
				end
				return false
			end
			return prevPageCanPutIn(self)
		end
		ISInventoryPage._USV_CanPutInWrapped = true
	end
	if ISInventoryPane and type(ISInventoryPane.onMouseUp) == "function" and not ISInventoryPane._USV_OnMouseUpWrapped then
		local prevMouseUp = ISInventoryPane.onMouseUp
		ISInventoryPane.onMouseUp = function(self, x, y)
			if self.player == 0 and self.inventory and USV.isUnlimitedContainer(self.inventory)
				and ISMouseDrag.dragging ~= nil and ISMouseDrag.draggingFocus ~= self and ISMouseDrag.draggingFocus ~= nil
				and getCore():getGameMode() ~= "Tutorial" then
				USV.ensureContainerCapacity(self.inventory)
				if self:canPutIn() then
					local playerObj = getSpecificPlayer(self.player)
					local doWalk = true
					local items = {}
					local dragging = ISInventoryPane.getActualItems(ISMouseDrag.dragging)
					for _, v in ipairs(dragging) do
						local transfer = not self.inventory:isInside(v)
						if v.isFavorite and v:isFavorite() and not self.inventory:isInCharacterInventory(playerObj) then
							transfer = false
						end
						if transfer then
							if doWalk then
								if not luautils.walkToContainer(self.inventory, self.player) then
									break
								end
								doWalk = false
							end
							table.insert(items, v)
						end
					end
					self:transferItemsByWeight(items, self.inventory)
					self.selected = {}
					if getPlayerLoot and getPlayerLoot(self.player) and getPlayerLoot(self.player).inventoryPane then
						getPlayerLoot(self.player).inventoryPane.selected = {}
					end
					if getPlayerInventory and getPlayerInventory(self.player) and getPlayerInventory(self.player).inventoryPane then
						getPlayerInventory(self.player).inventoryPane.selected = {}
					end
				end
				if ISMouseDrag.draggingFocus then
					ISMouseDrag.draggingFocus:onMouseUp(0, 0)
				end
				ISMouseDrag.draggingFocus = nil
				ISMouseDrag.dragging = nil
				return
			end
			return prevMouseUp(self, x, y)
		end
		ISInventoryPane._USV_OnMouseUpWrapped = true
	end
	if ISInventoryPage and type(ISInventoryPage.dropItemsInContainer) == "function" and not ISInventoryPage._USV_DropItemsWrapped then
		local prevDrop = ISInventoryPage.dropItemsInContainer
		ISInventoryPage.dropItemsInContainer = function(self, button)
			if button and button.inventory and USV.isUnlimitedContainer(button.inventory)
				and self.player == 0 and ISMouseDrag.dragging ~= nil
				and getCore():getGameMode() ~= "Tutorial" then
				USV.ensureContainerCapacity(button.inventory)
				if self:canPutIn() then
					local doWalk = true
					local items = {}
					if self.inventoryPane and self.inventoryPane.draggedItems then
						self.inventoryPane.draggedItems:reset()
						self.inventoryPane.draggedItems:update()
					end
					local dragging = ISInventoryPane.getActualItems(ISMouseDrag.dragging)
					for _, v in ipairs(dragging) do
						local bad = false
						if self.inventoryPane and self.inventoryPane.draggedItems and self.inventoryPane.draggedItems:cannotDropItem(v) then
							bad = true
						end
						if not bad then
							if doWalk then
								if not luautils.walkToContainer(button.inventory, self.player) then
									break
								end
								doWalk = false
							end
							table.insert(items, v)
						end
					end
					if self.inventoryPane then
						self.inventoryPane:transferItemsByWeight(items, button.inventory)
						self.inventoryPane.selected = {}
					end
					if getPlayerLoot and getPlayerLoot(self.player) and getPlayerLoot(self.player).inventoryPane then
						getPlayerLoot(self.player).inventoryPane.selected = {}
					end
					if getPlayerInventory and getPlayerInventory(self.player) and getPlayerInventory(self.player).inventoryPane then
						getPlayerInventory(self.player).inventoryPane.selected = {}
					end
				end
				if ISMouseDrag.draggingFocus then
					ISMouseDrag.draggingFocus:onMouseUp(0, 0)
					ISMouseDrag.draggingFocus = nil
					ISMouseDrag.dragging = nil
				end
				self:refreshWeight()
				self:updateItemCount()
				return true
			end
			return prevDrop(self, button)
		end
		ISInventoryPage._USV_DropItemsWrapped = true
	end
	if ISInventoryPane and type(ISInventoryPane.transferItemsByWeight) == "function" and not ISInventoryPane._USV_TransferItemsByWeightWrapped then
		local prevTransferWeight = ISInventoryPane.transferItemsByWeight
		ISInventoryPane.transferItemsByWeight = function(self, items, container)
			if container and USV.isUnlimitedContainer(container) then
				USV.ensureContainerCapacity(container)
				local playerObj = getSpecificPlayer(self.player)
				self:sortItemsByTypeAndWeight(items)
				for _, item in ipairs(items) do
					if container:isItemAllowed(item) then
						local src = item:getContainer()
						if not src then
							local wi = item.getWorldItem and item:getWorldItem() or nil
							local sq = wi and wi.getSquare and wi:getSquare() or (playerObj and playerObj.getSquare and playerObj:getSquare() or nil)
							if sq and sq.getFloorContainer then
								src = sq:getFloorContainer()
							end
						end
						ISTimedActionQueue.add(ISInventoryTransferUtil.newInventoryTransferAction(playerObj, item, src, container))
					end
				end
				return
			end
			return prevTransferWeight(self, items, container)
		end
		ISInventoryPane._USV_TransferItemsByWeightWrapped = true
	end
	if ISInventoryPage and type(ISInventoryPage.loadWeight) == "function" then
		if not ISInventoryPage._USV_LoadWeightWrapped then
			-- Do not force 0; vanilla loadWeight shows real used weight against USV.CAPACITY.
			ISInventoryPage._USV_LoadWeightWrapped = true
		end
	end
	-- Drag UI greys out items via hasRoomFor weight accumulation; force-allow for USV.
	if DraggedItems and type(DraggedItems.update) == "function" then
		if not DraggedItems._USV_UpdateWrapped then
			local prevDrag = DraggedItems.update
			DraggedItems.update = function(self, ...)
				prevDrag(self, ...)
				local container = self.mouseOverContainer
				if not container or not self.items or not USV.isUnlimitedContainer(container) then
					return
				end
				local playerObj = nil
				if self.inventoryPane and self.inventoryPane.player ~= nil and getSpecificPlayer then
					playerObj = getSpecificPlayer(self.inventoryPane.player)
				end
				table.wipe(self.itemNotOK)
				local inInv = playerObj and container.isInCharacterInventory and container:isInCharacterInventory(playerObj)
				for _, item in ipairs(self.items) do
					local bad = false
					if container.isInside and container:isInside(item) then
						bad = true
					elseif item.getContainer and item:getContainer() == container then
						bad = true
					elseif item.isFavorite and item:isFavorite() and not inInv then
						bad = true
					elseif container.isItemAllowed and not container:isItemAllowed(item) then
						bad = true
					end
					if bad then
						self.itemNotOK[item] = true
					end
				end
			end
			DraggedItems._USV_UpdateWrapped = true
		end
	end
end

--- Force re-wrap transfer hooks after other mods (call from OnGameStart).
function USV.reinstallTransferHooks()
	if ISInventoryTransferAction then
		ISInventoryTransferAction._USV_NewWrapped = nil
		ISInventoryTransferAction._USV_IsValidWrapped = nil
		ISInventoryTransferAction._USV_TransferItemWrapped = nil
		ISInventoryTransferAction._USV_StartWrapped = nil
		ISInventoryTransferAction._USV_UpdateWrapped = nil
		ISInventoryTransferAction._USV_PerformWrapped = nil
	end
	if ISInventoryTransferUtil then
		ISInventoryTransferUtil._USV_Wrapped = nil
	end
	if ISTransferAction then
		ISTransferAction._USV_TransferWrapped = nil
	end
	if ISInventoryPaneContextMenu then
		ISInventoryPaneContextMenu._USV_HasRoomForAnyWrapped = nil
	end
	if ISInventoryPane then
		ISInventoryPane._USV_CanPutInWrapped = nil
		ISInventoryPane._USV_OnMouseUpWrapped = nil
		ISInventoryPane._USV_TransferItemsByWeightWrapped = nil
	end
	if ISInventoryPage then
		ISInventoryPage._USV_LoadWeightWrapped = nil
		ISInventoryPage._USV_CanPutInWrapped = nil
		ISInventoryPage._USV_DropItemsWrapped = nil
	end
	if DraggedItems then
		DraggedItems._USV_UpdateWrapped = nil
	end
	USV.installTransferHooks()
end

--- Allow picking up / relocating USV furniture even when containers have items or appearance changed.
function USV.installMoveableHooks()
	if rawget(_G, "UnlimitedStorageVault_MoveableHooksInstalled") then
		return true
	end
	if not ISMoveableSpriteProps or type(ISMoveableSpriteProps.canPickUpMoveableInternal) ~= "function" then
		return false
	end

	-- No sprite-only override in new(): appearance sprites include vanilla fridges/lockers.
	-- Real USV objects are handled in fromObject below, which checks the object itself.

	if type(ISMoveableSpriteProps.fromObject) == "function" and not ISMoveableSpriteProps._USV_FromObjectWrapped then
		local prevFromObject = ISMoveableSpriteProps.fromObject
		ISMoveableSpriteProps.fromObject = function(obj)
			local s = prevFromObject(obj)
			if s and obj and USV.isUSVMoveableObject(obj, s.spriteName) then
				s.isMoveable = true
				s.pickUpTool = nil
				s.placeTool = nil
				s.canBreak = false
				s.pickUpLevel = 0
				s.weight = USV.MOVEABLE_CARRY_WEIGHT or 1
				s.rawWeight = (USV.MOVEABLE_CARRY_WEIGHT or 1) * 10
			end
			return s
		end
		ISMoveableSpriteProps._USV_FromObjectWrapped = true
	end

	if type(ISMoveableSpriteProps.hasRequiredSkill) == "function" and not ISMoveableSpriteProps._USV_SkillWrapped then
		local prevSkill = ISMoveableSpriteProps.hasRequiredSkill
		ISMoveableSpriteProps.hasRequiredSkill = function(self, _player, _mode)
			if (_mode == "pickup" or _mode == "place") and (USV.resolveSpriteKind(self.spriteName) or (self.object and USV.isUSVMoveableObject(self.object, self.spriteName))) then
				return true
			end
			return prevSkill(self, _player, _mode)
		end
		ISMoveableSpriteProps._USV_SkillWrapped = true
	end

	if type(ISMoveableSpriteProps.hasTool) == "function" and not ISMoveableSpriteProps._USV_ToolWrapped then
		local prevTool = ISMoveableSpriteProps.hasTool
		ISMoveableSpriteProps.hasTool = function(self, _player, _mode)
			if (_mode == "pickup" or _mode == "place") and (USV.resolveSpriteKind(self.spriteName) or (self.object and USV.isUSVMoveableObject(self.object, self.spriteName))) then
				return true
			end
			return prevTool(self, _player, _mode)
		end
		ISMoveableSpriteProps._USV_ToolWrapped = true
	end

	-- Tooltip / info panel: do not show red "- Items in container" or "- Too heavy" for USV objects.
	if type(ISMoveableSpriteProps.getInfoPanelFlagsPerTile) == "function"
		and not ISMoveableSpriteProps._USV_InfoPanelFlagsWrapped then
		local prevInfoFlags = ISMoveableSpriteProps.getInfoPanelFlagsPerTile
		ISMoveableSpriteProps.getInfoPanelFlagsPerTile = function(self, _square, _object, _player, _mode)
			local res = prevInfoFlags(self, _square, _object, _player, _mode)
			if _mode == "pickup" and USV.isUSVMoveableObject(_object, self.spriteName) then
				if InfoPanelFlags then
					InfoPanelFlags.hasItems = false
					InfoPanelFlags.tooHeavy = false
				end
			end
			return res
		end
		ISMoveableSpriteProps._USV_InfoPanelFlagsWrapped = true
	end

	if type(ISMoveableSpriteProps.getInfoPanelFlagsGeneral) == "function"
		and not ISMoveableSpriteProps._USV_InfoPanelFlagsGeneralWrapped then
		local prevInfoGeneral = ISMoveableSpriteProps.getInfoPanelFlagsGeneral
		ISMoveableSpriteProps.getInfoPanelFlagsGeneral = function(self, _square, _object, _player, _mode)
			local res = prevInfoGeneral(self, _square, _object, _player, _mode)
			if _mode == "pickup" and (USV.isUSVMoveableObject(_object, self.spriteName) or (self.spriteName and USV.resolveSpriteKind(self.spriteName))) then
				if InfoPanelFlags then
					InfoPanelFlags.weight = tostring(USV.MOVEABLE_CARRY_WEIGHT or 1)
				end
			end
			return res
		end
		ISMoveableSpriteProps._USV_InfoPanelFlagsGeneralWrapped = true
	end

	local prev = ISMoveableSpriteProps.canPickUpMoveableInternal
	ISMoveableSpriteProps.canPickUpMoveableInternal = function(self, _character, _square, _object, _isMulti)
		local isUSV = USV.isUSVMoveableObject(_object, self.spriteName)
		if isUSV then
			-- nil object skips isObjectNoContainerOrEmpty; carry weight is fixed (contents ignored).
			local oldWeight = self.weight
			self.weight = USV.MOVEABLE_CARRY_WEIGHT or 1
			local ok, allowed = pcall(prev, self, _character, _square, nil, _isMulti)
			self.weight = oldWeight
			if _object and _object.getRenderYOffset then
				pcall(function()
					self.yOffsetCursor = _object:getRenderYOffset() or 0
				end)
			end
			if ok then
				return allowed and true or false
			end
			return true
		end
		return prev(self, _character, _square, _object, _isMulti)
	end

	if type(ISMoveableSpriteProps.canPlaceMoveableInternal) == "function" then
		local prevCanPlace = ISMoveableSpriteProps.canPlaceMoveableInternal
		ISMoveableSpriteProps.canPlaceMoveableInternal = function(self, _character, _square, _item, _forceTypeObject)
			if not prevCanPlace(self, _character, _square, _item, _forceTypeObject) then
				return false
			end
			if _item and USV.isUSVCarryItem(_item) then
				local kind = "vault"
				pcall(function()
					local md = _item:getModData()
					kind = (md and md[USV.KIND_FLAG]) or USV.resolveSpriteKind(self.spriteName) or "vault"
				end)
				local ok = USV.canPlaceKind(kind, _character, _square, true)
				if not ok then
					return false
				end
			end
			return true
		end
	end

	if type(ISMoveableSpriteProps.pickUpMoveableInternal) == "function" then
		local prevPick = ISMoveableSpriteProps.pickUpMoveableInternal
		ISMoveableSpriteProps.pickUpMoveableInternal = function(self, _character, _square, _object, _sprInstance, _spriteName, _createItem, _rotating)
			local sprName = _spriteName or self.spriteName
			local isUSV = USV.isUSVMoveableObject(_object, sprName)
			local packs = nil
			local kind = nil
			local ownerId = nil
			local appearanceId = nil
			if isUSV and _object then
				kind = USV.getObjectKind(_object) or USV.resolveSpriteKind(sprName) or "vault"
				pcall(function()
					local md = _object:getModData()
					if md then
						ownerId = md[USV.OWNER_FLAG]
					end
				end)
				appearanceId = USV.getObjectAppearanceId(_object)
				-- Pull items out before TransferComponents / world-remove (destroy hooks would wipe them).
				packs = USV.harvestContainerItems(_object)
				local coords = USV.getLiveCoords(_object) or USV.getObjectCoords(_object)
				USV.unregisterPlacement(kind, _object)
				if ownerId then
					USV.markOwnerCarrying(kind, ownerId, coords)
				end
				USV.beginPreserveMove()
			end
			local ok, itemOrErr = pcall(prevPick, self, _character, _square, _object, _sprInstance, _spriteName, _createItem, _rotating)
			if isUSV then
				USV.endPreserveMove()
			end
			if not ok then
				USV.logError("pickUpMoveableInternal failed: " .. tostring(itemOrErr))
				return nil
			end
			local item = itemOrErr
			if isUSV and item then
				pcall(function()
					local md = item:getModData()
					if md then
						md[USV.KIND_FLAG] = kind or "vault"
						md[USV.FLAG] = true
						md[USV.WEIGHTLESS_FLAG] = true
						if ownerId then
							md[USV.OWNER_FLAG] = ownerId
						end
						if appearanceId then
							md[USV.APPEARANCE_FLAG] = appearanceId
						end
						md[USV.AUTH_FLAG] = nil
						md[USV.POS_X] = nil
						md[USV.POS_Y] = nil
						md[USV.POS_Z] = nil
					end
				end)
				USV.storeCarryPacks(item, packs)
				USV.makeMoveableWeightless(item)
				pcall(function()
					USV.purgeNestedFurnitureItems(item)
				end)
			elseif item and USV.isUSVCarryItem(item) then
				USV.makeMoveableWeightless(item)
			end
			return item
		end
	end

	if type(ISMoveableSpriteProps.placeMoveableInternal) == "function" then
		local prevPlace = ISMoveableSpriteProps.placeMoveableInternal
		ISMoveableSpriteProps.placeMoveableInternal = function(self, _character, _square, _item, _spriteName)
			local sprName = _spriteName or self.spriteName
			local packs = nil
			local kind = nil
			local ownerId = nil
			local appearanceId = nil
			local isUSV = _item and USV.isUSVCarryItem(_item)
			if isUSV then
				pcall(function()
					local md = _item:getModData()
					if md then
						kind = md[USV.KIND_FLAG] or USV.resolveSpriteKind(sprName) or "vault"
						ownerId = md[USV.OWNER_FLAG]
						appearanceId = md[USV.APPEARANCE_FLAG]
					end
				end)
				local character = _character
				pcall(function()
					local cont = _item.getContainer and _item:getContainer() or nil
					local parent = cont and cont.getParent and cont:getParent() or nil
					if parent and instanceof and instanceof(parent, "IsoGameCharacter") then
						character = parent
					end
				end)
				local ok, reason = USV.canPlaceKind(kind or "vault", character, _square, true)
				if not ok then
					USV.notifyPlaceBlocked(character, kind or "vault", reason)
					return nil
				end
				packs = USV.takeCarryPacks(_item)
			end
			local result = prevPlace(self, _character, _square, _item, _spriteName)
			local function finishObj(obj)
				if not obj then
					return
				end
				if not isUSV then
					if USV.isAuthoritative() and USV.isFlaggedObject(obj) then
						USV.stripUntrustedFlags(obj)
					end
					return
				end
				local objKind = USV.getObjectKind(obj) or kind or "vault"
				local authorized = false
				if USV.isAuthoritative() then
					local md = obj:getModData()
					if md then
						md[USV.FLAG] = true
						md[USV.KIND_FLAG] = objKind
						if ownerId then
							md[USV.OWNER_FLAG] = ownerId
						end
						if appearanceId then
							md[USV.APPEARANCE_FLAG] = appearanceId
						end
					end
					authorized = USV.authorizeObject(obj, objKind)
					if not authorized then
						-- Duplicate place while the original still exists: do not keep unlimited flags.
						USV.stripUntrustedFlags(obj)
						USV.logError("place rejected duplicate USV " .. tostring(objKind))
						return
					end
					if appearanceId then
						USV.applyAppearance(obj, appearanceId, true)
					end
				else
					authorized = true
				end
				if packs then
					local n = USV.depositContainerItems(obj, packs)
				end
				USV.applyObject(obj, true, objKind)
			end
			if isUSV then
				if result then
					finishObj(result)
				elseif _square and _square.getObjects then
					local objects = _square:getObjects()
					if objects then
						for i = 0, objects:size() - 1 do
							local obj = objects:get(i)
							local spr = USV.getSpriteNameFast(obj)
							if spr and USV.resolveSpriteKind(spr) then
								finishObj(obj)
								break
							end
						end
					end
				end
			elseif result and USV.isAuthoritative() and USV.isFlaggedObject(result) then
				USV.stripUntrustedFlags(result)
			end
			return result
		end
	end
	UnlimitedStorageVault_MoveableHooksInstalled = true
	return true
end

local function patchInventoryItemWeightMethod(index, methodName)
	local old = index[methodName]
	if type(old) ~= "function" then
		return false
	end
	index[methodName] = function(self, ...)
		if USV.isUSVCarryItem(self) then
			-- Contents are packed / ignored; furniture itself uses fixed carry weight.
			if methodName == "getContentsWeight" then
				return 0
			end
			return USV.MOVEABLE_CARRY_WEIGHT or 1
		end
		return old(self, ...)
	end
	return true
end

function USV.installInventoryWeightHooks()
	if rawget(_G, "UnlimitedStorageVault_InventoryWeightHooksInstalled") then
		return true
	end
	if not InventoryItem or not InventoryItem.class or not __classmetatables then
		return false
	end
	local mt = __classmetatables[InventoryItem.class]
	if not mt or type(mt.__index) ~= "table" then
		return false
	end
	local index = mt.__index
	local patched = false
	patched = patchInventoryItemWeightMethod(index, "getWeight") or patched
	patched = patchInventoryItemWeightMethod(index, "getActualWeight") or patched
	patched = patchInventoryItemWeightMethod(index, "getUnequippedWeight") or patched
	patched = patchInventoryItemWeightMethod(index, "getContentsWeight") or patched
	patched = patchInventoryItemWeightMethod(index, "getEquippedWeight") or patched
	if not patched then
		return false
	end
	UnlimitedStorageVault_InventoryWeightHooksInstalled = true
	return true
end

function USV.installAllHooks()
	USV.installCapacityHooks()
	USV.installTransferHooks()
	USV.installMoveableHooks()
	USV.installInventoryWeightHooks()
	USV.installBuildLimitHook()
	USV.installDestroyHooks()
	USV.installRemovalHooks()
end

function USV.installBuildLimitHook()
	if rawget(_G, "UnlimitedStorageVault_BuildLimitHookInstalled") then
		return
	end
	if not ISBuildIsoEntity or type(ISBuildIsoEntity.isValid) ~= "function" then
		return
	end
	local prev = ISBuildIsoEntity.isValid
	ISBuildIsoEntity.isValid = function(self, square)
		if not prev(self, square) then
			return false
		end
		local kind = USV.getBuildCursorKind(self)
		if kind then
			local character = self.character
			if not character and self.player ~= nil and getSpecificPlayer then
				character = getSpecificPlayer(self.player)
			end
			local ok = USV.canPlaceKind(kind, character, square)
			if not ok then
				return false
			end
		end
		return true
	end
	UnlimitedStorageVault_BuildLimitHookInstalled = true
end

--- Scrap / dismantle / object-removed: furniture scrap does not fire OnDestroyIsoThumpable
--- for non-thumpable entities, so ownership was never released.
function USV.installRemovalHooks()
	if ISMoveableSpriteProps and type(ISMoveableSpriteProps.scrapObjectInternal) == "function"
		and not ISMoveableSpriteProps._USV_ScrapWrapped then
		local prevScrap = ISMoveableSpriteProps.scrapObjectInternal
		ISMoveableSpriteProps.scrapObjectInternal = function(self, character, scrapDef, square, object, scrapResult, chance, perkName)
			if object then
				USV.onWorldObjectRemoved(object, "scrap")
				if isClient and isClient() and not (isServer and isServer()) and sendClientCommand and character then
					local coords = USV.getLiveCoords(object) or USV.getObjectCoords(object)
					local md = object.getModData and object:getModData() or nil
					sendClientCommand(character, "USV", "ReleaseAt", {
						x = coords and coords.x or nil,
						y = coords and coords.y or nil,
						z = coords and coords.z or 0,
						kind = (md and md[USV.KIND_FLAG]) or USV.getObjectKind(object) or "vault",
					})
				end
			end
			return prevScrap(self, character, scrapDef, square, object, scrapResult, chance, perkName)
		end
		ISMoveableSpriteProps._USV_ScrapWrapped = true
	end
	if ISDismantleAction and type(ISDismantleAction.complete) == "function"
		and not ISDismantleAction._USV_CompleteWrapped then
		local prevDis = ISDismantleAction.complete
		ISDismantleAction.complete = function(self)
			if self and self.thumpable then
				USV.onWorldObjectRemoved(self.thumpable, "dismantle")
			end
			return prevDis(self)
		end
		ISDismantleAction._USV_CompleteWrapped = true
	end
	if Events and Events.OnObjectAboutToBeRemoved and not rawget(_G, "UnlimitedStorageVault_AboutToBeRemovedHooked") then
		Events.OnObjectAboutToBeRemoved.Add(function(obj)
			USV.onWorldObjectRemoved(obj, "aboutToBeRemoved")
		end)
		UnlimitedStorageVault_AboutToBeRemovedHooked = true
	end
	UnlimitedStorageVault_RemovalHooksInstalled = true
end

function USV.deleteContainerItems(container)
	if not container or not container.getItems then
		return 0
	end
	local items = container:getItems()
	if not items then
		return 0
	end
	local n = items:size()
	if n <= 0 then
		return 0
	end
	if sendRemoveItemsFromContainer then
		pcall(function()
			sendRemoveItemsFromContainer(container, items)
		end)
	end
	if container.clear then
		pcall(function()
			container:clear()
		end)
		USV.invalidateContainerCache(container)
		return n
	end
	while items:size() > 0 do
		local item = items:get(0)
		if container.DoRemoveItem then
			container:DoRemoveItem(item)
		elseif container.Remove then
			container:Remove(item)
		else
			break
		end
	end
	USV.invalidateContainerCache(container)
	return n
end

function USV.clearAllContents(obj)
	if USV.isPreservingMove() then
		return 0
	end
	if not obj then
		return 0
	end
	local removed = 0
	local count = 0
	if obj.getContainerCount then
		local ok, n = pcall(function()
			return obj:getContainerCount()
		end)
		if ok and n then
			count = n
		end
	end
	if count > 0 then
		for i = 0, count - 1 do
			local ok, c = pcall(function()
				return obj:getContainerByIndex(i)
			end)
			if ok and c then
				removed = removed + USV.deleteContainerItems(c)
			end
		end
		return removed
	end
	if obj.getItemContainer then
		local ok, c = pcall(function()
			return obj:getItemContainer()
		end)
		if ok and c then
			removed = removed + USV.deleteContainerItems(c)
		end
	elseif obj.getContainer then
		local ok, c = pcall(function()
			return obj:getContainer()
		end)
		if ok and c then
			removed = removed + USV.deleteContainerItems(c)
		end
	end
	return removed
end

local function patchDumpContentsInSquare(cls, label)
	if not cls or not cls.class or not __classmetatables then
		return false
	end
	local mt = __classmetatables[cls.class]
	if not mt or type(mt.__index) ~= "table" then
		return false
	end
	local index = mt.__index
	local oldDump = index.dumpContentsInSquare
	if type(oldDump) ~= "function" then
		return false
	end
	local guardKey = "UnlimitedStorageVault_DumpHook_" .. tostring(label)
	if rawget(_G, guardKey) then
		return true
	end
	index.dumpContentsInSquare = function(self, ...)
		if USV.isTrustedUSVObject(self) or USV.isFlaggedObject(self) then
			if USV.isPreservingMove() then
				return nil
			end
			-- Trusted: wipe. Flagged-but-untrusted: still wipe to deny forged USV dumps to floor.
			local n = USV.clearAllContents(self)
			return nil
		end
		return oldDump(self, ...)
	end
	_G[guardKey] = true
	return true
end

function USV.installDestroyHooks()
	if rawget(_G, "UnlimitedStorageVault_DestroyHooksInstalled") then
		return
	end
	local patched = false
	if IsoObject then
		patched = patchDumpContentsInSquare(IsoObject, "IsoObject") or patched
	end
	if IsoThumpable then
		patched = patchDumpContentsInSquare(IsoThumpable, "IsoThumpable") or patched
	end
	if ISBuildingObject and type(ISBuildingObject.onDestroy) == "function" then
		local prev = ISBuildingObject.onDestroy
		ISBuildingObject.onDestroy = function(thump, player)
			if thump and USV.shouldReleaseOnRemove(thump) then
				if USV.isPreservingMove() then
					if thump.getSquare and thump:getSquare() and thump:getSquare().transmitRemoveItemFromSquare then
						pcall(function()
							thump:getSquare():transmitRemoveItemFromSquare(thump)
						end)
					end
					return
				end
				USV.onWorldObjectRemoved(thump, "buildingDestroy")
				if thump.getSquare and thump:getSquare() and thump:getSquare().transmitRemoveItemFromSquare then
					pcall(function()
						thump:getSquare():transmitRemoveItemFromSquare(thump)
					end)
				end
				return
			end
			return prev(thump, player)
		end
		patched = true
	end
	if ISDestroyStuffAction and type(ISDestroyStuffAction.complete) == "function" then
		local prevComplete = ISDestroyStuffAction.complete
		ISDestroyStuffAction.complete = function(self)
			if self and self.item then
				USV.onWorldObjectRemoved(self.item, "destroy")
			end
			return prevComplete(self)
		end
		patched = true
	end
	if patched then
		UnlimitedStorageVault_DestroyHooksInstalled = true
	end
end

USV.installAllHooks()
