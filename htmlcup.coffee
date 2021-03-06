# htmlcup.coffee - HTML5 generating library

version = "1.2.6"
  
# Copyright (c) 2013, 2014, 2015 Michele Bini

# This program is free software: you can redistribute it and/or modify
# it under the terms of the version 3 of the GNU General Public License
# as published by the Free Software Foundation.

# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
  
list2set = (l) ->
  r = { }
  r[x] = 1 for x in l
  r

lib =
  libraryName: "htmlcup"
  libraryVersion: "0.2.0"
  extendObject: (fields) ->
    o = { }
    o[n] = v for n,v of @
    o[n] = v for n,v of fields
    o
  printHtml: (t) -> process.stdout.write t
  quoteTagText: (str) ->
    str.replace /[&<]/g, (c) ->
      if c is '<' then '&lt;' else '&amp;'
  quoteText: (str) ->
    str.replace /[&<"]/g, (c) ->              # "
      if c is '<' then '&lt;'
      else if c is '&'
      then '&amp;'
      else '&quot;'
  docType: (name = 'html')-> @printHtml "<!DOCTYPE #{name}>\n"
  # References:
  #  http://www.w3.org/TR/html5/syntax.html
  #  http://www.w3.org/TR/html-markup/elements.html
  voidElements: list2set 'area, base, br, col, command, embed, hr, img, input, keygen, link, meta, param, source, track, wbr'.split /, */
  # foreignElements: list2set 'math, svg'.split /, */
  rawTextElements: list2set [ 'script', 'style' ]
  allElements: """
a, abbr, address, area, article, aside, audio, b, base, bdi, bdo,
blockquote, body, br, button, button, button, button, canvas, caption,
cite, code, col, colgroup, command, command, command, command,
datalist, dd, del, details, dfn, div, dl, dt, em, embed, fieldset,
figcaption, figure, footer, form, h1, h2, h3, h4, h5, h6, head,
header, hgroup, hr, html, i, iframe, img, input, ins, kbd, keygen,
label, legend, li, link, map, mark, menu, meta, meta, meta, meta,
meta, meta, meter, nav, noscript, object, ol, optgroup, option,
output, p, param, pre, progress, q, rp, rt, ruby, s, samp, script,
section, select, small, source, span, strong, style, sub, summary,
sup, table, tbody, td, textarea, tfoot, th, thead, time, title, tr,
track, u, ul, var, video, wbr
""".match /[a-z0-9]+/g
  compileTag: (tagName, isVoid, isRawText) -> (args...) ->
    @printHtml "<#{tagName}"
    for arg in args
      if typeof arg is 'function'
        f = arg
        break
      if typeof arg is 'string'
        s = arg
        break
      for x,y of arg
        if y? and y isnt ""
          @printHtml " #{x}=\"#{@quoteText y}\""
        else
          @printHtml " #{x}"
    @printHtml '>'
    return if isVoid
    f.apply @     if f
    if s
      if isRawText
        @printHtml s
      else
        @printHtml @quoteTagText s
    @printHtml '</' + tagName + '>'
  compileLib: ->
    h = { }
    h[x] = @compileTag(x, ((@voidElements[x])?), ((@rawTextElements[x])?)) for x in @allElements
    @.extendObject h
  html5Page: (args...) ->
    @docType()
    @html.apply @, args

lib = lib.compileLib()

lib = lib.extendObject
  bareHtmlcup: lib
  libraryVersion: version
  cssStyle:    (x) -> @style type: 'text/css', x
  javaScript:  (x) -> @script type: "text/javascript", (x.replace("</", "<\/"))
  sassyStyle: (x)-> @cssStyle do->
    # A tiny Sass subset
    lines = x.split "\n"
    context = { }
    output = [ ]
    flush = ->
      if context.selector? and context.lines?
        output.push context.selector + " {\n  " + context.lines.join(";\n  ") + ";\n}\n"
      context.lines = null
    extend = (s, p)->
      return s unless p?
      if /,/.test(s)
         (extend(x,p) for x in s.split /, */).join ', '
      else if /,/.test p
        (extend(s,x) for x in p.split /, */).join ', '
      else
        if /[&]/.test s
          s.replace /[&]/g, p
        else
          "#{p} #{s}"
    for line in lines
      if parts = /^[ ]*([^ ][^:]*): +([^ ].*)/.exec line
        (context.lines ?= [ ]).push parts[1] + ": " + parts[2]
      else if parts = /^([ ]*)([^ ].*)/.exec line
        flush()
        level = parts[1].length
        if context.level?
          if context.level < level
            context = parent: context
          else while context.level and context.parent and level < context.level
            context = context.parent
        context.level = level
        context.selector = extend parts[2], context.parent?.selector
    flush()
    output.join ''
  coffeeScript: (x) ->
    isString = (x) -> typeof x is "string" or x instanceof String
    codeToString = (x) ->
      if isString x
        cs = require "coffee-script"
        cs.compile x
      else "(#{x.toString()})();\n"
    @javaScript codeToString(x)
  cssStyleSource:      (s) -> @style   type: "text/css",           src: s
  javaScriptSource:    (s) -> @script  type: "text/javascript",    src: s
  coffeeScriptSource:  (s) -> @script  type: "text/coffeescript",  src: s
  embedCoffeeScriptSource: (f) ->
    fs = require "fs"
    @coffeeScript (fs.readFileSync(f)).toString()
  embedJavaScriptSource: (f) ->
    fs = require "fs"
    @javaScript (fs.readFileSync(f)).toString()
  embedCssStyleSource: (f) ->
    fs = require "fs"
    @cssStyle (fs.readFileSync(f)).toString()
  embedScriptSource: (f) ->
    if /\.coffee$/.test(f)
      @embedCoffeeScriptSource f
    else
      @embedJavaScriptSource f
  embedFavicon: (f = "favicon.ico") ->
    fs = require "fs"
    icon = fs.readFileSync(f).toString('base64')
    icon = "data:image/x-icon;base64,#{icon}"
    @link rel:"shortcut icon", href:icon

(exports ? window).htmlcup = lib
