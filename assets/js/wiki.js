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

// Minecraft-style tooltip, naming the member an icon currently shows, or showing an element's data-tooltip
// (with an optional gray data-tooltip-note below it). Follows the mouse, or is toggled by tapping
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
  if (tooltipTarget.hasAttribute("data-tooltip")) {
    tooltip.textContent = tooltipTarget.getAttribute("data-tooltip");
    var note = tooltipTarget.getAttribute("data-tooltip-note");
    if (note) {
      var noteLine = document.createElement("span");
      noteLine.className = "mc-tooltip-note";
      noteLine.textContent = note;
      tooltip.appendChild(noteLine);
    }
  } else {
    tooltip.textContent = cycleEntry(tooltipTarget, "data-cycle-names", "|");
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
      // Load the next one ahead, so the switch doesn't flicker
      var images = img.getAttribute("data-cycle").split(" ");
      new Image().src = images[(cycleStep + 1) % images.length];
    });
    if (tooltipTarget) updateTooltip();
  }, 2000);
}

// Close the mobile drawer once a sidebar link is followed (e.g. a section of the current page)
document.addEventListener("click", function (event) {
  if (event.target.closest(".nav-bar a[href]")) navToggle.checked = false;
});

// Sidebar table of contents: remember whether the current page's one is collapsed, highlight the section
// being read, and open its group while it's read (unless the reader has toggled that group themselves)
var navBar = document.querySelector(".nav-bar");
var currentLink = document.querySelector(".nav-page > summary > a[aria-current]");
var tocDetails = currentLink && currentLink.closest(".nav-page");
var tocEntries = [];
var currentTocLink = null;
var currentGroup = null;
var autoOpenedGroup = null;

// Scroll the sidebar (only) so the link is in view
function revealInSidebar(link) {
  if (!link.offsetParent) return;
  var navRect = navBar.getBoundingClientRect();
  var linkRect = link.getBoundingClientRect();
  var top = Math.max(navRect.top, bar.getBoundingClientRect().bottom);
  if (linkRect.top < top) navBar.scrollTop -= top - linkRect.top + 8;
  else if (linkRect.bottom > navRect.bottom) navBar.scrollTop += linkRect.bottom - navRect.bottom + 8;
}

function updateCurrentSection() {
  // A section counts as being read once its heading is near the top
  var threshold = (document.body.classList.contains("mobile-bar-hidden") ? 0 : bar.offsetHeight) + 80;
  var current = null;
  for (var i = 0; i < tocEntries.length; i++) {
    if (tocEntries[i].heading.getBoundingClientRect().top > threshold) break;
    current = tocEntries[i].link;
  }
  if (current === currentTocLink) return;

  if (currentTocLink) currentTocLink.classList.remove("current");
  if (current) current.classList.add("current");
  currentTocLink = current;

  var group = current && current.closest(".toc-group");
  if (group !== currentGroup) {
    if (currentGroup) currentGroup.querySelector("summary > a").classList.remove("current-group");
    if (autoOpenedGroup && autoOpenedGroup !== group) autoOpenedGroup.open = false;
    autoOpenedGroup = null;
    if (group) {
      group.querySelector("summary > a").classList.add("current-group");
      if (!group.open) {
        group.open = true;
        autoOpenedGroup = group;
      }
    }
    currentGroup = group;
  }

  if (current && tocDetails.open) revealInSidebar(current);
}

if (tocDetails) {
  tocDetails.addEventListener("toggle", function (event) {
    if (event.target !== tocDetails) return;
    try { localStorage.setItem("wiki-toc-open", tocDetails.open); } catch (e) {}
  });

  // A group the reader toggled stays as they left it
  tocDetails.addEventListener("click", function (event) {
    var summary = event.target.closest(".toc-group > summary");
    if (summary && !event.target.closest("a") && summary.parentElement === autoOpenedGroup) autoOpenedGroup = null;
  });

  tocDetails.querySelectorAll(".toc a").forEach(function (link) {
    var heading = document.getElementById(decodeURIComponent(link.getAttribute("href").slice(1)));
    if (heading) tocEntries.push({ link: link, heading: heading });
  });

  var sectionFrame = 0;
  window.addEventListener("scroll", function () {
    if (!sectionFrame) sectionFrame = requestAnimationFrame(function () {
      sectionFrame = 0;
      updateCurrentSection();
    });
  }, { passive: true });
  updateCurrentSection();
}

// Search through all wiki pages of the current language, using the index built alongside the site
var searchInput = document.querySelector(".search-input");
var searchResults = document.getElementById("search-results");
var searchIndex = null;
var searchLoading = null;
var activeResult = -1;

