var bar = document.querySelector(".mobile-bar");
var navToggle = document.getElementById("nav-toggle");
var lastScrollY = window.scrollY;

function setBarHidden(hidden) {
  document.body.classList.toggle("mobile-bar-hidden", hidden);
}

// Hide the mobile bar while scrolling down, show it again when scrolling up
window.addEventListener("scroll", function () {
  var scrollY = window.scrollY;
  var delta = scrollY - lastScrollY;
  if (Math.abs(delta) < 5) return;

  setBarHidden(delta > 0 && scrollY > bar.offsetHeight && !navToggle.checked);

  lastScrollY = scrollY;
}, { passive: true });

// Anchor jumps: settle the bar state before the browser scrolls,
// so that scroll-padding (which depends on it) leaves no gap
function prepareJump(hash) {
  var target = document.getElementById(decodeURIComponent(hash.slice(1)));
  if (!target) return;

  var top = target.getBoundingClientRect().top;
  setBarHidden(top > bar.offsetHeight && window.scrollY + top > bar.offsetHeight);
}

document.addEventListener("click", function (event) {
  var link = event.target.closest("a[href^='#']");
  if (link) prepareJump(link.getAttribute("href"));
});

if (location.hash) prepareJump(location.hash);

// Icons of grouped entries cycle through their members' images, all in step
var cycleIcons = document.querySelectorAll("img[data-cycle]");
var cycleStep = 0;

function cycleEntry(img, attribute, separator) {
  var entries = img.getAttribute(attribute).split(separator);
  return entries[cycleStep % entries.length];
}

// Minecraft-style tooltip, naming the member an icon currently shows
var tooltip = document.createElement("div");
var tooltipTarget = null;
var tooltipX = 0;
var tooltipY = 0;
tooltip.className = "mc-tooltip";
tooltip.hidden = true;

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
  tooltip.textContent = cycleEntry(tooltipTarget, "data-cycle-names", "|");
  placeTooltip();
}

document.addEventListener("mouseover", function (event) {
  var img = event.target.closest("img[data-cycle]");
  if (!img) return;
  if (!tooltip.isConnected) document.body.appendChild(tooltip);
  tooltipTarget = img;
  tooltipX = event.clientX;
  tooltipY = event.clientY;
  tooltip.hidden = false;
  updateTooltip();
});

document.addEventListener("mousemove", function (event) {
  if (!tooltipTarget) return;
  tooltipX = event.clientX;
  tooltipY = event.clientY;
  placeTooltip();
});

document.addEventListener("mouseout", function (event) {
  if (event.target !== tooltipTarget) return;
  tooltipTarget = null;
  tooltip.hidden = true;
});

if (cycleIcons.length) {
  setInterval(function () {
    cycleStep++;
    cycleIcons.forEach(function (img) {
      img.src = cycleEntry(img, "data-cycle", " ");
      // Load the next one ahead, so the switch doesn't flicker
      var images = img.getAttribute("data-cycle").split(" ");
      new Image().src = images[(cycleStep + 1) % images.length];
    });
    if (tooltipTarget) updateTooltip();
  }, 2000);
}
