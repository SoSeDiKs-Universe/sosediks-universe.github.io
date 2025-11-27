var lastCopy;

function copyIp() {
  var time = new Date().getTime();
  lastCopy = time;

  var ip = document.getElementById("server-ip");
  ip.select();
  ip.setSelectionRange(0, 99999);
  document.execCommand("copy");
  ip.blur();

  applyButtonHover();

  var ipTitle = document.getElementById("ip-title");
  ipTitle.innerHTML = ipTitle.getAttribute("data-copied");

  setTimeout(function () {
    if (lastCopy != time) return;

    removeButtonHover();
    ipTitle.innerHTML = ipTitle.getAttribute("data-copy");
  }, 2000);
}

function applyButtonHover() {
  document.getElementById("ip-title").classList.add("ip-title-hover");
  document.getElementById("ip-button").classList.add("ip-button-hover");
}

function removeButtonHover() {
  document.getElementById("ip-title").classList.remove("ip-title-hover");
  document.getElementById("ip-button").classList.remove("ip-button-hover");
}
