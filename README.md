![My Base Defence GitHub](https://repository-images.githubusercontent.com/365612047/078c1480-b05d-11eb-9e15-e0b4115bc1fe)
# **My Base Defence Gamemode!**
***The Original Unoffical Version :: My Base Defence **( 32/64-bit )** ::***

**[My Base Defence Gamemode on Steam Workshop](https://steamcommunity.com/sharedfiles/filedetails/?id=2074331908)**

### *You can install Optional Content Packs for many different SWEPs!*
* [Content Pack 1 of 3](https://steamcommunity.com/sharedfiles/filedetails/?id=1716416721)
* [Content Pack 2 of 3](https://steamcommunity.com/sharedfiles/filedetails/?id=1716419608)
* [Content Pack 3 of 3](https://steamcommunity.com/sharedfiles/filedetails/?id=1716420640)

### Recommened Mounted Games

* **Half-Life 2: Episode One** (Zombine)
* **Half-Life 2: Episode Two** (Jalopy)

**You can now edit the spawn list (BuyBox/NPC) from the settings panel!**

*Multiplayer is best with a lower NPC limit (e.g. 30).*

***My Base Defence has been in development for a while - It is basically a player controlled game. You set and decide the rules yourself!** Delete the old M.B.D. Beta from addons folder if you have it.*

*Recommended age limit is +18, because of the extra gore added to the game.*
*As for many FPS games, this gamemode might not be suitable for people with epilepsy.*

## What is M.B.D.?
The Inspiration? To do a mix between **Garry's Mod Sandbox** and **Call of Duty: WaW: Zombies** - A *Build*, *Defend* and *Survive* Gamemode you can play with your friends agains enemy AI.

## Visual Effects In-game (buttons supports the default layout):

* Speed up the game (global/single-player) through the quick menu for a different gameplay
* Slow motion effect in single-player. Press & Hold "E" while shooting. You can adjust the speed by holding "E" + mouse wheel; press down the mouse wheel to reset and stop all current occuring sounds in-game. You can for that reason by default not throw grenade with "E" + Mouse 1 in single-player. The admin can disable this complety (default) on global server
* Player views like first-person and third-person. It also supports orthographic view! This almost creates a whole different gameplay experience. Must try!


## Current Key Features:

* Can turn on (default) or off strict mode. This will enable/disable default Sandbox mode inside My Base Defence, since My Base Defence is derrived from Garry's Mod Sandbox. M.B.D. have a limit version of it by default (limited Spawnmenu)
* The **Content Packs contains a custom modified version of FA:S 2 Alpha SWEPs**. M.B.D. would not have been the same without these (thank [Spy](https://steamcommunity.com/id/anoosbloast) the creator)
* **Customizable NPC Spawner, BuyBox and Spawnmenu for Props**
* A replica Mystery Box that chooses any weapons on server. Costs 950 £B.D. to use (this entity is made by me)
* Custom class system. Choose from: Engineer, Mechanic, Medic or Terminator. They all have custom properties; like Medics have access to buy health chargers from the BuyBox
* Different pre-set games you can use by accessing the quick menu. Basically two main modes: Regualar MBD and Pyramid Collection MBD
* Custom respawn system (this can be disabled). When a player dies, they can respawn again after X seconds defined by an Admin
* Props have health. NPCs will try and destroy all props. This is added automatically be the server, and is based on their mass. Higher is more health
* Custom SWEPs that can fix props/vehicles when damaged. You can also "Super Charge" props (this costs B.P.) to make them very strong
* Custom points system. You have points you get from picking up drops from enemies. These are called B.P. (Build Points) and £B.D. ("Base Defence Euros")
* Custom gore models added to Zombie Classic, Zombine (EP: Two), All combine soldiers (not metro police)
* Supports orthographic view! Make sure to select a good map for this (make your own?) like gm_flatgrass. Maybe not to many high buildings, if not a custom map that would eliminate these visual defects you get from a orthographic view, where you will see through the map sometimes
* Bunch of visual effects
* Can almost tune every setting to make the game very custom (not all values are saves)
* Mechanics (and admins) can buy and spawn vehicles!
* Custom quick button menu when pressing TAB (IN_SCORE). Here you can also see some other stats for current running wave/game
* Auto. generated whitelist for spawnmenu, buybox and tools menu

![NPC Spawner](https://steamuserimages-a.akamaihd.net/ugc/1014943649046399429/E9EB5BD2127B03F4AA14D330905E358A931997C3/?imw=637&imh=358&ima=fit)

## Get Started
Enter the gamemode as an admin, and place preferraly a NPC Spawner (to spawn enemy AI) and a BuyBox Station (to be able to purchase stuff), and maybe a Mystery Box (you can disable particles - look under "ConVars"). Now wait for the countdown timer, or start the game manually through the settings panel/quick settings menu. The server needs atleast one admin to set the game up before being able to play. After this, the admin can leave the server and the game will be controlled automatically by the server.

## Admin
Admins have access to the settings of the gamemode itself - There is also a quick setting menu available (look under "Quick access"). Admins can spawn different entities; like e.g. Blockers, which will let Admins through, but no other entities

## Help
You can access the help menu in-game from the lobby or quick access menu (look underneath)

## Quick access
Press TAB (IN_SCORE) to open the quick access buttons on the left side

## Duplicator tool (save creations)
It is still a Sandbox, but you can **only** save creations made inside the gamemode. You will have to pay for every prop in your saved creation (your base ?) when spawned (if not a cheating admin).

## FA:S 2 SWEPs Settings

* Hold down "C" to open the customize menu
* Press "E" (IN_USE) + "R" (IN_RELOAD) to change fire mode
* Go into Spawnmenu ("Q") => Options, to change further settings


## ConVars
**My Base Defence:**
### SAVES WHEN CLOSING THE GAME:
```lua
mbd_enableStrictMode
mbd_howManyDropsNeedsToBePickedUpBeforeWaveEnd
mbd_turnOffSirenSoundStartGame
mbd_countDownTimerAttack
mbd_countDownTimerEnd
mbd_npcLimit
mbd_superAdminsDontHaveToPay
mbd_respawnTimeBeforeCanSpawnAgain
mbd_enableAutoScaleModelNPC
mbd_enableHardEnemiesEveryThreeRound
mbd_ladderLimit
mbd_npcSpawnerMaxNPCRowCount
mbd_disableHonkHornSoundEffect
```
**CLIENT**:
```lua
mbd_disablePlayerTilt ( 0 or 1 ( def. ) )
mbd_PlayerColorEnhancerState ( States: 0 ( def. ), 1, 2 ( disabled ) )
mbd_disablePlayerBlurEffect ( motion blur ) ( 0 or 1 ( def. ) )
mbd_disablePlayerToyTownBlurEffect ( 0 or 1 ( def. ) )
```
### **DOESN'T** SAVE WHEN CLOSING THE GAME:
```lua
mbd_game_status
mbd_roundWaveNumber
mbd_disableSlowMotionEffect
mbd_shouldOutputWhenPropIsRemoved
```
**CHEATS (sv_cheats 1)**:
```lua
mbd_disableStamina
```

**My Base Defence - Black Ops 3 Mystery Box Replica:**
### SAVES WHEN CLOSING THE GAME:
```lua
mbd_mysterybox_bo3_ravo_exchangeWeapons
mbd_mysterybox_bo3_ravo_teddybearGetChance
mbd_mysterybox_bo3_ravo_MysteryBoxTotalHealth
mbd_mysterybox_bo3_ravo_hideAllNotificationsFromMysteryBox
mbd_mysterybox_bo3_ravo_disableAllParticlesEffects
```

### License:
This addon is created by [ravo (Norway)](https://steamcommunity.com/sharedfiles/filedetails/?id=1647345157) or the uploader of this [Gamemode](https://steamcommunity.com/sharedfiles/filedetails/?id=2074331908) on Steam Workshop.

**Copyright content:**

* The sounds used for the Mystery Box belongs to the rightful owner(s) within the COD Zombie Series.
* The wood texture is from: [valeria_aksakova](https://www.freepik.com/valeria-aksakova).


[PayPal - ravonorway](https://paypal.me/ravonorway)

***Made in Norway. - by ravo Norway 🏔***
