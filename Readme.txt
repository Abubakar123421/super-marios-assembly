========================================================================
SUPER MARIO CLONE (x86 MASM)

--- OVERVIEW ---
This is a side-scrolling platformer game written in x86 Assembly language
using the Irvine32 library. It features custom physics, enemy AI, level
loading from text files, and audio playback.

--- CONTROLS ---
[ A ]       : Move Left
[ D ]       : Move Right
[ SPACE ]   : Jump
[ P ]       : Pause Game / View Pause Menu
[ S ]       : Enter Secret Room (Must be standing on a '5' block)
[ Z ]       : Activate MOON JUMP (Low gravity, usable once per level)
[ ESC ]     : Quit to Main Menu

--- GAMEPLAY FEATURES ---

PLAYER MECHANICS

Variable jump height physics.

"Big Mario" state after collecting a Mushroom.

"Turbo Mode" (Increased movement speed) after collecting a Star (*).

"Moon Jump" ability: Gives you 4 seconds of low gravity to reach high areas.

ENEMIES & BOSSES

Goombas (G): Simple patrolling enemies.

Koopas (K): Turn into shells when stomped.

Shells (S): Can be kicked to defeat other enemies.

Boss (N): A tough enemy requiring 4 hits to defeat. Defeating him wins the game.

INTERACTIVE BLOCKS

Mystery Blocks ('0'): Give coins and score.

Mushroom Blocks ('9'): Spawn a power-up Mushroom.

Spikes (x) & Lava (v): Instant death hazards.

Pipes (P) & Poles (|): Solid structures.

Flag (F): Reaching this completes the level.

LEVEL SYSTEM

Level Loading: Maps are loaded from external text files (.txt).

Multi-Stage Levels: Supports sub-areas (e.g., pipes leading to underground zones).

Secret Rooms: Hidden areas accessible via specific map tiles.

Dynamic Backgrounds: Level 1 has a blue sky; Level 2 features a black night sky.

SYSTEM FEATURES

High Score System: Saves player name, score, and level to 'game_record.txt'.

Audio System: Background music and sound effects (Jump, Coin, Game Over).

HUD: Real-time display of Score, Coins, Time, Lives, and Power-up status.

--- HOW TO RUN ---

Ensure you have the MASM assembler and Irvine32 library installed.

Place the following assets in the same directory:

MarioGame.asm (Source code)

level1.txt, level2.txt, etc. (Map files)

theme.mp3, jump.wav, coin.mp3, etc. (Audio files)

Build and Run the executable.

--- CREDITS ---
Developed by: Roll No: 24i0753
Language: Assembly (x86)