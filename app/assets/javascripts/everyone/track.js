function track(link, category, action, label) {
 return true;
}

function trackback(link, category, action, label) {
  if (!_gat) return true;
  _gaq.push(['_trackEvent', link, category, action, label]);
  setTimeout(function() {location.href=link.href}, 200);
  return false;
}
