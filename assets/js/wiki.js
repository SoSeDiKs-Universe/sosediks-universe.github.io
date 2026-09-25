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
