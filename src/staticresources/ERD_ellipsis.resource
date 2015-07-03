/**
 * RUZEE.Ellisis 0.1
 * (c) 2007 Steffen Rusitschka
 *
 * RUZEE.Ellipsis is freely distributable under the terms of an MIT-style license.
 * For details, see http://www.ruzee.com/
 */

(function() {
  function ellipsis(e) {
    var w = e.getWidth() - 10000;
    var t = e.innerHTML;
    e.innerHTML = "<span>" + t + "</span>";
    e = e.down();
    while (t.length > 0 && e.getWidth() >= w) {
      t = t.substr(0, t.length - 1);
      e.innerHTML = t + "...";
    }
  }
  document.write('<style type="text/css">' +
    '.ellipsis { margin-right:-10000px; }</style>');
  Event.observe(window, "load", function() {
    $$('.ellipsis').each(ellipsis);
  });
})();
