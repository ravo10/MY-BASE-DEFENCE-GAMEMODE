# Features that can be added

* The posiblility to enable AI spawns every e.g. 2, 9, 8, 10 sec. that is friendly AI. That will spawn at normal Spawn Point (register players on initial spawn, and use those spawn points.. + z*index 10 ) https://github.com/Facepunch/garrysmod/blob/28eb7cdf0d5a4a723a3a7a0283c8dba1ccd9bbc6/garrysmod/gamemodes/base/gamemode/player.lua#L405*L462
* When open buybox, blur the screen a little for the player and darken (just paint a panel with HUD:... )
* Add possiblity to shoot through World walls ( not to thick ) ( define what ammo can go through ) and NPCs. Use TraceLine with some logic and Player fowards Vector ..
* Trace to entity on bullet hit ( client ) and spawn particle effects
* Editable Tools menu in strict mode
* Breath effect animaiton for player ( up/down )

## Known bugs ( not fixed yet )
* -

# Stable

### 0.0.2053 ( 09.05.21 )
* Fixed problem with NPC Spawner trying to spawn NPCs, when the total amount is reached
* Added "weapon_fist" as a default SWEP that will be givien on init.
* Added so that if the server does not have the content packs installed, it will use default fallback SWEPs that GMod has
* Added new ConVar `mbd_alwaysGiveFallbackSweps` if the server wants players to always receive fallback SWEPs

### 0.0.2052 ( 09.05.21 )
* New unexpected bug fix on NPC spawn, where the NPC Class could not get fetched
* Fixed so that the merged NPC class list wil not have duplicates

### 0.0.2051 ( 09.05.21 )
* Small bug fix for some empty uneeded files that needed to be removed
* Added so the timer that updates enemies on map, only updates when the games is started ( or else 0 )

