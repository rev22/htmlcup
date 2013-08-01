# Copyright (c) 2013 Michele Bini

# This program is free software: you can redistribute it and/or modify
# it under the terms of the version 3 of the GNU General Public License
# as published by the Free Software Foundation.

# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

title = "@htmlcup"

{ htmlcup } = require "./htmlcup"

argv = process.argv
args = argv[1..]
progname = argv[0]
stdout = process.stdout
stderr = process.stderr
write = (msg) -> stdout.write msg
echo = (msg) -> write "#{msg}\n"
warn = (msg) -> stderr.write "#{progname}: #{msg}\n"
exit = process.exit
die = (msg) -> warn msg; exit 1

{ readFileSync } = require 'fs'
isString = (f) -> typeof f is "string" or f instanceof String

testCode = readFileSync("./test/test.html.coffee")
testCode = testCode.toString() if testCode
die "No test code could be obtained!" unless testCode? and testCode and /./.test(testCode)
stripCode = (c) -> c.replace(/(\n|.)*\nhtmlcup[.]/, "htmlcup.")
testCode = stripCode testCode

# No actual minification at the moment, just print code
minify = (f) ->
  if isString f then f else "(#{f.toString()})();\n"

htmlcupOrig = htmlcup
htmlcup = htmlcup.extendObject
  cssStyle: (x) -> @style type: 'text/css', x
  javaScript: (s) ->
    @script type: "text/javascript", (s.replace("</", "<\/"))
  javaScriptSource: (s) ->
    @script type: "text/javascript", src: s
  #coffeeScriptSource: (s) ->
  #  @script type: "text/coffeescript", src: s
  coffeeScript: (f) ->
    @javaScript minify(f)

headCoffeeScript = ->
  # Display a 'Loading...' message when loading is taking long
  timeout = ->
    x = document.createElement "div"
    x.id = "loadmsg"
    x.innerHTML = "Loading... <a href=\"?\">Reload</a>"
    document.body.insertBefore x, document.body.firstChild
  window.htmlcupProtoLoadTimeout = setTimeout timeout, 2000


pageCoffeeScript = ->
  rmTag = (x) -> x.parentNode.removeChild(x)

  log = (x) -> console.log x

  delayUpdates = (minDelay, maxDelay) ->
    do (minTimeout = null, maxTimeout = null) -> (thunk) -> ->
      run = ->
        clearInterval minTimeout if minTimeout
        clearInterval maxTimeout if maxTimeout
        minTimeout = null
        maxTimeout = null
        thunk()
      clearInterval minTimeout if minTimeout
      minTimeout = setTimeout run, minDelay
      maxTimeout = setTimeout run, maxDelay unless maxTimeout

  jsload = (src, callback) ->
    log "Loading #{src}"
    x = document.createElement('script')
    x.type = 'text/javascript'
    x.src = src
    y = 1
    x.onload = x.onreadystatechange = () ->
      if y and not @readyState or @readyState is 'complete'
        log "Loaded #{src}"
        y = 0
        callback()
    document.getElementsByTagName('head')[0].appendChild x

  # Create a version of htmlcup that can be used in-browser
  htmlcup = htmlcup.extendObject
    originalLib: htmlcup
    capturedTokens: []
    printHtml: (t) -> @capturedTokens.push t
    captureHtml: (f) ->
      o = @capturedTokens
      @capturedTokens = []
      f.apply @
      p = @capturedTokens
      @capturedTokens = o
      r = p.join ""
      @printHtml r
      r

    stripOuter: (x) ->
      x.replace(/^<[^>]*>/, "").replace(/<[^>]*>$/, "")
    capturedParts: {}
    capturePart: (tagName, stripOuter = @stripOuter) -> ->
      x = arguments
      @capturedParts[tagName] =
        stripOuter (@captureHtml ->
          @originalLib[tagName].apply @, x
        )
    body: -> (@capturePart "body").apply @, arguments 
    head: ->
      lib = @.extendObject
        title: -> (@capturePart "title").apply @, arguments
        headStyles: []
        style: ->
          @headStyles.push (@capturePart "style").apply @, arguments
      r = (lib.capturePart "head").apply lib, arguments
      @capturedParts.headStyles = lib.headStyles
      @capturedParts.headTitle = lib.capturedParts.title
      r
    html5Page: () ->
      x = arguments
      @captureHtml -> @originalLib.html5Page.apply @, x
      r = @capturedParts
      @capturedParts = {}
      r

  sourcePane = document.getElementById("sourcepane")
  updateSource = (source) ->
    { body, headTitle, headStyles } = CoffeeScript.eval(source)
    innerDocument = window.frames[0].window.document
    innerDocument.title = headTitle
    rmTag x for x in innerDocument.head.getElementsByTagName "style"
    if headStyles
      for style in headStyles
        x = innerDocument.createElement "style"
        x.innerHTML = style
        innerDocument.getElementsByTagName("head")[0].appendChild x
    document.title = headTitle ? "@htmlcup"
    innerDocument.getElementsByTagName("body")[0].innerHTML = body
  update = (delayUpdates 300, 2000) () ->
    updateSource sourcePane.value
  sourcePane.onchange = update
  sourcePane.oninput = -> update(); false

  do update
      
  # Remove page loading message
  clearLoadTimeout = ->
    if (t = window.htmlcupProtoLoadTimeout)?
      window.clearTimeout t
    delete window.htmlcupProtoLoadTimeout
    rmTag t if t = document.getElementById "loadmsg"
  do clearLoadTimeout

  # Start the ace editor
  upgradeTextareas = (areas, callback) ->
    baseUrl = "http://ajaxorg.github.com/ace-builds/textarea/src/"

    areas = document.getElementsByClassName("aceTransform") unless areas
    areas = document.getElementsByTagName("textarea") unless areas
    return unless areas

    load = window.__ace_loader__ = (path, module, callback) ->
      jsload baseUrl + path, ->
        window.__ace_shadowed__.require [module], callback

    load "ace-bookmarklet.js", "ace/ext/textarea", ->
      ace = window.__ace_shadowed__
      ace.options =
        mode:             "coffee"
        theme:            "cobalt"
        gutter:           "true"
        fontSize:         "10px"
        softWrap:         "off"
        keybindings:      "ace"
        showPrintMargin:  "true"
        useSoftTabs:      "true"
        showInvisibles:   "false"

      Event = ace.require "ace/lib/event"
      
      transformed = []

      callback = (->) unless callback
                  
      for area in areas
        # Event.addListener area, "click", (e) ->
        callback area, ace.transformTextarea(area, load) #  if e.detail is 3

  upgradeTextareas null, (plain, ace) ->
    update = (delayUpdates 300, 2000) () ->
        updateSource (sourcePane.value = ace.getValue())
    log "Upgrading textarea"
    ace.on("change",  update)
    ace.on("blur",    update)
    ace.setTheme "ace/theme/cobalt"
    ace.getSession().setMode "ace/mode/coffee"
    

