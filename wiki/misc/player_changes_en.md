---
layout: wiki
title: "Changes — Players"
lang: en
permalink: /wiki/misc/player_changes
page_id: wiki_misc_player_changes
---

## {% href_link 🎮️ | Gameplay %}

### {% href_link ⛏️ | Proper tooling %}
You need to use a correct tool for breaking blocks, otherwise you won't break it.

### {% href_link 🪦 | Tombstones on death %}
If possible, {% symlink player, Players %} will leave skeleton remains upon death. Breaking them will restore the inventory and dropped experience.

### {% href_link 👕 | Clothes and gloves %}
In addition to the usual four armor slots, there are also four visual armor slots for clothing and a slot for {% symlink gloves, Gloves %}.

{% symlink gloves, Gloves %} are required for some actions on the server, such as collecting {% symlink lava, Lava %} in a {% symlink bucket, Bucket %} or safely destroying {% symlink glass, Glass %} with bare hands.

Clothing is worn over armor and serves both for visuals and to help with other aspects of the game, such as {% symlink temperature, Temperature %}.

The {% symlink player, Player %} renders their clothing first, and falls back to armor underneath otherwise.

Since both clothing and armor occupy the same slots, you can switch the preview between armor and clothing in the inventory using {% game_action drop %}.

You can put _any_ item (1 pc.) in the helmet clothing slot. Some items will have functionality when worn this way, such as lighting the way with a {% symlink torch, Torch %}, or allowing other {% symlink player, Players %} to ride on you with a {% symlink saddle, Saddle %}.



## {% href_link 🤸 | Movement %}

### {% href_link 🌊 | Swimming improvements %}
When swimming on the surface of water, air won't be consumed, which allows you to swim quickly without getting out of breath.

When sprinting on the surface of water, you can enter swimming mode, even if the water is one block high.

Ability to jump out of the water onto a block above the water.

### {% href_link 🔥 | Burning causes panic %}
Burning (without any protection like {% symlink fire_resistance, Fire Resistance %}) causes the {% symlink player, Player %} to run forward in panic.

### {% href_link 🛹 | Crawling %}
You can enter crawling state by pressing {% game_action sneak %} twice, which allows squeezing through single block gaps.

Entering crawling state while running wil trigger sliding. The slide allows you to move faster under blocks, as well as deal minor damage and push away mobs in your path.

You can exit crawling and sliding by pressing {% game_action sneak %} again.

You can also crawl into a hole in front of you by jumping while holding {% game_action sneak %}.

### {% href_link 💨 | Leap of Faith %}
By triple-pressing {% game_action sneak %}, you can enter the "leap of faith" state. The fall speeds up significantly, and the player can no longer move to the side (the entire fall occurs within one block). If the player falls into water or onto a soft block, the damage from the fall is greatly reduced.

### {% href_link 🍥 | Roll %}
If you manage to hold down {% game_action sneak %} right before falling to the ground, you will perform a roll, which allows you to slightly reduce the damage from the fall (or avoid it altogether) and get a small increase in speed.

Rolling moves the player forward a little, so better not to perform it on the edge of a cliff.

### {% href_link 🌾 | Softer falls %}
Some types of blocks reduce the damage from falling, allowing you to fall from greater heights.

Fragile blocks can break under the player's weight when falling from a great height.

### {% href_link 🪝 | Hooking onto blocks %}
If, while in the air and without a block underneath you, you crouch ({% game_action sneak %}) in front of a block that has no obstacles above, the player will hook onto this block and hang in place. Exiting the hook gives a small upward push, which allows you to climb two blocks in height. It will not be possible to hook onto a block if the height of the fall during the hooking is more than 5 blocks. You will fall if you try to move in the direction opposite to the hooking side.

If there is a one-block gap above the block you are grabbing onto that you can crawl into, pressing {% game_action use %} on the grabbed block or a block in the gap (e.g. {% symlink oak_leaves, Leaves %} that might block the gap but allow crawling) will move the player into it and enter crawling state.



## {% href_link 🗣️ | Chatting %}

### {% href_link *️⃣ | Formatting %}
Chat, signs and books support formatting with Markdown and MiniMessage, allowing for rich messages.

### {% href_link 💖 | Emoji %}
Server resource pack ships with full support for Emoji 14.



## {% href_link 🤝 | Player interactions %}

### {% href_link ❔ | Stealth %}
{% symlink player, Player %} nicknames above them and join/leave messages are hidden.

### {% href_link 🦙 | Spits %}
Similarly to {% symlink llama, Llamas %}, you can*¹ use `/spit`{: .mc-gold} to spit.

{% side_note %}
*¹ Note: sadly, {% symlink ghost, Ghosts %} aren't capable of spitting.
{% endside_note %}

### {% href_link ⛑️ | Teamwork %}
If {% symlink player, Players %} have leather {% symlink leather_helmet, Caps %} or {% symlink leather_chestplate, Tunics %} of the same color, they do not damage each other, and projectiles fly right through.
