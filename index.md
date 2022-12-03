---
layout: overview
title: "Добро пожаловать"
---

<div class="server">
    <img src="./assets/server_logo.png" draggable="false" alt="Server Logo" class="server-logo">
    <div class="server-background center-column">
        <div class="ip center-column">
            <p class="ip-text">🎮</p>
            <p class="ip-text">IP сервера</p>
            <form class="ip-input"><input class="mc mc-white" type="text" id="server-ip" name="server-ip" value="sosedik.com"></form>
            <button id="ip-button" class="menu-button mc mc-white" onclick="copyIp();"><span id="ip-title" class="ip-title">Копировать!</span></button>
        </div>
        <div class="bottom_buttons">
            <button id="discord-button" class="menu-button mc mc-white" onclick="window.open('https://discord.io/sosedik', '_blank');">👾 Дискорд</button>
            <button id="wiki-button" class="menu-button mc mc-white" onclick="location.href='./wiki.html'" type="button">❓ Что это?</button>
        </div>
    </div>
</div>
