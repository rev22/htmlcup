// Generated by CoffeeScript 1.4.0
(function() {
  var lib, list2set, version,
    __slice = [].slice;

  version = "1.1.0-inbrowser.8";

  list2set = function(l) {
    var r, x, _i, _len;
    r = {};
    for (_i = 0, _len = l.length; _i < _len; _i++) {
      x = l[_i];
      r[x] = 1;
    }
    return r;
  };

  lib = {
    libraryName: "htmlcup",
    libraryVersion: "0.2.0",
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
    },
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
  };

  lib = lib.compileLib();

  lib = lib.extendObject({
    bareHtmlcup: lib,
    libraryVersion: version,
    cssStyle: function(x) {
      return this.style({
        type: 'text/css'
      }, x);
    },
    javaScript: function(x) {
      return this.script({
        type: "text/javascript"
      }, x.replace("</", "<\/"));
    },
    coffeeScript: function(x) {
      var codeToString, isString;
      isString = function(x) {
        return typeof x === "string" || x instanceof String;
      };
      codeToString = function(x) {
        var cs;
        if (isString(x)) {
          cs = require("coffee-script");
          return cs.compile(x);
        } else {
          return "(" + (x.toString()) + ")();\n";
        }
      };
      return this.javaScript(codeToString(x));
    },
    cssStyleSource: function(s) {
      return this.style({
        type: "text/css",
        src: s
      });
    },
    javaScriptSource: function(s) {
      return this.script({
        type: "text/javascript",
        src: s
      });
    },
    coffeeScriptSource: function(s) {
      return this.script({
        type: "text/coffeescript",
        src: s
      });
    },
    embedCoffeeScriptSource: function(f) {
      var fs;
      fs = require("fs");
      return this.coffeeScript((fs.readFileSync(f)).toString());
    },
    embedJavaScriptSource: function(f) {
      var fs;
      fs = require("fs");
      return this.javaScript((fs.readFileSync(f)).toString());
    },
    embedScriptSource: function(f) {
      var fs;
      fs = require("fs");
      if (/\.coffee$/.test(f)) {
        return this.embedCoffeeScriptSource(f);
      } else {
        return this.embedJavaScriptSource(f);
      }
    },
    embedFavicon: function(f) {
      var fs, icon;
      if (f == null) {
        f = "favicon.ico";
      }
      fs = require("fs");
      icon = fs.readFileSync(f).toString('base64');
      icon = "data:image/x-icon;base64," + icon;
      return this.link({
        rel: "shortcut icon",
        href: icon
      });
    }
  });

  lib = lib.extendObject({
    originalLib: htmlcup,
    capturedTokens: [],
    printHtml: function(t) {
      return this.capturedTokens.push(t);
    },
    captureHtml: function(f) {
      var o, p, r;
      o = this.capturedTokens;
      this.capturedTokens = [];
      f.apply(this);
      p = this.capturedTokens;
      this.capturedTokens = o;
      r = p.join("");
      this.printHtml(r);
      return r;
    },
    stripOuter: function(x) {
      return x.replace(/^<[^>]*>/, "").replace(/<[^>]*>$/, "");
    },
    capturedParts: {},
    capturePart: function(tagName, stripOuter) {
      if (stripOuter == null) {
        stripOuter = this.stripOuter;
      }
      return function() {
        var x;
        x = arguments;
        return this.capturedParts[tagName] = stripOuter(this.captureHtml(function() {
          return this.originalLib[tagName].apply(this, x);
        }));
      };
    },
    body: function() {
      return (this.capturePart("body")).apply(this, arguments);
    },
    head: function() {
      var r;
      lib = this.extendObject({
        title: function() {
          return (this.capturePart("title")).apply(this, arguments);
        },
        headStyles: [],
        style: function() {
          return this.headStyles.push((this.capturePart("style")).apply(this, arguments));
        }
      });
      r = (lib.capturePart("head")).apply(lib, arguments);
      this.capturedParts.headStyles = lib.headStyles;
      this.capturedParts.headTitle = lib.capturedParts.title;
      return r;
    },
    html5Page: function() {
      var r, x;
      x = arguments;
      this.captureHtml(function() {
        return this.originalLib.html5Page.apply(this, x);
      });
      r = this.capturedParts;
      this.capturedParts = {};
      return r;
    }
  });

  (typeof exports !== "undefined" && exports !== null ? exports : window).htmlcup = lib;

}).call(this);
