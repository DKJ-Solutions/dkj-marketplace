// Measures block offsets inside a product page's buy box on a REALLY emulated viewport, through the
// Chrome DevTools Protocol. Called by measure-buybox.ps1; see there for why, and for the two routes that
// are deliberately NOT used here because they silently measure the wrong width.
//
// Call:   node measure-buybox.harness.js <url> <width> <height> <settleMs> <inputBase64>
// Input:  the store's selectors as UTF-8 JSON, base64-encoded into ONE argument so no shell or
//         Start-Process quoting rule can touch it:
//           { boxSelector, atcSelector, blockSelectors: [..], stickySelector, mobileMaxWidth }
//         This file knows no theme: every selector arrives here, none is written into it.
// Output: one line of JSON on stdout. Everything diagnostic goes to stderr.
//
// Dependency-free on purpose: WebSocket is in the node runtime since node 22, so no puppeteer is needed
// and no node_modules lands in the consuming repo. The file uses ES module syntax with a top-level await,
// which node 22.7+ recognises in a plain .js file without a package.json. Moved here from a store repo
// (#4290).

import { spawn } from 'node:child_process';
import { existsSync, mkdtempSync, rmSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';

const [url, widthArg, heightArg, settleArg, inputArg] = process.argv.slice(2);
if (!url) {
  console.error('measure-buybox.harness.js: no URL given.');
  process.exit(2);
}
let input;
try {
  input = JSON.parse(Buffer.from(inputArg || '', 'base64').toString('utf8'));
} catch {
  input = null;
}
if (!input || typeof input.boxSelector !== 'string' || !input.boxSelector
  || typeof input.atcSelector !== 'string' || !input.atcSelector) {
  console.error('measure-buybox.harness.js: the selector input (argument 5, base64 JSON with '
    + 'boxSelector and atcSelector) is missing or unreadable.');
  process.exit(2);
}
const width = Number(widthArg) || 390;
const height = Number(heightArg) || 900;
const settleMs = Number(settleArg) || 5000;
const mobileMaxWidth = Number(input.mobileMaxWidth) || 749;
const blockSelectors = Array.isArray(input.blockSelectors) ? input.blockSelectors.map(String) : [];

// Late-filled blocks (swatch rows, compatibility lists) are rendered after load, so the measurement has
// to WAIT. Without the settle it measures half a page, which reads as a met height requirement.
const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

const CHROME_CANDIDATES = [
  process.env.CHROME_EXE,
  'C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe',
  'C:\\Program Files (x86)\\Google\\Chrome\\Application\\chrome.exe',
  '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome',
  '/usr/bin/google-chrome',
  '/usr/bin/chromium',
].filter(Boolean);

const chrome = CHROME_CANDIDATES.find((p) => existsSync(p));
if (!chrome) {
  console.error(`measure-buybox.harness.js: Chrome not found. Looked in: ${CHROME_CANDIDATES.join('; ')}. `
    + 'Set CHROME_EXE to the full path.');
  process.exit(3);
}

// The probe runs inside the page. The selectors are data spliced in as JSON, never as code.
const PROBE = `((cfg) => {
  const box = document.querySelector(cfg.boxSelector);
  const out = {
    innerWidth: window.innerWidth,
    viewportHeight: window.innerHeight,
    mobileMQ: window.matchMedia('(max-width: ' + cfg.mobileMaxWidth + 'px)').matches,
    title: document.title.slice(0, 90),
  };
  if (!box) { out.error = 'no element matches the box selector on this page'; return JSON.stringify(out); }
  const bt = box.getBoundingClientRect().top;

  // THE OFFSET INSIDE THE BUY BOX IS NOT THE FOLD. The offset is counted from the top of the box, and
  // the box itself starts below the gallery. A sticky bar with an ATC button of its own may also be
  // pinned to the viewport, outside the box, and it does not move with the offset. Without these two
  // numbers a missed offset reads as "the button is unreachable" while a button is pinned on screen.
  out.page = { buyBoxTop: Math.round(bt + window.scrollY) };
  const sticky = cfg.stickySelector ? document.querySelector(cfg.stickySelector) : null;
  if (!sticky) {
    out.sticky = null;
  } else {
    const sr = sticky.getBoundingClientRect();
    out.sticky = {
      position: getComputedStyle(sticky).position,
      top: Math.round(sr.top),
      height: Math.round(sr.height),
      onScreen: sr.height > 0 && sr.top < window.innerHeight && sr.bottom > 0,
    };
  }
  out.order = [...box.children]
    .map((el) => {
      const r = el.getBoundingClientRect();
      return {
        cls: (el.getAttribute('class') || '(no class)').slice(0, 64),
        top: Math.round(r.top - bt),
        h: Math.round(r.height),
      };
    })
    .filter((c) => c.h > 0);
  out.blocks = {};
  for (const sel of cfg.blockSelectors) {
    const el = document.querySelector(sel);
    if (!el) { out.blocks[sel] = null; continue; }
    const r = el.getBoundingClientRect();
    out.blocks[sel] = { top: Math.round(r.top - bt), h: Math.round(r.height) };
  }
  const atc = document.querySelector(cfg.atcSelector);
  if (atc) {
    const ar = atc.getBoundingClientRect();
    out.atc = { top: Math.round(ar.top - bt), h: Math.round(ar.height) };
  } else {
    out.atc = null;
  }
  out.page.atcFromPageTop = atc
    ? Math.round(atc.getBoundingClientRect().top + window.scrollY)
    : null;
  return JSON.stringify(out);
})(${JSON.stringify({
  boxSelector: input.boxSelector,
  atcSelector: input.atcSelector,
  stickySelector: typeof input.stickySelector === 'string' ? input.stickySelector : '',
  blockSelectors,
  mobileMaxWidth,
})})`;

function connect(wsUrl) {
  const ws = new WebSocket(wsUrl);
  let id = 0;
  const pending = new Map();
  const seen = new Set();
  ws.addEventListener('message', (ev) => {
    const msg = JSON.parse(ev.data);
    if (msg.id && pending.has(msg.id)) {
      const { resolve, reject } = pending.get(msg.id);
      pending.delete(msg.id);
      if (msg.error) { reject(new Error(JSON.stringify(msg.error))); } else { resolve(msg.result); }
    } else if (msg.method) {
      seen.add(msg.method);
    }
  });
  const open = new Promise((res, rej) => {
    ws.addEventListener('open', res);
    ws.addEventListener('error', () => rej(new Error('the WebSocket to Chrome did not open')));
  });
  const send = (method, params = {}) => new Promise((resolve, reject) => {
    const n = ++id;
    pending.set(n, { resolve, reject });
    ws.send(JSON.stringify({ id: n, method, params }));
  });
  return { ws, open, send, seen };
}

const port = 9000 + Math.floor(Math.random() * 900);
const profile = mkdtempSync(join(tmpdir(), 'buybox-measure-'));
const child = spawn(chrome, [
  '--headless=new',
  `--remote-debugging-port=${port}`,
  `--user-data-dir=${profile}`,
  '--no-first-run', '--no-default-browser-check', '--disable-gpu',
  '--hide-scrollbars', '--mute-audio',
  'about:blank',
], { stdio: 'ignore' });

let exitCode = 0;
try {
  let version = null;
  for (let i = 0; i < 100 && !version; i++) {
    try {
      const r = await fetch(`http://127.0.0.1:${port}/json/version`);
      if (r.ok) version = await r.json();
    } catch { /* not up yet */ }
    if (!version) await sleep(200);
  }
  if (!version) throw new Error('the DevTools endpoint of Chrome did not come up');

  const res = await fetch(`http://127.0.0.1:${port}/json/new?url=about:blank`, { method: 'PUT' });
  if (!res.ok) throw new Error(`could not open a tab (${res.status})`);
  const target = await res.json();

  const c = connect(target.webSocketDebuggerUrl);
  await c.open;
  await c.send('Page.enable');
  await c.send('Runtime.enable');

  // THIS is the whole reason the harness exists: setDeviceMetricsOverride sets the CSS viewport to
  // <width> for real, so media queries fire as they do on a phone.
  await c.send('Emulation.setDeviceMetricsOverride', {
    width, height, deviceScaleFactor: 1, mobile: width <= mobileMaxWidth,
  });
  if (width <= mobileMaxWidth) {
    await c.send('Emulation.setUserAgentOverride', {
      userAgent: 'Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15'
        + ' (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1',
    });
  }

  await c.send('Page.navigate', { url });
  for (let i = 0; i < 150; i++) {
    if (c.seen.has('Page.loadEventFired')) break;
    await sleep(200);
  }
  await sleep(settleMs);

  const r = await c.send('Runtime.evaluate', { expression: PROBE, returnByValue: true });
  const value = r.result && r.result.value;
  if (typeof value !== 'string') throw new Error('the probe did not return JSON');
  process.stdout.write(`${value}\n`);
  c.ws.close();
} catch (err) {
  console.error(`measure-buybox.harness.js: ${err.message}`);
  exitCode = 1;
} finally {
  child.kill();
  await sleep(300);
  try { rmSync(profile, { recursive: true, force: true }); } catch { /* best effort */ }
}
process.exit(exitCode);
