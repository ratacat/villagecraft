// util.js
// common scripts

if(!String.prototype.trim) {
  String.prototype.trim = function () {
    return this.replace(/^\s+|\s+$/g,'');
  };
}

jQuery(function($){
  $(".tooltipify").tooltip();
});