// Case-insensitive, treating ё as е and all apostrophe variants alike; keeps the text length
function normalizeSearch(text) {
  return text.toLowerCase().replace(/ё/g, "е").replace(/[ʼ’‘`]/g, "'");
}

function escapeHtml(text) {
  return text.replace(/[&<>"]/g, function (c) {
    return { "&": "&amp;", "<": "&lt;", ">": "&gt;", "\"": "&quot;" }[c];
  });
}

function loadSearchIndex() {
  if (!searchLoading) {
    searchLoading = fetch(searchInput.getAttribute("data-index"))
      .then(function (response) { return response.json(); })
      .then(function (data) {
        data.entries.forEach(function (entry) {
          entry.page = data.pages[entry.p];
          entry.heading = normalizeSearch(entry.h);
          entry.text = normalizeSearch(entry.x);
          entry.title = normalizeSearch(entry.page.t);
        });
        searchIndex = data;
      })
      .catch(function () { searchLoading = null; });
  }
  return searchLoading;
}

function findResults(terms) {
  var results = [];
  searchIndex.entries.forEach(function (entry, order) {
    var score = 0;
    for (var i = 0; i < terms.length; i++) {
      var inHeading = entry.heading.indexOf(terms[i]) >= 0;
      var inTitle = entry.title.indexOf(terms[i]) >= 0;
      var inText = entry.text.indexOf(terms[i]) >= 0;
      if (!inHeading && !inTitle && !inText) return;
      score += (inHeading ? 10 : 0) + (inTitle ? 2 : 0) + (inText ? 1 : 0);
    }
    if (terms.length > 1 && entry.heading.indexOf(terms.join(" ")) >= 0) score += 10;
    results.push({ entry: entry, score: score, order: order });
  });
  results.sort(function (a, b) { return b.score - a.score || a.order - b.order; });
  return results.slice(0, 30);
}

// Escaped text with every term occurrence marked
function highlight(text, terms) {
  var normalized = normalizeSearch(text);
  var marks = [];
  terms.forEach(function (term) {
    for (var i = normalized.indexOf(term); i >= 0; i = normalized.indexOf(term, i + term.length)) {
      marks.push([i, i + term.length]);
    }
  });
  marks.sort(function (a, b) { return a[0] - b[0]; });

  var html = "";
  var pos = 0;
  marks.forEach(function (mark) {
    if (mark[1] <= pos) return;
    var start = Math.max(mark[0], pos);
    html += escapeHtml(text.slice(pos, start)) + "<mark>" + escapeHtml(text.slice(start, mark[1])) + "</mark>";
    pos = mark[1];
  });
  return html + escapeHtml(text.slice(pos));
}

// A piece of the section's text around the first found term
function snippet(entry, terms) {
  var first = -1;
  terms.forEach(function (term) {
    var i = entry.text.indexOf(term);
    if (i >= 0 && (first < 0 || i < first)) first = i;
  });

  var start = Math.max(0, first - 40);
  if (start > 0) start = entry.x.indexOf(" ", start) + 1 || start;
  var end = Math.min(entry.x.length, start + 140);
  if (end < entry.x.length) end = entry.x.lastIndexOf(" ", end) > start ? entry.x.lastIndexOf(" ", end) : end;

  return (start > 0 ? "…" : "") + highlight(entry.x.slice(start, end), terms) + (end < entry.x.length ? "…" : "");
}

function samePage(url) {
  var clean = function (path) { return path.replace(/\.html$/, "").replace(/\/$/, ""); };
  return clean(url) === clean(location.pathname);
}

function setActiveResult(index) {
  var links = searchResults.querySelectorAll("a");
  if (!links.length) return;
  activeResult = (index + links.length) % links.length;
  links.forEach(function (link, i) { link.classList.toggle("active", i === activeResult); });
  links[activeResult].scrollIntoView({ block: "nearest" });
}

function renderSearch() {
  var terms = normalizeSearch(searchInput.value).split(/\s+/).filter(Boolean);
  searchInput.closest(".nav-links").classList.toggle("searching", terms.length > 0);
  searchResults.hidden = !terms.length;
  activeResult = -1;
  if (!terms.length || !searchIndex) return;

  var results = findResults(terms);
  if (!results.length) {
    searchResults.innerHTML = "<p class=\"search-empty\">" + escapeHtml(searchInput.getAttribute("data-no-results")) + "</p>";
    return;
  }

  searchResults.innerHTML = results.map(function (result) {
    var entry = result.entry;
    var href = samePage(entry.page.u) ? "#" + entry.a : entry.page.u + (entry.a ? "#" + entry.a : "");
    if (href === "#") href = entry.page.u;
    return "<a href=\"" + escapeHtml(href) + "\">" +
      "<span class=\"search-heading\">" + highlight(entry.h || entry.page.t, terms) + "</span>" +
      (entry.h ? "<span class=\"search-page\">" + escapeHtml(entry.page.t) + "</span>" : "") +
      (entry.x ? "<span class=\"search-snippet\">" + snippet(entry, terms) + "</span>" : "") +
      "</a>";
  }).join("");
}

if (searchInput) {
  searchInput.addEventListener("focus", loadSearchIndex);
  searchInput.addEventListener("input", function () {
    renderSearch();
    loadSearchIndex().then(renderSearch);
  });

  searchInput.addEventListener("keydown", function (event) {
    if (event.key === "ArrowDown" || event.key === "ArrowUp") {
      event.preventDefault();
      setActiveResult(activeResult + (event.key === "ArrowDown" ? 1 : -1));
    } else if (event.key === "Enter") {
      var link = searchResults.querySelectorAll("a")[Math.max(activeResult, 0)];
      if (link) link.click();
    } else if (event.key === "Escape") {
      searchInput.value = "";
      renderSearch();
    }
  });

  // "/" focuses the search, like on many sites
  document.addEventListener("keydown", function (event) {
    if (event.key !== "/" || event.ctrlKey || event.metaKey || event.altKey) return;
    if (event.target.closest("input, textarea, select, [contenteditable]")) return;
    event.preventDefault();
    // Open the drawer if the sidebar is one
    if (getComputedStyle(bar).display !== "none") navToggle.checked = true;
    searchInput.focus();
  });
}
