(() => {
  const SELF = document.currentScript && document.currentScript.src;
  const FONT = (f) => (SELF ? new URL('./fonts/' + f, SELF).href : './fonts/' + f);

  const FONTS = `
@font-face{font-family:'PWC Caslon';src:url('${FONT('caslon-400.woff2')}') format('woff2');font-weight:400;font-display:swap}
@font-face{font-family:'PWC Caslon';src:url('${FONT('caslon-700.woff2')}') format('woff2');font-weight:700;font-display:swap}
@font-face{font-family:'PWC Sans';src:url('${FONT('publicsans.woff2')}') format('woff2');font-weight:100 900;font-display:swap}
@font-face{font-family:'PWC Mono';src:url('${FONT('dmmono-500.woff2')}') format('woff2');font-weight:500;font-display:swap}`;

  const CSS = `
.ct{--paper:#efe9dd;--sheet:#faf6ee;--ink:#1d1a16;--mute:#685f55;--faint:#93897c;--line:rgba(29,26,22,.14);--line2:rgba(29,26,22,.24);
  --baize:#2c5a47;--on:#f6f1e6;--ox:#9a2b2b;--brass:#8a6a1f;--tab:#e4d3ac;
  position:absolute;inset:0;display:grid;grid-template-rows:auto auto minmax(0,1fr);background:var(--paper);color:var(--ink);
  font:500 .875rem/1.4 'PWC Sans',system-ui,sans-serif;padding:var(--safe-top,0) 0 var(--safe-bottom,0);user-select:none}
.ct *{box-sizing:border-box}
.ct ::selection{background:var(--baize);color:var(--on)}
.ct-head{display:flex;align-items:baseline;gap:.625rem;padding:.875rem 1.125rem .5rem}
.ct-head h1{margin:0;font:700 1.625rem/1.1 'PWC Caslon',Georgia,serif;letter-spacing:-.01em}
.ct-head .who{margin-left:auto;font-size:.75rem;color:var(--mute);text-align:right;line-height:1.25}
.ct-nav{position:relative;display:flex;gap:.25rem;margin:0 1.125rem .625rem;padding:.25rem;border:1px solid var(--line2);border-radius:.625rem;background:var(--sheet)}
.ct-nav button{position:relative;z-index:1;flex:1;border:0;background:none;color:var(--mute);font:600 .8125rem 'PWC Sans',sans-serif;padding:.5rem .25rem;border-radius:.4375rem;cursor:pointer;transition:color .2s}
.ct-nav button.on{color:var(--on)}
.ct-nav .glide{position:absolute;z-index:0;top:.25rem;bottom:.25rem;left:0;width:6.25rem;border-radius:.4375rem;background:var(--ink);transform-origin:0 0;transition:transform .42s cubic-bezier(.22,1.2,.36,1)}
.ct-body{min-height:0;overflow-y:auto;overflow-x:hidden;padding:0 1.125rem 1.5rem;display:grid;align-content:start;gap:.875rem}
.ct-body::-webkit-scrollbar{width:.375rem}.ct-body::-webkit-scrollbar-track{background:transparent}
.ct-body::-webkit-scrollbar-thumb{background:var(--line2);border-radius:1rem}.ct-body::-webkit-scrollbar-button{display:none;height:0}
.ct-lbl{font:700 .6875rem 'PWC Sans',sans-serif;letter-spacing:.14em;text-transform:uppercase;color:var(--faint);margin:0 0 .375rem}
.ct-empty{color:var(--mute);padding:1.25rem .25rem;text-align:center}
.ct-no{font:500 .75rem 'PWC Mono',ui-monospace,monospace;letter-spacing:.04em}
.ct-fold{position:relative;margin-top:1.375rem}
.ct-fold>.tab{position:absolute;left:0;top:-1.375rem;height:1.4375rem;padding:.25rem .75rem 0;background:var(--tab);border:1px solid var(--line2);border-bottom:0;border-radius:.5rem .5rem 0 0}
.ct-fold>.card{background:var(--sheet);border:1px solid var(--line2);border-radius:0 .625rem .625rem .625rem;padding:.875rem 1rem;display:grid;gap:.75rem}
.ct-row{display:flex;align-items:center;gap:.75rem;width:100%;text-align:left;background:var(--sheet);border:1px solid var(--line);border-radius:.625rem;padding:.75rem .875rem;color:inherit;font:inherit;cursor:pointer;transition:transform .12s}
.ct-row:active{transform:scale(.985)}
.ct-row .t{flex:1;min-width:0;display:grid;gap:.125rem}
.ct-row .t b{font:700 1rem/1.2 'PWC Caslon',Georgia,serif;overflow-wrap:anywhere}
.ct-row .t span{font-size:.75rem;color:var(--mute)}
.ct-pill{flex:none;font:700 .6875rem 'PWC Sans',sans-serif;letter-spacing:.06em;text-transform:uppercase;padding:.25rem .5rem;border-radius:2rem;border:1px solid currentColor;color:var(--mute)}
.ct-pill.due{color:var(--brass)}.ct-pill.ox{color:var(--ox)}.ct-pill.ok{color:var(--baize)}
.ct-name{font:700 1.5rem/1.15 'PWC Caslon',Georgia,serif;margin:0;overflow-wrap:anywhere}
.ct-sub{color:var(--mute);font-size:.8125rem;margin:.125rem 0 0}
.ct-ch{display:grid;gap:.375rem}
.ct-ch div{display:flex;gap:.75rem;align-items:baseline;border-bottom:1px solid var(--line);padding-bottom:.375rem}
.ct-ch div:last-child{border-bottom:0;padding-bottom:0}
.ct-ch span{flex:1;overflow-wrap:anywhere}.ct-ch em{font-style:normal;color:var(--mute);font-variant-numeric:tabular-nums;white-space:nowrap}
.ct-fact{display:flex;align-items:center;gap:.75rem}
.ct-fact .t{flex:1;min-width:0}
.ct-fact .t b{display:block;font:700 1.125rem 'PWC Caslon',Georgia,serif;font-variant-numeric:tabular-nums}
.ct-fact .t span{font-size:.75rem;color:var(--mute)}
.ct-btn{flex:none;border:1px solid var(--line2);background:var(--sheet);color:var(--ink);font:700 .8125rem 'PWC Sans',sans-serif;padding:.5625rem .875rem;border-radius:.5rem;cursor:pointer;transition:transform .12s}
.ct-btn:active{transform:scale(.96)}
.ct-btn.go{background:var(--baize);border-color:var(--baize);color:var(--on)}
.ct-btn.ox{color:var(--ox);border-color:currentColor}
.ct-btn.wide{width:100%;padding:.75rem}
.ct-btn:disabled{opacity:.45;cursor:default;transform:none}
.ct-acts{display:flex;flex-wrap:wrap;gap:.5rem}
.ct-deal{border:1px dashed var(--baize);border-radius:.625rem;padding:.75rem .875rem;display:grid;gap:.5rem}
.ct-deal p{margin:0}
.ct-dock{display:grid;gap:0;position:relative;padding-left:1rem}
.ct-dock::before{content:'';position:absolute;left:.25rem;top:.375rem;bottom:.375rem;width:1px;background:var(--line2)}
.ct-dock div{position:relative;padding:.25rem 0 .625rem}
.ct-dock div::before{content:'';position:absolute;left:-.9375rem;top:.6rem;width:.4375rem;height:.4375rem;border-radius:50%;background:var(--paper);border:1px solid var(--ink)}
.ct-dock div.ruling::before{background:var(--ink)}
.ct-dock b{font:700 .6875rem 'PWC Sans',sans-serif;letter-spacing:.12em;text-transform:uppercase;color:var(--faint)}
.ct-dock p{margin:.125rem 0 0;overflow-wrap:anywhere}
.ct-dock small{color:var(--faint);font-size:.6875rem}
.ct-in{width:100%;border:1px solid var(--line2);background:var(--paper);color:var(--ink);font:500 .875rem 'PWC Sans',sans-serif;padding:.625rem .75rem;border-radius:.5rem;outline:none}
.ct-in:focus{border-color:var(--baize)}
.ct-in::placeholder{color:var(--faint)}
textarea.ct-in{min-height:4.5rem;resize:none}
.ct-stamp{position:absolute;right:.875rem;top:.75rem;transform:rotate(-8deg);font:700 .9375rem 'PWC Caslon',Georgia,serif;letter-spacing:.14em;text-transform:uppercase;
  color:var(--ox);border:1px solid currentColor;outline:1px solid currentColor;outline-offset:.125rem;padding:.25rem .5rem;border-radius:.25rem;pointer-events:none}
.ct-stamp.ok{color:var(--baize)}.ct-stamp.mute{color:var(--mute)}
.ct-stamp.land{animation:ct-stamp .34s cubic-bezier(.2,1.4,.4,1) both}
@keyframes ct-stamp{from{opacity:0;transform:rotate(-14deg) scale(1.9)}to{opacity:1;transform:rotate(-8deg) scale(1)}}
.ct-back{display:inline-flex;align-items:center;gap:.25rem;border:0;background:none;color:var(--mute);font:600 .8125rem 'PWC Sans',sans-serif;padding:0;cursor:pointer;justify-self:start}
.ct-scrim{position:absolute;inset:0;background:rgba(29,26,22,.42);z-index:5;animation:ct-fade .24s ease-out both}
.ct-sheet{position:absolute;left:0;right:0;bottom:0;z-index:6;background:var(--sheet);border-top:1px solid var(--line2);border-radius:1rem 1rem 0 0;
  padding:1rem 1.125rem calc(1.125rem + var(--safe-bottom,0rem));display:grid;gap:.75rem;max-height:86%;overflow-y:auto;animation:ct-up .32s cubic-bezier(.22,1,.36,1) both}
.ct-sheet h2{margin:0;font:700 1.25rem 'PWC Caslon',Georgia,serif}
.ct-sheet::-webkit-scrollbar{width:.375rem}.ct-sheet::-webkit-scrollbar-thumb{background:var(--line2);border-radius:1rem}.ct-sheet::-webkit-scrollbar-button{display:none;height:0}
@keyframes ct-up{from{transform:translateY(100%)}to{transform:none}}
@keyframes ct-fade{from{opacity:0}to{opacity:1}}
.ct-chips{display:flex;flex-wrap:wrap;gap:.375rem}
.ct-chips button{border:1px solid var(--line2);background:var(--paper);color:var(--ink);font:600 .8125rem 'PWC Sans',sans-serif;padding:.4375rem .6875rem;border-radius:2rem;cursor:pointer}
.ct-chips button.on{background:var(--ink);border-color:var(--ink);color:var(--on)}
.ct-check{display:flex;align-items:center;gap:.625rem;width:100%;border:1px solid var(--line);background:var(--paper);color:var(--ink);font:500 .875rem 'PWC Sans',sans-serif;padding:.5625rem .75rem;border-radius:.5rem;cursor:pointer;text-align:left}
.ct-check i{flex:none;width:1.125rem;height:1.125rem;border:1px solid var(--line2);border-radius:.25rem;display:grid;place-items:center}
.ct-check.on i{background:var(--ink);border-color:var(--ink)}
.ct-check.on i::after{content:'';width:.5rem;height:.25rem;border:solid var(--on);border-width:0 0 .125rem .125rem;transform:translateY(-.0625rem) rotate(-45deg)}
.ct-check span{flex:1;overflow-wrap:anywhere}.ct-check em{font-style:normal;color:var(--mute);white-space:nowrap}
.ct-step{display:flex;align-items:center;gap:.5rem}
.ct-step b{min-width:3.5rem;text-align:center;font:700 1.375rem 'PWC Caslon',Georgia,serif;font-variant-numeric:tabular-nums}
.ct-err{display:flex;gap:.5rem;align-items:center;margin:0 1.125rem .625rem;padding:.5625rem .75rem;border:1px solid var(--ox);color:var(--ox);border-radius:.5rem;background:var(--sheet);font-weight:600}
.ct-err span{flex:1}.ct-err button{border:0;background:none;color:inherit;font:inherit;cursor:pointer}
.ct.wide .ct-body{padding:0 1.5rem 1.5rem}
.ct.wide .ct-case{display:grid;grid-template-columns:minmax(0,1.35fr) minmax(0,1fr);gap:1.25rem;align-items:start}
.ct.wide .ct-list{display:grid;grid-template-columns:repeat(2,minmax(0,1fr));gap:.75rem;align-items:start}
.ct-case,.ct-list{display:grid;gap:.875rem;align-content:start}
.ct-side{display:grid;gap:.875rem;align-content:start}
.ct-two{display:grid;grid-template-columns:minmax(0,1fr) auto;gap:.5rem;align-items:center}
.ct-wait{position:sticky;top:0;z-index:2;height:.125rem;margin-bottom:-.875rem;overflow:hidden;opacity:0;transition:opacity .2s}
.ct-wait.on{opacity:1}.ct-wait::after{content:'';position:absolute;inset:0;background:var(--baize);transform-origin:0 0;animation:ct-wait 1s ease-in-out infinite}
@keyframes ct-wait{0%{transform:translateX(-100%) scaleX(.4)}100%{transform:translateX(250%) scaleX(.4)}}
`;

  const esc = (v) => String(v == null ? '' : v).replace(/[&<>"']/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c]));
  const money = (n) => '$' + Math.round(Number(n) || 0).toLocaleString('en-US');
  const when = (sec) => {
    if (!sec) return '';
    const d = new Date(sec * 1000);
    return d.toLocaleDateString('en-GB', { weekday: 'short', day: '2-digit', month: 'short' }) + ', ' + d.toTimeString().slice(0, 5);
  };
  const until = (sec) => {
    const m = Math.round((sec - Date.now() / 1000) / 60);
    if (m < 0) return 'started';
    if (m < 60) return 'in ' + m + ' min';
    const h = Math.floor(m / 60);
    return h < 24 ? 'in ' + h + ' h' + (m % 60 ? ' ' + (m % 60) + ' min' : '') : 'in ' + Math.round(h / 24) + ' days';
  };
  const OUT = { guilty: ['Guilty', ''], not_guilty: ['Not guilty', 'ok'], dismissed: ['Dismissed', 'ok'], no_show: ['Failed to appear', ''], deal: ['Plea deal', ''], plea: ['Pleaded guilty', ''], expired: ['Dismissed', 'mute'] };
  const BAIL = { due: 'Bail due', posted: 'Bail posted', denied: 'No bail', returned: 'Bail returned', forfeited: 'Bail forfeited', applied: 'Bail paid the fine', none: 'No bail' };
  const KIND = { filed: 'Filed', bail: 'Bail', hearing: 'Hearing', lawyer: 'Attorney', deal: 'Plea deal', motion: 'Motion', ruling: 'Ruling' };

  const live = new WeakMap();

  const RUNTIME = ['land'];
  const sameKind = (a, b) => a.nodeType === b.nodeType && a.nodeName === b.nodeName && (a.nodeType !== 1 || (a.getAttribute('data-key') || '') === (b.getAttribute('data-key') || ''));
  const morphAttrs = (o, n) => {
    for (const at of [...o.attributes]) if (at.name !== 'class' && at.name !== 'style' && !n.hasAttribute(at.name)) o.removeAttribute(at.name);
    for (const at of [...n.attributes]) if (at.name !== 'class' && o.getAttribute(at.name) !== at.value) o.setAttribute(at.name, at.value);
    const keep = RUNTIME.filter((c) => o.classList.contains(c));
    const cls = [...new Set([...(n.getAttribute('class') || '').split(' '), ...keep].filter(Boolean))].join(' ');
    if ((o.getAttribute('class') || '') !== cls) { if (cls) o.setAttribute('class', cls); else o.removeAttribute('class'); }
    if ((o.tagName === 'INPUT' || o.tagName === 'TEXTAREA') && o.ownerDocument.activeElement !== o && o.value !== n.value) o.value = n.value;
  };
  const morphKids = (o, n) => {
    const old = [...o.childNodes];
    const want = [...n.childNodes];
    want.forEach((w, i) => {
      const c = old[i];
      if (!c) o.appendChild(w);
      else if (!sameKind(c, w)) o.replaceChild(w, c);
      else if (c.nodeType === 1) { morphAttrs(c, w); if (c.tagName !== 'TEXTAREA' || c.ownerDocument.activeElement !== c) morphKids(c, w); }
      else if (c.nodeValue !== w.nodeValue) c.nodeValue = w.nodeValue;
    });
    for (let i = want.length; i < old.length; i++) old[i].remove();
  };
  const morph = (el, html) => { const t = el.ownerDocument.createElement('template'); t.innerHTML = html; morphKids(el, t.content); };

  const tabsFor = (s) => {
    const me = s.me || {};
    const list = [['mine', 'My cases']];
    if (me.lawyer) list.push(['clients', 'Clients']);
    if (me.justice) list.push(['docket', 'Docket'], ['hearings', 'Hearings']);
    return list;
  };

  const ask = async (app, action, args, after, quiet) => {
    const s = app.state;
    let timer = 0;
    if (!quiet) { s.waiting += 1; timer = setTimeout(() => { s.waitShown = true; paint(app); }, 300); }
    try {
      const r = await app.request(action, args || {});
      if (!quiet) s.err = null;
      if (after) await after(r);
      return r;
    } catch (e) {
      s.err = (e && e.reason) || 'Something went wrong';
      return null;
    } finally {
      if (!quiet) { clearTimeout(timer); s.waiting = Math.max(0, s.waiting - 1); if (!s.waiting) s.waitShown = false; }
      draw(app);
    }
  };

  const load = async (app) => {
    const s = app.state;
    if (s.open) { await ask(app, 'case', { id: s.open.id }, (r) => { s.open = r; }, true); return; }
    if (s.tab === 'mine') await ask(app, 'mine', {}, (r) => { s.mine = r || []; }, true);
    else if (s.tab === 'clients') await ask(app, 'clients', {}, (r) => { s.clients = r || []; }, true);
    else if (s.tab === 'docket') await ask(app, 'docket', {}, (r) => { s.docket = r || []; }, true);
    else if (s.tab === 'hearings') await ask(app, 'docket', {}, (r) => { s.docket = r || []; }, true);
  };

  const pill = (r) => {
    if (r.status === 'closed') { const o = OUT[r.outcome] || ['Closed', '']; return `<span class="ct-pill ${o[1] === 'ok' ? 'ok' : ''}">${esc(o[0])}</span>`; }
    if (r.bailState === 'due') return '<span class="ct-pill due">Bail due</span>';
    if (r.hearingAt) return `<span class="ct-pill ok">${esc(until(r.hearingAt))}</span>`;
    return '<span class="ct-pill">Open</span>';
  };

  const caseRow = (r, sub) => `<button class="ct-row" data-key="c${r.id}" data-act="open" data-id="${r.id}"><span class="t"><span class="ct-no">${esc(r.no)}</span><b>${esc(r.name || 'Defendant')}</b><span>${esc(sub || (r.charges || []).map((c) => c.title).join(', '))}</span></span>${pill(r)}</button>`;

  const list = (rows, empty, sub) => (rows && rows.length ? `<div class="ct-list">${rows.map((r) => caseRow(r, sub && sub(r))).join('')}</div>` : `<div class="ct-empty">${esc(empty)}</div>`);

  const mineView = (s) => `
    ${list(s.mine, 'No court cases. Keep it that way.')}
    <section><p class="ct-lbl">Post bail for someone</p><div class="ct-two"><input id="f-lookup" class="ct-in ct-no" data-bind="lookup" data-enter="lookup" value="${esc(s.f.lookup || '')}" placeholder="Case number, e.g. CR-2026-0042" autocomplete="off"><button class="ct-btn" data-act="lookup">Find</button></div></section>`;

  const hearingsView = (s) => {
    const rows = (s.docket || []).filter((r) => r.hearingAt).sort((a, b) => a.hearingAt - b.hearingAt);
    return list(rows, 'No hearings set.', (r) => when(r.hearingAt) + ' · ' + (r.courtroom || ''));
  };

  const docketView = (s) => {
    const rows = s.docket || [];
    const need = rows.filter((r) => !r.hearingAt);
    const set = rows.filter((r) => r.hearingAt);
    return `<section><p class="ct-lbl">Waiting for a hearing</p>${list(need, 'Nothing waiting.')}</section>
      <section><p class="ct-lbl">Hearing set</p>${list(set, 'None yet.', (r) => when(r.hearingAt) + ' · ' + (r.courtroom || ''))}</section>`;
  };

  const caseView = (app) => {
    const s = app.state; const r = s.open; const me = s.me || {}; const j = me.justice; const as = r.as;
    const perms = (j && j.onDuty && j.perms) || {};
    const open = r.status === 'open';
    const total = (r.charges || []).reduce((a, c) => ({ m: a.m + (c.months || 0), f: a.f + (c.fine || 0) }), { m: 0, f: 0 });
    const out = !open && (OUT[r.outcome] || ['Closed', '']);
    const stamp = out ? `<span class="ct-stamp ${out[1]}${s.landed === r.id ? ' land' : ''}" data-key="stamp">${esc(out[0])}</span>` : '';
    const charges = `<div class="ct-ch">${(r.charges || []).map((c) => `<div><span>${esc(c.title)}${c.count > 1 ? ' ×' + c.count : ''}</span><em>${c.months} mo · ${money(c.fine)}</em></div>`).join('')}</div>`;
    const bailFact = r.bailState && r.bailState !== 'none' || open ? `<div class="ct-fact"><span class="t"><b>${r.bailState === 'due' || r.bailState === 'posted' ? money(r.bail || r.bailPaid) : esc(BAIL[r.bailState] || 'No bail')}</b><span>${r.bailState === 'due' || r.bailState === 'posted' ? esc(BAIL[r.bailState]) : (r.held ? 'Held in custody' : 'Bail')}</span></span>
      ${open && r.bailState === 'due' ? '<button class="ct-btn go" data-act="postBail">Post bail</button>' : ''}${open && perms.bail ? '<button class="ct-btn" data-act="sheet" data-k="bail">Change</button>' : ''}</div>` : '';
    const hearing = open ? `<div class="ct-fact"><span class="t"><b>${r.hearingAt ? esc(when(r.hearingAt)) : 'Not set'}</b><span>${r.hearingAt ? esc((r.courtroom || '') + ' · ' + until(r.hearingAt)) : 'Hearing'}</span></span>
      ${r.hearingAt && (me.courtrooms || []).some((c) => c.label === r.courtroom && c.map) ? '<button class="ct-btn" data-act="waypoint">Waypoint</button>' : ''}${perms.schedule ? `<button class="ct-btn" data-act="sheet" data-k="schedule">${r.hearingAt ? 'Move' : 'Set'}</button>` : ''}</div>` : '';
    const lawyer = `<div class="ct-fact"><span class="t"><b>${esc(r.lawyer || 'None')}</b><span>${r.lawyerState === 'requested' ? 'Attorney, asked' : 'Attorney'}</span></span>
      ${open && as === 'defendant' && r.lawyerState !== 'accepted' ? `<button class="ct-btn" data-act="sheet" data-k="lawyer">${r.lawyerCharId ? 'Change' : 'Pick one'}</button>` : ''}
      ${open && as === 'lawyer' && r.lawyerState === 'requested' ? '<button class="ct-btn go" data-act="answerLawyer" data-v="1">Take it</button><button class="ct-btn" data-act="answerLawyer" data-v="0">Decline</button>' : ''}</div>`;
    const deal = open && r.deal ? `<div class="ct-deal"><p class="ct-lbl">Plea deal on the table</p><p><b>${r.deal.months} months, ${money(r.deal.fine)}</b> for pleading guilty to ${esc((r.charges || []).filter((c) => (r.deal.codes || []).includes(c.code)).map((c) => c.title).join(', '))}.</p>
      ${as === 'defendant' ? '<div class="ct-acts"><button class="ct-btn go" data-act="answerDeal" data-v="1">Take the deal</button><button class="ct-btn" data-act="answerDeal" data-v="0">Turn it down</button></div>' : ''}</div>` : '';
    const staffActs = open && j && j.onDuty ? [
      perms.prosecute ? '<button class="ct-btn" data-act="sheet" data-k="deal">Offer a deal</button>' : '',
      perms.prosecute ? '<button class="ct-btn ox" data-act="drop">Drop charges</button>' : '',
      perms.rule ? '<button class="ct-btn go" data-act="sheet" data-k="rule">Rule</button>' : '',
    ].join('') : '';
    const canMotion = open && (as === 'defendant' || (as === 'lawyer' && r.lawyerState === 'accepted') || as === 'justice');
    const dock = (r.docket || []).length ? `<div class="ct-dock">${r.docket.map((d, i) => `<div class="${d.kind === 'ruling' ? 'ruling' : ''}" data-key="d${i}"><b>${esc(KIND[d.kind] || d.kind)}</b><p>${esc(d.text)}</p><small>${esc([d.by, when(d.at)].filter(Boolean).join(' · '))}</small></div>`).join('')}</div>` : '';
    const side = `${canMotion ? `<section><p class="ct-lbl">File a motion</p><textarea id="f-motion" class="ct-in" data-bind="motion" placeholder="What you ask the court for, and why">${esc(s.f.motion || '')}</textarea><div style="margin-top:.5rem"><button class="ct-btn" data-act="motion">File</button></div></section>` : ''}
      ${dock ? `<section><p class="ct-lbl">Docket</p>${dock}</section>` : ''}`;
    return `<button class="ct-back" data-act="close"><svg viewBox="0 0 24 24" style="width:1rem;height:1rem" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M15 5l-7 7 7 7"/></svg>Back</button>
      <div class="ct-case"><div class="ct-fold"><span class="tab ct-no">${esc(r.no)}</span><div class="card">${stamp}
        <div><p class="ct-name">${esc(r.name || 'Defendant')}</p><p class="ct-sub">${esc([r.officer ? 'Charged by ' + r.officer : '', r.judge ? 'Judge ' + r.judge : ''].filter(Boolean).join(' · '))}</p></div>
        <section><p class="ct-lbl">Charges · ${total.m} months · ${money(total.f)}</p>${charges}</section>
        ${bailFact}${hearing}${as !== 'public' ? lawyer : ''}${deal}
        ${staffActs ? `<div class="ct-acts">${staffActs}</div>` : ''}
      </div></div>
      <div class="ct-side">${side}</div></div>`;
  };

  const DAY = 86400;
  const sheet = (app) => {
    const s = app.state; const k = s.sheet; const r = s.open;
    if (!k || !r) return '';
    let body = '';
    if (k === 'bail') {
      body = `<h2>Bail for ${esc(r.no)}</h2><input id="f-bail" class="ct-in" data-bind="bail" inputmode="numeric" value="${esc(s.f.bail != null ? s.f.bail : r.bail || '')}" placeholder="Amount in $ (0 releases them on their word)">
        <div class="ct-acts"><button class="ct-btn go" data-act="setBail">Set bail</button><button class="ct-btn ox" data-act="denyBail">Deny bail</button></div>`;
    } else if (k === 'schedule') {
      const days = Math.max(1, (s.me && s.me.hearingDays) || 7);
      const base = new Date(); base.setHours(0, 0, 0, 0);
      const chips = Array.from({ length: Math.min(days + 1, 8) }, (_, i) => {
        const d = new Date(base.getTime() + i * DAY * 1000);
        const label = i === 0 ? 'Today' : i === 1 ? 'Tomorrow' : d.toLocaleDateString('en-GB', { weekday: 'short', day: '2-digit' });
        return `<button class="${s.f.day === i ? 'on' : ''}" data-act="pick" data-f="day" data-v="${i}">${label}</button>`;
      }).join('');
      const rooms = ((s.me && s.me.courtrooms) || []).map((c) => `<button class="${s.f.room === c.label ? 'on' : ''}" data-act="pick" data-f="room" data-v="${esc(c.label)}">${esc(c.label)}</button>`).join('');
      body = `<h2>Hearing for ${esc(r.no)}</h2><p class="ct-lbl">Day</p><div class="ct-chips">${chips}</div>
        <p class="ct-lbl">Time</p><div class="ct-step"><button class="ct-btn" data-act="hour" data-d="-1" aria-label="Earlier">−</button><b>${String(s.f.hour).padStart(2, '0')}:${String(s.f.min).padStart(2, '0')}</b><button class="ct-btn" data-act="hour" data-d="1" aria-label="Later">+</button>
        <div class="ct-chips">${[0, 15, 30, 45].map((m) => `<button class="${s.f.min === m ? 'on' : ''}" data-act="pick" data-f="min" data-v="${m}">:${String(m).padStart(2, '0')}</button>`).join('')}</div></div>
        <p class="ct-lbl">Courtroom</p><div class="ct-chips">${rooms}</div>
        <button class="ct-btn go wide" data-act="schedule">Set the hearing</button>`;
    } else if (k === 'deal' || k === 'rule') {
      const sel = s.f.codes || {};
      const checks = (r.charges || []).map((c) => `<button class="ct-check ${sel[c.code] ? 'on' : ''}" data-act="code" data-c="${esc(c.code)}"><i></i><span>${esc(c.title)}${c.count > 1 ? ' ×' + c.count : ''}</span><em>${c.months} mo · ${money(c.fine)}</em></button>`).join('');
      if (k === 'deal') {
        body = `<h2>Offer a plea deal</h2><p class="ct-sub">Pick the charges they plead guilty to; the plea discount of ${Math.round(((s.me && s.me.discount) || 0) * 100)}% comes off.</p><div style="display:grid;gap:.375rem">${checks}</div>
          <button class="ct-btn go wide" data-act="deal">Send the offer</button>`;
      } else {
        const v = s.f.verdict;
        body = `<h2>Ruling on ${esc(r.no)}</h2><div class="ct-chips">${[['guilty', 'Guilty'], ['not_guilty', 'Not guilty'], ['dismissed', 'Dismissed'], ['no_show', 'Failed to appear']].map(([id, l]) => `<button class="${v === id ? 'on' : ''}" data-act="pick" data-f="verdict" data-v="${id}">${l}</button>`).join('')}</div>
          ${v === 'guilty' ? `<p class="ct-lbl">Guilty of</p><div style="display:grid;gap:.375rem">${checks}</div>${r.bailState === 'posted' ? `<button class="ct-check ${s.f.applyBail ? 'on' : ''}" data-act="applyBail"><i></i><span>Pay the fine from the bail</span></button>` : ''}` : ''}
          ${v === 'no_show' ? '<p class="ct-sub">Bail is forfeited and a warrant goes out.</p>' : ''}
          <button class="ct-btn go wide" data-act="rule" ${v ? '' : 'disabled'}>Rule</button>`;
      }
    } else if (k === 'lawyer') {
      const ls = s.lawyers || [];
      body = `<h2>Pick an attorney</h2>${ls.length ? ls.map((l) => `<button class="ct-row" data-act="requestLawyer" data-id="${l.charId}"><span class="t"><b>${esc(l.name)}</b><span>${l.onDuty ? 'Working now' : 'Off duty'}</span></span></button>`).join('') : '<div class="ct-empty">No attorneys in town yet.</div>'}`;
    } else if (k === 'found') {
      const f = s.found;
      body = `<h2>${esc(f.no)}</h2><p class="ct-sub">${esc(f.name || '')}</p><div class="ct-fact"><span class="t"><b>${f.bailState === 'due' ? money(f.bail) : esc(BAIL[f.bailState] || 'No bail')}</b><span>${f.bailState === 'due' ? 'Bail due' : 'Bail'}</span></span></div>
        ${f.bailState === 'due' ? `<button class="ct-btn go wide" data-act="postBailFor">Post ${money(f.bail)} bail</button>` : ''}`;
    }
    return `<div class="ct-scrim" data-act="closeSheet"></div><div class="ct-sheet" role="dialog">${body}</div>`;
  };

  const render = (app) => {
    const s = app.state;
    const me = s.me || {};
    const tabs = tabsFor(s);
    const role = me.justice ? (me.justice.rank + (me.justice.onDuty ? '' : ', off duty')) : me.lawyer ? me.lawyer.rank : 'Citizen';
    let body;
    if (!s.me) body = '<div class="ct-empty">Opening the court records…</div>';
    else if (s.open) body = caseView(app);
    else if (s.tab === 'clients') body = list(s.clients, 'No clients yet. Defendants pick you in their case.');
    else if (s.tab === 'docket') body = docketView(s);
    else if (s.tab === 'hearings') body = hearingsView(s);
    else body = mineView(s);
    return `<div class="ct-head"><h1>Court</h1><span class="who">${esc(me.name || '')}<br>${esc(role)}</span></div>
      ${tabs.length > 1 ? `<nav class="ct-nav" role="tablist"><span class="glide"></span>${tabs.map(([id, l]) => `<button class="${s.tab === id ? 'on' : ''}" role="tab" aria-selected="${s.tab === id}" data-act="tab" data-t="${id}">${l}</button>`).join('')}</nav>` : '<div></div>'}
      <div class="ct-body" data-scroll="body"><div class="ct-wait ${s.waitShown ? 'on' : ''}"></div>${s.err ? `<div class="ct-err" role="alert"><span>${esc(s.err)}</span><button data-act="dismissErr" aria-label="Dismiss">×</button></div>` : ''}${body}</div>
      ${sheet(app)}`;
  };

  const glide = (root) => {
    const nav = root.querySelector('.ct-nav');
    if (!nav) return;
    const g = nav.querySelector('.glide'); const on = nav.querySelector('button.on');
    if (!g || !on) return;
    g.style.transform = `translateX(${on.offsetLeft}px) scaleX(${on.offsetWidth / g.offsetWidth})`;
  };

  const paint = (app) => {
    const ctx = live.get(app);
    const bar = ctx && ctx.el.querySelector('.ct-wait');
    if (bar) bar.classList.toggle('on', !!app.state.waitShown);
  };

  const draw = (app) => {
    const ctx = live.get(app);
    if (!ctx) return;
    const root = ctx.el.querySelector('.ct');
    if (!root) return;
    root.classList.toggle('wide', !!(ctx.view && ctx.view.size && ctx.view.size !== 'phone'));
    morph(root, render(app));
    glide(root);
    if (app.state.landed) setTimeout(() => { app.state.landed = null; }, 500);
  };

  const pickDefaults = (s) => {
    const n = new Date(Date.now() + 3600e3);
    s.f.day = 0; s.f.hour = n.getHours(); s.f.min = 0;
    s.f.room = ((s.me && s.me.courtrooms) || [])[0] ? s.me.courtrooms[0].label : null;
  };

  const reopen = async (app) => { const s = app.state; if (s.open) await ask(app, 'case', { id: s.open.id }, (r) => { s.open = r; }); };

  const actions = {
    tab(app, d) { const s = app.state; s.tab = d.t; s.open = null; s.sheet = null; draw(app); load(app); },
    async open(app, d) { const s = app.state; s.f.motion = ''; await ask(app, 'case', { id: Number(d.id) }, (r) => { s.open = r; }); },
    close(app) { app.state.open = null; app.state.sheet = null; draw(app); load(app); },
    dismissErr(app) { app.state.err = null; draw(app); },
    async sheet(app, d) {
      const s = app.state; s.sheet = d.k; s.f.codes = {}; s.f.verdict = null; s.f.applyBail = true; s.f.bail = null;
      if (d.k === 'schedule') pickDefaults(s);
      if (d.k === 'lawyer') { draw(app); await ask(app, 'lawyers', {}, (r) => { s.lawyers = r || []; }, true); return; }
      draw(app);
    },
    closeSheet(app) { app.state.sheet = null; draw(app); },
    pick(app, d) { const s = app.state; s.f[d.f] = d.f === 'day' || d.f === 'min' ? Number(d.v) : d.v; draw(app); },
    hour(app, d) { const s = app.state; s.f.hour = (s.f.hour + Number(d.d) + 24) % 24; draw(app); },
    code(app, d) { const c = app.state.f.codes; c[d.c] = !c[d.c]; draw(app); },
    applyBail(app) { app.state.f.applyBail = !app.state.f.applyBail; draw(app); },
    async postBail(app) { const s = app.state; await ask(app, 'postBail', { id: s.open.id }, async () => { app.toast('Bail posted'); await reopen(app); }); },
    async lookup(app) {
      const s = app.state;
      await ask(app, 'lookup', { q: s.f.lookup || '' }, (r) => { if (r) { s.found = r; s.sheet = 'found'; } });
    },
    async postBailFor(app) {
      const s = app.state;
      await ask(app, 'postBail', { id: s.found.id }, () => { app.toast('Bail posted for ' + (s.found.name || s.found.no)); s.sheet = null; s.f.lookup = ''; });
    },
    async setBail(app) {
      const s = app.state; const v = Number(String(s.f.bail != null ? s.f.bail : s.open.bail || '').replace(/[^0-9]/g, ''));
      await ask(app, 'setBail', { id: s.open.id, amount: v }, async () => { s.sheet = null; await reopen(app); });
    },
    async denyBail(app) { const s = app.state; await ask(app, 'setBail', { id: s.open.id, deny: true }, async () => { s.sheet = null; await reopen(app); }); },
    async schedule(app) {
      const s = app.state; const base = new Date(); base.setHours(0, 0, 0, 0);
      const at = Math.floor((base.getTime() + s.f.day * DAY * 1000) / 1000) + s.f.hour * 3600 + s.f.min * 60;
      await ask(app, 'schedule', { id: s.open.id, at, room: s.f.room }, async () => { s.sheet = null; app.toast('Hearing set'); await reopen(app); });
    },
    async deal(app) {
      const s = app.state; const codes = Object.keys(s.f.codes).filter((c) => s.f.codes[c]);
      await ask(app, 'deal', { id: s.open.id, codes }, async () => { s.sheet = null; app.toast('Offer sent'); await reopen(app); });
    },
    async drop(app) { const s = app.state; await ask(app, 'drop', { id: s.open.id }, async () => { s.landed = s.open.id; await reopen(app); }); },
    async rule(app) {
      const s = app.state; const codes = Object.keys(s.f.codes).filter((c) => s.f.codes[c]);
      await ask(app, 'rule', { id: s.open.id, verdict: s.f.verdict, codes, applyBail: !!s.f.applyBail }, async () => { s.sheet = null; s.landed = s.open.id; await reopen(app); });
    },
    async answerDeal(app, d) { const s = app.state; await ask(app, 'answerDeal', { id: s.open.id, accept: d.v === '1' }, async () => { if (d.v === '1') s.landed = s.open.id; await reopen(app); }); },
    async answerLawyer(app, d) { const s = app.state; await ask(app, 'answerLawyer', { id: s.open.id, accept: d.v === '1' }, async () => { await reopen(app); }); },
    async requestLawyer(app, d) { const s = app.state; await ask(app, 'requestLawyer', { id: s.open.id, lawyer: Number(d.id) }, async () => { s.sheet = null; app.toast('Request sent'); await reopen(app); }); },
    async motion(app) { const s = app.state; await ask(app, 'motion', { id: s.open.id, text: s.f.motion || '' }, async () => { s.f.motion = ''; await reopen(app); }); },
    async waypoint(app) { const s = app.state; await ask(app, 'waypoint', { room: s.open.courtroom }, () => app.toast('Waypoint set')); },
  };

  const wire = (app, el) => {
    el.addEventListener('click', (e) => {
      const t = e.target.closest('[data-act]');
      if (!t || !el.contains(t) || t.disabled) return;
      const fn = actions[t.dataset.act];
      if (fn) fn(app, { ...t.dataset });
    });
    el.addEventListener('input', (e) => { const k = e.target.dataset && e.target.dataset.bind; if (k) app.state.f[k] = e.target.value; });
    el.addEventListener('keydown', (e) => {
      const act = e.key === 'Enter' && e.target.dataset && e.target.dataset.enter;
      if (!act) return;
      e.preventDefault();
      if (actions[act]) actions[act](app, {});
    });
  };

  WhipPhone.module({
    id: 'pwcourt', name: 'Court', version: '1.0.0', order: 6, statusBar: 'dark',
    icon: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M12 3l8 4H4z"/><path d="M5 10v7M9.5 10v7M14.5 10v7M19 10v7"/><path d="M3.5 20.5h17"/></svg>',
    css: CSS, globalCss: FONTS,
    state: () => ({ tab: 'mine', me: null, open: null, sheet: null, err: null, waiting: 0, waitShown: false, landed: null, f: {} }),
    mount(app, el, view) {
      el.innerHTML = '<div class="ct"></div>';
      const root = el.querySelector('.ct');
      const ro = new ResizeObserver(() => glide(root));
      ro.observe(root);
      live.set(app, { el, view, ro });
      wire(app, el);
      draw(app);
    },
    update(app, el, view, changed) {
      const ctx = live.get(app);
      if (ctx && (ctx.el !== el || changed)) { ctx.el = el; ctx.view = view; draw(app); }
    },
    unmount(app) {
      const ctx = live.get(app);
      if (ctx && ctx.ro) ctx.ro.disconnect();
      live.delete(app);
    },
    async open(app) {
      await ask(app, 'me', {}, (r) => { app.state.me = r; }, true);
      await load(app);
      draw(app);
    },
    back(app) {
      const s = app.state;
      if (s.sheet) { s.sheet = null; draw(app); return true; }
      if (s.open) { s.open = null; draw(app); load(app); return true; }
      return false;
    },
    on: { changed(app) { load(app).then(() => draw(app)); } },
  });
})();
