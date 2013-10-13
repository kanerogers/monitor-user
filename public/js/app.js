var source = new EventSource('/subscribe');

source.addEventListener('boom', function (event) {
  log.innerText += '\n' + event.data;
}, false);
