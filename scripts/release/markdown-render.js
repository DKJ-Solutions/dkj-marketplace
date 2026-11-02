// The house's one markdown renderer -- a FRAGMENT, not a module: function declarations that a page
// inlines inside its own script scope, so each page calls renderMd(md) as if it had written it itself.
// Two pages inline it: the release-notes pages (build-release-notes-page.ps1, at @@MARKDOWN_RENDERER@@
// in release-notes-page-template.html) and a specialist lens's page on the hub (Format-HubLensPageHtml,
// plugins/dkj-policy/hub/lib/general-pages-lib.ps1). One file, so one format never has two renderers.
// Indented two spaces because that is where it lands: inside an IIFE.

  // --- markdown -------------------------------------------------------------------------------
  // A small renderer rather than a library: the page is served as one self-contained string by a
  // worker, so pulling in a CDN would both break offline reading and tell a third party who opened
  // the page. It covers what a release note actually uses -- headings, paragraphs, nested lists,
  // fenced code, tables, blockquotes, rules, and the inline set.

  // The code-span sentinel. Built here rather than typed, so the template carries no invisible
  // byte. It must be something prose cannot contain: a readable placeholder is a trap, because a
  // note that writes a bare number between markers would have it replaced by a code span that was
  // never there.
  var SENT = String.fromCharCode(1);
  var SENT_RE = new RegExp(SENT + '(\\d+)' + SENT, 'g');

  function esc(s) {
    return String(s).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
  }

  function inlineMd(src) {
    // Code spans are lifted out FIRST and put back last, so their contents are never treated as
    // markup -- a note that shows two asterisks inside backticks must render the asterisks.
    var codes = [];
    var s = String(src).replace(/`([^`]+)`/g, function (m, c) {
      codes.push(esc(c));
      return SENT + (codes.length - 1) + SENT;
    });
    s = esc(s);
    s = s.replace(/\[([^\]]*)\]\(([^)\s]+)(?:\s+"[^"]*")?\)/g, function (m, text, url) {
      // A repo-relative link has no target on this page, so it renders as plain text rather than
      // as a link that 404s. Only absolute and in-page links survive.
      if (!/^(https?:|mailto:|#)/i.test(url)) { return text; }
      return '<a href="' + url + '" rel="noopener noreferrer">' + text + '</a>';
    });
    s = s.replace(/\*\*([^*]+)\*\*/g, '<strong>$1</strong>');
    s = s.replace(/(^|[\s(])\*([^*\s][^*]*)\*/g, '$1<em>$2</em>');
    s = s.replace(SENT_RE, function (m, i) { return '<code>' + codes[+i] + '</code>'; });
    return s;
  }

  function isBlank(l) { return /^\s*$/.test(l); }
  function isItem(l) { return /^\s*([-*+]|\d+\.)\s+/.test(l); }
  function isRule(l) { return /^\s*(-{3,}|\*{3,}|_{3,})\s*$/.test(l); }
  function isTableRow(l) { return /^\s*\|.*\|\s*$/.test(l); }
  function isHeading(l) { return /^\s*#{1,6}\s/.test(l); }

  function renderTable(rows) {
    function cells(r) {
      return r.trim().replace(/^\|/, '').replace(/\|\s*$/, '').split('|').map(function (c) { return c.trim(); });
    }
    var head = cells(rows[0]);
    var body = rows.slice(2).map(cells);
    return '<div class="table-scroll"><table><thead><tr>' +
      head.map(function (c) { return '<th>' + inlineMd(c) + '</th>'; }).join('') +
      '</tr></thead><tbody>' +
      body.map(function (r) {
        return '<tr>' + r.map(function (c) { return '<td>' + inlineMd(c) + '</td>'; }).join('') + '</tr>';
      }).join('') +
      '</tbody></table></div>';
  }

  function renderList(block) {
    var ordered = /^\s*\d+\./.test(block[0]);
    var baseIndent = block[0].match(/^\s*/)[0].length;
    var items = [];
    block.forEach(function (l) {
      var indent = isBlank(l) ? baseIndent + 99 : l.match(/^\s*/)[0].length;
      if (isItem(l) && indent <= baseIndent) {
        items.push({ lines: [l.replace(/^\s*([-*+]|\d+\.)\s+/, '')], sub: [] });
      } else if (items.length) {
        var it = items[items.length - 1];
        if (isItem(l) && indent > baseIndent) { it.sub.push(l.slice(baseIndent + 2)); }
        else if (it.sub.length) { it.sub.push(isBlank(l) ? '' : l.slice(Math.min(indent, baseIndent + 2))); }
        else { it.lines.push(l.trim()); }
      }
    });
    var body = items.map(function (it) {
      var paras = it.lines.join('\n').split(/\n\s*\n/).filter(function (p) { return p.trim(); });
      var html = paras.map(function (p) { return '<p>' + inlineMd(p.replace(/\n/g, ' ').trim()) + '</p>'; }).join('');
      if (it.sub.length) { html += renderList(it.sub); }
      return '<li>' + html + '</li>';
    }).join('');
    return (ordered ? '<ol>' : '<ul>') + body + (ordered ? '</ol>' : '</ul>');
  }

  function renderMd(md) {
    var lines = String(md).replace(/\r\n/g, '\n').split('\n');
    var out = [];
    var i = 0;

    while (i < lines.length) {
      var l = lines[i];

      if (isBlank(l)) { i++; continue; }

      var fence = l.match(/^\s*```/);
      if (fence) {
        var code = [];
        i++;
        while (i < lines.length && !/^\s*```\s*$/.test(lines[i])) { code.push(lines[i]); i++; }
        i++;
        out.push('<pre><code>' + esc(code.join('\n')) + '</code></pre>');
        continue;
      }

      var head = l.match(/^\s*(#{1,6})\s+(.*)$/);
      if (head) {
        var level = head[1].length;
        out.push('<h' + level + '>' + inlineMd(head[2].trim()) + '</h' + level + '>');
        i++;
        continue;
      }

      // A table is tested before a rule: a separator row is otherwise read as a horizontal rule.
      if (isTableRow(l) && i + 1 < lines.length && /^\s*\|[\s:|-]+\|\s*$/.test(lines[i + 1])) {
        var rows = [];
        while (i < lines.length && isTableRow(lines[i])) { rows.push(lines[i]); i++; }
        out.push(renderTable(rows));
        continue;
      }

      if (isRule(l)) { out.push('<hr>'); i++; continue; }

      if (/^\s*>/.test(l)) {
        var quote = [];
        while (i < lines.length && /^\s*>/.test(lines[i])) {
          quote.push(lines[i].replace(/^\s*>\s?/, ''));
          i++;
        }
        out.push('<blockquote>' + renderMd(quote.join('\n')) + '</blockquote>');
        continue;
      }

      if (isItem(l)) {
        // A list runs until a blank line that is NOT followed by an indented continuation. That is
        // what keeps a multi-paragraph bullet -- which every note here uses -- in one item.
        var block = [];
        while (i < lines.length) {
          if (isBlank(lines[i])) {
            var nxt = lines[i + 1];
            if (nxt === undefined || !/^\s{2,}\S/.test(nxt)) { i++; break; }
            block.push('');
            i++;
            continue;
          }
          if (isHeading(lines[i]) || isRule(lines[i])) { break; }
          block.push(lines[i]);
          i++;
        }
        out.push(renderList(block));
        continue;
      }

      var para = [];
      while (i < lines.length && !isBlank(lines[i]) && !isItem(lines[i]) && !isRule(lines[i]) &&
             !isHeading(lines[i]) && !/^\s*>/.test(lines[i]) && !/^\s*```/.test(lines[i]) &&
             !isTableRow(lines[i])) {
        para.push(lines[i].trim());
        i++;
      }
      if (para.length) { out.push('<p>' + inlineMd(para.join(' ')) + '</p>'); }
      else { i++; }
    }
    return out.join('\n');
  }
