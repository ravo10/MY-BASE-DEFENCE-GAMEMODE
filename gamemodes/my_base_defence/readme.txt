[h1]The [u]Unoffical[/u] My Base Defence Gamemode for Garry's Mod![/h1]
[i]- Made by ravo Norway[/i]

[u]Version: [b]0.01[/b][/u]
My Base Defence [b](32-bit)[/b] [i][Tested on: Windows 10][/i]

[u]Requires These Games: [b]Half-Life 2 and Half-Life 2 EP: 2[/b][/u]

[i][b]My Base Defence has been in development for a while - This is the new Workshop site for the finished stable version.[/b][/i]

[i]Recommended age limit is +18, because of the extra violence added to the game (can shoot of body parts)[/i]

[h2]What is M.B.D.?[/h2]
The Inspiration? A mix between [b]Garry's Mod Sandbox[/b] and [b]Call of Duty: WaW: Zombies[/b] - A [i]Build[/i], [i]Defend[/i] and [i]Survive[/i] Gamemode you can play with your friends agains enemy AI.

You can choose between four classes:
[list]
[*] Engineer (can super strengthen props)
[*] Mechanic (can spawn cars)
[*] Medic (can heal players on field + buy health charger)
[*] Terminator (have access to more weapons and health + buy suit charger)
[/list]

(There is a limited amount, but the server will adapt as needed.)

My Base Defence is basically a player controlled game. You have to set the game up yourself (see the quick settings menu) to have fun. You choose the difficulty by changing the speed of the attack timer and rest timer (between each wave). You can start at wave 10 instead of 1 to make it even harder quick etc. It is a wave based system. After each wave, there will spawn even more AIs (NPCs). Currently the maximum amount of NPCs per. player is 60. This occurs at around wave 10.

[u]Survie for as long as you can![/u] You should start planing and building your base right away (admins can cheat by getting free stuff). AIs will attack the props. players buy and place out in the map; this is a custom destruction system for M.B.D. You can always use one of the custom SWEPs to super charge the prop, but it does have a price. You have $B.D. to use at the BuyBox Station / Vehicle store and B.P. to buy props. to build your base with. You do have some tools for the tool gun available inside the Strict Setting Mode of the gamemode, like the custom door tool and weld tool. The gamemodes content packs are equiped with a modified and slightly improved version of the FA:S 2 Alpha SWEPs.
If you want a random weapon generator in the map, use the Mystery Box! It is a custom made entity for this gamemode. It will take any weapon found on the server as a possible outcome; admins can spawn this.

To make the game more challenging, you can set the gamemode to spawn collectables. These are called pyramid drops. They spawn at different locations where NPCs have been; or at a NPC Spawner / BuyBox location. Each wave, a new group of pyramids will randomly spawn. These must be picked up by players before the current wave ends, or else the game ends. This will also hinder camping. Admins can disable/enable this in settings/quick settings.

[h2]Get Started[/h2]
Enter the gamemode as an admin, and place preferraly a NPC Spawner (to spawn enemy AI) and a BuyBox Station (to be able to purchase stuff), and maybe a Mystery Box (you can disable particles - look under "ConVars"). Now wait for the countdown timer, or start the game manually through the settings panel/quick settings menu. The server needs atleast one admin to set the game up before being able to play. After this, the admin can leave the server and the game will be controlled automatically by the server.

[h2]Admin[/h2]
Admins have access to the settings of the gamemode itself - There is also a quick setting menu available (look under "Quick access"). Admins can spawn different entities; like e.g. Blockers, which will let Admins through, but no other entities

[h2]Help[/h2]
You can access the help menu in-game from the lobby or quick access menu (look underneath)

[h2]Quick access[/h2]
Press TAB (IN_SCORE) to open the quick access buttons on the left side

[h2]Save creations/Duplicator tool[/h2]
It is still a sandbox, but you can only save creations made inside the gamemode. You will have to pay for every prop. in your saved creation (your base ?) when spawned (if not a cheating admin).

[h2]Customize the BuyBox Station[/h2]
You can customize the contents of the BuyBox Station! Start up a server with the gamemode atleast once (to generate the files). Then go into your [code]data folder => my_base_defence[/code]. There you will find a clean template you can edit (empty = use original settings), the original template (this is only used to look at) and all of the weapons and items currently on your server.

[h2]Customize the Spawn list[/h2]
You can customize the spawn list! Start up a server with the gamemode atleast once (to generate the files). Then go into your [code]data folder => my_base_defence/mbd-spawnlist[/code]. There you will find a fresh template JSON file you can edit. If you mess up the template, you can delete it and restart your server to generate a new one. Remember to turn on Strict Mode under admin settings to enable your custom spawn list (this is on by default).

[h2]FA:S 2 SWEPs User Settings[/h2]
[list]
[*] Hold down "C" to open the customize menu
[*] Press "E" (IN_USE) + "R" (IN_RELOAD) to change fire mode
[*] Go into Spawnmenu ("Q") => Options, to change further settings
[/list]

[h2]ConVars[/h2]
[b]My Base Defence:[/b]
[code]
------------------------
[b]SERVER PROTECTED CONSOLE VARIABLES :[/b]
--------------------------------------------------
Variables that Saves when closing the game:
--------------------------------------------------
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
--------------------------------------------------
Variables that Doesn't Save:
--------------------------------------------------
mbd_game_status
mbd_roundWaveNumber
--------------------------------------------------
[/code]

[b]My Base Defence - Black Ops 3 Mystery Box Replica:[/b]
[code]
------------------------
[b]SERVER PROTECTED CONSOLE VARIABLES :[/b]
--------------------------------------------------
mbd_mysterybox_bo3_ravo_exchangeWeapons
mbd_mysterybox_bo3_ravo_teddybearGetChance
mbd_mysterybox_bo3_ravo_MysteryBoxTotalHealth
mbd_mysterybox_bo3_ravo_hideAllNotificationsFromMysteryBox
mbd_mysterybox_bo3_ravo_disableAllParticlesEffects
--------------------------------------------------
[/code]

[h3]License:[/h3]
This addon is created by [url=https://steamcommunity.com/sharedfiles/filedetails/?id=1647345157]ravo (Norway)[/url] or the uploader of this current viewed [url=https://steamcommunity.com/sharedfiles/filedetails/?id=2074331908]Gamemode[/url] on Steam Workshop.
All of the custom code created by the creator/uploader (this site), that is given for [b]My Base Defence (M.B.D.)[/b], is supplied under the: [url=https://steamcommunity.com/sharedfiles/filedetails/?id=1647345157]CC BY-NC-SA 4.0 Licence[/url] If not specified otherwise.

[b]Copyright content:[/b]
[list]
[*] The sounds used for the Mystery Box belongs to the rightful owner(s) within the COD Zombie Series.
[*] The wood texture is from: [url=https://www.freepik.com/valeria-aksakova]valeria_aksakova[/url].
[/list]

[u][b]Made in Norway.[/b][/u]