### 0.0.205 ( 08.05.21 )
***Allot of fine tuning of the important stuff - Better performance***
* Enabled custom context menu as in default Sandbox
* Small bug with strict mode setting, where the Player table was not initialized before toolmenu init.
* Fixed issue with Jalopy button for buying vehicles
* Adjusted the colors for better contrast and animation in the spawnmenu
* Added so that desctruction pieces from props, are client side and not server side anymore
* Added so you can see if the current prop or weapon is free or not for superadmins in the spawnmenu
* Fixed a performance bug when a prop gets removed ( a client side hook )
* Added cleanup.UpdateUI to when spawnmenu is opened ( don't now if it makes any difference )
* Fixed so when jumping, the jump stamina will only contract if players velocity in Z-pos is 0
* Added new custom sounds for when prop and vehicles are fixed
* Fixed some bugs with math.Random(), where float types where used instead of intengers
* Moved bodyparts from NPCs to client side from server side for better performance
* Fixed so the BuyBox does not print out more than one time if the DButton already exists for that ent class
* Added small animation when clicking on a BuyBox button item
* Added new fading for dead NPCs and NPC bodyparts
* Fixed bug where bodypart for NPC could be spawned more than one time
* Fixed small bug with getting allowed NPC classes for NPC Spawner
* ... Fix above, fixes bug with the NPC Spawner not spawning enough enemies relative to the total amount allowed
* Added so the enemies total updates every second instead of when NPC spawned/killed
* Removed sound when undoing props ( not needed )

### 0.0.204 ( 09.06.20 )
***New big feature added (custom BuyBox and NPCs for NPC Spawner)***

* Fixed a few small bugs with the screen color modifier (the redness)
* **New Feature**: Added possibility to add custom NPCs, that the NPC Spawner will spawn using JSON (similar to the BuyBox JSON)
* Fixed a bug with the owner system of vehicles
* Fixed duplication of vehicles
* Adjustment: Added No Collide to default allowed tools
* Improved how the custom gore models are being added to the NPC spawn list
* Custom gore NPCs are now available to spawn withing the spawnmenu, if strict setting is off (0)
* NPC are now possible to spawn from spawnmenu without them getting removed
* Fixed a bug, where the enemies alive counter, would not get reset on game end
* Made the client side ragdoll model for all NPCs as good as it can be at the moment..
* Added so content that needs either Half-Life 2: EP One or Two, will only show up as an option if the respective games are mounted
* **New Feature**: Added so an Admin can customize the spawnlist for the NPC Spawner and BuyBox within the settings panel! Can be found under the "Options" tab
* Fixed a bug with the ladder creating an error with the model
* Improved position marker for Players (visuals)
* Added so players can not open spawnmenu when spectating and MBD is not finished loading
* Cleaned up some player functions (placement etc.)
* Improved spawn time for Player on death and the strip time
* Cut down the time it takes to open lobby with TAB + E
* Fixed a bug with removing of unvalid NPCs. You also need to enable the developer convar to show what got removed
* Improved the NPC-marker (CLIENT)
* Fixed some particle errors (gib juice and smoke grenade from M79)
* Added so enemies will have a schedule of SCHED_WAKE_ANGRY instead of SCHED_SHOOT_ENEMY_COVER after spawn
* Made it so enemies will have a neatural (D_NU) relatioship between eachother, instead of like (D_LI)
* Added another way to make NPC Headcrab to D_NU every other NPC on map on spawn
* Improved relationship adding
* Improved spawning of NPCs from NPC Spawner allot ( will almost never fail/get stuck ) (new system and logic)
* Removed scaling of NPC Headcrab if it spawns from a NPC Zombie
* Added chat print if a Player gets killed by an NPC

### 0.0.203
***Fine tuning of different stuff and multiplayer improvement***

* Fixed so the BuyBox tag fill always shows...
* Added more strict/correct way of limiting the Admins access to free stuff/benefits if they do not have the setting enabled (spawnmeny, lobby, BuyBox & Vehicles)
* Added a notify color for the lobby menu for class name on hover, if not possible to change to that class right now (e.g. full or round/wave !% 3)
* Fixed a bug where you could not spawn vehicles from spawnmenu even if strict setting was off
* Added propper owner check of vehicles
* Adjustment: Removed long aim for NPCs
* Adjustment: Added more aggressive checks to figure out if NPCs has an enemy
* Adjustment: Added so you can spawn props for free when game has not started (always)
* Added prediction for countdown timer (no lag)
* Added prediction for class picker (no lag)
* Added prediction for respawn button text, when a class is picked (no lag)
* Fixed a security issue with changing player class
* Added visual communication for when choosing a class + new sound if removing self from picked class
* Fixed a small bug when populating the Admin Settings panel, where if the panel was closed before loading has completed, an error would occure (net.receive)
* Fixed a bug where the players loadout would continue to give weapons for the prev. selected class, when the class was changed by player for self withing the lobby

### 0.0.20219
***Hot fix***

* Added the correct filtration system for checking if NPC is valid or not...

### 0.0.2021
***Mostly old bug fixes (from the beta)***

* Fixed a problem with the lobby countdown timer, after an admin has placed the NPC Spawner and BuyBox
* Updated the information of the Manual in-game with the new client side ConVars
* `mbd_disablePlayerBlurEffect`, `mbd_disablePlayerToyTownBlurEffect` and `mbd_disablePlayerTilt` is now on (1) by default for new players (old players have to change it manually)
* Changed logic to not end game when no players are in-game; just pause the countdown time for the game
* Adjusted logic for when to remove NPC if something wrong with it (not completed spawn etc.)
* Adjusted so NPC Spawner will always reach the NPC limit exactly
* Added so Lobby picker int., can't go under 0
* Added so all timers are reset on start game (if developing)
* Made counting of new NPCs spawned, only for NPC Spawner
* Only allow to see enemies through walls that have been succesfully spawned
* Fixed an issue where the grenade for Zombines could get removed
* Added better list check if NPC is an accepted NPC (e.g. not npc_bullseye or npc_grenade)
* Added so the player will receive current wave and enemies alive if joining a started game

### 0.0.202
***Mostly multiplayer fixes, to make it more stable***

* NPC Strider and Heli. attacked other NPCs (should not) fixed
* Could not change class before NPC Spawner and BuyBox was placed out, and game not started adjusted to allow
* Several populations of spawn list on player join (multiplayer)
* Added support for ULIB and ULX hooks in strict mode
* Maybe fixed that sometimes (multiplayer) SWEP would not register prop/vehicle
* Maybe fixed that sometimes (multiplayer) NPC Spawner would not set NPC to finished spawn state
* You can now disable toy town blur effect with `mbd_disablePlayerToyTownBlurEffect` (CLIENT)
* Removed admin button also, if admin access changes for a player while in lobby (visual purpose)
* Improved logic to check if NPC should be removed, if stuck
* Fixed a bug where removing an entity while fixing it created an error (nil entity)
* Added animation that will no longer be affected by lag: Player tilt angle, toy town blur effect and other HUD items that such as the stamina bar and camera view option button color (ADMIN)
* Fixed a bug with the minifier, where " not " was replaced in the wrong place
* Fixed a bug with the NPC Spawner spawning enemies when there are no players on server
* Added propper language for spawnmenu tabs
* Fixed a bug with the ammo for medic kits not being correct...
* Increased the health given by IFak SWEP (medic kit for medic class)
* Added medical supplies "ammo" to BuyBox under category "Other" for medic class

### 0.0.2
* Fixed some duplication problems
* Fixed SWEP icons, so they are better size on small screens
* Added so you can disable the color enhancer (state: 0, 1 or 2) `mbd_PlayerColorEnhancerState` and blur effect `mbd_disablePlayerBlurEffect` ( and they are saved + `disablePlayerTilt` now also ) (CLIENT)
* Added Honk Horn sound effect to vehicles. Can be disabled with `mbd_disableHonkHornSoundEffect` (SERVER)
* Fixed a bug with the spawn menu names not appearing properly when strict mode is 0
* Fixed a bug with some NPC models changing model on model scale change
* Added so potential loose bodyparts from NPCs will scale to normal size (1) on NPC death, as the ragdoll will be
* Minified code using my own minifier application ( https://sourceforge.net/projects/lua-minifier/ )

### 0.0111
* Fixed a propper fallback for Lerp, if it fails...
* Pre-cached a missing particle effect
* Fixed correct naming for spawnmenu

### 0.011
* Fixed a bug, where the whitelist of the BuyBox didn't populate correctly
* Added so you can set a row limit for the NPC Spawner with convar `mbd_npcSpawnerMaxNPCRowCount` (def. 21)
* Added so crouching increases stamina faster
* Fixed some issues with removing prop the correct way from client list (undo)
* Added so the NPCs spawner will every nine seconds make the NPCs search for an enemy target, if they don't have one
* Fixed so e.g. NOTIFY_GENERIC is defined on server (it is really a client constant)
* Fixed the NPC Spawner; it had messy code and was broken at some places
* Added so hooks (in strict mode) that are not allowed, will get removed. This can increase performance!
* Fixed NPC spawner npc relationship bug... They didn't like each other (combines and zombies)
* Fixed some bugs and improved code...
* Fine tuned the aim toybox

### 0.01
* Fixed some bugs
* Upgraded the spawnmenu to look much nicer
* Adjusted the max health and added extra health for props
* Added so you can edit the spawn*lists inside the data folder for MBD (my_base_defence)
* Added small amount of blur effect when very tierd + adjusted the colors for client screen
* Adjusted running stamina (increased)
* BUG: Added a timer which removes unwanted NPCs... Because of custom "split" models, they sometimes can't find animations ? This removes them atlest... No fix other fix found as of yet
* Added sound when NPCs get shot
* Added force from weapon when NPC get shot
* Added the VGUI icons hint, error, notify etc., becuase for some reason it is not included on a global server normally..
* Completly fixed the Door tool. All functions tested on NPCs and then converted to support Players
* Added the possibility to change the game speed through the quick menu
* Added vehicle quick menu/buy menu (press tab) for mechanics (and admins)
* Added RealTime() instead of SysTime() for animations; very important actually; or else it will go to fast
* Fixed the spawnmenu not loading async.
* Fixed bug with recharing stamina
* Adjusted the blur effect to look smoother and nice for players in/out of vehicles
* Math.ceiled(...) every value for stamina
* Fixed bug with spawning for non*admin... Unspectate mode not set ?? For reference changed func. maybeSpawnPlayerFromClass => unsetspectate mode
* Added effect when player is spectating
* Added (only for single player) function to slow the game down (for cool effect when e.g. shooting)
* (Big Feature) Added so user can slow down time if in singleplayer holding "E" (IN_USE) and clicking Mouse 1 down. Can also adjust speed with scroll wheel when "E" (IN_USE) is down. This will adjust in percentage of the current speed set by an Admin
* Disabled throw grenade for FA:S 2 on throw, because it used "E" (IN_USE), and interferred with the slow motion effect
* Adjusted the icons for the FA:S 2 to fit better
* (Big Feature) Added different view for the player. Also a top view, which is a orthograpic view! This makes it to like a mini game almost. The admin can control if this is allowed or not for user
* Imporved code, to make sure no functions are created inside hooks running every frame etc.
* Added tilt effect for player when moving in all views
* Adjusted the color effect for fit the top view when tired etc. (a little less/more)
* Adjusted the blur effect/tilt effect, so it response to the time scale of the game (in slow motion) when under 1 for screen effects and under 3 for tilt effect
* Added bounce to FA:S 2 weapons
* Fixed critical bug with populating spawnmenu... It was not secure or reliable. It is now secure (client gets spawnmenu from server + whitelist check on prop spawn)
* Fine tuned the spawnmenu HUD and added so the menu will never populate more tabs ( entity, dupes. ) etc. than it should there
* Fixed so you only have what you are supposed to have in the tools menu ( fixed it properly )
* Added whitelist for tool gun and a table "mbd_toolgun_config.lua" when in strict mode
* Added sound for vehicle spawn
* Added propper Undo for items when removed + for vehicles
* Updated the new undo function
* Edited the dtree file
* Added propper remove function to the removal tool also
* Added math.round to all prices for the customziable buybox menu
* Added whitelist check to buybox, and will kick player if he tries to buy something not on server whitelist
* Added icon for smoke and he ammo for M79 (content pack 3)

# Beta

### 2.62
* (Big Feature) Added destroyable models for NPC: Zombie, Zombine and the different Combine Soldiers + Particle effects for it, and code; makes the game +18
* Quick menu for admins (and voting system??) to configure of the gamemode to etiher: Regular MBD, Fast MBD, Slow MBD, Chase MBD (pyramids) etc.
* Added quick buttons for lobby, help/commands, quick menu and admin settings when pressing tab in*game
* Stamina for sprint and jump added

### 2.61
* Fixed bug with spawning pyramids, so it spawned more than it should etc.
* Fixed a bug with the Buy Box, where the non*admin Player could not buy stuff from the Buy Box
* Made a new sound system, so it doesn't play the same sound on*top of itself (stops the sound before a new one starts)
* Fixed another bug with the door tool, so players would not get added to it...
* Added so you can see how many pyramids are allready spawned
* Fixed a bug with respawn, where you could not respawn after closing and opening the lobby
* Fixed the pyramid spawn sequence/algorithm, because it was totally broken before on when to allow it...
* Added effect to door tool when using it
* My Base Defence Content 0 * Fixed the sounds not playing for FA:S 2 on global server
* Fixed issue with some particle effects not showing on client side
* Adjusted blood particle effects
* Add small blood mist on bullet hit (zombies have green)

### 2.60
* Fixed bug with tool gun... Did overwrite the Sec. attack etc.. with the door tool
* Added a check to remove unvalidated NPCs after 9 sec. after spawn with the NPC Spawner
* Adjusted/fine tunded the particle effects when killing an enemy

### 2.59
* Added marker to BuyBox through walls
* Fixed a bug with writing BuyBox config. files on first load
* Added particle effect when killing an enemy
* Nice transition when money/build points increases

### 2.58
* You now get B.P. and £B.D. from picking up pyramid drops
* Added small text if admin on respawn, and also on spawning ladder and reached the limit (so the Player knows it has more rights)
* Added so that the custom SWEPs will now use the Player model chosen in Sandbox
* Added phong refelction to SWEP material/texture file

### 2.57
* New custom cursors over menus
* Now the BuyBox will mark all available attachments for the maybe current equiped FA:S 2 weapon
* Big Change New Feature: The possibility to add custom weapons/items class in a JSON file. The templates are generated in the DATA folder under "my_base_defence"
* Added smoke grenade to M79 launcher (E + R to change fire mode)
* Added a new ladder entity! Everyone can spawn this

### 2.56
* Added some logic so the NPC Spawner will try to move the spawned NPC up or down (Z position) to find a valid spawn point, so no NPCs should get stuck!
* New Derma Lobby... Since HTML/CSS/JS is not supported by compression in .gma...
* New Derma BuyBox menu
* Added a small marker for where enemies are (which can be seen through e.g. walls)

### 2.55
* New Lobby (HTML/CSS/JS)
* New BuyBox menu (HTML/CSS/JS)
* Added all of the GMod pictures to BuyBox
* Made the files/classes for FA:S 2 its own name (added mbd_ at start) so it won't interfere with the normal FA:S 2
* Fixed some fonts issues
* Added more pictures for FA:S 2 entities, like ammo

### 2.54
* Fixed door tool * It was totally broken..
* Added text and box if you look at a prop that is either a door or roof (when close)
* Fixed many small bug on start up for player, when using an external server * Lobby should be pretty OK+ bug free now
* Added color to the print messages
* Added so you can open the lobby with CTRL + E in game

### 2.53
* Added new backgrounds to start up screen
* Fixed particle effect to stop when out of healing area using repair SWEPs

### 2.52
* A small bug with spawning pyramids... Adjusted the algoritm
* Adjusted the NPC Spawners spawning position (space)

### 2.51
* Balanced the pyramid spawn cycle pretty OK
* Added better particle effects (more) for the custom repair SWEPS
* Optimized loading for all FA:S 2 SWEPS. Pre*caching models; so should be allot less lagging when choosing a new class (after the first time) (the content packs)

### 2.5
* General bug fixes
* Added so you can see at all times where your other teamates are on the map (get a sence of it)
* Added a possibility to enable (default setting) so your team has to pick up drops each wave/round. These are dropped by enemy NPCs. If task is not completed the game will end. The default is three drops each round. The drops will start after wave three. This can change the whole gameplay; you can no longer "camp".
* Fixed the animation speed for BuyBox and NPC Spawner
* Improved loading speeds for first time load and performance (lag) when picking a class
* Added loading screen at start (first time spawning)

### 2.4
* Added new models and animations for the M.B.D. SWEPs
* Updated the GUI for the SWEPs
* General bug fixes for the SWEPs

### 2.3
* Updated the alogrithm to the amount of enemies spawning each round (intensity). Max. 60 per player each round.
* Updated the GUI for the lobby and the player screen
