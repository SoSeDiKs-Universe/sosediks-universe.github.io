// Text like in Minecraft, shared by the wiki and the home page: emoji drawn as pixel art in text made here,
// icons of grouped entries cycling through their members, and tooltips

function escapeHtml(text) {
  return text.replace(/[&<>"]/g, function (c) {
    return { "&": "&amp;", "<": "&lt;", ">": "&gt;", "\"": "&quot;" }[c];
  });
}

// Emoji drawn as pixel art, like the build does for the pages' text (see _plugins/pixel_emoji.rb), for the text
// made here. The sheet cells of the emoji in use come with the page (for tooltips) and with the search index
var emojiCells = {};
var emojiPattern = null;

function addEmoji(cells) {
  if (!cells) return;
  Object.keys(cells).forEach(function (emoji) { emojiCells[emoji] = cells[emoji]; });
  var emoji = Object.keys(emojiCells).sort(function (a, b) { return b.length - a.length; });
  if (!emoji.length) return;
  emojiPattern = new RegExp(emoji.map(function (e) { return e.replace(/[.*+?^${}()|[\]\\]/g, "\\$&"); }).join("|"), "g");
}

// HTML (escaped text) with its emoji drawn
function pixelEmoji(html) {
  if (!emojiPattern) return html;
  return html.replace(emojiPattern, function (emoji) {
    var cell = emojiCells[emoji];
    return "<span class=\"emoji emoji-" + cell[0] + "\" style=\"--x:" + cell[1] + ";--y:" + cell[2] + "\">" + emoji + "</span>";
  });
}

var pageEmoji = document.getElementById("emoji-map");
if (pageEmoji) addEmoji(JSON.parse(pageEmoji.textContent));

// Icons of grouped entries cycle through their members' images, all in step
var cycleIcons = document.querySelectorAll("img[data-cycle]");
var cycleStep = 0;

function cycleEntry(img, attribute, separator) {
  var entries = img.getAttribute(attribute).split(separator);
  return entries[cycleStep % entries.length];
}

// Minecraft-style tooltip, naming the member an icon currently shows, or showing an element's data-tooltip
// (with an optional gray data-tooltip-note below it, and an optional data-tooltip-size). Follows the mouse,
// or is toggled by tapping
var tooltip = document.createElement("div");
var tooltipTarget = null;
var tooltipX = 0;
var tooltipY = 0;
var lastPointerType = "mouse";
tooltip.className = "mc-tooltip";
tooltip.hidden = true;

var TOOLTIP_TARGETS = "img[data-cycle], [data-tooltip]";

function placeTooltip() {
  // Like in-game: up and to the right of the cursor, flipped when it wouldn't fit
  var offset = 12;
  var left = tooltipX + offset;
  var top = tooltipY - offset - tooltip.offsetHeight;
  if (left + tooltip.offsetWidth > document.documentElement.clientWidth) left = tooltipX - offset - tooltip.offsetWidth;
  if (top < 0) top = tooltipY + offset;
  tooltip.style.left = Math.max(0, left) + "px";
  tooltip.style.top = top + "px";
}

function updateTooltip() {
  // Never smaller than the text it belongs to; bigger targets can ask for a bigger one
  var textSize = parseFloat(getComputedStyle(tooltipTarget).fontSize);
  var baseSize = parseFloat(getComputedStyle(document.documentElement).fontSize);
  tooltip.style.fontSize = tooltipTarget.getAttribute("data-tooltip-size") || (textSize > baseSize ? textSize + "px" : "");
  if (tooltipTarget.hasAttribute("data-tooltip")) {
    tooltip.innerHTML = pixelEmoji(escapeHtml(tooltipTarget.getAttribute("data-tooltip")));
    var note = tooltipTarget.getAttribute("data-tooltip-note");
    if (note) {
      var noteLine = document.createElement("span");
      noteLine.className = "mc-tooltip-note";
      noteLine.innerHTML = pixelEmoji(escapeHtml(note));
      tooltip.appendChild(noteLine);
    }
  } else {
    tooltip.innerHTML = pixelEmoji(escapeHtml(cycleEntry(tooltipTarget, "data-cycle-names", "|")));
  }
  placeTooltip();
}

function showTooltip(target, x, y) {
  if (!tooltip.isConnected) document.body.appendChild(tooltip);
  tooltipTarget = target;
  tooltipX = x;
  tooltipY = y;
  tooltip.hidden = false;
  updateTooltip();
}

function hideTooltip() {
  tooltipTarget = null;
  tooltip.hidden = true;
}

// Touches also emulate mouse events, which shouldn't count as hovering
["pointerover", "pointerdown"].forEach(function (type) {
  document.addEventListener(type, function (event) {
    lastPointerType = event.pointerType;
  }, true);
});

document.addEventListener("mouseover", function (event) {
  if (lastPointerType === "touch") return;
  var target = event.target.closest(TOOLTIP_TARGETS);
  if (target && target !== tooltipTarget) showTooltip(target, event.clientX, event.clientY);
});

document.addEventListener("mousemove", function (event) {
  if (!tooltipTarget || lastPointerType === "touch") return;
  tooltipX = event.clientX;
  tooltipY = event.clientY;
  placeTooltip();
});

document.addEventListener("mouseout", function (event) {
  if (lastPointerType === "touch") return;
  // Moving between the target's own children doesn't leave it
  if (!tooltipTarget || tooltipTarget.contains(event.relatedTarget)) return;
  hideTooltip();
});

// Tapping toggles the tooltip above the element (links are just followed); tapping elsewhere or scrolling hides it
document.addEventListener("click", function (event) {
  if (lastPointerType !== "touch") return;
  var target = event.target.closest(TOOLTIP_TARGETS);
  if (!target || target.closest("a[href]") || target === tooltipTarget) {
    hideTooltip();
    return;
  }
  var rect = target.getBoundingClientRect();
  showTooltip(target, rect.left + rect.width / 2, rect.top);
});

window.addEventListener("scroll", function () {
  if (tooltipTarget && lastPointerType === "touch") hideTooltip();
}, { passive: true });

if (cycleIcons.length) {
  setInterval(function () {
    cycleStep++;
    cycleIcons.forEach(function (img) {
      img.src = cycleEntry(img, "data-cycle", " ");
      // Load the next one ahead, so the switch doesn't flicker (unless the icon isn't shown at all)
      if (!img.offsetParent) return;
      var images = img.getAttribute("data-cycle").split(" ");
      new Image().src = images[(cycleStep + 1) % images.length];
    });
    if (tooltipTarget) updateTooltip();
  }, 2000);
}
