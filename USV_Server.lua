--[[
  Unlimited Storage Vault — server: vault + commercial fridge
]]

require "USV_Shared"

BuildRecipeCode = BuildRecipeCode or {}
BuildRecipeCode.USV_InfiniteVault = BuildRecipeCode.USV_InfiniteVault or {}
BuildRecipeCode.USV_InfiniteFridge = BuildRecipeCode.USV_InfiniteFridge or {}

local function createKind(kind, params)
	local thumpable = params and params.thumpable or nil
	local character = params and params.character or nil
	if not thumpable then
		USV.logError("OnCreate(" .. tostring(kind) .. "): missing thumpable")
		return
	end
	local square = nil
	if thumpable.getSquare then
		local ok, sq = pcall(function()
			return thumpable:getSquare()
		end)
		if ok then
			square = sq
		end
	end
	local canPlace, reason = USV.canPlaceKind(kind, character, square)
	if not canPlace then
		USV.notifyPlaceBlocked(character, kind, reason)
		USV.removeBuiltObject(thumpable)
		return { objectAlreadyTransmitted = true }
	end
	local claimed = USV.claim(kind, character, thumpable)
	if not claimed then
		USV.logError("OnCreate(" .. tostring(kind) .. "): claim failed sprite=" .. tostring(USV.getSpriteNameFast(thumpable)))
		USV.removeBuiltObject(thumpable)
		return { objectAlreadyTransmitted = true }
	end
	USV.applyObject(thumpable, true, kind)
end

function BuildRecipeCode.USV_InfiniteVault.OnCreate(params)
	return createKind("vault", params)
end

function BuildRecipeCode.USV_InfiniteFridge.OnCreate(params)
	return createKind("fridge", params)
end

local function onLoadGridsquare(square)
	if not USV or not USV.scanSquare then
		return
	end
	USV.scanSquare(square)
end

local function onObjectAdded(obj)
	if not USV or not USV.scanSquare or not obj then
		return
	end
	local sq = obj.getSquare and obj:getSquare() or nil
	if sq then
		USV.scanSquare(sq)
	end
end

local function onDestroyIsoThumpable(thump, _player)
	if not USV then
		return
	end
	if USV.onWorldObjectRemoved then
		USV.onWorldObjectRemoved(thump, "destroyThumpable")
		return
	end
	local wasTrusted = thump and USV.isTrustedUSVObject and USV.isTrustedUSVObject(thump)
	if wasTrusted or (USV.isFlaggedObject and USV.isFlaggedObject(thump)) then
		if USV.isPreservingMove and USV.isPreservingMove() then
			return
		end
		if USV.clearAllContents then
			USV.clearAllContents(thump)
		end
		if wasTrusted then
			USV.releaseObject(thump)
		elseif USV.stripUntrustedFlags then
			USV.stripUntrustedFlags(thump)
		end
	end
end

local function onInitGlobalModData(_isNewGame)
	if not USV then
		return
	end
	USV.getStore()
	USV.installAllHooks()
end

