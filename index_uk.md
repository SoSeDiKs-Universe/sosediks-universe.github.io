---
layout: overview
title: {{ site.data.index.title }}
lang: uk
permalink: /
page_id: landing
---

<div class="server">
    <img src="/assets/server_logo.png" draggable="false" alt="Server Logo" class="server-logo">
    <div class="server-background center-column">
        <div class="ip center-column">
            <p class="ip-text">🎮</p>
            <p class="ip-text mc mc-gray">{{ site.data.index.address }}</p>
            <form class="ip-input"><input class="mc mc-white" type="text" id="server-ip" name="server-ip" value="sosedik.com"></form>
            <button id="ip-button" class="menu-button mc mc-white" onclick="copyIp();"><span id="ip-title" class="ip-title">{{ site.data.index.copy }}</span></button>
        </div>
        <div class="mc-buttons">
            <button id="discord-button" class="menu-button mc mc-white" onclick="window.open('{{ site.discord_invite }}', '_blank');">👾 Discord</button>
            <button id="wiki-button" class="menu-button mc mc-white" onclick="location.href='./wiki'" type="button">❓ {{ site.data.index.wiki }}</button>
        </div>
        {% include language_switcher.html %}
    </div>
    <img src="/assets/moople_logo.svg" draggable="false" alt="Moople Logo" class="moople-logo">
</div>
