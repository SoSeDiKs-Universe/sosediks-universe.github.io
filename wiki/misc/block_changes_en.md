---
layout: wiki
title: "Changes — Blocks"
lang: en
permalink: /wiki/misc/block_changes
page_id: wiki_misc_block_changes
---

## {% href_link 🏞️ | Environmental %}

### {% href_link 🔥 | Campfires can set on fire %}
If someone stands on a lit {% symlink campfire, Campfire %}, the fire will spread to them. Having `«Frost Walker»`{: .mc-aqua} enchantment on boots makes you exempt, though.

### {% href_link 🧊 | Melting ice in Nether %}
Regular {% symlink ice, Ice %} will instantly melt in ultra warm dimensions like Nether. {% symlink packed_ice, Packed Ice %} will melt too, given enough time (regardless of default vanilla restrictions like the light level). {% symlink blue_ice, Blue Ice %}, on the other hand, is capable of withstanding such high temperatures.

### {% href_link 🐾 | Dynamic trails %}
If you walk the same path over time, the blocks may change. A {% symlink grass_block, Grass Block %} / {% symlink podzol, Podzol %} will turn into {% symlink dirt, Dirt %}, then {% symlink coarse_dirt, Coarse Dirt %}, then {% symlink gravel, Gravel %}, and finally {% symlink cracked_stone_bricks, Cracked Stone Bricks %}. {% symlink sand, Sand %} / {% symlink red_sand, Red Sand %} will turn into {% symlink sandstone, Sandstone %} / {% symlink red_sandstone, Red Sandstone %}.

### {% href_link 🍃 | Non-solid leaves %}
Entities can go through {% symlink oak_leaves, Leaves %}.



## {% href_link 🔧 | Mechanics %}

### {% href_link 🔄 | Shared world destruction %}
Block breaking is now shared among players with cracks staying in place for some time.

### {% href_link 🌊 | Water puddles hurt %}
Falling into a puddle (one block of {% symlink water, Water %}) causes damage, you won't be able to save yourself with a {% symlink water_bucket, Water Bucket %}) anymore.

### {% href_link 🔔 | Knock-knock and ding-dong %}
{% symlink oak_door, Doors %} and {% symlink oak_trapdoor, Trapdoors %} can be knocked on with {% game_action attack %}. If there is a {% symlink oak_button, Button %} next to them, {% game_action attack %} on it will act as a doorbell.

### {% href_link 🐈 | The cat won't let you open the chest? %}
Opening a {% symlink chest, Chest %} will knock entities on it towards the lid. But be careful! If there is a wall behind the lid or a mob is on the {% symlink chest, Chest %} when the lid is closed, the entity will take one point of damage.

### {% href_link ⚙️ | Smart door opening %}
{% symlink oak_door, Doors %}, {% symlink oak_trapdoor, Trapdoors %} and {% symlink oak_fence_gate, Fence Gates %} open together if they are next to each other. This can be prevented by crouching, or in the case of redstone, having a signal below 8.

### {% href_link 🚪 | Tall doors %}
Placing an opened {% symlink oak_trapdoor, Trapdoor %} (either one or two) above the {% symlink oak_door, Doors %} will allow them both to be opened at the same time.

### {% href_link 💧 | Containers release items in liquids %}
Opening a container exposed to liquid will release all stored items. Be especially cautious with lava.

### {% href_link 🍈 | Exploding melons and pumpkins %}
If any {% symlink arrow, Arrow %} or a {% symlink trident, Trident %} hits a {% symlink melon, Melon %} or {% symlink pumpkin, Pumpkin %}, the block will break into pieces.

### {% href_link 💥 | Exploding coal ore %}
{% symlink coal_ore, Coal Ores %} (of any kind) are not keen of {% symlink fire, Fire %}, and will explode upon contact with it. This includes lit {% symlink torch, Torches %} (of any kind) and {% symlink campfire, Campfires %}, as well as `«Fire Aspect»`{: .mc-aqua} enchantment.

Moreover, trying to mine the ore with a metal tool will lead to the same result, causing level 5 fiery explosion in both cases.

### {% href_link 🚧 | Jumping over fences %}
{% symlink player, Players %} can jump over {% symlink oak_fence, Fences %}, but they still act as an obstacle for other entities.

### {% href_link 🔥 | Fire spread on touch %}
Trying to extinguish {% symlink fire, Fire %} with an empty hand will set you on fire.

### {% href_link 🧯 | Unlit campfire %}
{% symlink campfire, Campfires %} are no longer lit by default. Breaking them will drop the {% symlink campfire, Campfire %} as an item, with `«Silk Touch»`{: .mc-aqua} allowing to keep the lit state.

### {% href_link 💧 | Wet cauldrons %}
Entities inside {% symlink water_cauldron, Water Cauldrons %} are considered wet ([MC-145311](https://bugs.mojang.com/browse/MC-145311){: .mc .mc-gold}).



## {% href_link ⚙️ | Tweaks %}

### {% href_link 🪧 | Better sign editing %}
{% symlink oak_sign, Sign %} editing screen is no longer opened automatically on place.

{% symlink oak_sign, Signs %} keep their text when broken and render it in the inventory. Clicking {% game_action use %} with a {% symlink oak_sign, Sign %} in hand on another placed {% symlink oak_sign, Sign %} will apply the stored text to it. The text can be erased in the crafting grid.

### {% href_link 📦 | Easier access to storage %}
Interacting ({% game_action use %}, without crouching) with {% symlink item_frame, Item Frames %}, {% symlink painting, Paintings %} and {% symlink oak_sign, Signs %} opens the inventory of the block behind them.

### {% href_link 🎶 | Improved note blocks %}
{% symlink note_block, Note Blocks %} display the note and instrument when played.
