--[[
  Unlimited Storage Vault — shared helpers (vault + commercial fridge)
]]

USV = USV or {}

USV.MOD = "[UnlimitedStorageVault] "
USV.FLAG = "USV_Unlimited"
USV.AUTH_FLAG = "USV_Auth"
USV.WEIGHTLESS_FLAG = "USV_Weightless"
USV.CARRY_TOKEN = "USV_CarryToken"
USV.CONTENTS_ID = "USV_ContentsId"
USV.CONTENTS_FILE_PREFIX = "USV_" -- legacy short prefix
USV.CONTENTS_FILE_PREFIX_LEGACY = "USV_Contents_" -- pre-fix27 files
USV.CONTENTS_STORE_FILE = "USV_Store.json" -- single global store (all worlds in units[])
USV.CONTENTS_STORE_VERSION = 4 -- global store; each unit carries its own world
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
	-- Appearance-only sprites (vanilla fridge/locker tiles) must NOT map to USV kind identity.
	for kindId, list in pairs(USV.APPEARANCES or {}) do
		if type(list) == "table" then
			for i = 1, #list do
				local app = list[i]
				if app and app.faces then
					for _, spriteName in pairs(app.faces) do
						if type(spriteName) == "string" then
							appearanceBySprite[spriteName] = app.id
						end
					end
				end
			end
		end
	end
end

USV.CONTENTS_MAX_ITEMS = 10000 -- hard cap for snapshot packs (anti-abuse)
USV.CONTENTS_MAX_STACK = 10000 -- max count on a single stacked descriptor row
USV.BLIND_XFER_MAX_DIST = 12 -- tiles; BlindTransfer must be near the USV
USV.CLIENT_CMD_RATE_WINDOW_MS = 1000
USV.CLIENT_CMD_RATE_LIMIT = 80 -- commands per window per player (bulk transfer bursts)

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

function USV.getSandboxBool(key, fallback)
	local root = SandboxVars and SandboxVars.UnlimitedStorageVault
	if not root then
		return fallback
	end
	local v = root[key]
	if type(v) == "boolean" then
		return v
	end
	if type(v) == "number" then
		return v ~= 0
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

--- Lua 5.1 / Kahlua compatible hash (no bitwise ~ which is Lua 5.3+ only).
local function simpleHash(str)
	local h = 2166136261
	for i = 1, #str do
		-- FNV-1a style without XOR: mix with multiply + add
		h = (h * 16777619 + string.byte(str, i)) % 2147483647
	end
	return tostring(h)
end

--- Server-only secret (never written to synced ModData / never transmitted).
--- Persisted in Lua/USV_ServerSecret.txt so auth tokens survive restarts.
function USV.getServerSecret()
	if not USV.isAuthoritative() then
		return nil
	end
	if type(USV._serverSecret) == "string" and USV._serverSecret ~= "" then
		return USV._serverSecret
	end
	local fileName = "USV_ServerSecret.txt"
	local existing = nil
	if getFileReader then
		local ok, reader = pcall(getFileReader, fileName, false)
		if ok and reader then
			pcall(function()
				existing = reader:readLine()
				reader:close()
			end)
		end
	end
	if type(existing) == "string" and existing ~= "" and #existing >= 8 then
		USV._serverSecret = existing
		return USV._serverSecret
	end
	local seed = tostring(os.time()) .. ":" .. tostring(ZombRand and ZombRand(1, 2000000000) or 42)
	USV._serverSecret = "usv:" .. simpleHash(seed) .. ":" .. tostring(os.time())
	if getFileWriter then
		local wok, writer = pcall(getFileWriter, fileName, true, false)
		if wok and writer then
			pcall(function()
				writer:write(USV._serverSecret)
				writer:close()
			end)
		end
	end
	return USV._serverSecret
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

--- Soft legitimacy for capacity/UI: registered USV markers only (never sprite-only).
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

--- Capacity / transfer bypass: USV ModData / registry only (vanilla tiles may share sprites).
function USV.isLegitimateUSVObject(obj)
	if not obj then
		return false
	end
	if unlimitedParentRegistry[obj] then
		return true
	end
	if USV.isFlaggedObject(obj) then
		return true
	end
	if USV.isTrustedUSVObject(obj) then
		return true
	end
	if USV.isRegisteredPlacementObject(obj) then
		return true
	end
	local md = obj.getModData and obj:getModData() or nil
	if md and md[USV.KIND_FLAG] and (md[USV.OWNER_FLAG] or md[USV.AUTH_FLAG]) then
		return true
	end
	if USV.objectNameLooksUSV(obj) and USV.isFlaggedObject(obj) then
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

--- Sandbox + MP: placement must be inside a safehouse the player belongs to.
function USV.enforceSafehouseOnlyPlacement()
	if not USV.getSandboxBool("SafehouseOnlyPlacement", true) then
		return false
	end
	return USV.requiresSafehouseRules()
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
	-- Stale ownerPlacement.carried must not block a fresh build when inventory has no USV item.
	if carriedItems > 0 and carriedSeals > carried then
		carried = carriedSeals
	end
	return world + carried
end

function USV.pruneStaleCarriedSeals(kind, player)
	if not USV.isAuthoritative() or not player or not USV.getKindDef(kind) then
		return
	end
	if USV.countCarryingKind(kind, player) > 0 then
		return
	end
	local ownerId = USV.getOwnerId(player)
	local store = USV.getStore()
	local list = ownerId and store and store.ownerPlacement and store.ownerPlacement[kind]
		and store.ownerPlacement[kind][ownerId]
	if not list then
		return
	end
	local changed = false
	for i = #list, 1, -1 do
		if list[i] and list[i].carried then
			table.remove(list, i)
			changed = true
		end
	end
	if changed then
		USV.transmitStore()
	end
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
			USV.pruneStaleCarriedSeals(kind, player)
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
	if USV.enforceSafehouseOnlyPlacement() and not relocating then
		if not square or not player then
			return false, "needSafehouse"
		end
		sh = USV.getSafeHouseAt(square)
		if not sh then
			return false, "needSafehouse"
		end
		if not USV.playerAllowedInSafehouse(sh, player, square) then
			return false, "needSafehouse"
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
		if not spriteKind then
			-- B42 entity builds may not expose tile sprites at OnCreate yet (see Invalid SpriteConfig).
			if not USV.getKindDef(kind) then
				USV.logError("claim rejected: invalid sprite " .. tostring(sprite))
				return false
			end
		else
			kind = spriteKind
			def = USV.getKindDef(kind)
			if not def then
				return false
			end
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
	if not md[USV.CONTENTS_ID] then
		md[USV.CONTENTS_ID] = USV.newContentsId(id, kind, player)
	end
	if not USV.authorizeObject(obj, kind) then
		USV.logError("claim: authorizeObject failed for " .. tostring(id))
		return false
	end
	-- Never clobber an existing non-empty contents JSON (re-claim / scan must not wipe stash).
	local existingSnap = USV.readContentsSnapshot(md[USV.CONTENTS_ID])
	local existingCount = existingSnap and existingSnap.itemCount or 0
	if existingCount <= 0 then
		USV.writeContentsSnapshot(md[USV.CONTENTS_ID], {}, {
			kind = kind,
			ownerId = id,
			ownerName = USV.resolveOwnerUserName(id, player),
		})
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
	-- Legacy flagged objects: prefer sprite kind (fridge tiles must not read as vault).
	if md and md[USV.FLAG] == true then
		local sk = USV.resolveSpriteKind(USV.getSpriteNameFast(obj))
		if sk then
			return sk
		end
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
	local contentsId = USV.getEntityContentsId(obj)
	USV.clearAllContents(obj)
	if contentsId then
		USV.deleteContentsSnapshot(contentsId)
	end
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

-- ---------------------------------------------------------------------------
-- Contents JSON snapshot (carry / relocate durable backup)
-- Files: Zomboid/Lua/USV_Store.json — one global store; units[] holds every vault/fridge (per-world via unit.world)
-- JSON field `world` must match current save or restore is refused.
-- Legacy unscoped USV_Contents_* / USV_<Name>_* are NOT used for restore (cross-world safety).
-- ---------------------------------------------------------------------------

local function usvJsonEscape(s)
	s = tostring(s or "")
	s = string.gsub(s, "\\", "\\\\")
	s = string.gsub(s, '"', '\\"')
	s = string.gsub(s, "\r", "\\r")
	s = string.gsub(s, "\n", "\\n")
	s = string.gsub(s, "\t", "\\t")
	return s
end

