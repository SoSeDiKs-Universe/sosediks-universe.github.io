// Copying the server address, with the button saying so for a moment
var ipButton = document.getElementById("ip-button");
var ipTitle = document.getElementById("ip-title");
var ipInput = document.getElementById("server-ip");
var lastCopy;

function copyWithSelection() {
  ipInput.select();
  ipInput.setSelectionRange(0, ipInput.value.length);
  document.execCommand("copy");
  ipInput.blur();
}

function copyIp() {
  var time = Date.now();
  lastCopy = time;

  if (navigator.clipboard && window.isSecureContext) {
    navigator.clipboard.writeText(ipInput.value).catch(copyWithSelection);
  } else {
    copyWithSelection();
  }

  ipButton.classList.add("ip-button-hover");
  ipTitle.classList.add("ip-title-hover");
  ipTitle.textContent = ipTitle.getAttribute("data-copied");

  setTimeout(function () {
    if (lastCopy !== time) return;

    ipButton.classList.remove("ip-button-hover");
    ipTitle.classList.remove("ip-title-hover");
    ipTitle.textContent = ipTitle.getAttribute("data-copy");
  }, 2000);
}

ipButton.addEventListener("click", copyIp);

// The server as seen in the game's server list: its icon, MOTD, player count and ping,
// from a public status service (which caches the result for a few minutes)
var entry = document.getElementById("server-entry");
var entryIcon = entry.querySelector(".server-entry-icon");
var entryMotd = entry.querySelector(".server-entry-motd");
var entryPlayers = entry.querySelector(".server-entry-players");

var COLOR_CODES = "0123456789abcdef";
var COLORS = ["000000", "0000aa", "00aa00", "00aaaa", "aa0000", "aa00aa", "ffaa00", "aaaaaa",
  "555555", "5555ff", "55ff55", "55ffff", "ff5555", "ff55ff", "ffff55", "ffffff"];
var FORMATS = { k: "mc-obfuscated", l: "mc-bold", m: "mc-strikethrough", n: "mc-underline", o: "mc-italic" };

// A color with its shadow, a quarter as bright, like the game draws text
function setColor(element, hex) {
  var shadow = hex.match(/../g).map(function (channel) {
    return ("0" + (parseInt(channel, 16) >> 2).toString(16)).slice(-2);
  }).join("");
  element.style.color = "#" + hex;
  element.style.textShadow = "2px 2px 0 #" + shadow;
}

// A line with § formatting codes (legacy colors, §#rrggbb and §x§r§r§g§g§b§b hex colors, formats and §r),
// as elements with only text in them
function formattedLine(raw, defaultColor) {
  var line = document.createElement("div");
  var color = defaultColor;
  var formats = [];
  var text = "";

  function flush() {
    if (!text) return;
    var span = document.createElement("span");
    span.textContent = text;
    setColor(span, color);
    formats.forEach(function (format) { span.classList.add(format); });
    line.appendChild(span);
    text = "";
  }

  for (var i = 0; i < raw.length; i++) {
    if (raw[i] !== "§" || i + 1 >= raw.length) {
      text += raw[i];
      continue;
    }

    var code = raw[i + 1].toLowerCase();
    var hex = null;
    if (code === "#" && /^[0-9a-f]{6}$/i.test(raw.substr(i + 2, 6))) {
      hex = raw.substr(i + 2, 6);
      i += 7;
    } else if (code === "x" && /^(§[0-9a-f]){6}$/i.test(raw.substr(i + 2, 12))) {
      hex = raw.substr(i + 2, 12).replace(/§/g, "");
      i += 13;
    } else if (COLOR_CODES.indexOf(code) >= 0) {
      hex = COLORS[COLOR_CODES.indexOf(code)];
      i += 1;
    }

    flush();
    if (hex) {
      // A color resets the formatting
      color = hex.toLowerCase();
      formats = [];
    } else if (code === "r") {
      color = defaultColor;
      formats = [];
      i += 1;
    } else if (FORMATS[code]) {
      if (formats.indexOf(FORMATS[code]) < 0) formats.push(FORMATS[code]);
      i += 1;
    } else {
      text += raw[i];
    }
  }
  flush();
  return line;
}

function showStatus(state, motd, players) {
  entry.className = "server-entry mc " + state;
  entryMotd.textContent = "";
  motd.forEach(function (line) { entryMotd.appendChild(line); });
  entryPlayers.textContent = "";
  if (players) entryPlayers.appendChild(players);
}

entry.hidden = false;
showStatus("pinging", [formattedLine(entry.getAttribute("data-pinging"), "808080")]);

fetch("https://api.mcsrvstat.us/3/" + encodeURIComponent(entry.getAttribute("data-address")))
  .then(function (response) {
    if (!response.ok) throw new Error(response.status);
    return response.json();
  })
  .then(function (data) {
    if (!data.online) {
      showStatus("offline", [formattedLine(entry.getAttribute("data-cannot-connect"), "aa0000")]);
      return;
    }

    if (data.icon && /^data:image\/png;base64,[A-Za-z0-9+/=]+$/.test(data.icon)) {
      entryIcon.src = data.icon;
      entryIcon.hidden = false;
    }

    var motd = (data.motd && data.motd.raw || []).map(function (line) { return formattedLine(line, "808080"); });
    // Servers can report a made-up protocol to show a message (like maintenance) instead of the player count
    var protocol = data.protocol && data.protocol.version;
    var incompatible = protocol === 2147483647 || protocol < 0;
    var players = incompatible
      ? formattedLine(String(data.version || ""), "ff5555")
      : formattedLine((data.players ? data.players.online + "§8/§7" + data.players.max : ""), "aaaaaa");
    showStatus(incompatible ? "online incompatible" : "online", motd, players);
  })
  .catch(function () {
    entry.hidden = true;
  });

// Random trivia: a random fact, and another one on request (the box stays hidden without JavaScript)
var facts = document.querySelectorAll(".trivia-fact");
var nextFact = document.getElementById("trivia-next");
var currentFact = 0;

var factLink = document.getElementById("trivia-link");

function showFact(index) {
  facts[currentFact].hidden = true;
  facts[index].hidden = false;
  factLink.href = facts[index].getAttribute("data-url");
  currentFact = index;
}

if (facts.length) {
  showFact(Math.floor(Math.random() * facts.length));
  document.querySelector(".trivia").hidden = false;
  nextFact.hidden = facts.length < 2;
  nextFact.addEventListener("click", function () {
    // Any fact but the current one
    showFact((currentFact + 1 + Math.floor(Math.random() * (facts.length - 1))) % facts.length);
  });
}