local function findItemById(container, itemID, player, srcRef)
	if not itemID then
		return nil
	end
	local item = nil
	if container then
		pcall(function()
			if container.getItemById then
				item = container:getItemById(itemID)
			end
		end)
		if item then
			return item
		end
		pcall(function()
			local items = container.getItems and container:getItems() or nil
			if not items then
				return
			end
			for i = 0, items:size() - 1 do
				local it = items:get(i)
				if it and it.getID and it:getID() == itemID then
					item = it
					return
				end
			end
		end)
		if item then
			return item
		end
	end

	-- Floor fallback: check squares from container, srcRef, and player
	local squares = {}
	local cell = getCell and getCell() or nil
	if player and player.getSquare then
		pcall(function()
			local psq = player:getSquare()
			if psq and cell then
				local px = psq:getX()
				local py = psq:getY()
				local pz = psq:getZ()
				for dx = -2, 2 do
					for dy = -2, 2 do
						local sq = cell:getGridSquare(px + dx, py + dy, pz)
						if sq then
							squares[#squares + 1] = sq
						end
					end
				end
			end
		end)
	end
	if srcRef and srcRef.x ~= nil and cell then
		pcall(function()
			local sq = cell:getGridSquare(srcRef.x, srcRef.y, srcRef.z or 0)
			if sq then
				squares[#squares + 1] = sq
			end
		end)
	end
	if container then
		pcall(function()
			local sq = container.getSourceGrid and container:getSourceGrid() or nil
			if not sq and container.getSquare then
				sq = container:getSquare()
			end
			if not sq and container.getParent then
				local p = container:getParent()
				if p and p.getSquare then
					sq = p:getSquare()
				elseif p and instanceof and instanceof(p, "IsoGridSquare") then
					sq = p
				end
			end
			if sq then
				squares[#squares + 1] = sq
			end
		end)
	end

	for _, sq in ipairs(squares) do
		if sq and sq.getWorldObjects then
			local wobs = sq:getWorldObjects()
			if wobs then
				for i = 0, wobs:size() - 1 do
					local wo = wobs:get(i)
					local it = wo and wo.getItem and wo:getItem() or nil
					if it and it.getID and it:getID() == itemID then
						return it
					end
				end
			end
		end
		if sq and sq.getFloorContainer then
			local fc = sq:getFloorContainer()
			if fc and fc.getItems then
				local items = fc:getItems()
				if items then
					for i = 0, items:size() - 1 do
						local it = items:get(i)
						if it and it.getID and it:getID() == itemID then
							return it
						end
					end
				end
			end
		end
	end

	return nil
end

-- MP: clients cannot complete ItemTransaction when Java capacityWeight already exceeds 100.
-- Client sends BlindTransfer; server removes from src and DoAddItemBlind into USV.
local function onClientCommand(module, command, player, args)
	if module ~= "USV" or not USV then
		return
	end
	-- Allowlist + rate limit (cheat clients spamming BlindTransfer / SaveContents).
	local allowed = {
		ReleaseAt = true,
		SetAppearance = true,
		SaveContents = true,
		RestoreContents = true,
		BlindTransfer = true,
	}
	if not allowed[command] then
		return
	end
	if USV.allowClientCommand and not USV.allowClientCommand(player, command) then
		USV.logError("USV cmd rate-limited: " .. tostring(command))
		return
	end
	if command == "ReleaseAt" then
		if not player or not args then
			return
		end
		if not USV.isAuthoritative or not USV.isAuthoritative() then
			return
		end
		local ownerId = USV.getOwnerId and USV.getOwnerId(player) or nil
		local kind = args.kind or "fridge"
		-- Only delete JSON when the requesting player owns it (prevents wiping others' snapshots).
		if args.contentsId and USV.deleteContentsSnapshot and ownerId then
			local snap = USV.readContentsSnapshot and USV.readContentsSnapshot(args.contentsId) or nil
			-- readContentsSnapshot already enforces world match; allow delete of missing/empty too after own scrap
			local okDelete = true
			if snap and snap.ownerName and USV.resolveOwnerUserName then
				local myName = USV.resolveOwnerUserName(ownerId, player)
				if snap.ownerName ~= myName then
					okDelete = false
				end
			end
			if okDelete then
				USV.deleteContentsSnapshot(args.contentsId)
			end
		end
		if not ownerId or not USV.getKindDef or not USV.getKindDef(kind) then
			return
		end
		if args.x ~= nil and args.y ~= nil and USV.releaseOwnerPlacementAt then
			USV.releaseOwnerPlacementAt(kind, ownerId, {
				x = args.x,
				y = args.y,
				z = args.z or 0,
			})
			return
		end
		-- Ignore pickup (still carrying) and ignore if a live object remains.
		if USV.playerOwns and not USV.playerOwns(kind, player) then
			return
		end
		if USV.playerIsCarryingKind and USV.playerIsCarryingKind(kind, player) then
			return
		end
		if USV.playerHasLiveKind and USV.playerHasLiveKind(kind, player) then
			return
		end
		if USV.releaseOwnerId then
			USV.releaseOwnerId(kind, ownerId)
		end
		return
	end
	if command == "SetAppearance" then
		if not player or not args or args.x == nil or args.y == nil or not args.appearanceId then
			return
		end
		if not USV.isAuthoritative or not USV.isAuthoritative() then
			return
		end
		if not USV.applyAppearance or not USV.playerCanCustomize then
			USV.logError("SetAppearance: helpers missing")
			return
		end
		local cell = getCell and getCell() or nil
		local sq = cell and cell:getGridSquare(args.x, args.y, args.z or 0) or nil
		if not sq or not sq.getObjects then
			return
		end
		local obj = nil
		local objects = sq:getObjects()
		if objects then
			for i = 0, objects:size() - 1 do
				local candidate = objects:get(i)
				if candidate and USV.isLegitimateUSVObject(candidate) then
					obj = candidate
					break
				end
			end
		end
		if not obj then
			return
		end
		if not USV.playerCanCustomize(player, obj) then
			return
		end
		local ps = player.getSquare and player:getSquare() or nil
		if ps and sq then
			local dx = math.abs((ps:getX() or 0) - (sq:getX() or 0))
			local dy = math.abs((ps:getY() or 0) - (sq:getY() or 0))
			if dx > 8 or dy > 8 then
				return
			end
		end
		if not USV.applyAppearance(obj, args.appearanceId, true) then
			USV.logError("SetAppearance failed id=" .. tostring(args.appearanceId))
		end
		return
	end
	if command == "SaveContents" then
		if not USV.isAuthoritative or not USV.isAuthoritative() then
			return
		end
		if not player or not args or not args.id or not args.packs then
			return
		end
		local id = USV.sanitizeContentsId and USV.sanitizeContentsId(args.id) or nil
		if not id then
			return
		end
		local ownerId = USV.getOwnerId and USV.getOwnerId(player) or nil
		if not ownerId then
			return
		end
		-- Client cannot claim another player's ownerId in the snapshot.
		if args.ownerId and args.ownerId ~= ownerId then
			USV.logError("SaveContents: owner mismatch")
			return
		end
		local kind = args.kind or "vault"
		local clean, err = USV.sanitizeSnapshotPacks(args.packs, kind)
		if not clean then
			USV.logError("SaveContents: rejected packs (" .. tostring(err) .. ")")
			return
		end
		USV.writeContentsSnapshot(id, { packs = clean }, {
			kind = kind,
			ownerId = ownerId,
			ownerName = USV.resolveOwnerUserName and USV.resolveOwnerUserName(ownerId, player) or nil,
		})
		return
	end
	if command == "RestoreContents" then
		if not USV.isAuthoritative or not USV.isAuthoritative() then
			return
		end
		if not player or not args or not args.id or args.x == nil or args.y == nil then
			return
		end
		local id = USV.sanitizeContentsId and USV.sanitizeContentsId(args.id) or nil
		if not id then
			return
		end
		local ownerId = USV.getOwnerId and USV.getOwnerId(player) or nil
		local cell = getCell and getCell() or nil
		local sq = cell and cell:getGridSquare(args.x, args.y, args.z or 0) or nil
		if not sq or not sq.getObjects then
			return
		end
		local obj = nil
		local objects = sq:getObjects()
		if objects then
			for i = 0, objects:size() - 1 do
				local candidate = objects:get(i)
				if candidate and USV.isLegitimateUSVObject(candidate) then
					local kind = USV.getObjectKind(candidate)
					if not args.kind or kind == args.kind then
						obj = candidate
						break
					end
				end
			end
		end
		if not obj then
			USV.logError("RestoreContents: object not found")
			return
		end
		-- Only the owner (or customize-capable player) may refill from JSON.
		if USV.playerCanCustomize and not USV.playerCanCustomize(player, obj) then
			USV.logError("RestoreContents: not owner")
			return
		end
		local md = obj.getModData and obj:getModData() or nil
		if ownerId and md and md[USV.OWNER_FLAG] and md[USV.OWNER_FLAG] ~= ownerId then
			USV.logError("RestoreContents: owner flag mismatch")
			return
		end
		USV.setEntityContentsId(obj, id)
		USV.applyObject(obj, true, args.kind or USV.getObjectKind(obj) or "vault")
		local existing = 0
		pcall(function()
			local containers = USV.collectContainers(obj)
			for _, c in ipairs(containers) do
				local items = c.getItems and c:getItems() or nil
				if items then
					existing = existing + items:size()
				end
			end
		end)
		local n = 0
		if existing <= 0 then
			n = USV.restoreContentsFromSnapshot(obj, id)
		else
			n = existing
		end
		USV.syncEntityContentsSnapshot(obj)
		if n <= 0 then
			USV.logError("RestoreContents: no items restored id=" .. tostring(id))
		end
		return
	end
	if command ~= "BlindTransfer" then
		return
	end
	if not player or not args or not args.itemID or not args.src or not args.dest then
		return
	end
	if not USV.resolveContainerRef or not USV.doBlindTransfer then
		USV.logError("BlindTransfer: shared helpers missing")
		return
	end
	local src = USV.resolveContainerRef(args.src, player)
	local dest = USV.resolveContainerRef(args.dest, player)
	local srcIsFloor = args.src and (args.src.kind == "floor" or args.src.type == "floor")
	local destIsFloor = args.dest and (args.dest.kind == "floor" or args.dest.type == "floor")
	-- Floor side may have nil FloorContainer on dedicated; still allow if the other side resolves.
	if (not src and not srcIsFloor) or (not dest and not destIsFloor) then
		USV.logError("BlindTransfer: container resolve failed")
		return
	end
	local destFloorSq = nil
	if destIsFloor then
		pcall(function()
			if getCell and args.dest and args.dest.x ~= nil then
				destFloorSq = getCell():getGridSquare(args.dest.x, args.dest.y, args.dest.z or 0)
			end
		end)
		if not destFloorSq and dest and dest.getSourceGrid then
			pcall(function()
				destFloorSq = dest:getSourceGrid()
			end)
		end
		if not destFloorSq and player and player.getSquare then
			pcall(function()
				destFloorSq = player:getSquare()
			end)
		end
		if not dest and not destFloorSq then
			USV.logError("BlindTransfer: floor dest square missing")
			return
		end
	end
	local destUSV = dest and USV.isUnlimitedContainer(dest) or false
	local srcUSV = src and USV.isUnlimitedContainer(src) or false
	if not destUSV and not srcUSV then
		USV.logError("BlindTransfer: neither side is USV")
		return
	end
	-- Require trusted world parent for the USV side(s) (blocks forged FLAG containers).
	local function trustedSide(cont)
		local parent = USV.getContainerWorldObject and USV.getContainerWorldObject(cont) or nil
		if not parent then
			local ok, p = pcall(function()
				return cont.getParent and cont:getParent() or nil
			end)
			parent = ok and p or nil
		end
		return parent and USV.isCapacityTrustedParent and USV.isCapacityTrustedParent(parent)
	end
	if destUSV and not trustedSide(dest) then
		USV.logError("BlindTransfer: dest not trusted USV")
		return
	end
	if srcUSV and not trustedSide(src) then
		USV.logError("BlindTransfer: src not trusted USV")
		return
	end
	-- Proximity: player must be near the USV square.
	local usvCont = destUSV and dest or src
	local usvObj = USV.getContainerWorldObject and USV.getContainerWorldObject(usvCont) or nil
	local usvSq = nil
	pcall(function()
		usvSq = usvObj and usvObj.getSquare and usvObj:getSquare() or nil
		if not usvSq and usvCont and usvCont.getSourceGrid then
			usvSq = usvCont:getSourceGrid()
		end
	end)
	if USV.playerNearObjectOrSquare and not USV.playerNearObjectOrSquare(player, usvObj, usvSq, USV.BLIND_XFER_MAX_DIST) then
		USV.logError("BlindTransfer: too far")
		return
	end
	local item = findItemById(src, args.itemID, player, args.src)
	if not item and src and args.src and args.src.kind == "world" and args.src.x ~= nil then
		-- Stacked crates share one tile and type, and the ref has no way to tell them apart,
		-- so resolveContainerRef returns the first one. Look in the other non-USV containers there.
		local sq = getCell and getCell():getGridSquare(args.src.x, args.src.y, args.src.z or 0) or nil
		local objects = sq and sq.getObjects and sq:getObjects() or nil
		if objects then
			for i = 0, objects:size() - 1 do
				local obj = objects:get(i)
				local conts = {}
				pcall(function()
					local count = obj.getContainerCount and obj:getContainerCount() or 0
					for ci = 0, count - 1 do
						conts[#conts + 1] = obj:getContainerByIndex(ci)
					end
					if count == 0 and obj.getItemContainer and obj:getItemContainer() then
						conts[#conts + 1] = obj:getItemContainer()
					end
				end)
				for _, c in ipairs(conts) do
					if c and c ~= src and not USV.isUnlimitedContainer(c) then
						local it = nil
						pcall(function()
							it = c.getItemById and c:getItemById(args.itemID) or nil
						end)
						if it then
							src = c
							item = it
							break
						end
					end
				end
				if item then
					break
				end
			end
		end
	end
	if not item then
		-- Listen-server host often already applied the transfer via client prediction.
		USV.logError("BlindTransfer: item not found in source id=" .. tostring(args.itemID))
		return
	end
	if USV.isUSVFurnitureItem and USV.isUSVFurnitureItem(item) then
		USV.logError("BlindTransfer: refuse USV furniture item")
		return
	end
	-- Fridge food gate (do NOT call itemAllowedInUSVFridge with nil vanilla fn — that always returns false).
	if destUSV and USV.containerIsUSVFridge and USV.containerIsUSVFridge(dest) then
		local allowFood = true
		if USV.isTobaccoItem and USV.isTobaccoItem(item) then
			allowFood = false
		elseif USV.itemFridgeHardDeny and USV.itemFridgeHardDeny(item) then
			allowFood = false
		elseif USV.isFridgeFoodItemStrict and not USV.isFridgeFoodItemStrict(item) then
			allowFood = false
		end
		if not allowFood then
			USV.logError("BlindTransfer: fridge reject " .. tostring(USV.itemFullType and USV.itemFullType(item)))
			return
		end
	end
	local ok = USV.doBlindTransfer(player, item, src, dest, { destFloorSq = destFloorSq })
	if not ok then
		USV.logError("BlindTransfer fail item=" .. tostring(args.itemID))
	else
	end
end

Events.LoadGridsquare.Add(onLoadGridsquare)
if Events.OnObjectAdded then
	Events.OnObjectAdded.Add(onObjectAdded)
end
Events.OnDestroyIsoThumpable.Add(onDestroyIsoThumpable)
Events.OnInitGlobalModData.Add(onInitGlobalModData)
if Events.OnClientCommand then
	Events.OnClientCommand.Add(onClientCommand)
end

Events.OnGameStart.Add(function()
	if not USV then
		return
	end
	USV.installAllHooks()
	USV.reinstallTransferHooks()
end)

if not USV then
	print("[UnlimitedStorageVault] ERROR: USV_Shared failed to load (USV is nil)")
end