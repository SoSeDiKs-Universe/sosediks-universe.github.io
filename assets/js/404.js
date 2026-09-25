// GitHub Pages serves the root (English) 404 page for every missing URL,
// so load the localized one when the URL belongs to another language
(function () {
  var page = document.querySelector(".not-found");
  var urlLang = location.pathname.split("/")[1];

  if (["ru", "uk"].indexOf(urlLang) !== -1 && page.getAttribute("data-lang") !== urlLang) {
    document.documentElement.style.visibility = "hidden";
    var missing = location.pathname + location.search + location.hash;
    location.replace("/" + urlLang + "/404.html?from=" + encodeURIComponent(missing));
    return;
  }

  // Show the originally requested URL again after the redirect above
  var from = new URLSearchParams(location.search).get("from");
  if (from && from.charAt(0) === "/" && from.charAt(1) !== "/") history.replaceState(null, "", from);

  var path = location.pathname;
  try {
    path = decodeURI(path);
  } catch (e) {
    // Keep the encoded path
  }
  page.querySelector(".not-found-path").textContent = path;
})();
