// Generated by CoffeeScript 1.4.0
(function() {
  var lib, list2set, object,
    __slice = [].slice;

  object = {
    extendObject: function(fields) {
      var n, o, v;
      o = {};
      for (n in this) {
        v = this[n];
        o[n] = v;
      }
      for (n in fields) {
        v = fields[n];
        o[n] = v;
      }
      return o;
    }
  };

  list2set = function(l) {
    var r, x, _i, _len;
    r = {};
    for (_i = 0, _len = l.length; _i < _len; _i++) {
      x = l[_i];
      r[x] = 1;
    }
    return r;
  };

  lib = object.extendObject({
    printHtml: function(t) {
      return process.stdout.write(t);
    },
    quoteTagText: function(str) {
      return str.replace(/[&<]/g, function(c) {
        if (c === '<') {
          return "&lt;";
        } else {
          return "&amp;";
        }
      });
    },
    quoteText: function(str) {
      return str.replace(/[&<"]/g, function(c) {
        if (c === '<') {
          return "&lt;";
        } else if (c === '&') {
          return "&amp;";
        } else {
          return '"';
        }
      });
    },
    docType: function() {
      return this.printHtml("<!DOCTYPE html>\n");
    },
    voidElements: list2set('area, base, br, col, command, embed, hr, img, input, keygen, link, meta, param, source, track, wbr'.split(/, */)),
    rawTextElements: list2set(['script', 'style']),
    allElements: "a, abbr, address, area, article, aside, audio, b, base, bdi, bdo,\nblockquote, body, br, button, button, button, button, canvas, caption,\ncite, code, col, colgroup, command, command, command, command,\ndatalist, dd, del, details, dfn, div, dl, dt, em, embed, fieldset,\nfigcaption, figure, footer, form, h1, h2, h3, h4, h5, h6, head,\nheader, hgroup, hr, html, i, iframe, img, input, ins, kbd, keygen,\nlabel, legend, li, link, map, mark, menu, meta, meta, meta, meta,\nmeta, meta, meter, nav, noscript, object, ol, optgroup, option,\noutput, p, param, pre, progress, q, rp, rt, ruby, s, samp, script,\nsection, select, small, source, span, strong, style, sub, summary,\nsup, table, tbody, td, textarea, tfoot, th, thead, time, title, tr,\ntrack, u, ul, var, video, wbr".match(/[a-z0-9]+/g),
    compileTag: function(tagName, isVoid, isRawText) {
      return function() {
        var arg, args, f, s, x, y, _i, _len;
        args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
        this.printHtml("<" + tagName);
        for (_i = 0, _len = args.length; _i < _len; _i++) {
          arg = args[_i];
          if (typeof arg === 'function') {
            f = arg;
            break;
          }
          if (typeof arg === 'string') {
            s = arg;
            break;
          }
          for (x in arg) {
            y = arg[x];
            if (y != null) {
              this.printHtml(" " + x + "=\"" + (this.quoteText(y)) + "\"");
            } else {
              this.printHtml(" " + x);
            }
          }
        }
        this.printHtml('>');
        if (isVoid) {
          return;
        }
        if (f) {
          f.apply(this);
        }
        if (s) {
          if (isRawText) {
            this.printHtml(s);
          } else {
            this.printHtml(this.quoteTagText(s));
          }
        }
        return this.printHtml('</' + tagName + '>');
      };
    },
    compileLib: function() {
      var h, x, _i, _len, _ref;
      h = {};
      _ref = this.allElements;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        x = _ref[_i];
        h[x] = this.compileTag(x, (this.voidElements[x] != null), (this.rawTextElements[x] != null));
      }
      return this.extendObject(h);
    },
    html5Page: function() {
      var args;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      this.docType(5);
      return this.html.apply(this, args);
    }
  });

  lib = lib.compileLib();

  (typeof exports !== "undefined" && exports !== null ? exports : window).htmlcup = lib;

}).call(this);
