(function(){
  var f={};
  document.querySelectorAll('time[data-tz]').forEach(function(t){
    f[t.dataset.tz]=new Intl.DateTimeFormat('en-GB',{timeZone:t.dataset.tz,hour:'2-digit',minute:'2-digit',second:'2-digit',hour12:false});
  });
  function tick(){
    var d=new Date();
    document.querySelectorAll('time[data-tz]').forEach(function(t){t.textContent=f[t.dataset.tz].format(d)});
  }
  tick();setInterval(tick,1000);
})();