htmlcup.html5Page ->
  @head ->
    @title "#{title}"
    @coffeeScript headCoffeeScript
    @cssStyle """
      body, .fullpage, .reset { margin:0;padding:0;border:0 }
      .fullpage { width:100%; height:100%; }
      #sourcepaneCnt {
        opacity:0.22;
      }
      #sourcepaneCnt:hover {
        opacity:0.88;
      }
      .sourcepaneTextarea {
        width:100%;
        height:100%;
        background: black;
        color: white;
      }
      .invertBg {
        color: white;
        background: black;
      }
      .ribbonCnt {
        overflow: hidden;
        position: relative;
      }
      .ribbon, .ribbon a {
        background: #037;
        color: yellow;
        font-weight: bold;
        text-decoration: none;
      }
      .ribbon {
        text-align:center;
        transform: rotate(45deg);
        right: -60px;
        top: 30px;
        width: 200px;
        height: 20px;
        font-size: 16px;
        position: absolute;
        -webkit-transform:  rotate(45deg);
        -moz-transform:     rotate(45deg);
        -ms-transform:      rotate(45deg);
        -o-transform:       rotate(45deg);
        transform:          rotate(45deg);
        z-index: 1000000;
      }
      """
  @body ->
    @div class: "fullpage", ->
      @iframe class: "fullpage", style: "position:absolute"
      @div id:"sourcepaneCnt", class:"ribbonCnt", style: """
        width:70%;
        height:70%;
        top:15%;
        right:15%;
        position:absolute;
        z-index:100;
        """, ->
          @div class:"ribbon", ->
            @a
              href:"https://github.com/rev22/htmlcup",
              style:"font-family:monospace,fixed",
              title:"#{htmlcupOrig.libraryName} #{htmlcupOrig.libraryVersion}\nVisit homepage"
              "@htmlcup"
          @textarea id:"sourcepane", class:"reset sourcepaneTextarea aceTransform", testCode
        # """
        # htmlcup.html5Page ->
        #   @head ->
        #     @title 'My sweet test page'
        #     @style type: 'text/css', \"body { background:pink }\"
        #   @body ->
        #     @p 'Cupcake ipsum dolor. Sit amet I love sugar plum.'
        #     # And now a list of yummies
        #     @ol ->
        #       @li \"Sweet jelly fruitcake\"
        #       @li ->
        #         @a href: 'http://recipe.com/marzipan', 'Marzipan'
        #     @h2 \"Loops: print cubes of numbers from 1 to 100\"
        #     @span \"#{x*x*x} \" for x in [1..100]
        #     """
    @javaScriptSource "http://js2coffee.org/scripts/coffeescript.min.js"
    @javaScriptSource "htmlcup.js"
    @coffeeScript pageCoffeeScript
