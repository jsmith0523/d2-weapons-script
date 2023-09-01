# CREATED BY Joe Smith (Hobbes), Aug 2023
param ([string] $key = $env:BungieWpnScriptKey, [switch] $adept, [switch] $debug)

if($debug) { $DebugPreference = 'Continue' }

#region || ENUM DEFINITIONS ||
$eventNameHash = @{
  1 = "The Dawning"
  2 = "Crimson Days"
  3 = "Solstice of Heroes"
  4 = "Festival of the Lost"
  5 = "The Revelry"
  6 = "Guardian Games"
}

$specialItemTypeHash = @{
	0 = "None"
	1 = "Special Currency"
	8 = "Armor"
	9 = "Weapon"
	23 = "Engram"
	24 = "Consumable"
	25 = "Exchange Material"
	27 = "Mission Reward"
	29 = "Currency"
}

$itemTypeHash = @{
	0 = "None"
	1 = "Currency"
	2 = "Armor"
	3 = "Weapon"
	7 = "Message"
	8 = "Engram"
	9 = "Consumable"
	10 = "Exchange Material"
	11 = "Mission Reward"
	12 = "Quest Step"
	13 = "Quest Step Complete"
	14 = "Emblem"
	15 = "Quest"
	16 = "Subclass"
	17 = "Clan Banner"
	18 = "Aura"
	19 = "Mod"
	20 = "Dummy"
	21 = "Ship"
	22 = "Vehicle"
	23 = "Emote"
	24 = "Ghost"
	25 = "Package"
	26 = "Bounty"
	27 = "Wrapper"
	28 = "Seasonal Artifact"
	29 = "Finisher"
}

$itemSubTypeHash = @{
	0 = "None"
	6 = "Auto Rifle"
	7 = "Shotgun"
	8 = "Machinegun"
	9 = "Hand Cannon"
	10 = "Rocket Launcher"
	11 = "Fusion Rifle"
	12 = "Sniper Rifle"
	13 = "Pulse Rifle"
	14 = "Scout Rifle"
	17 = "Sidearm"
	18 = "Sword"
	19 = "Mask"
	20 = "Shader"
	21 = "Ornament"
	22 = "Fusion Rifle Line"
	23 = "Grenade Launcher"
	24 = "Submachine Gun"
	25 = "Trace Rifle"
	26 = "Helmet Armor"
	27 = "Gauntlets Armor"
	28 = "Chest Armor"
	29 = "Leg Armor"
	30 = "Class Armor"
	31 = "Combat Bow"
	32 = "DummyRepeatableBounty"
	33 = "Glaive"
}

$damageTypeHash = @{
	0 = "None"
	1 = "Kinetic"
	2 = "Arc"
	3 = "Solar" #it's not 'Thermal' you assholes
	4 = "Void"
	5 = "Raid"
	6 = "Stasis"
	7 = "Strand"
}

$ammunitionTypeHash = @{
	0 = "None"
	1 = "Primary"
	2 = "Special"
	3 = "Heavy"
	4 = "Unknown"
}
#endregion || ENUM DEFINITIONS ||

