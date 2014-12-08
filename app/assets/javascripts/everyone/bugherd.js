(function (d, t) {
    var bh = d.createElement(t), s = d.getElementsByTagName(t)[0];
    bh.type = 'text/javascript';
    bh.src = '//www.bugherd.com/sidebarv2.js?apikey=' + ENV.BUGHERD_API_KEY;
    s.parentNode.insertBefore(bh, s);
    })(document, 'script');