function USV.jsonEncode(value)
	local t = type(value)
	if t == "nil" then
		return "null"
	elseif t == "boolean" then
		return value and "true" or "false"
	elseif t == "number" then
		if value ~= value or value == math.huge or value == -math.huge then
			return "null"
		end
		return tostring(value)
	elseif t == "string" then
		return '"' .. usvJsonEscape(value) .. '"'
	elseif t ~= "table" then
		return "null"
	end
	local isArray = true
	local maxN = 0
	for k, _ in pairs(value) do
		if type(k) ~= "number" or k < 1 or math.floor(k) ~= k then
			isArray = false
			break
		end
		if k > maxN then
			maxN = k
		end
	end
	if isArray then
		local parts = {}
		for i = 1, maxN do
			parts[#parts + 1] = USV.jsonEncode(value[i])
		end
		return "[" .. table.concat(parts, ",") .. "]"
	end
	local parts = {}
	for k, v in pairs(value) do
		if type(k) == "string" or type(k) == "number" then
			parts[#parts + 1] = '"' .. usvJsonEscape(k) .. '":' .. USV.jsonEncode(v)
		end
	end
	return "{" .. table.concat(parts, ",") .. "}"
end

function USV.jsonDecode(str)
	if not str or str == "" then
		return nil
	end
	local i = 1
	local n = #str
	local function peek()
		return string.sub(str, i, i)
	end
	local function skipWs()
		while i <= n do
			local c = peek()
			if c ~= " " and c ~= "\t" and c ~= "\r" and c ~= "\n" then
				break
			end
			i = i + 1
		end
	end
	local parseValue
	local function parseString()
		i = i + 1
		local out = {}
		while i <= n do
			local c = peek()
			if c == '"' then
				i = i + 1
				return table.concat(out)
			elseif c == "\\" then
				i = i + 1
				local e = peek()
				i = i + 1
				if e == "n" then
					out[#out + 1] = "\n"
				elseif e == "r" then
					out[#out + 1] = "\r"
				elseif e == "t" then
					out[#out + 1] = "\t"
				else
					out[#out + 1] = e
				end
			else
				out[#out + 1] = c
				i = i + 1
			end
		end
		return table.concat(out)
	end
	local function parseNumber()
		local start = i
		if peek() == "-" then
			i = i + 1
		end
		while i <= n and string.find(peek(), "%d") do
			i = i + 1
		end
		if peek() == "." then
			i = i + 1
			while i <= n and string.find(peek(), "%d") do
				i = i + 1
			end
		end
		if peek() == "e" or peek() == "E" then
			i = i + 1
			if peek() == "+" or peek() == "-" then
				i = i + 1
			end
			while i <= n and string.find(peek(), "%d") do
				i = i + 1
			end
		end
		return tonumber(string.sub(str, start, i - 1))
	end
	local function parseArray()
		i = i + 1
		local arr = {}
		skipWs()
		if peek() == "]" then
			i = i + 1
			return arr
		end
		while i <= n do
			arr[#arr + 1] = parseValue()
			skipWs()
			local c = peek()
			if c == "]" then
				i = i + 1
				break
			elseif c == "," then
				i = i + 1
				skipWs()
			else
				break
			end
		end
		return arr
	end
	local function parseObject()
		i = i + 1
		local obj = {}
		skipWs()
		if peek() == "}" then
			i = i + 1
			return obj
		end
		while i <= n do
			skipWs()
			if peek() ~= '"' then
				break
			end
			local key = parseString()
			skipWs()
			if peek() == ":" then
				i = i + 1
			end
			skipWs()
			obj[key] = parseValue()
			skipWs()
			local c = peek()
			if c == "}" then
				i = i + 1
				break
			elseif c == "," then
				i = i + 1
			else
				break
			end
		end
		return obj
	end
	parseValue = function()
		skipWs()
		local c = peek()
		if c == '"' then
			return parseString()
		elseif c == "{" then
			return parseObject()
		elseif c == "[" then
			return parseArray()
		elseif c == "t" and string.sub(str, i, i + 3) == "true" then
			i = i + 4
			return true
		elseif c == "f" and string.sub(str, i, i + 4) == "false" then
			i = i + 5
			return false
		elseif c == "n" and string.sub(str, i, i + 3) == "null" then
			i = i + 4
			return nil
		else
			return parseNumber()
		end
	end
	local ok, result = pcall(parseValue)
	if ok then
		return result
	end
	return nil
end

function USV.sanitizeContentsId(id)
	if not id then
		return nil
	end
	local s = tostring(id)
	-- Strip path / traversal characters first (Mac/Win/Linux).
	s = string.gsub(s, "%.%.", "")
	s = string.gsub(s, "[/\\]", "")
	s = string.gsub(s, "[^%w%-%_]", "_")
	s = string.gsub(s, "_+", "_")
	s = string.gsub(s, "^_+", "")
	s = string.gsub(s, "_+$", "")
	if s == "" or #s > 96 then
		return nil
	end
	return s
end

--- FullType must look like Module.ItemName (blocks path / script injection).
function USV.isSafeItemFullType(ft)
	if type(ft) ~= "string" or ft == "" or #ft > 128 then
		return false
	end
	if string.find(ft, "%.%.", 1, true) or string.find(ft, "/", 1, true) or string.find(ft, "\\", 1, true) then
		return false
	end
	return string.match(ft, "^[%w_]+%.[%w_]+$") ~= nil
end

function USV.itemScriptExists(ft)
	if not USV.isSafeItemFullType(ft) then
		return false
	end
	local ok = false
	pcall(function()
		if getScriptManager and getScriptManager().getItem then
			ok = getScriptManager():getItem(ft) ~= nil
		end
	end)
	return ok
end

--- Never persist raw steam IDs in Lua-folder JSON (shared-machine / backup privacy).
function USV.ownerIdForDisk(ownerId)
	if not ownerId or ownerId == "" then
		return nil
	end
	local s = tostring(ownerId)
	if string.match(s, "^steam:") then
		local sum = 0
		for i = 1, #s do
			sum = (sum + string.byte(s, i) * i) % 100000000
		end
		return string.format("steam#%08d", sum)
	end
	return USV.sanitizeContentsId(s)
end

--- Validate / scrub client-supplied snapshot packs before writing on the server.
--- Identical items are collapsed to one row with `count` (array length ≠ item quantity).
function USV.descriptorStackKey(desc)
	if type(desc) ~= "table" or not desc.ft then
		return nil
	end
	local mdName = ""
	if type(desc.md) == "table" and type(desc.md.customName) == "string" then
		mdName = desc.md.customName
	end
	-- Round volatile floats so near-identical food stacks merge.
	local function r4(n)
		n = tonumber(n)
		if not n then
			return ""
		end
		return string.format("%.4f", n)
	end
	return table.concat({
		tostring(desc.ft),
		tostring(desc.condition or ""),
		tostring(desc.conditionMax or ""),
		desc.favorite and "1" or "0",
		r4(desc.usedDelta),
		desc.cooked and "1" or "0",
		desc.burnt and "1" or "0",
		desc.frozen and "1" or "0",
		r4(desc.baseHunger),
		r4(desc.hungChange),
		tostring(desc.name or ""),
		mdName,
	}, "|")
end

function USV.collapseDescriptorItems(items)
	if type(items) ~= "table" then
		return {}
	end
	local maxStack = USV.CONTENTS_MAX_STACK or 10000
	local map = {}
	local order = {}
	for _, desc in ipairs(items) do
		if type(desc) == "table" and desc.ft then
			local key = USV.descriptorStackKey(desc)
			local add = tonumber(desc.count) or 1
			if add < 1 then
				add = 1
			end
			if add > maxStack then
				add = maxStack
			end
			if key and map[key] then
				local nextCount = (map[key].count or 1) + add
				if nextCount > maxStack then
					nextCount = maxStack
				end
				map[key].count = nextCount
			elseif key then
				local row = {}
				for k, v in pairs(desc) do
					if k ~= "count" then
						row[k] = v
					end
				end
				row.count = add
				map[key] = row
				order[#order + 1] = key
			end
		end
	end
	local out = {}
	for _, key in ipairs(order) do
		out[#out + 1] = map[key]
	end
	return out
end

function USV.descriptorItemsTotal(items)
	if type(items) ~= "table" then
		return 0
	end
	local n = 0
	for _, desc in ipairs(items) do
		if type(desc) == "table" then
			local c = tonumber(desc.count) or 1
			if c < 1 then
				c = 1
			end
			n = n + c
		end
	end
	return n
end

function USV.sanitizeSnapshotPacks(packs, kind)
	if type(packs) ~= "table" then
		return nil, "bad_packs"
	end
	local maxItems = USV.CONTENTS_MAX_ITEMS or 10000
	local maxStack = USV.CONTENTS_MAX_STACK or 10000
	local total = 0
	local clean = {}
	for _, pack in ipairs(packs) do
		if type(pack) == "table" then
			local p = {
				index = tonumber(pack.index) or 0,
				type = USV.sanitizeContentsId(tostring(pack.type or "")) or "",
				items = {},
			}
			if type(pack.items) == "table" then
				for _, desc in ipairs(pack.items) do
					if type(desc) == "table" and USV.itemScriptExists(desc.ft) then
						local ft = desc.ft
						local deny = false
						pcall(function()
							if string.find(ft, "Moveable", 1, true) then
								deny = true
							end
						end)
						if not deny then
							local stack = tonumber(desc.count) or 1
							if stack < 1 then
								stack = 1
							end
							if stack > maxStack then
								stack = maxStack
							end
							local scrubbed = {
								ft = ft,
								count = stack,
								name = type(desc.name) == "string" and string.sub(desc.name, 1, 128) or nil,
								condition = tonumber(desc.condition),
								conditionMax = tonumber(desc.conditionMax),
								favorite = desc.favorite and true or nil,
								usedDelta = tonumber(desc.usedDelta),
								age = tonumber(desc.age),
								cooked = desc.cooked and true or nil,
								burnt = desc.burnt and true or nil,
								frozen = desc.frozen and true or nil,
								offAge = tonumber(desc.offAge),
								offAgeMax = tonumber(desc.offAgeMax),
								baseHunger = tonumber(desc.baseHunger),
								hungChange = tonumber(desc.hungChange),
								r = tonumber(desc.r),
								g = tonumber(desc.g),
								b = tonumber(desc.b),
							}
							if type(desc.md) == "table" and type(desc.md.customName) == "string" then
								scrubbed.md = { customName = string.sub(desc.md.customName, 1, 128) }
							end
							p.items[#p.items + 1] = scrubbed
							total = total + stack
							if total > maxItems then
								return nil, "too_many"
							end
						end
					end
				end
			end
			p.items = USV.collapseDescriptorItems(p.items)
			clean[#clean + 1] = p
		end
	end
	return clean, nil
end

function USV.getWorldSaveKey()
	local world = ""
	local mode = ""
	local server = ""
	pcall(function()
		if getWorld and getWorld() and getWorld().getWorld then
			world = tostring(getWorld():getWorld() or "")
		end
	end)
	pcall(function()
		if getCore and getCore() and getCore().getGameMode then
			mode = tostring(getCore():getGameMode() or "")
		end
	end)
	pcall(function()
		if getServerName then
			server = tostring(getServerName() or "")
		end
	end)
	local raw = tostring(mode) .. "|" .. tostring(world) .. "|" .. tostring(server)
	if raw == "||" or raw == "| |" or string.gsub(raw, "|", "") == "" then
		raw = "default"
	end
	return raw
end

--- Short stable tag for filenames (keeps Mac paths short, avoids cross-world clashes).
function USV.worldFileTag(worldKey)
	worldKey = worldKey or USV.getWorldSaveKey()
	local sum = 0
	local s = tostring(worldKey)
	for i = 1, #s do
		sum = (sum + string.byte(s, i) * (i % 17 + 1)) % 1000000
	end
	local label = ""
	pcall(function()
		if getWorld and getWorld() and getWorld().getWorld then
			label = tostring(getWorld():getWorld() or "")
		end
	end)
	label = USV.sanitizeContentsId(label) or "w"
	if #label > 6 then
		label = string.sub(label, 1, 6)
	end
	return string.format("%s%04d", label, sum % 10000)
end

--- One global JSON store for all worlds: `USV_Store.json` with a units[] array.
--- Each unit carries its own `world` / `worldTag` for isolation.
function USV.contentsStoreFileName(_worldKey)
	return USV.CONTENTS_STORE_FILE or "USV_Store.json"
end

--- Legacy per-world store name (fix36–37): `USV_<worldTag>.json`
function USV.contentsWorldStoreFileName(worldKey)
	local tag = USV.worldFileTag(worldKey)
	return USV.CONTENTS_FILE_PREFIX .. tag .. ".json"
end

function USV.contentsFileName(id, legacy, worldScoped)
	local safe = USV.sanitizeContentsId(id)
	if not safe then
		return nil
	end
	local prefix = legacy and USV.CONTENTS_FILE_PREFIX_LEGACY or USV.CONTENTS_FILE_PREFIX
	if legacy or worldScoped == false then
		-- Pre-world-scoped / explicit global name
		return prefix .. safe .. ".json"
	end
	-- Legacy per-unit file (pre-unified store)
	local tag = USV.worldFileTag()
	return prefix .. tag .. "_" .. safe .. ".json"
end

--- Prefer in-game username so Lua folder files read as who owns the stash.
function USV.findPlayerByOwnerId(ownerId)
	if not ownerId then
		return nil
	end
	local found = nil
	if getOnlinePlayers then
		pcall(function()
			local list = getOnlinePlayers()
			if list then
				for i = 0, list:size() - 1 do
					local p = list:get(i)
					if p and USV.getOwnerId(p) == ownerId then
						found = p
						return
					end
				end
			end
		end)
	end
	if found then
		return found
	end
	if getSpecificPlayer then
		for i = 0, 3 do
			local p = nil
			pcall(function()
				p = getSpecificPlayer(i)
			end)
			if p and USV.getOwnerId(p) == ownerId then
				return p
			end
		end
	end
	return nil
end

function USV.resolveOwnerUserName(ownerId, player)
	local name = nil
	local p = player or USV.findPlayerByOwnerId(ownerId)
	if p then
		pcall(function()
			if p.getUsername then
				name = p:getUsername()
			end
		end)
		if name and tostring(name) ~= "" then
			return tostring(name)
		end
		pcall(function()
			if p.getDisplayName then
				name = p:getDisplayName()
			end
		end)
		if name and tostring(name) ~= "" then
			return tostring(name)
		end
	end
	if type(ownerId) == "string" then
		local user = string.match(ownerId, "^user:(.+)$")
		if user and user ~= "" then
			return user
		end
		local named = string.match(ownerId, "^name:(.+)$")
		if named and named ~= "" then
			return named
		end
		local steam = string.match(ownerId, "^steam:(.+)$")
		if steam and steam ~= "" then
			local digits = string.gsub(steam, "[^%d]", "")
			if #digits > 4 then
				digits = string.sub(digits, -4)
			end
			return "s" .. (digits ~= "" and digits or "0")
		end
	end
	return "u"
end

local function usvKindFileTag(kind)
	if kind == "fridge" then
		return "f"
	end
	return "v"
end

--- Short readable unit id (stored inside the world JSON `units[]`, not as its own file).
function USV.newContentsId(ownerId, kind, player)
	local ownerName = USV.resolveOwnerUserName(ownerId, player)
	local safeName = USV.sanitizeContentsId(ownerName) or "u"
	if #safeName > 10 then
		safeName = string.sub(safeName, 1, 10)
	end
	USV._contentsIdSeq = (USV._contentsIdSeq or 0) + 1
	return string.format("%s_%s%d", safeName, usvKindFileTag(kind), USV._contentsIdSeq)
end

function USV.getEntityContentsId(entity)
	if not entity or not entity.getModData then
		return nil
	end
	local id = nil
	pcall(function()
		local md = entity:getModData()
		id = md and md[USV.CONTENTS_ID] or nil
	end)
	return id
end

function USV.setEntityContentsId(entity, id)
	if not entity or not entity.getModData or not id then
		return
	end
	pcall(function()
		local md = entity:getModData()
		if md then
			md[USV.CONTENTS_ID] = id
		end
	end)
	if entity.transmitModData and USV.isAuthoritative and USV.isAuthoritative() then
		pcall(function()
			entity:transmitModData()
		end)
	end
end

function USV.copyModDataSafe(src)
	local out = {}
	if not src then
		return out
	end
	pcall(function()
		for k, v in pairs(src) do
			local tk = type(k)
			local tv = type(v)
			if (tk == "string" or tk == "number") and (tv == "string" or tv == "number" or tv == "boolean") then
				local ks = tostring(k)
				if not string.find(ks, "USV_", 1, true) then
					out[ks] = v
				end
			end
		end
	end)
	return out
end

function USV.serializeInventoryItem(item)
	if not item then
		return nil
	end
	local desc = {
		ft = USV.itemFullType(item),
	}
	if not desc.ft or desc.ft == "" then
		return nil
	end
	pcall(function()
		if item.getName then
			desc.name = item:getName()
		end
		if item.getCondition then
			desc.condition = item:getCondition()
		end
		if item.getConditionMax then
			desc.conditionMax = item:getConditionMax()
		end
		if item.isFavorite and item:isFavorite() then
			desc.favorite = true
		end
		if item.getUsedDelta then
			desc.usedDelta = item:getUsedDelta()
		end
		if item.getAge then
			desc.age = item:getAge()
		end
		if item.isCooked and item:isCooked() then
			desc.cooked = true
		end
		if item.isBurnt and item:isBurnt() then
			desc.burnt = true
		end
		if item.isFrozen and item:isFrozen() then
			desc.frozen = true
		end
		if item.isPoisonous and item:isPoisonous() then
			desc.poison = true
		end
		if item.getOffAge then
			desc.offAge = item:getOffAge()
		end
		if item.getOffAgeMax then
			desc.offAgeMax = item:getOffAgeMax()
		end
		if item.getBaseHunger then
			desc.baseHunger = item:getBaseHunger()
		end
		if item.getHungChange then
			desc.hungChange = item:getHungChange()
		end
		if item.getColorRed and item.getColorGreen and item.getColorBlue then
			desc.r = item:getColorRed()
			desc.g = item:getColorGreen()
			desc.b = item:getColorBlue()
		end
		if item.getModData then
			desc.md = USV.copyModDataSafe(item:getModData())
		end
	end)
	return desc
end

function USV.createItemFromDescriptor(desc)
	if not desc or not USV.isSafeItemFullType(desc.ft) or not USV.itemScriptExists(desc.ft) then
		return nil
	end
	local item = nil
	pcall(function()
		if instanceItem then
			item = instanceItem(desc.ft)
		end
	end)
	if not item and InventoryItemFactory and InventoryItemFactory.CreateItem then
		pcall(function()
			item = InventoryItemFactory.CreateItem(desc.ft)
		end)
	end
	if not item then
		return nil
	end
	if USV.isUSVFurnitureItem(item) then
		return nil
	end
	pcall(function()
		if desc.name and item.setName then
			item:setName(tostring(desc.name))
		end
		if desc.condition ~= nil and item.setCondition then
			item:setCondition(tonumber(desc.condition) or 0)
		end
		if desc.favorite and item.setFavorite then
			item:setFavorite(true)
		end
		if desc.usedDelta ~= nil and item.setUsedDelta then
			item:setUsedDelta(tonumber(desc.usedDelta) or 0)
		end
		if desc.age ~= nil and item.setAge then
			item:setAge(tonumber(desc.age) or 0)
		end
		if desc.cooked and item.setCooked then
			item:setCooked(true)
		end
		if desc.burnt and item.setBurnt then
			item:setBurnt(true)
		end
		if desc.frozen and item.setFrozen then
			item:setFrozen(true)
		end
		-- Intentionally ignore desc.poison from JSON (cannot mark items poisonous via snapshot).
		if desc.offAge ~= nil and item.setOffAge then
			item:setOffAge(tonumber(desc.offAge) or 0)
		end
		if desc.offAgeMax ~= nil and item.setOffAgeMax then
			item:setOffAgeMax(tonumber(desc.offAgeMax) or 0)
		end
		if desc.baseHunger ~= nil and item.setBaseHunger then
			item:setBaseHunger(tonumber(desc.baseHunger) or 0)
		end
		if desc.hungChange ~= nil and item.setHungChange then
			item:setHungChange(tonumber(desc.hungChange) or 0)
		end
		if desc.r ~= nil and item.setColorRed then
			item:setColorRed(tonumber(desc.r) or 1)
			item:setColorGreen(tonumber(desc.g) or 1)
			item:setColorBlue(tonumber(desc.b) or 1)
		end
		if type(desc.md) == "table" and item.getModData then
			local md = item:getModData()
			if md and type(desc.md.customName) == "string" then
				md.customName = string.sub(desc.md.customName, 1, 128)
			end
		end
	end)
	return item
end

function USV.packsToDescriptors(packs)
	local out = {}
	if not packs then
		return out
	end
	for _, pack in ipairs(packs) do
		local p = {
			index = pack.index,
			type = pack.type or "",
			items = {},
		}
		if pack.items then
			for _, invItem in ipairs(pack.items) do
				local live = invItem
				local desc = nil
				if type(invItem) == "table" and invItem.ft then
					desc = invItem
				else
					desc = USV.serializeInventoryItem(live)
				end
				if desc then
					p.items[#p.items + 1] = desc
				end
			end
		end
		p.items = USV.collapseDescriptorItems(p.items)
		out[#out + 1] = p
	end
	return out
end

function USV.descriptorsToPacks(data)
	local packs = {}
	if not data then
		return packs
	end
	local list = data.packs or data
	if type(list) ~= "table" then
		return packs
	end
	local maxStack = USV.CONTENTS_MAX_STACK or 10000
	local maxTotal = USV.CONTENTS_MAX_ITEMS or 10000
	local spawned = 0
	for _, pack in ipairs(list) do
		local p = {
			index = pack.index or 0,
			type = pack.type or "",
			items = {},
		}
		if pack.items then
			for _, desc in ipairs(pack.items) do
				local n = tonumber(desc.count) or 1
				if n < 1 then
					n = 1
				end
				if n > maxStack then
					n = maxStack
				end
				for _ = 1, n do
					if spawned >= maxTotal then
						break
					end
					local item = USV.createItemFromDescriptor(desc)
					if item then
						p.items[#p.items + 1] = item
						spawned = spawned + 1
					end
				end
			end
		end
		packs[#packs + 1] = p
	end
	return packs
end

function USV.contentsUsesLegacyFile(id)
	local safe = USV.sanitizeContentsId(id)
	if not safe then
		return false
	end
	-- New short ids: Name_v1 / Name_f2
	if string.match(safe, "^[%w%-]+_[vf]%d+$") then
		return false
	end
	return true
end

local function usvReadJsonFile(fileName)
	if not fileName or not getFileReader then
		return nil
	end
	local ok, reader = pcall(getFileReader, fileName, false)
	if not ok or not reader then
		return nil
	end
	local parts = {}
	pcall(function()
		local line = reader:readLine()
		while line do
			parts[#parts + 1] = line
			line = reader:readLine()
		end
		reader:close()
	end)
	local text = table.concat(parts, "\n")
	if not text or text == "" then
		return nil
	end
	return text
end

local function usvWriteJsonFile(fileName, json)
	if not fileName or not getFileWriter or not json then
		return false
	end
	local ok = false
	local wok, writer = pcall(getFileWriter, fileName, true, false)
	if wok and writer then
		pcall(function()
			writer:write(json)
			writer:close()
			ok = true
		end)
	end
	return ok
end

local function usvEmptyContentsStore()
	return {
		v = USV.CONTENTS_STORE_VERSION or 4,
		units = {},
	}
end

function USV.invalidateContentsStoreCache()
	USV._contentsStoreCache = nil
end

local function usvFindStoreUnitIndex(store, id, worldKey)
	if not store or type(store.units) ~= "table" or not id then
		return nil
	end
	worldKey = worldKey or USV.getWorldSaveKey()
	for i, unit in ipairs(store.units) do
		if type(unit) == "table" and unit.id == id then
			local uw = unit.world
			if uw == nil or uw == worldKey then
				return i
			end
		end
	end
	return nil
end

--- Import units from a legacy v3 per-world store file into the global store.
local function usvImportWorldStoreFile(store, worldKey)
	if type(store) ~= "table" or type(store.units) ~= "table" or not worldKey then
		return 0
	end
	local oldName = USV.contentsWorldStoreFileName(worldKey)
	local storeName = USV.contentsStoreFileName()
	if not oldName or oldName == storeName then
		return 0
	end
	local text = usvReadJsonFile(oldName)
	if not text then
		return 0
	end
	local old = USV.jsonDecode(text)
	if type(old) ~= "table" or type(old.units) ~= "table" then
		return 0
	end
	-- Only import if file world matches (or missing but tag matches current).
	if type(old.world) == "string" and old.world ~= "" and old.world ~= worldKey then
		return 0
	end
	local imported = 0
	local tag = USV.worldFileTag(worldKey)
	for _, unit in ipairs(old.units) do
		if type(unit) == "table" and unit.id then
			unit.world = worldKey
			unit.worldTag = tag
			local idx = usvFindStoreUnitIndex(store, unit.id, worldKey)
			if idx then
				store.units[idx] = unit
			else
				store.units[#store.units + 1] = unit
			end
			imported = imported + 1
		end
	end
	if imported > 0 then
		USV.deleteLuaFile(oldName)
	end
	return imported
end

function USV.loadContentsStore(worldKey)
	worldKey = worldKey or USV.getWorldSaveKey()
	local cache = USV._contentsStoreCache
	if cache and cache.data and type(cache.data.units) == "table" then
		-- Opportunistically import current world's legacy per-world file once per session.
		if not cache.importedWorlds then
			cache.importedWorlds = {}
		end
		if worldKey and not cache.importedWorlds[worldKey] then
			cache.importedWorlds[worldKey] = true
			if usvImportWorldStoreFile(cache.data, worldKey) > 0 then
				USV.saveContentsStore(cache.data)
			end
		end
		if worldKey then
			if not USV._legacyPurgeDone then
				USV._legacyPurgeDone = {}
			end
			if not USV._legacyPurgeDone[worldKey] then
				USV._legacyPurgeDone[worldKey] = true
				USV.purgeLegacyContentsFiles(worldKey)
			end
		end
		return cache.data
	end
	local fileName = USV.contentsStoreFileName()
	local text = usvReadJsonFile(fileName)
	local store = nil
	if text then
		store = USV.jsonDecode(text)
	end
	if type(store) ~= "table" or type(store.units) ~= "table" then
		store = usvEmptyContentsStore()
	else
		store.v = USV.CONTENTS_STORE_VERSION or 4
		-- Strip obsolete top-level world binding from v3 files mistakenly named USV_Store.
		store.world = nil
		store.worldTag = nil
	end
	USV._contentsStoreCache = { data = store, importedWorlds = {} }
	if worldKey then
		USV._contentsStoreCache.importedWorlds[worldKey] = true
		if usvImportWorldStoreFile(store, worldKey) > 0 then
			USV.saveContentsStore(store)
		end
		-- One-shot per world: scrub leftover per-unit / per-world JSON stubs.
		if not USV._legacyPurgeDone then
			USV._legacyPurgeDone = {}
		end
		if not USV._legacyPurgeDone[worldKey] then
			USV._legacyPurgeDone[worldKey] = true
			USV.purgeLegacyContentsFiles(worldKey)
		end
	end
	return store
end

function USV.saveContentsStore(store, _worldKey)
	if type(store) ~= "table" then
		return false
	end
	store.v = USV.CONTENTS_STORE_VERSION or 4
	store.world = nil
	store.worldTag = nil
	if type(store.units) ~= "table" then
		store.units = {}
	end
	local fileName = USV.contentsStoreFileName()
	local json = USV.jsonEncode(store)
	local ok = usvWriteJsonFile(fileName, json)
	if ok then
		local imported = USV._contentsStoreCache and USV._contentsStoreCache.importedWorlds or {}
		USV._contentsStoreCache = { data = store, importedWorlds = imported }
	end
	return ok
end

local function usvUnitToSnapshot(unit, worldKey)
	if type(unit) ~= "table" then
		return nil
	end
	worldKey = worldKey or unit.world or USV.getWorldSaveKey()
	return {
		v = 2,
		id = unit.id,
		world = worldKey,
		worldTag = unit.worldTag or USV.worldFileTag(worldKey),
		kind = unit.kind,
		ownerId = unit.ownerId,
		ownerName = unit.ownerName,
		updated = unit.updated,
		itemCount = unit.itemCount or 0,
		packs = unit.packs or {},
	}
end

local function usvDeleteLegacyUnitFiles(safe, worldKey)
	local tag = USV.worldFileTag(worldKey)
	local storeName = USV.contentsStoreFileName()
	local names = {
		USV.CONTENTS_FILE_PREFIX .. tag .. "_" .. safe .. ".json",
		USV.CONTENTS_FILE_PREFIX_LEGACY .. tag .. "_" .. safe .. ".json",
		USV.CONTENTS_FILE_PREFIX .. safe .. ".json",
		USV.CONTENTS_FILE_PREFIX_LEGACY .. safe .. ".json",
		USV.contentsFileName(safe, false, false),
		USV.contentsFileName(safe, true, false),
		USV.contentsWorldStoreFileName(worldKey), -- old per-world store after unit migrated
	}
	local seen = {}
	for _, fileName in ipairs(names) do
		if fileName and not seen[fileName] and fileName ~= storeName then
			seen[fileName] = true
			USV.deleteLuaFile(fileName)
		end
	end
end

local function usvReadLegacyUnitSnapshot(safe, worldKey)
	local tag = USV.worldFileTag(worldKey)
	local candidates = {
		USV.CONTENTS_FILE_PREFIX .. tag .. "_" .. safe .. ".json",
		USV.CONTENTS_FILE_PREFIX_LEGACY .. tag .. "_" .. safe .. ".json",
		USV.CONTENTS_FILE_PREFIX .. safe .. ".json",
		USV.CONTENTS_FILE_PREFIX_LEGACY .. safe .. ".json",
	}
	for _, name in ipairs(candidates) do
		local text = usvReadJsonFile(name)
		if text then
			local data = USV.jsonDecode(text)
			if data then
				-- Accept matching world, or legacy files with no world field.
				if type(data.world) ~= "string" or data.world == "" or data.world == worldKey then
					return data, name
				end
			end
		end
	end
	return nil, nil
end

function USV.writeContentsSnapshot(id, packsOrData, meta)
	local safe = USV.sanitizeContentsId(id)
	if not safe then
		return false
	end
	local packsDesc = nil
	if type(packsOrData) == "table" and packsOrData.packs then
		packsDesc = packsOrData.packs
	else
		packsDesc = USV.packsToDescriptors(packsOrData)
	end
	local cleaned = USV.sanitizeSnapshotPacks(packsDesc, meta and meta.kind)
	if cleaned then
		packsDesc = cleaned
	end
	local worldKey = USV.getWorldSaveKey()
	local itemCount = 0
	for _, pack in ipairs(packsDesc) do
		itemCount = itemCount + USV.descriptorItemsTotal(pack.items)
	end
	local unit = {
		id = safe,
		world = worldKey,
		worldTag = USV.worldFileTag(worldKey),
		kind = meta and meta.kind or nil,
		ownerId = USV.ownerIdForDisk(meta and meta.ownerId),
		ownerName = (meta and meta.ownerName) or USV.resolveOwnerUserName(meta and meta.ownerId) or nil,
		updated = (getTimestampMs and getTimestampMs()) or 0,
		itemCount = itemCount,
		packs = packsDesc,
	}
	local store = USV.loadContentsStore(worldKey)
	local idx = usvFindStoreUnitIndex(store, safe, worldKey)
	if idx then
		store.units[idx] = unit
	else
		store.units[#store.units + 1] = unit
	end
	local fileName = USV.contentsStoreFileName()
	local ok = USV.saveContentsStore(store)
	if ok then
		usvDeleteLegacyUnitFiles(safe, worldKey)
	end
	return ok
end

function USV.readContentsSnapshot(id)
	local safe = USV.sanitizeContentsId(id)
	if not safe then
		return nil
	end
	local worldKey = USV.getWorldSaveKey()
	local store = USV.loadContentsStore(worldKey)
	local idx = usvFindStoreUnitIndex(store, safe, worldKey)
	if idx then
		local unit = store.units[idx]
		-- Refuse cross-world unit if world is set and mismatched.
		if type(unit.world) == "string" and unit.world ~= "" and unit.world ~= worldKey then
			return nil
		end
		local data = usvUnitToSnapshot(unit, worldKey)
		return data
	end
	-- Migrate legacy per-unit file into the unified store once.
	local legacy, used = usvReadLegacyUnitSnapshot(safe, worldKey)
	if not legacy then
		return nil
	end
	local unit = {
		id = safe,
		world = worldKey,
		worldTag = USV.worldFileTag(worldKey),
		kind = legacy.kind,
		ownerId = legacy.ownerId,
		ownerName = legacy.ownerName,
		updated = legacy.updated,
		itemCount = legacy.itemCount or 0,
		packs = legacy.packs or {},
	}
	store.units[#store.units + 1] = unit
	USV.saveContentsStore(store)
	usvDeleteLegacyUnitFiles(safe, worldKey)
	return usvUnitToSnapshot(unit, worldKey)
end

function USV.deleteContentsSnapshot(id)
	local safe = USV.sanitizeContentsId(id)
	if not safe then
		return false
	end
	local worldKey = USV.getWorldSaveKey()
	local store = USV.loadContentsStore(worldKey)
	local idx = usvFindStoreUnitIndex(store, safe, worldKey)
	local removed = false
	if idx then
		table.remove(store.units, idx)
		removed = USV.saveContentsStore(store)
	end
	usvDeleteLegacyUnitFiles(safe, worldKey)
	return true
end

--- Resolve absolute path under Zomboid/Lua/ for getFileWriter-relative names.
function USV.luaFolderAbsolutePath(relName)
	if not relName or relName == "" then
		return nil
	end
	local sep = "/"
	pcall(function()
		if getFileSeparator then
			sep = getFileSeparator()
		end
	end)
	local bases = {}
	local function addBase(b)
		if type(b) == "string" and b ~= "" then
			bases[#bases + 1] = b
		end
	end
	pcall(function()
		if getCore and getCore() and getCore().getMyDocumentFolder then
			addBase(getCore():getMyDocumentFolder())
		end
	end)
	pcall(function()
		if ZomboidFileSystem and ZomboidFileSystem.instance and ZomboidFileSystem.instance.getMyDocumentFolder then
			addBase(ZomboidFileSystem.instance:getMyDocumentFolder())
		end
	end)
	pcall(function()
		if ZomboidFileSystem and ZomboidFileSystem.instance and ZomboidFileSystem.instance.getCacheDir then
			addBase(ZomboidFileSystem.instance:getCacheDir())
		end
	end)
	local seen = {}
	local out = {}
	for _, base in ipairs(bases) do
		local normalized = tostring(base)
		-- Avoid .../Lua/Lua when the API already points at Lua/.
		local withLua = normalized
		if not string.find(string.lower(normalized), "[/\\]lua[/\\]?$") then
			withLua = normalized .. sep .. "Lua"
		end
		local abs = withLua .. sep .. tostring(relName)
		if not seen[abs] then
			seen[abs] = true
			out[#out + 1] = abs
		end
	end
	return out[1], out
end

local function usvFileStillReadable(relName)
	local text = usvReadJsonFile(relName)
	return text ~= nil and text ~= ""
end

--- Truly delete a Lua-folder file (not just empty-overwrite).
function USV.deleteLuaFile(relName)
	if not relName or relName == "" then
		return false
	end
	if relName == (USV.CONTENTS_STORE_FILE or "USV_Store.json") then
		return false
	end
	local primary, allAbs = USV.luaFolderAbsolutePath(relName)
	allAbs = allAbs or (primary and { primary } or {})
	local deleted = false
	local function tryAbs(abs)
		if not abs or deleted then
			return
		end
		pcall(function()
			if ZomboidFileSystem and ZomboidFileSystem.instance then
				local fs = ZomboidFileSystem.instance
				if fs.tryDeleteFile then
					fs:tryDeleteFile(abs)
				end
				if fs.deleteFile then
					fs:deleteFile(abs)
				end
			end
		end)
		pcall(function()
			local f = nil
			if luajava and luajava.newInstance then
				f = luajava.newInstance("java.io.File", abs)
			end
			if f and f.exists and f:exists() and f.delete then
				if f:delete() then
					deleted = true
				end
			end
		end)
		if not deleted and os and os.remove then
			local ok = pcall(os.remove, abs)
			if ok then
				deleted = true
			end
		end
	end
	-- Relative name (some FS helpers expect Lua/-relative paths).
	pcall(function()
		if ZomboidFileSystem and ZomboidFileSystem.instance and ZomboidFileSystem.instance.tryDeleteFile then
			ZomboidFileSystem.instance:tryDeleteFile(relName)
		end
	end)
	for _, abs in ipairs(allAbs) do
		tryAbs(abs)
	end
	-- Authority: if getFileReader can no longer open it, treat as deleted.
	if not usvFileStillReadable(relName) then
		deleted = true
	end
	-- Do NOT write tombstone stubs — that recreates files the user sees as "not consolidated".
	return deleted
end

--- After unified store is authoritative: remove leftover USV_*.json / USV_Contents_*.json stubs.
function USV.purgeLegacyContentsFiles(worldKey)
	worldKey = worldKey or USV.getWorldSaveKey()
	local storeName = USV.CONTENTS_STORE_FILE or "USV_Store.json"
	local removed = 0
	local failed = 0
	local store = USV._contentsStoreCache and USV._contentsStoreCache.data or nil
	if type(store) == "table" and type(store.units) == "table" then
		for _, unit in ipairs(store.units) do
			if type(unit) == "table" and unit.id then
				local safe = USV.sanitizeContentsId(unit.id)
				local wk = unit.world or worldKey
				if safe then
					usvDeleteLegacyUnitFiles(safe, wk)
				end
			end
		end
	end
	-- Always try current-world legacy names + common stub patterns.
	local tag = USV.worldFileTag(worldKey)
	local extras = {
		USV.contentsWorldStoreFileName(worldKey),
		USV.CONTENTS_FILE_PREFIX .. tag .. ".json",
		USV.CONTENTS_FILE_PREFIX_LEGACY .. tag .. ".json",
	}
	if type(store) == "table" and type(store.units) == "table" then
		for _, unit in ipairs(store.units) do
			if type(unit) == "table" and unit.id then
				local safe = USV.sanitizeContentsId(unit.id)
				if safe then
					extras[#extras + 1] = USV.CONTENTS_FILE_PREFIX .. safe .. ".json"
					extras[#extras + 1] = USV.CONTENTS_FILE_PREFIX_LEGACY .. safe .. ".json"
					extras[#extras + 1] = USV.CONTENTS_FILE_PREFIX .. tag .. "_" .. safe .. ".json"
					extras[#extras + 1] = USV.CONTENTS_FILE_PREFIX_LEGACY .. tag .. "_" .. safe .. ".json"
				end
			end
		end
	end
	-- Directory sweep: any USV_*.json except the unified store.
	pcall(function()
		local _, absList = USV.luaFolderAbsolutePath(".")
		local luaDirs = {}
		if absList then
			for _, absDot in ipairs(absList) do
				local dir = string.gsub(absDot, "[/\\]%.$", "")
				luaDirs[#luaDirs + 1] = dir
			end
		end
		for _, dir in ipairs(luaDirs) do
			local list = nil
			if luajava and luajava.newInstance then
				local f = luajava.newInstance("java.io.File", dir)
				if f and f.list then
					list = f:list()
				end
			end
			if list then
				local n = list.length or (list.length == nil and #list) or 0
				-- Java String[] may expose :length or be iterable via size-like APIs.
				local count = 0
				pcall(function()
					count = list.length
				end)
				if not count or count == 0 then
					pcall(function()
						count = #list
					end)
				end
				for i = 0, (count or 0) - 1 do
					local name = nil
					pcall(function()
						name = list[i] or list:get(i)
					end)
					if type(name) == "string" then
						local lower = string.lower(name)
						if lower ~= string.lower(storeName)
							and string.match(lower, "^usv_.*%.json$")
							and not string.match(lower, "^usv_serversecret")
						then
							extras[#extras + 1] = name
						end
					end
				end
			end
		end
	end)
	local seen = {}
	for _, fileName in ipairs(extras) do
		if fileName and not seen[fileName] and fileName ~= storeName then
			seen[fileName] = true
			if usvFileStillReadable(fileName) then
				if USV.deleteLuaFile(fileName) then
					removed = removed + 1
				else
					failed = failed + 1
				end
			end
		end
	end
	return removed, failed
end

function USV.snapshotPacksFromEntity(entity)
	local packs = {}
	local containers = USV.collectContainers(entity)
	for index, cont in ipairs(containers) do
		if cont and not USV.containerIsCharacterInventory(cont) then
			local pack = { index = index - 1, type = "", items = {} }
			pcall(function()
				pack.type = cont.getType and tostring(cont:getType() or "") or ""
			end)
			pcall(function()
				local items = cont.getItems and cont:getItems() or nil
				if items then
					for j = 0, items:size() - 1 do
						local invItem = items:get(j)
						if invItem and invItem ~= entity and not USV.isUSVFurnitureItem(invItem) then
							local desc = USV.serializeInventoryItem(invItem)
							if desc then
								pack.items[#pack.items + 1] = desc
							end
						end
					end
				end
			end)
			packs[#packs + 1] = pack
		end
	end
	return packs
end

function USV.getContainerWorldObject(container)
	if not container then
		return nil
	end
	local parent = nil
	pcall(function()
		parent = container.getParent and container:getParent() or nil
	end)
	if parent and USV.isLegitimateUSVObject(parent) then
		return parent
	end
	parent = USV.resolveContainerParent(container)
	if parent and USV.isLegitimateUSVObject(parent) then
		return parent
	end
	return nil
end

function USV.ensureContentsIdForEntity(entity, ownerId, kind)
	local id = USV.getEntityContentsId(entity)
	if id and id ~= "" then
		return id
	end
	id = USV.newContentsId(ownerId, kind)
	USV.setEntityContentsId(entity, id)
	return id
end

function USV.syncEntityContentsSnapshot(entity)
	if not entity then
		return false
	end
	local md = nil
	pcall(function()
		md = entity.getModData and entity:getModData() or nil
	end)
	local kind = (md and md[USV.KIND_FLAG]) or USV.getObjectKind(entity) or "vault"
	local ownerId = md and md[USV.OWNER_FLAG] or nil
	local id = USV.ensureContentsIdForEntity(entity, ownerId, kind)
	local packs = USV.snapshotPacksFromEntity(entity)
	return USV.writeContentsSnapshot(id, packs, {
		kind = kind,
		ownerId = ownerId,
		ownerName = USV.resolveOwnerUserName(ownerId),
	})
end

function USV.saveCarryContentsSnapshot(carryItem, packs, kind, ownerId, existingId)
	if not carryItem then
		return nil
	end
	local id = existingId or USV.getEntityContentsId(carryItem) or USV.newContentsId(ownerId, kind)
	USV.setEntityContentsId(carryItem, id)
	local ownerName = USV.resolveOwnerUserName(ownerId)
	USV.writeContentsSnapshot(id, packs, { kind = kind, ownerId = ownerId, ownerName = ownerName })
	if isClient and isClient() and not (isServer and isServer()) and sendClientCommand then
		local args = {
			id = id,
			kind = kind,
			ownerId = ownerId,
			ownerName = ownerName,
			packs = USV.packsToDescriptors(packs),
		}
		pcall(function()
			local player = nil
			if getSpecificPlayer then
				player = getSpecificPlayer(0)
			end
			if player then
				sendClientCommand(player, "USV", "SaveContents", args)
			end
		end)
	end
	return id
end

function USV.restoreContentsFromSnapshot(entity, contentsId)
	if not entity or not contentsId then
		return 0
	end
	local data = USV.readContentsSnapshot(contentsId)
	if not data or not data.packs then
		return 0
	end
	-- Extra guard: never restore another world's stash even if file was copied.
	local worldKey = USV.getWorldSaveKey()
	if data.world and data.world ~= worldKey then
		return 0
	end
	local packs = USV.descriptorsToPacks(data)
	local n = USV.depositContainerItems(entity, packs)
	return n
end

--- Add one item to a container (DoAddItemBlind for USV unlimited containers).
function USV.addItemToContainerSafe(cont, invItem)
	if not cont or not invItem then
		return false
	end
	if USV.isUnlimitedContainer(cont) then
		USV.ensureContainerCapacity(cont)
		if cont.isItemAllowed then
			local okA, allow = pcall(function()
				return cont:isItemAllowed(invItem)
			end)
			if okA and not allow then
				return false
			end
		end
		if type(USV._rawDoAddItemBlind) == "function" then
			local ok, res = pcall(USV._rawDoAddItemBlind, cont, invItem)
			if ok and res ~= nil then
				if isServer and isServer() and sendAddItemToContainer then
					pcall(function()
						sendAddItemToContainer(cont, invItem)
					end)
				end
				return true
			end
		end
		local okB, resB = pcall(function()
			return cont:DoAddItemBlind(invItem)
		end)
		if okB and resB ~= nil then
			if isServer and isServer() and sendAddItemToContainer then
				pcall(function()
					sendAddItemToContainer(cont, invItem)
				end)
			end
			return true
		end
		return false
	end
	local added = false
	pcall(function()
		if cont.DoAddItem then
			local r = cont:DoAddItem(invItem)
			added = r ~= nil
		elseif cont.AddItem then
			local r = cont:AddItem(invItem)
			added = r ~= nil
		end
		if added and isServer and isServer() and sendAddItemToContainer then
			sendAddItemToContainer(cont, invItem)
		end
	end)
	return added
end

function USV.packsItemCount(packs)
	local n = 0
	if not packs then
		return 0
	end
	for _, pack in ipairs(packs) do
		if pack.items then
			for _, it in ipairs(pack.items) do
				if type(it) == "table" and it.ft then
					local c = tonumber(it.count) or 1
					if c < 1 then
						c = 1
					end
					n = n + c
				else
					n = n + 1 -- live InventoryItem refs
				end
			end
		end
	end
	return n
end

function USV.restoreCarryPacksToItem(item, packs)
	if not item or not packs or USV.packsItemCount(packs) <= 0 then
		return false
	end
	USV.storeCarryPacks(item, packs)
	return true
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
					if USV.addItemToContainerSafe(cont, invItem) then
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
	if USV.isAuthorizedCarryItem(item) then
		return true
	end
	if item.getModData then
		local ok, md = pcall(function()
			return item:getModData()
		end)
		if ok and md and md[USV.FLAG] == true and (md[USV.OWNER_FLAG] or md[USV.KIND_FLAG]) then
			return true
		end
	end
	return false
end

--- Picked-up vault/fridge: inventory burden should be MOVEABLE_CARRY_WEIGHT (contents ignored).
function USV.useFixedCarryWeight(item)
	if not item then
		return false
	end
	if USV.isUSVCarryItem(item) or USV.isUSVMoveableItem(item) or USV.isUSVFurnitureItem(item) then
		return true
	end
	if item.getModData then
		local ok, md = pcall(function()
			return item:getModData()
		end)
		if ok and md and md[USV.WEIGHTLESS_FLAG] == true then
			return true
		end
	end
	return false
end

function USV.getContainerParentItem(container)
	if not container or not container.getContainingItem then
		return nil
	end
	local parentItem = nil
	pcall(function()
		parentItem = container:getContainingItem()
	end)
	return parentItem
end

--- ItemContainer that belongs to a wearable or world-placed bag (not player main inventory).
function USV.containerIsBagInventory(container)
	if not container then
		return false
	end
	local parentItem = USV.getContainerParentItem(container)
	if not parentItem then
		return false
	end
	if instanceof then
		local ok, isBag = pcall(function()
			if instanceof(parentItem, "InventoryContainer") then
				return true
			end
			if parentItem.IsInventoryContainer and parentItem:IsInventoryContainer() then
				return true
			end
			return false
		end)
		if ok and isBag then
			return true
		end
	end
	return false
end

--- USV vault/fridge must not nest inside bags; may use other containers (e.g. vehicle).
function USV.usvFurnitureBlockedInContainer(item, destContainer)
	if not item or not destContainer then
		return false, nil
	end
	if not USV.isUSVFurnitureItem(item) and not USV.useFixedCarryWeight(item) then
		return false, nil
	end
	if USV.containerIsBagInventory(destContainer) then
		return true, "bag"
	end
	return false, nil
end

--- True if an in-world object is a registered USV furniture item (not vanilla lookalike tiles).
function USV.isUSVMoveableObject(obj, _spriteName)
	if not obj then
		return false
	end
	return USV.isLegitimateUSVObject(obj)
end

function USV.parentLooksLikeUSV(parent)
	return USV.isLegitimateUSVObject(parent)
end

--- Authoritative capacity: FLAG / custom-name alone is not enough (anti forge).
function USV.isCapacityTrustedParent(obj)
	if not obj then
		return false
	end
	if unlimitedParentRegistry[obj] then
		return true
	end
	if USV.isTrustedUSVObject(obj) then
		return true
	end
	if USV.isAuthoritative() and USV.verifyAuthToken(obj) then
		return true
	end
	if USV.isRegisteredPlacementObject(obj) and USV.isFlaggedObject(obj) then
		return true
	end
	return false
end

function USV.playerNearObjectOrSquare(player, obj, sq, maxDist)
	if not player then
		return false
	end
	maxDist = maxDist or USV.BLIND_XFER_MAX_DIST or 12
	local ps = nil
	pcall(function()
		ps = player.getSquare and player:getSquare() or nil
	end)
	if not ps then
		return false
	end
	local tx, ty, tz = nil, nil, 0
	if obj and obj.getSquare then
		pcall(function()
			local osq = obj:getSquare()
			if osq then
				tx, ty, tz = osq:getX(), osq:getY(), osq:getZ() or 0
			end
		end)
	end
	if (tx == nil) and sq then
		pcall(function()
			tx, ty, tz = sq:getX(), sq:getY(), sq:getZ() or 0
		end)
	end
	if tx == nil then
		return false
	end
	local dx = math.abs((ps:getX() or 0) - tx)
	local dy = math.abs((ps:getY() or 0) - ty)
	local dz = math.abs((ps:getZ() or 0) - (tz or 0))
	return dx <= maxDist and dy <= maxDist and dz <= 1
end

function USV.allowClientCommand(player, command)
	if not player then
		return false
	end
	local id = USV.getOwnerId(player) or tostring(player)
	USV._cmdRate = USV._cmdRate or {}
	local now = (getTimestampMs and getTimestampMs()) or (os.time() * 1000)
	local window = USV.CLIENT_CMD_RATE_WINDOW_MS or 1000
	local limit = USV.CLIENT_CMD_RATE_LIMIT or 80
	local bucket = USV._cmdRate[id]
	if not bucket or (now - (bucket.t or 0)) > window then
		USV._cmdRate[id] = { t = now, n = 1, cmd = command }
		return true
	end
	bucket.n = (bucket.n or 0) + 1
	if bucket.n > limit then
		return false
	end
	return true
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

	-- Server / SP: never grant unlimited from forged FLAG or renamed customName alone.
	if USV.isAuthoritative() then
		if parent and USV.isCapacityTrustedParent(parent) then
			USV.rememberUnlimitedParent(parent)
			USV.rememberUnlimitedContainer(container, true)
			USV.ensureContainerCapacity(container)
			return true
		end
		return false
	end

	-- Client soft path (UI / prediction only — server rejects forged BlindTransfer).
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

	if USV.isLegitimateUSVObject(parent) then
		USV.rememberUnlimitedParent(parent)
		USV.rememberUnlimitedContainer(container, true)
		USV.ensureContainerCapacity(container)
		return true
	end

	return false
end

function USV.getUSVKindForContainer(container)
	if not container then
		return nil
	end
	local parent = nil
	pcall(function()
		parent = container.getParent and container:getParent() or nil
	end)
	if not parent then
		parent = USV.resolveContainerParent(container)
	end
	if not parent then
		return nil
	end
	return USV.getObjectKind(parent)
end

function USV.containerCustomNameLooksLikeFridge(container)
	if not container or not container.getCustomName then
		return false
	end
	local ok, cname = pcall(function()
		return container:getCustomName()
	end)
	if not ok or not cname or cname == "" then
		return false
	end
	local s = tostring(cname)
	local def = USV.KINDS.fridge
	if def then
		local keyName = getText and getText(def.containerNameKey) or nil
		if keyName and keyName ~= "" and s == keyName then
			return true
		end
		if def.containerNameFallback and s == def.containerNameFallback then
			return true
		end
	end
	if string.find(s, "Fridge", 1, true) or string.find(s, "冷蔵", 1, true) then
		return true
	end
	return false
end

--- True when this unlimited container belongs to a USV commercial fridge (not vault).
function USV.containerIsUSVFridge(container)
	if not container then
		return false
	end
	local kind = USV.getUSVKindForContainer(container)
	if kind == "fridge" then
		return true
	end
	if kind == "vault" then
		local parent = nil
		pcall(function()
			parent = container.getParent and container:getParent() or nil
		end)
		if not parent then
			parent = USV.resolveContainerParent(container)
		end
		if parent and USV.resolveSpriteKind(USV.getSpriteNameFast(parent)) == "fridge" then
			return true
		end
		return false
	end
	if not USV.isUnlimitedContainer(container) then
		return false
	end
	local ctype = ""
	pcall(function()
		ctype = container.getType and tostring(container:getType() or "") or ""
	end)
	if ctype == "fridge" or ctype == "freezer" then
		return true
	end
	return USV.containerCustomNameLooksLikeFridge(container)
end

function USV.containerFridgeCompartmentType(container)
	local ctype = ""
	pcall(function()
		ctype = container.getType and tostring(container:getType() or "") or ""
	end)
	return ctype
end

function USV.instanceofAny(item, ...)
	if not item or not instanceof then
		return false
	end
	local n = select("#", ...)
	for i = 1, n do
		local cls = select(i, ...)
		local ok, yes = pcall(function()
			return instanceof(item, cls)
		end)
		if ok and yes then
			return true
		end
	end
	return false
end

--- Non-food classes/categories that must never enter USV fridges (ammo, ID, tools, etc.).
function USV.itemFridgeHardDeny(item)
	if not item then
		return true
	end
	if USV.instanceofAny(
		item,
		"HandWeapon",
		"Clothing",
		"InventoryContainer",
		"Literature",
		"MapItem",
		"AlarmClock",
		"Radio"
	) then
		return true
	end
	local dc = USV.itemScriptDisplayCategory(item)
	if dc then
		local denyCat = {
			Ammo = true,
			Weapon = true,
			WeaponPart = true,
			Literature = true,
			Tool = true,
			Electronics = true,
			Communications = true,
			Cartography = true,
			Container = true,
			Camping = true,
			Fishing = true,
			Trapping = true,
			Gardening = true,
			Household = true,
			Material = true,
			Mechanics = true,
			Media = true,
			Clothing = true,
			Accessory = true,
			Appearance = true,
			Animal = true,
			SkillBook = true,
		}
		if denyCat[dc] then
			return true
		end
	end
	local uiCat = nil
	pcall(function()
		if item.getDisplayCategory then
			uiCat = item:getDisplayCategory()
		end
	end)
	if uiCat and uiCat ~= "" then
		local denyUi = {
			Ammo = true,
			Weapon = true,
			Literature = true,
			Tool = true,
			Electronics = true,
			Cartography = true,
		}
		if denyUi[uiCat] then
			return true
		end
		if getText then
			local ammoLbl = getText("IGUI_ItemCategory_Ammo")
			if ammoLbl and ammoLbl ~= "" and ammoLbl ~= "IGUI_ItemCategory_Ammo" and uiCat == ammoLbl then
				return true
			end
			local weapLbl = getText("IGUI_ItemCategory_Weapon")
			if weapLbl and weapLbl ~= "" and weapLbl ~= "IGUI_ItemCategory_Weapon" and uiCat == weapLbl then
				return true
			end
		end
	end
	local ft = string.lower(USV.itemFullType(item))
	local denyFt = {
		"bullet",
		"bullets",
		"ammo",
		"shell",
		"shotgun",
		"cartridge",
		"idcard",
		"id_card",
		"identification",
		"magazine",
		"9mm",
		"45auto",
		"223",
		"308",
		"556",
		"762",
	}
	for i = 1, #denyFt do
		if string.find(ft, denyFt[i], 1, true) then
			return true
		end
	end
	return false
end

--- Food/drink rules for USV fridge compartments (no script-nutrition heuristic).
function USV.isFridgeFoodItemStrict(item)
	if not item or USV.isUSVFurnitureItem(item) or USV.isTobaccoItem(item) then
		return false
	end
	if USV.itemFridgeHardDeny(item) then
		return false
	end
	if instanceof then
		local okW, isWeapon = pcall(function()
			return instanceof(item, "HandWeapon")
		end)
		if okW and isWeapon then
			return false
		end
		local okC, isCloth = pcall(function()
			return instanceof(item, "Clothing")
		end)
		if okC and isCloth then
			return false
		end
		local ok, isFoodClass = pcall(function()
			return instanceof(item, "Food")
		end)
		if ok and isFoodClass then
			return true
		end
	end
	local isFoodFlag = false
	pcall(function()
		if type(item.IsFood) == "function" then
			isFoodFlag = item:IsFood() and true or false
		elseif type(item.isFood) == "function" then
			isFoodFlag = item:isFood() and true or false
		end
	end)
	if isFoodFlag then
		return true
	end
	if USV.itemScriptCategoryFoodOrDrink(item) or USV.itemUiCategoryIsFoodOrDrink(item) then
		return true
	end
	if USV.isConsumableDrainable(item) then
		return true
	end
	return false
end

function USV.itemAllowedInUSVFridge(container, item, oldIsItemAllowed, ...)
	if not item or not container or type(oldIsItemAllowed) ~= "function" then
		return false
	end
	if not USV.isInventoryItemArg(item) then
		return false
	end
	if USV.isTobaccoItem(item) then
		return false
	end
	if USV.itemFridgeHardDeny(item) or not USV.isFridgeFoodItemStrict(item) then
		return false
	end
	local ok, allow = pcall(oldIsItemAllowed, container, item, ...)
	local allowed = ok and allow == true
	if allowed then
	end
	return allowed
end

function USV.itemScriptDisplayCategory(item)
	if not item then
		return nil
	end
	local dc = nil
	pcall(function()
		local script = item.getScript and item:getScript() or nil
		if script and script.getDisplayCategory then
			dc = script:getDisplayCategory()
		end
	end)
	return dc
end

function USV.itemFullType(item)
	if not item then
		return ""
	end
	local ft = ""
	pcall(function()
		if item.getFullType then
			ft = tostring(item:getFullType() or "")
		elseif item.getType and item.getModule then
			ft = tostring(item:getModule()) .. "." .. tostring(item:getType())
		end
	end)
	return ft
end

function USV.isInventoryItemArg(obj)
	if not obj then
		return false
	end
	if instanceof then
		local okSkip, skip = pcall(function()
			return instanceof(obj, "IsoGameCharacter")
				or instanceof(obj, "IsoPlayer")
				or instanceof(obj, "IsoZombie")
		end)
		if okSkip and skip then
			return false
		end
		local ok, yes = pcall(function()
			return instanceof(obj, "InventoryItem")
		end)
		if ok then
			return yes == true
		end
	end
	if type(obj.getFullType) == "function" then
		local ft = ""
		pcall(function()
			ft = tostring(obj:getFullType() or "")
		end)
		return ft ~= "" and string.find(ft, "%.") ~= nil
	end
	return false
end

--- First InventoryItem argument in hasRoomFor(...); B42 may pass (player, item) or (item).
function USV.pickInventoryItemArg(...)
	local n = select("#", ...)
	local fallback = nil
	for i = 1, n do
		local a = select(i, ...)
		if not a then
			-- skip
		elseif instanceof then
			local okItem, isItem = pcall(function()
				return instanceof(a, "InventoryItem")
			end)
			if okItem and isItem then
				return a
			end
		elseif type(a.getFullType) == "function" then
			fallback = fallback or a
		end
	end
	if fallback and USV.isInventoryItemArg(fallback) then
		return fallback
	end
	return nil
end

function USV.itemScriptHasTag(item, tagName)
	if not item or not tagName or tagName == "" then
		return false
	end
	local function tagMatches(t)
		return t ~= nil and tostring(t) == tagName
	end
	local function scanTagList(tags)
		if not tags or type(tags.size) ~= "function" then
			return false
		end
		local n = 0
		local okN, count = pcall(function()
			return tags:size()
		end)
		if not okN or not count then
			return false
		end
		n = count
		for i = 0, n - 1 do
			local okT, t = pcall(function()
				if type(tags.get) == "function" then
					return tags:get(i)
				end
				return nil
			end)
			if okT and tagMatches(t) then
				return true
			end
		end
		return false
	end
	local ok, found = pcall(function()
		if type(item.getTags) == "function" then
			local okTags, tags = pcall(function()
				return item:getTags()
			end)
			if okTags and scanTagList(tags) then
				return true
			end
		end
		local script = nil
		if type(item.getScriptItem) == "function" then
			local okS, s = pcall(function()
				return item:getScriptItem()
			end)
			if okS then
				script = s
			end
		end
		if not script and type(item.getScript) == "function" then
			local okS, s = pcall(function()
				return item:getScript()
			end)
			if okS then
				script = s
			end
		end
		if script and type(script.getTags) == "function" then
			local okTags, tags = pcall(function()
				return script:getTags()
			end)
			if okTags and scanTagList(tags) then
				return true
			end
		end
		return false
	end)
	return ok and found == true
end

--- Cigarettes / cigars / tobacco mods — never treat as fridge food.
function USV.isTobaccoItem(item)
	if not item or not USV.isInventoryItemArg(item) then
		return false
	end
	local ft = USV.itemFullType(item)
	if ft ~= "" then
		if string.find(ft, "KnoxCountySmokes", 1, true) then
			return true
		end
		local lower = string.lower(ft)
		for _, token in ipairs({ "cigarette", "cigarettes", "tobacco", "cigar", "cigars", "smoking", "smokes." }) do
			if string.find(lower, token, 1, true) then
				return true
			end
		end
	end
	local dc = USV.itemScriptDisplayCategory(item)
	if dc == "Smokes" or dc == "Tobacco" then
		return true
	end
	for _, tag in ipairs({ "Smokes", "Tobacco", "Cigarette", "Cigar" }) do
		if USV.itemScriptHasTag(item, tag) then
			return true
		end
	end
	return false
end

function USV.itemUiCategoryIsFoodOrDrink(item)
	if not item then
		return false
	end
	local cat = nil
	pcall(function()
		if item.getDisplayCategory then
			cat = item:getDisplayCategory()
		end
	end)
	if not cat or cat == "" then
		return false
	end
	local labels = { "Food", "Drink", "Water" }
	if getText then
		labels[#labels + 1] = getText("IGUI_ItemCategory_Food")
		local drink = getText("IGUI_ItemCategory_Drink")
		if drink and drink ~= "" and drink ~= "IGUI_ItemCategory_Drink" then
			labels[#labels + 1] = drink
		end
	end
	for i = 1, #labels do
		if labels[i] and cat == labels[i] then
			return true
		end
	end
	return false
end

function USV.itemScriptCategoryFoodOrDrink(item)
	local dc = USV.itemScriptDisplayCategory(item)
	return dc == "Food" or dc == "Drink" or dc == "Water"
end

function USV.itemScriptHasNutrition(item)
	local ok = false
	pcall(function()
		local script = item.getScript and item:getScript() or nil
		if not script then
			return
		end
		if script.getCalories and (script:getCalories() or 0) > 0 then
			ok = true
		end
		if script.getHungerChange and (script:getHungerChange() or 0) ~= 0 then
			ok = true
		end
		if script.getThirstChange and (script:getThirstChange() or 0) ~= 0 then
			ok = true
		end
	end)
	return ok
end

function USV.isConsumableDrainable(item)
	if not item then
		return false
	end
	local isDrain = false
	pcall(function()
		isDrain = item.IsDrainable and item:IsDrainable() and true or false
	end)
	if not isDrain then
		return false
	end
	local ft = string.lower(USV.itemFullType(item))
	if string.find(ft, "gasoline", 1, true) or string.find(ft, "petrol", 1, true) then
		return false
	end
	if USV.itemScriptCategoryFoodOrDrink(item) or USV.itemUiCategoryIsFoodOrDrink(item) then
		return true
	end
	local hasEffect = false
	pcall(function()
		if item.getHungChange and (item:getHungChange() or 0) ~= 0 then
			hasEffect = true
		end
		if item.getThirstChange and (item:getThirstChange() or 0) ~= 0 then
			hasEffect = true
		end
	end)
	return hasEffect
end

--- Fridge contents: food/drink (incl. juice, alcohol, mod food). Tobacco excluded.
function USV.isFridgeFoodItem(item)
	if not item or USV.isUSVFurnitureItem(item) or USV.isTobaccoItem(item) then
		return false
	end
	if instanceof then
		local ok, isFoodClass = pcall(function()
			return instanceof(item, "Food")
		end)
		if ok and isFoodClass then
			return true
		end
	end
	local isFoodFlag = false
	pcall(function()
		if type(item.IsFood) == "function" then
			isFoodFlag = item:IsFood() and true or false
		elseif type(item.isFood) == "function" then
			isFoodFlag = item:isFood() and true or false
		end
	end)
	if isFoodFlag then
		return true
	end
	if USV.itemScriptCategoryFoodOrDrink(item) or USV.itemUiCategoryIsFoodOrDrink(item) then
		return true
	end
	if USV.isConsumableDrainable(item) then
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
			local spr = USV.getSpriteNameFast(obj)
			local isOwner = obj
				and (USV.isLegitimateUSVObject(obj) or USV.isFlaggedObject(obj) or USV.resolveSpriteKind(spr) ~= nil)
			if isOwner then
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
		elseif USV.isAuthoritative() and USV.isFlaggedObject(obj) and not USV.isTrustedUSVObject(obj)
			and not USV.isRegisteredPlacementObject(obj) then
			-- Forged FLAG / KIND without seal or registry — strip so capacity bypass cannot stick.
			USV.stripUntrustedFlags(obj)
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
			local transferItem = USV.pickInventoryItemArg(...)
			if transferItem and USV.useFixedCarryWeight(transferItem) then
				if USV.containerIsBagInventory(self) then
					return false
				end
				if not isUnlimitedSafe(self) then
					local carryW = USV.MOVEABLE_CARRY_WEIGHT or 1
					local maxW = 0
					pcall(function()
						maxW = self:getMaxWeight()
					end)
					local used = 0
					pcall(function()
						used = self:getCapacityWeight()
					end)
					if maxW > 0 and used + carryW > maxW + 0.001 then
						return false
					end
					if self.isItemAllowed then
						local okAllow, allowed = pcall(function()
							return self:isItemAllowed(transferItem)
						end)
						if okAllow and not allowed then
							return false
						end
					end
					return true
				end
			end
			if isUnlimitedSafe(self) then
				USV.ensureContainerCapacity(self)
				local fridge = USV.containerIsUSVFridge(self)
				if transferItem and self.isItemAllowed then
					local okAllow, allowed = pcall(function()
						return self:isItemAllowed(transferItem)
					end)
					if not okAllow then
						if fridge then
							return false
						end
					elseif not allowed then
						return false
					end
				elseif fridge then
					return oldHasRoomFor(self, ...)
				end
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
	local function usvRejectItemAdd(container, item)
		if not item or not container or not container.isItemAllowed then
			return false
		end
		local ok, allowed = pcall(function()
			return container:isItemAllowed(item)
		end)
		if USV.containerIsUSVFridge(container) then
			return (not ok) or (not allowed)
		end
		return ok and not allowed
	end

	if type(oldAddItem) == "function" then
		index.AddItem = function(self, first, ...)
			if isUnlimitedSafe(self) then
				USV.ensureContainerCapacity(self)
				local argc = select("#", ...)
				if first ~= nil and type(first) ~= "string" and argc == 0 then
					if usvRejectItemAdd(self, first) then
						return nil
					end
					if type(oldDoAddItemBlind) == "function" then
						local ok, result = pcall(oldDoAddItemBlind, self, first)
						if ok then
							return result
						end
					end
				end
			end
			return oldAddItem(self, first, ...)
		end
	end
	if type(oldDoAddItem) == "function" then
		index.DoAddItem = function(self, first, ...)
			if isUnlimitedSafe(self) and first ~= nil then
				USV.ensureContainerCapacity(self)
				if type(first) ~= "string" and usvRejectItemAdd(self, first) then
					return nil
				end
				if type(oldDoAddItemBlind) == "function" then
					local ok, result = pcall(oldDoAddItemBlind, self, first)
					if ok then
						return result
					end
				end
			end
			return oldDoAddItem(self, first, ...)
		end
	end
	if type(oldDoAddItemBlind) == "function" then
		index.DoAddItemBlind = function(self, first, ...)
			if isUnlimitedSafe(self) then
				USV.ensureContainerCapacity(self)
				if first ~= nil and type(first) ~= "string" and usvRejectItemAdd(self, first) then
					return nil
				end
			end
			return oldDoAddItemBlind(self, first, ...)
		end
	end
	if type(oldIsItemAllowed) == "function" then
		index.isItemAllowed = function(self, item, ...)
			if item and not USV.isInventoryItemArg(item) then
				if isUnlimitedSafe(self) and USV.containerIsUSVFridge(self) then
					return false
				end
				return oldIsItemAllowed(self, item, ...)
			end
			local blocked, why = USV.usvFurnitureBlockedInContainer(item, self)
			if blocked then
				local destType = ""
				pcall(function()
					destType = self.getType and tostring(self:getType() or "") or ""
				end)
				return false
			end
			if isUnlimitedSafe(self) then
				USV.ensureContainerCapacity(self)
				if USV.isUSVFurnitureItem(item) then
					return false
				end
				if USV.containerIsUSVFridge(self) then
					local allow = USV.itemAllowedInUSVFridge(self, item, oldIsItemAllowed, ...)
					local ctype = USV.containerFridgeCompartmentType(self)
					if not allow then
					elseif not USV.isFridgeFoodItemStrict(item) and ctype ~= "fridge" and ctype ~= "freezer" then
					end
					return allow
				end
			end
			return oldIsItemAllowed(self, item, ...)
		end
	end

	UnlimitedStorageVault_CapacityHooksInstalled = true
end

--- Parent object + square for MP container refs (avoid falling back to player tile).
function USV.getWorldContainerPackContext(container, character)
	if not container then
		return nil, nil, nil, nil, nil, 0
	end
	local parent = nil
	pcall(function()
		parent = container.getParent and container:getParent() or nil
	end)
	if not parent then
		parent = USV.resolveContainerParent(container)
	end
	local coords = parent and (USV.getLiveCoords(parent) or USV.getObjectCoords(parent)) or nil
	local sq = nil
	if parent and parent.getSquare then
		pcall(function()
			sq = parent:getSquare()
		end)
	end
	if not sq and coords and getCell then
		pcall(function()
			sq = getCell():getGridSquare(coords.x, coords.y, coords.z or 0)
		end)
	end
	if not sq then
		pcall(function()
			if container.getSourceGrid then
				sq = container:getSourceGrid()
			end
		end)
	end
	if not sq and container.getSquare then
		pcall(function()
			sq = container:getSquare()
		end)
	end
	if not sq and not parent and character and character.getSquare then
		pcall(function()
			sq = character:getSquare()
		end)
	end
	local ownerId, kind = nil, nil
	if parent and parent.getModData then
		pcall(function()
			local md = parent:getModData()
			if md then
				ownerId = md[USV.OWNER_FLAG]
				kind = md[USV.KIND_FLAG]
			end
		end)
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
	elseif parent and parent.getItemContainer and parent:getItemContainer() == container then
		index = 0
	end
	return parent, sq, coords, ownerId, kind, index
end

function USV.worldObjectMatchesContainerRef(obj, ref)
	if not obj or not ref then
		return false
	end
	if ref.usvOwner or ref.usvKind or ref.usvX ~= nil then
		if not (USV.isLegitimateUSVObject(obj) or USV.isFlaggedObject(obj)) then
			return false
		end
		local md = obj.getModData and obj:getModData() or nil
		if ref.usvOwner and (not md or md[USV.OWNER_FLAG] ~= ref.usvOwner) then
			return false
		end
		if ref.usvKind and md and md[USV.KIND_FLAG] and md[USV.KIND_FLAG] ~= ref.usvKind then
			return false
		end
		if ref.usvX ~= nil and ref.usvY ~= nil then
			local c = USV.getLiveCoords(obj) or USV.getObjectCoords(obj)
			if not c or c.x ~= ref.usvX or c.y ~= ref.usvY or (c.z or 0) ~= (ref.usvZ or 0) then
				return false
			end
		end
		return true
	end
	return true
end

function USV.containerFromWorldObject(obj, ref)
	if not obj then
		return nil
	end
	local idx = ref.index or 0
	if obj.getContainerCount then
		local count = obj:getContainerCount() or 0
		if count > 0 then
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
			if idx >= 0 and idx < count then
				return obj:getContainerByIndex(idx)
			end
		end
	end
	if obj.getItemContainer then
		local c = obj:getItemContainer()
		if c then
			local ctype = c.getType and c:getType() or ""
			if not ref.type or ref.type == "" or ctype == ref.type then
				return c
			end
		end
	end
	return nil
end

--- Pack a container reference for MP BlindTransfer (Java ItemTransaction rejects over-cap containers).
function USV.packContainerRef(container, character)
	if not container then
		return nil
	end
	if character and character.getInventory and container == character:getInventory() then
		return { kind = "player" }
	end
	-- B42: player inv type is often "none" and object identity != getInventory(); use ownership.
	local inChar = false
	pcall(function()
		inChar = container.isInCharacterInventory and container:isInCharacterInventory(character) or false
	end)
	local containing = nil
	pcall(function()
		containing = container.getContainingItem and container:getContainingItem() or nil
	end)
	if containing and containing.getID then
		return { kind = "bag", itemID = containing:getID() }
	end
	if inChar then
		return { kind = "player" }
	end
	local ctype = ""
	pcall(function()
		ctype = container.getType and tostring(container:getType() or "") or ""
	end)
	local parent, sq, coords, ownerId, kind, index = USV.getWorldContainerPackContext(container, character)
	-- FloorContainer often has no parent; probe source grid only (do NOT use character tile fallback as floor).
	if not sq then
		pcall(function()
			if container.getSourceGrid then
				sq = container:getSourceGrid()
			end
		end)
	end
	if not sq and container.getSquare then
		pcall(function()
			sq = container:getSquare()
		end)
	end
	-- Only explicit floor containers — never "parent==nil + character square" (that mislabels player inv).
	if ctype == "floor" then
		if not sq and character and character.getSquare then
			pcall(function()
				sq = character:getSquare()
			end)
		end
		if not sq then
			return nil
		end
		return {
			kind = "floor",
			x = sq:getX(),
			y = sq:getY(),
			z = sq:getZ() or 0,
			type = "floor",
			index = 0,
		}
	end
	if not sq then
		return nil
	end
	return {
		kind = "world",
		x = sq:getX(),
		y = sq:getY(),
		z = sq:getZ(),
		type = ctype,
		index = index,
		usvOwner = ownerId,
		usvKind = kind,
		usvX = coords and coords.x or nil,
		usvY = coords and coords.y or nil,
		usvZ = coords and coords.z or nil,
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
		-- B42 floor loot uses a synthetic ItemContainer("floor"), not square:getFloorContainer().
		local fc = USV.getOrCreateFloorContainer(character)
		if fc then
			return fc
		end
		local sq = getCell():getGridSquare(ref.x, ref.y, ref.z or 0)
		if sq and sq.getFloorContainer then
			local sqFc = sq:getFloorContainer()
			if sqFc then
				return sqFc
			end
		end
		return nil
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
				if ref.usvOwner or ref.usvKind or ref.usvX ~= nil then
					for i = 0, objects:size() - 1 do
						local obj = objects:get(i)
						if USV.worldObjectMatchesContainerRef(obj, ref) then
							local c = USV.containerFromWorldObject(obj, ref)
							if c then
								return c
							end
						end
					end
				end
				for i = 0, objects:size() - 1 do
					local obj = objects:get(i)
					if not ref.usvOwner and not ref.usvKind and ref.usvX == nil then
						local c = USV.containerFromWorldObject(obj, ref)
						if c then
							return c
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

--- B42: loot "floor" is a synthetic ItemContainer (see ISInventoryPage.GetFloorContainer),
--- not IsoGridSquare:getFloorContainer().
function USV.getOrCreateFloorContainer(character)
	local playerNum = 0
	pcall(function()
		if character and character.getPlayerNum then
			playerNum = character:getPlayerNum() or 0
		end
	end)
	if ISInventoryPage and ISInventoryPage.GetFloorContainer then
		local ok, fc = pcall(function()
			return ISInventoryPage.GetFloorContainer(playerNum)
		end)
		if ok and fc then
			return fc
		end
	end
	USV._floorContainers = USV._floorContainers or {}
	local key = (tonumber(playerNum) or 0) + 1
	if not USV._floorContainers[key] then
		local fc = nil
		pcall(function()
			if ItemContainer and ItemContainer.new then
				fc = ItemContainer.new("floor", nil, nil)
				if fc and fc.setExplored then
					fc:setExplored(true)
				end
			end
		end)
		USV._floorContainers[key] = fc
	end
	return USV._floorContainers[key]
end

--- Place an item onto a floor square the vanilla way (synthetic floor container + WorldItem).
--- Returns true only when the item is confirmed on the floor / world.
function USV.placeItemOnFloorSquare(character, item, dropSq, floorContainer)
	if not item or not dropSq then
		return false
	end
	local fc = floorContainer or USV.getOrCreateFloorContainer(character)
	if not fc then
		return false
	end
	-- Only strip from character inventory when the item is actually there.
	-- USV→floor items are already removed from the vault; removeItemOnCharacter
	-- returning false must not abort WorldItem placement.
	local inCharInv = false
	pcall(function()
		local inv = character and character.getInventory and character:getInventory() or nil
		inCharInv = inv and inv.contains and inv:contains(item) or false
	end)
	if inCharInv and character and ISTransferAction and ISTransferAction.removeItemOnCharacter then
		local ok, res = pcall(function()
			return ISTransferAction:removeItemOnCharacter(character, item)
		end)
		if ok and res == false then
			return false
		end
	end
	pcall(function()
		if fc.DoAddItemBlind then
			fc:DoAddItemBlind(item)
		elseif fc.DoAddItem then
			fc:DoAddItem(item)
		elseif fc.AddItem then
			fc:AddItem(item)
		end
	end)
	local dropX, dropY, dropZ = 0.5, 0.5, 0.0
	if ISTransferAction and ISTransferAction.GetDropItemOffset then
		pcall(function()
			dropX, dropY, dropZ = ISTransferAction.GetDropItemOffset(character, dropSq, item)
		end)
	end
	pcall(function()
		if dropSq.AddWorldInventoryItem then
			dropSq:AddWorldInventoryItem(item, dropX, dropY, dropZ)
		end
	end)
	local okPlace = false
	pcall(function()
		-- Visible floor loot requires a WorldItem; synthetic floorCont:contains is not enough.
		okPlace = item.getWorldItem and item:getWorldItem() ~= nil
	end)
	if okPlace and isServer and isServer() then
		pcall(function()
			local wi = item:getWorldItem()
			if wi then
				if wi.transmitCompleteItemToClients then
					wi:transmitCompleteItemToClients()
				end
				if dropSq.transmitAddObjectToSquare then
					dropSq:transmitAddObjectToSquare(wi)
				end
			end
		end)
		pcall(function()
			if sendAddItemToContainer and fc then
				sendAddItemToContainer(fc, item)
			end
		end)
	end
	return okPlace
end

--- Server/SP Blind transfer — bypasses Java capacity hard-cap (100) for USV containers.
--- opts.destFloorSq: floor drop square when dest FloorContainer may be missing on dedicated.
function USV.doBlindTransfer(character, item, srcContainer, destContainer, opts)
	opts = opts or {}
	local destFloorSq = opts.destFloorSq
	if not item then
		return false
	end
	local destType = destContainer and destContainer.getType and destContainer:getType() or ""
	local wantFloor = destFloorSq ~= nil or destType == "floor"
	if not destContainer and not wantFloor then
		return false
	end
	local destUSV = destContainer and USV.isUnlimitedContainer(destContainer) or false
	local srcUSV = srcContainer and USV.isUnlimitedContainer(srcContainer) or false
	if not destUSV and not srcUSV then
		return false
	end
	if USV.isUSVFurnitureItem(item) then
		return false
	end
	if destUSV then
		USV.ensureContainerCapacity(destContainer)
	end
	if srcUSV then
		USV.ensureContainerCapacity(srcContainer)
	end
	local srcType = srcContainer and srcContainer.getType and srcContainer:getType() or ""
	if srcType == "TradeUI" then
		return false
	end
	-- Floor drop: remove from USV then place WorldItem (success = getWorldItem only).
	if wantFloor then
		local floorCont = (destType == "floor" and destContainer) or USV.getOrCreateFloorContainer(character)
		local dropSq = destFloorSq
		if not dropSq and character and character.getSquare then
			pcall(function()
				dropSq = character:getSquare()
			end)
		end
		if floorCont and ISTransferAction and ISTransferAction.getNotFullFloorSquare and character and item then
			pcall(function()
				local better = ISTransferAction:getNotFullFloorSquare(character, item, floorCont)
				if better then
					dropSq = better
				end
			end)
		end
		if not floorCont or not dropSq or not srcContainer then
			return false
		end
		-- Already on floor (e.g. duplicate command): treat as success, still scrub USV.
		local alreadyWI = false
		pcall(function()
			alreadyWI = item.getWorldItem and item:getWorldItem() ~= nil
		end)
		if alreadyWI then
			if srcUSV and srcContainer and srcContainer.contains and srcContainer:contains(item) then
				pcall(function()
					srcContainer:DoRemoveItem(item)
				end)
				if isServer and isServer() and sendRemoveItemFromContainer then
					pcall(function()
						sendRemoveItemFromContainer(srcContainer, item)
					end)
				end
				local srcObj = USV.getContainerWorldObject(srcContainer)
				if srcObj then
					USV.syncEntityContentsSnapshot(srcObj)
				end
			end
			return true
		end
		-- Remove from USV first, then place; rollback if WorldItem never appears.
		if srcType ~= "floor" then
			pcall(function()
				srcContainer:DoRemoveItem(item)
			end)
			if isServer and isServer() and sendRemoveItemFromContainer then
				pcall(function()
					sendRemoveItemFromContainer(srcContainer, item)
				end)
			end
		end
		local added = USV.placeItemOnFloorSquare(character, item, dropSq, floorCont)
		local hasWI = false
		pcall(function()
			hasWI = item.getWorldItem and item:getWorldItem() ~= nil
		end)
		added = added and hasWI
		if not added and srcUSV then
			pcall(function()
				if type(USV._rawDoAddItemBlind) == "function" then
					USV._rawDoAddItemBlind(srcContainer, item)
				elseif srcContainer.DoAddItemBlind then
					srcContainer:DoAddItemBlind(item)
				end
			end)
			if isServer and isServer() and sendAddItemToContainer then
				pcall(function()
					sendAddItemToContainer(srcContainer, item)
				end)
			end
		end
		if added or srcUSV then
			local srcObj = srcUSV and USV.getContainerWorldObject(srcContainer) or nil
			if srcObj then
				USV.syncEntityContentsSnapshot(srcObj)
			end
		end
		if added then
			if ISInventoryPage then
				ISInventoryPage.renderDirty = true
			end
		end
		return added
	end

	if destContainer and destContainer.isItemAllowed and not destContainer:isItemAllowed(item) then
		return false
	end
	if srcContainer and srcContainer.isRemoveItemAllowed then
		local okRem, canRem = pcall(function()
			return srcContainer:isRemoveItemAllowed(item)
		end)
		if okRem and not canRem and srcType ~= "floor" and not (item.getWorldItem and item:getWorldItem() ~= nil) then
			return false
		end
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

	-- Handle floor world inventory object removal (floor → USV / other).
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
	if destUSV then
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
	else
		if destContainer.DoAddItem then
			local ok, res = pcall(destContainer.DoAddItem, destContainer, item)
			added = ok and res ~= nil
		end
		if not added and destContainer.AddItem then
			local ok, res = pcall(destContainer.AddItem, destContainer, item)
			added = ok and res ~= nil
		end
		if isServer and isServer() and added and sendAddItemToContainer then
			pcall(function()
				sendAddItemToContainer(destContainer, item)
			end)
		end
	end
	if added then
	end
	pcall(function()
		if srcContainer and srcContainer.setDrawDirty then
			srcContainer:setDrawDirty(true)
			srcContainer:setHasBeenLooted(true)
		end
		if destContainer and destContainer.setDrawDirty then
			destContainer:setDrawDirty(true)
		end
	end)
	if ISInventoryPage then
		ISInventoryPage.renderDirty = true
	end
	if added then
		local destObj = destUSV and USV.getContainerWorldObject(destContainer) or nil
		local srcObj = srcUSV and USV.getContainerWorldObject(srcContainer) or nil
		if destObj then
			USV.syncEntityContentsSnapshot(destObj)
		end
		if srcObj and srcObj ~= destObj then
			USV.syncEntityContentsSnapshot(srcObj)
		end
	end
	return added
end

function USV.packBlindTransferArgs(character, item, srcContainer, destContainer)
	if not item or not item.getID then
		return nil
	end
	local src = USV.packContainerRef(srcContainer, character)
	local hasWI = false
	pcall(function()
		hasWI = item.getWorldItem and item:getWorldItem() ~= nil
	end)
	-- Inventory items must never be sent as floor (parent-less inv + character tile mispack).
	if (not hasWI) and character and character.getInventory then
		local inPlayer = false
		pcall(function()
			inPlayer = character:getInventory():contains(item)
		end)
		if not inPlayer and srcContainer and srcContainer.contains then
			pcall(function()
				inPlayer = srcContainer:contains(item)
					and srcContainer.isInCharacterInventory
					and srcContainer:isInCharacterInventory(character)
			end)
		end
		if inPlayer and (not src or src.kind == "floor" or src.kind == nil) then
			local containing = nil
			pcall(function()
				containing = srcContainer and srcContainer.getContainingItem and srcContainer:getContainingItem() or nil
			end)
			if containing and containing.getID then
				src = { kind = "bag", itemID = containing:getID() }
			else
				src = { kind = "player" }
			end
		end
	end
	-- Floor / world loot: FloorContainer often has no parent; pin coords from the WorldItem.
	if (not src or src.x == nil) and hasWI then
		local sq = nil
		pcall(function()
			local wi = item.getWorldItem and item:getWorldItem() or nil
			sq = wi and wi.getSquare and wi:getSquare() or nil
		end)
		if sq then
			src = {
				kind = "floor",
				x = sq:getX(),
				y = sq:getY(),
				z = sq:getZ() or 0,
				type = "floor",
				index = 0,
			}
		end
	elseif (not src or src.x == nil) and srcContainer then
		local ctype = ""
		pcall(function()
			ctype = srcContainer.getType and tostring(srcContainer:getType() or "") or ""
		end)
		if ctype == "floor" then
			local sq = nil
			pcall(function()
				sq = srcContainer.getSourceGrid and srcContainer:getSourceGrid() or nil
			end)
			if not sq and character and character.getSquare then
				pcall(function()
					sq = character:getSquare()
				end)
			end
			if sq then
				src = {
					kind = "floor",
					x = sq:getX(),
					y = sq:getY(),
					z = sq:getZ() or 0,
					type = "floor",
					index = 0,
				}
			end
		end
	end
	local dest = USV.packContainerRef(destContainer, character)
	if not src or not dest then
		return nil
	end
	return {
		itemID = item:getID(),
		src = src,
		dest = dest,
	}
end

--- Client MP: request server BlindTransfer.
--- Dedicated clients must NOT move the item locally — that causes "Dupe item ID"
--- when sendAddItemToContainer sync arrives. Listen-server host applies locally.
function USV.clientBlindTransferNow(character, item, srcContainer, destContainer, action)
	if not character or not item or not srcContainer or not destContainer then
		return false
	end
	local destUSV = USV.isUnlimitedContainer(destContainer)
	local srcUSV = srcContainer and USV.isUnlimitedContainer(srcContainer) or false
	if not destUSV and not srcUSV then
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
	if not args then
		return false
	end
	-- Listen-server host: apply once locally. Do NOT also sendClientCommand (that double-applies
	-- and can destroy WorldItems when USV→floor runs twice).
	if isServer and isServer() then
		local opts = nil
		local destType = ""
		pcall(function()
			destType = destContainer.getType and tostring(destContainer:getType() or "") or ""
		end)
		if destType == "floor" and character and character.getSquare then
			opts = { destFloorSq = character:getSquare() }
		end
		return USV.doBlindTransfer(character, item, srcContainer, destContainer, opts)
	end
	if sendClientCommand then
		sendClientCommand(character, "USV", "BlindTransfer", args)
	end
	return true
end

function USV.transferInvolvesUnlimited(srcContainer, destContainer)
	if srcContainer and USV.isUnlimitedContainer(srcContainer) then
		return true
	end
	if destContainer and USV.isUnlimitedContainer(destContainer) then
		return true
	end
	return false
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
	if USV.isUnlimitedContainer(self.srcContainer) then
		USV.ensureContainerCapacity(self.srcContainer)
	end
	if USV.isUnlimitedContainer(self.destContainer) then
		USV.ensureContainerCapacity(self.destContainer)
	end
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
		-- Still enforce fridge food rules and other isItemAllowed checks.
		if self.destContainer.isItemAllowed and not self.destContainer:isItemAllowed(self.item) then
			return false
		end
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
			local t = time
			if USV.transferInvolvesUnlimited(src, destContainer) then
				t = 0
			end
			return prevUtil(character, item, src, destContainer, t)
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
			local t = time
			if USV.transferInvolvesUnlimited(src, destContainer) then
				t = 0
			end
			return prevNewAction(self, character, item, src, destContainer, t)
		end
		ISInventoryTransferAction._USV_NewWrapped = true
	end

	-- Re-wrap whatever is currently installed (other mods may replace isValid).
	if ISInventoryTransferAction and type(ISInventoryTransferAction.isValid) == "function" then
		if not ISInventoryTransferAction._USV_IsValidWrapped then
			local prev = ISInventoryTransferAction.isValid
			ISInventoryTransferAction.isValid = function(self)
				if self and self.item and self.destContainer then
					local blocked, why = USV.usvFurnitureBlockedInContainer(self.item, self.destContainer)
					if blocked then
						return false
					end
					if USV.useFixedCarryWeight(self.item) and not USV.isUnlimitedContainer(self.destContainer) then
						local destType = ""
						local allowed, room, iw = nil, nil, nil
						pcall(function()
							destType = self.destContainer.getType and tostring(self.destContainer:getType() or "") or ""
						end)
						pcall(function()
							allowed = self.destContainer.isItemAllowed and self.destContainer:isItemAllowed(self.item)
						end)
						pcall(function()
							room = self.destContainer.hasRoomFor and self.destContainer:hasRoomFor(self.item)
						end)
						pcall(function()
							iw = self.item.getWeight and self.item:getWeight() or nil
						end)
						if allowed == false or room == false then
						end
					end
				end
				if self and USV.transferInvolvesUnlimited(self.srcContainer, self.destContainer) then
					if USV.isUnlimitedContainer(self.srcContainer) then
						USV.ensureContainerCapacity(self.srcContainer)
					end
					if USV.isUnlimitedContainer(self.destContainer) then
						USV.ensureContainerCapacity(self.destContainer)
					end
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
				if isClient and isClient() and self and USV.transferInvolvesUnlimited(self.srcContainer, self.destContainer)
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
							self.action:setTime(0)
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
				if self and USV.transferInvolvesUnlimited(self.srcContainer, self.destContainer) then
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
					and USV.transferInvolvesUnlimited(self.srcContainer, self.destContainer)) then
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
							local valid = self:isValid()
							local srcType = self.srcContainer and self.srcContainer.getType and self.srcContainer:getType() or ""
							local hasItem = self.srcContainer and self.srcContainer:contains(item)
							local hasWI = item.getWorldItem and item:getWorldItem() ~= nil
							if not hasItem and (srcType == "floor" or hasWI) then
								hasItem = true
							end
							if valid then
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
				if self and USV.transferInvolvesUnlimited(self.srcContainer, self.destContainer)
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
				if not (item and USV.transferInvolvesUnlimited(srcContainer, destContainer)) then
					return prevTransfer(self, character, item, srcContainer, destContainer, dropSquare)
				end
				-- Trade paths keep vanilla.
				local destType = destContainer.getType and destContainer:getType() or ""
				local srcType = srcContainer and srcContainer.getType and srcContainer:getType() or ""
				if destType == "TradeUI" or srcType == "TradeUI" then
					USV.ensureContainerCapacity(destContainer)
					return prevTransfer(self, character, item, srcContainer, destContainer, dropSquare)
				end
				-- Floor dest must create a WorldItem; DoAddItemBlind into synthetic floor = vanish.
				if destType == "floor" or dropSquare ~= nil then
					local opts = { destFloorSq = dropSquare }
					local ok = USV.doBlindTransfer(character, item, srcContainer, destContainer, opts)
					return ok and item or nil
				end
				if destContainer.isItemAllowed and not destContainer:isItemAllowed(item) then
					return nil
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
			local src = srcContainer
			if src and instanceof and instanceof(src, "InventoryContainer") and src.getInventory then
				src = src:getInventory()
			end
			if USV.transferInvolvesUnlimited(src, dest) then
				if USV.isUnlimitedContainer(src) then
					USV.ensureContainerCapacity(src)
				end
				if USV.isUnlimitedContainer(dest) then
					USV.ensureContainerCapacity(dest)
				end
				if ISTimedActionQueue and ISInventoryTransferAction then
					ISTimedActionQueue.add(ISInventoryTransferAction:new(character, item, srcContainer, dest, 0))
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
					if not items then
						return false
					end
					for i = 1, #items do
						local it = items[i]
						if it and dest.isItemAllowed and dest:isItemAllowed(it) then
							return true
						end
					end
					return false
				end
				return prevRoom(playerObj, container, items)
			end
			ISInventoryPaneContextMenu._USV_HasRoomForAnyWrapped = true
		end
	end
	if ISInventoryPane and type(ISInventoryPane.canPutIn) == "function" and not ISInventoryPane._USV_CanPutInWrapped then
		local prevCanPutIn = ISInventoryPane.canPutIn
		ISInventoryPane.canPutIn = function(self)
			if self.inventory and USV.containerIsBagInventory(self.inventory) then
				local dragging = ISInventoryPane.getActualItems(ISMouseDrag.dragging)
				if dragging then
					for _, v in ipairs(dragging) do
						if USV.isUSVFurnitureItem(v) or USV.useFixedCarryWeight(v) then
							return false
						end
					end
				end
			end
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
			if container and USV.containerIsBagInventory(container) then
				local dragging = ISInventoryPane.getActualItems(ISMouseDrag.dragging)
				if dragging then
					for _, item in ipairs(dragging) do
						if USV.isUSVFurnitureItem(item) or USV.useFixedCarryWeight(item) then
							return false
						end
					end
				end
			end
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
			if (_mode == "pickup" or _mode == "place") and self.object and USV.isUSVMoveableObject(self.object, self.spriteName) then
				return true
			end
			return prevSkill(self, _player, _mode)
		end
		ISMoveableSpriteProps._USV_SkillWrapped = true
	end

	if type(ISMoveableSpriteProps.hasTool) == "function" and not ISMoveableSpriteProps._USV_ToolWrapped then
		local prevTool = ISMoveableSpriteProps.hasTool
		ISMoveableSpriteProps.hasTool = function(self, _player, _mode)
			if (_mode == "pickup" or _mode == "place") and self.object and USV.isUSVMoveableObject(self.object, self.spriteName) then
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
			if _mode == "pickup" and USV.isUSVMoveableObject(_object, self.spriteName) then
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
		if _object then
		end
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
				local ownerId = nil
				pcall(function()
					local md = _item:getModData()
					kind = (md and md[USV.KIND_FLAG]) or USV.resolveSpriteKind(self.spriteName) or "vault"
					ownerId = md and md[USV.OWNER_FLAG] or nil
				end)
				local ok = USV.canPlaceKind(kind, _character, _square, ownerId ~= nil)
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
				local existingContentsId = USV.getEntityContentsId(_object)
				if not existingContentsId or existingContentsId == "" then
					existingContentsId = USV.newContentsId(ownerId, kind)
				end
				USV._pendingContentsId = existingContentsId
				USV.writeContentsSnapshot(existingContentsId, packs, {
					kind = kind,
					ownerId = ownerId,
					ownerName = USV.resolveOwnerUserName(ownerId, _character),
				})
				if isClient and isClient() and not (isServer and isServer()) and sendClientCommand and _character then
					pcall(function()
						sendClientCommand(_character, "USV", "SaveContents", {
							id = existingContentsId,
							kind = kind,
							ownerId = ownerId,
							ownerName = USV.resolveOwnerUserName(ownerId, _character),
							packs = USV.packsToDescriptors(packs),
						})
					end)
				end
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
						if USV._pendingContentsId then
							md[USV.CONTENTS_ID] = USV._pendingContentsId
						end
					end
				end)
				USV._pendingContentsId = nil
				USV.storeCarryPacks(item, packs)
				USV.makeMoveableWeightless(item)
				pcall(function()
					USV.purgeNestedFurnitureItems(item)
				end)
				USV.makeMoveableWeightless(item)
				local gw, ga, gc, customW = nil, nil, nil, nil
				pcall(function()
					gw = item.getWeight and item:getWeight() or nil
					ga = item.getActualWeight and item:getActualWeight() or nil
					gc = item.getContentsWeight and item:getContentsWeight() or nil
					customW = item.isCustomWeight and item:isCustomWeight() or nil
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
			-- Must stay in outer scope: finishObj is a closure and cannot see block-locals.
			local character = _character
			local isRelocate = false
			local contentsId = nil
			local isUSV = _item and USV.isUSVCarryItem(_item)
			if isUSV then
				pcall(function()
					local md = _item:getModData()
					if md then
						kind = md[USV.KIND_FLAG] or USV.resolveSpriteKind(sprName) or "vault"
						ownerId = md[USV.OWNER_FLAG]
						appearanceId = md[USV.APPEARANCE_FLAG]
						contentsId = md[USV.CONTENTS_ID]
					end
				end)
				pcall(function()
					local cont = _item.getContainer and _item:getContainer() or nil
					local parent = cont and cont.getParent and cont:getParent() or nil
					if parent and instanceof and instanceof(parent, "IsoGameCharacter") then
						character = parent
					end
				end)
				isRelocate = ownerId ~= nil
				local ok, reason = USV.canPlaceKind(kind or "vault", character, _square, isRelocate)
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
					local placeSq = obj.getSquare and obj:getSquare() or _square
					local canPlace, blockReason = USV.canPlaceKind(objKind, character, placeSq, isRelocate)
					if not canPlace then
						USV.notifyPlaceBlocked(character, objKind, blockReason)
						-- Preserve JSON SoT: removeBuiltObject must not trigger deleteContentsSnapshot.
						USV.beginPreserveMove()
						USV.removeBuiltObject(obj)
						USV.endPreserveMove()
						USV.stripUntrustedFlags(obj)
						if packs and _item then
							USV.restoreCarryPacksToItem(_item, packs)
						elseif contentsId and packs and USV.packsItemCount(packs) > 0 then
							-- Carry item may already be consumed; keep durable JSON.
							USV.writeContentsSnapshot(contentsId, packs, { kind = objKind, ownerId = ownerId })
						end
						return
					end
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
						if contentsId then
							md[USV.CONTENTS_ID] = contentsId
						end
					end
					authorized = USV.authorizeObject(obj, objKind)
					if not authorized then
						USV.beginPreserveMove()
						if packs and _item then
							USV.restoreCarryPacksToItem(_item, packs)
							packs = nil
						elseif contentsId and packs and USV.packsItemCount(packs) > 0 then
							USV.writeContentsSnapshot(contentsId, packs, { kind = objKind, ownerId = ownerId })
						end
						USV.endPreserveMove()
						USV.stripUntrustedFlags(obj)
						USV.logError("place rejected duplicate USV " .. tostring(objKind))
						return
					end
					if appearanceId then
						USV.applyAppearance(obj, appearanceId, true)
					end
				else
					authorized = ownerId ~= nil and (isRelocate or USV.isFlaggedObject(obj))
				end
				if authorized then
					USV.applyObject(obj, true, objKind)
					contentsId = contentsId or USV.getEntityContentsId(_item) or USV.getEntityContentsId(obj)
					if contentsId then
						USV.setEntityContentsId(obj, contentsId)
					end
					local packsWereEmpty = (not packs) or USV.packsItemCount(packs) <= 0
					if packs and not packsWereEmpty then
						USV.depositContainerItems(obj, packs)
					end
					local afterLive = 0
					pcall(function()
						local containers = USV.collectContainers(obj)
						for _, c in ipairs(containers) do
							local items = c.getItems and c:getItems() or nil
							if items then
								afterLive = afterLive + items:size()
							end
						end
					end)
					local dedicatedClient = isClient and isClient() and not (isServer and isServer())
					-- SP / listen-host: restore from JSON when live refs were lost.
					-- Dedicated client skips local spawn (server RestoreContents is SoT).
					if contentsId and (packsWereEmpty or afterLive <= 0) and not dedicatedClient then
						local restored = USV.restoreContentsFromSnapshot(obj, contentsId)
						if restored > 0 then
							packs = nil -- JSON is SoT; avoid duplicating remainders onto carry item
						end
					end
					if packs and USV.packsItemCount(packs) > 0 and _item then
						USV.restoreCarryPacksToItem(_item, packs)
					end
					if contentsId and not dedicatedClient then
						USV.syncEntityContentsSnapshot(obj)
					end
					-- Dedicated MP client: server JSON is SoT — request refill.
					if contentsId and dedicatedClient and sendClientCommand and character then
						local sq = obj.getSquare and obj:getSquare() or _square
						if sq then
							pcall(function()
								sendClientCommand(character, "USV", "RestoreContents", {
									id = contentsId,
									kind = objKind,
									x = sq:getX(),
									y = sq:getY(),
									z = sq:getZ() or 0,
								})
							end)
						end
					end
				elseif packs and _item then
					USV.restoreCarryPacksToItem(_item, packs)
				elseif contentsId and packs and USV.packsItemCount(packs) > 0 then
					USV.writeContentsSnapshot(contentsId, packs, { kind = kind or "vault", ownerId = ownerId })
				end
			end
			if isUSV then
				if result then
					finishObj(result)
				elseif _square and _square.getObjects then
					local objects = _square:getObjects()
					if objects then
						for i = 0, objects:size() - 1 do
							local obj = objects:get(i)
							if USV.isUSVMoveableObject(obj, USV.getSpriteNameFast(obj)) then
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

local WEIGHT_HOOK_METHODS = {
	"getWeight",
	"getActualWeight",
	"getUnequippedWeight",
	"getContentsWeight",
	"getEquippedWeight",
	"getInventoryWeight",
}

local function patchInventoryItemWeightMethod(index, methodName)
	local old = index[methodName]
	if type(old) ~= "function" then
		return false
	end
	index[methodName] = function(self, ...)
		if USV.useFixedCarryWeight(self) then
			if methodName == "getContentsWeight" or methodName == "getInventoryWeight" then
				return 0
			end
			return USV.MOVEABLE_CARRY_WEIGHT or 1
		end
		return old(self, ...)
	end
	return true
end

local function installWeightHooksForClass(classObj, label)
	if not classObj or not __classmetatables then
		return false, "no_class"
	end
	local guardKey = "UnlimitedStorageVault_WeightHooks_" .. tostring(label)
	if rawget(_G, guardKey) then
		return true, "already"
	end
	local mt = __classmetatables[classObj]
	if not mt or type(mt.__index) ~= "table" then
		return false, "no_index"
	end
	local index = mt.__index
	local patched = false
	for i = 1, #WEIGHT_HOOK_METHODS do
		if patchInventoryItemWeightMethod(index, WEIGHT_HOOK_METHODS[i]) then
			patched = true
		end
	end
	if not patched then
		return false, "no_methods"
	end
	rawset(_G, guardKey, true)
	return true, "patched"
end

function USV.installInventoryWeightHooks()
	if rawget(_G, "UnlimitedStorageVault_InventoryWeightHooksInstalled") then
		return true
	end
	if not __classmetatables then
		return false
	end
	local any = false
	local details = {}
	local classes = {
		{ InventoryItem and InventoryItem.class, "InventoryItem" },
		{ Moveable and Moveable.class, "Moveable" },
		{ InventoryContainer and InventoryContainer.class, "InventoryContainer" },
	}
	for i = 1, #classes do
		local cls, label = classes[i][1], classes[i][2]
		if cls then
			local ok, why = installWeightHooksForClass(cls, label)
			details[label] = why
			if ok then
				any = true
			end
		else
			details[label] = "missing"
		end
	end
	if not any then
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
				local contentsId = USV.getEntityContentsId(object)
				USV.onWorldObjectRemoved(object, "scrap")
				if isClient and isClient() and not (isServer and isServer()) and sendClientCommand and character then
					local coords = USV.getLiveCoords(object) or USV.getObjectCoords(object)
					local md = object.getModData and object:getModData() or nil
					sendClientCommand(character, "USV", "ReleaseAt", {
						x = coords and coords.x or nil,
						y = coords and coords.y or nil,
						z = coords and coords.z or 0,
						kind = (md and md[USV.KIND_FLAG]) or USV.getObjectKind(object) or "vault",
						contentsId = contentsId,
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