try {
	#region || DOWNLOAD SECTION ||
	
	# GET UPDATED SEASON AND EVENT CONVERSIONS
	#seasons - updated every season
	$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
	$path = "https://raw.githubusercontent.com/DestinyItemManager/d2-additional-info/master/output/watermark-to-season.json"
	$temp = Invoke-RestMethod $path -Method 'GET' -Headers $headers | ConvertTo-Json -Depth 5
	$seasonHash = @{}
	(ConvertFrom-Json $temp).psobject.properties | Foreach { $seasonHash[$_.Name] = $_.Value }
	
	#events - rarely updated
	$path = "https://raw.githubusercontent.com/DestinyItemManager/d2-additional-info/master/output/watermark-to-event.json"
	$temp = Invoke-RestMethod $path -Method 'GET' -Headers $headers | ConvertTo-Json -Depth 5
	$eventHash = @{}
	(ConvertFrom-Json $temp).psobject.properties | Foreach { $eventHash[$_.Name] = $_.Value }

	# PULL MANIFEST LIST
	Write-Host "Pulling manifests..."
	$path = "https://www.bungie.net/Platform/Destiny2/Manifest/"
	$manifests = Invoke-RestMethod $path -Method 'GET' -Headers $headers
	$headers.Add("x-api-key", $key) #add api key after getting the manifests		
	
	#PULL LOOKUP HASHES
	$path = "https://www.bungie.net" + $manifests.Response.jsonWorldComponentContentPaths.en.DestinyInventoryBucketDefinition
	$inventoryBucketLookup = Invoke-RestMethod $path -Method 'GET' -Headers $headers
	
	$path = "https://www.bungie.net" + $manifests.Response.jsonWorldComponentContentPaths.en.DestinyItemTierTypeDefinition
	$itemTierTypeLookup = Invoke-RestMethod $path -Method 'GET' -Headers $headers
	
	$path = "https://www.bungie.net" + $manifests.Response.jsonWorldComponentContentPaths.en.DestinyStatDefinition
	$statLookup = Invoke-RestMethod $path -Method 'GET' -Headers $headers
	
	$path = "https://www.bungie.net" + $manifests.Response.jsonWorldComponentContentPaths.en.DestinyEquipmentSlotDefinition
	$equipmentSlotLookup = Invoke-RestMethod $path -Method 'GET' -Headers $headers
	
	$path = "https://www.bungie.net" + $manifests.Response.jsonWorldComponentContentPaths.en.DestinyItemCategoryDefinition
	$itemCategoryLookup = Invoke-RestMethod $path -Method 'GET' -Headers $headers
	
	$path = "https://www.bungie.net" + $manifests.Response.jsonWorldComponentContentPaths.en.DestinyPowerCapDefinition
	$powerCapLookup = Invoke-RestMethod $path -Method 'GET' -Headers $headers
	
	$path = "https://www.bungie.net" + $manifests.Response.jsonWorldComponentContentPaths.en.DestinyCollectibleDefinition
	$collectibleLookup = Invoke-RestMethod $path -Method 'GET' -Headers $headers
	
	$path = "https://www.bungie.net" + $manifests.Response.jsonWorldComponentContentPaths.en.DestinySocketTypeDefinition
	$socketTypeLookup = Invoke-RestMethod $path -Method 'GET' -Headers $headers
	
	$path = "https://www.bungie.net" + $manifests.Response.jsonWorldComponentContentPaths.en.DestinySocketCategoryDefinition
	$socketCategoryLookup = Invoke-RestMethod $path -Method 'GET' -Headers $headers
	
	$path = "https://www.bungie.net" + $manifests.Response.jsonWorldComponentContentPaths.en.DestinyPlugSetDefinition
	$plugSetLookup = Invoke-RestMethod $path -Method 'GET' -Headers $headers
	
	$path = "https://www.bungie.net" + $manifests.Response.jsonWorldComponentContentPaths.en.DestinyInventoryItemDefinition
	$inventoryItemLookup = Invoke-RestMethod $path -Method 'GET' -Headers $headers

	#Note on DestinyInventoryItemDefinition:
	#    We can use 'itemType' to check which version of the weapon
	#    it is because the one we want has 3 / Weapon while the one we
	#    don't want has 20 / Dummy (see Destiny.DestinyItemType enum)

	#endregion || DOWNLOAD SECTION ||

	#region || PARSE SECTION ||
	
	# BUILD WEAPON LIST
	Write-Host "Building weapon list..."
	$myList = [System.Collections.Generic.List[object]]::new()
	$count = 0
	($inventoryItemLookup.psobject.properties) | foreach-object {
		try {
			# ADD TO NEW LIST IF WEAPON TYPE
			$item = $inventoryItemLookup.($_.name)
			if($item.itemType -eq 3) {
				$myList.Add($item)
			}
		}
		catch {}
		$count++
		Write-Host -NoNewline "`r$($count)"
	}
	Write-Host #reset after NoNewline
	
	Write-Host "Building CSV structure..."
	$output = [System.Collections.ArrayList]::new()
	foreach($weapon in $myList) {
		# QUIT LOOP CHECKS
		#ignore non-legendary / non-exotic weapons
		if(($weapon.inventory.tierType -ne 5) -and
			($weapon.inventory.tierType -ne 6)) {
				continue
		}
		#ignore old version of items (duplicates) that can't be identified by season;
		#  mostly event weapons have this issue because the watermark icon can only
		#  be traced to the event and doesn't distinguish between seasons.
		$temp =	@(3400256755, #Zephyr
				2603335652, #Jurassic Green
				2869466318) #BrayTech Werewolf
		if($weapon.hash -in $temp) { continue }
		#conditionally ignore adept versions of weapons
		if(-not $adept) {
			if(($weapon.displayProperties.name -match "(Adept)") -or
				($weapon.displayProperties.name -match "(Timelost)") -or
				($weapon.displayProperties.name -match "(Harrowed)")) {
					continue
				}
		}
		
		# GATHER INFO FOR ONE WEAPON
		$save = @{}
		
		# get name
		Write-Debug "Name = $($weapon.displayProperties.name)"
		$save.Add("Name",$weapon.displayProperties.name)
		
		# get weapon type
		Write-Debug "Wpn Type = $($itemSubTypeHash.($weapon.itemSubType))"
		$save.Add("Weapon Type",$itemSubTypeHash.($weapon.itemSubType))
		
		# get damage type
		Write-Debug "Default Damage Type = $($damageTypeHash.($weapon.defaultDamageType))"
		$save.Add("Damage Type",$damageTypeHash.($weapon.defaultDamageType))
		
		# get weapon hash
		Write-Debug "Hash = $($weapon.hash)"
		$save.Add("Hash",$weapon.hash)
		
		# get weapon's originating season or event
		if($weapon.iconWatermark) { #some old weapons don't have watermarks
			Write-Debug "watermark = $($weapon.iconWatermark)"
			if($seasonHash.($weapon.iconWatermark)) {
				Write-Debug "Season = $($seasonHash.($weapon.iconWatermark))"
				$save.Add("Season",$seasonHash.($weapon.iconWatermark))
			}
			else {
				Write-Debug "Event = $($eventHash.($weapon.iconWatermark))"
				$save.Add("Event",$eventHash.($weapon.iconWatermark))
			}
		}
		
		# get 'source'
		Write-Debug "Source = $($collectibleLookup.($weapon.collectibleHash).sourceString)"
		$save.Add("Source",$collectibleLookup.($weapon.collectibleHash).sourceString)
		
		# get whether or not the weapon is exotic
		#note: we're only saving legendary and exotic weapons
		if($itemTierTypeLookup.($weapon.inventory.tierTypeHash).displayProperties.name -eq "Exotic") {
			Write-Debug "IsExotic = TRUE"
			$save.Add("IsExotic","TRUE")
		}
		else {
			Write-Debug "IsExotic = FALSE"
			$save.Add("IsExotic","FALSE")
		}
		
		# is weapon craftable
		if($weapon.inventory.recipeItemHash) {
			Write-Debug "Craftable = TRUE"
			$save.Add("IsCraftable","TRUE")
		}
		else {
			Write-Debug "Craftable = FALSE"
			$save.Add("IsCraftable","FALSE")
		}
		
		# ammo type
		Write-Debug "Ammo Type = $($ammunitionTypeHash.($weapon.equippingBlock.ammoType))"
		$save.Add("Ammo Type",$ammunitionTypeHash.($weapon.equippingBlock.ammoType))
		
		# weapon stats
		#note: need to go through each sub-object here since it's not a simple list
		($weapon.stats.stats.psobject.properties) | foreach-object {
			$stat = $weapon.stats.stats.($_.name)
			if($statLookup.($stat.statHash).displayProperties.name -ne "") {
				Write-Debug "$($statLookup.($stat.statHash).displayProperties.name) = $($stat.value)"
				$save.Add($statLookup.($stat.statHash).displayProperties.name,$stat.value)
			}
		}
		
		try {
			$a = $weapon.sockets.socketEntries[0]
			$b = $plugSetLookup.($a.reusablePlugSetHash).reusablePlugItems[0]
			$c = $inventoryItemLookup.($b.plugItemHash).displayProperties.name
			$save.Add("Frame",$c)
		}
		catch { $save.Add("Frame","") }
		
		# save the weapon to output
		$output += New-Object -Type PSObject -Property @{
			Name = $save["Name"]
			WeaponType = $save["Weapon Type"]
			DamageType = $save["Damage Type"]
			AmmoType =  $save["Ammo Type"]
			Frame =  $save["Frame"]
			
			RPM = $save["Rounds Per Minute"]			# not bow, fusion, linear fusion
			DrawTime = $save["Draw Time"]				# bow
			ChargeTime = $save["Charge Time"]			# fusion, linear fusion;
														#   also sword but chargerate mirrors this
														#   glaive uses this but not for dps
			
			Hash = $save["Hash"]
			Season = $save["Season"]
			Event = $save["Event"]
			Source = $save["Source"]

			Impact = $save["Impact"]					# not rl, gl
			BlastRadius = $save["Blast Radius"]			# gl, rl
			Velocity = $save["Velocity"]				# gl, rl
			Accuracy = $save["Accuracy"]				# bow
			ShieldDur = $save["Shield Duration"]		# glaive
			
			Range = $save["Range"]
			Stability = $save["Stability"]
			Handling = $save["Handling"]
			Reload = $save["Reload Speed"]
			RecoilDir = $save["Recoil Direction"]
			AimAssist = $save["Aim Assistance"]
			AirEffect = $save["Airborne Effectiveness"]
			
			SwingSpeed = $save["Swing Speed"]			# sword
			GuardResist = $save["Guard Resistance"]		# sword
			GuardEffic = $save["Guard Efficiency"]		# sword
			ChargeRate = $save["Charge Rate"]			# sword, bow??
			
			Zoom = $save["Zoom"]						# not glaive, 0 on swords
			
			Magazine = $save["Magazine"]				# not bows
			Inventory = $save["Inventory Size"]			# seems inconsistent
			AmmoCap = $save["Ammo Capacity"]			# sword
			
			IsCraftable = $save["IsCraftable"]
			IsExotic = $save["IsExotic"]
			
			#FUTURE OUTPUTS?
			# SetPerks ; determine if perks are set
			# Scope ; determine if wpn has a scope (needed to calculate zoom)
			# Sight ; determine if wpn has a sight (relevant to hand cannons and sidearms)
			# Rangefinder ; determine if wpn has rangefinder perk (needed to calculate dist)
			# Seraph ; determine if wpn has seraph rounds
			# Ricochet ; determine if wpn has ricochet rounds
			# Steady ; determine if wpn has steady rounds
		}
	}
	
	#WRITE TO FILE
	Write-Host "Writing CSV file..."
	$output | Select-Object -Property Name,WeaponType,DamageType,AmmoType,Frame,RPM,DrawTime,ChargeTime,Hash,Season,Event,Source,Impact,BlastRadius,Velocity,Accuracy,ShieldDur,Range,Stability,Handling,Reload,RecoilDir,AimAssist,AirEffect,SwingSpeed,GuardResist,GuardEffic,ChargeRate,Zoom,Magazine,Inventory,AmmoCap,IsCraftable,IsExotic | Export-Csv -Path ".\d2wpns.csv" -Delimiter ',' -NoTypeInformation
	Write-Host "Done"
	#endregion || PARSE SECTION ||
}
catch {
	Write-Host "Error: $($_)"
}