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

isString = (f) -> typeof f is "string" or f instanceof String

# No actual minification at the moment, just print code
minify = (f) ->
  if isString f then f else "(#{f.toString()})();\n"

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

htmlcup.html5Page ->
  @head ->
    @title "Loading: #{title}"
    @coffeeScript ->
      # Display a 'Loading...' message when loading is taking long
      timeout = ->
        x = document.createElement "div"
        x.id = "loadmsg"
        x.innerHTML = "Loading... <a href=\"?\">Reload</a>"
        document.body.insertBefore x, document.body.firstChild
      window.htmlcupProtoLoadTimeout = setTimeout timeout, 2000
    @cssStyle """
      body, .fullpage, .reset { margin:0;padding:0;border:0 }
      .fullpage { width:100%; height:100%; }
      #sourcepane {
        opacity:0.2;
      }
      #sourcepane:hover {
        opacity:0.8;
      }
      """
  @body ->
    @div class: "fullpage", ->
      @iframe class: "fullpage", style: "position:absolute"
      @textarea id:"sourcepane", style: """
        width:60%;
        height:60%;
        top:20%;
        left:20%;
        position:absolute;
        z-index:1000000;
        """, """
        htmlcup.html5Page ->
          @head ->
            @title 'My sweet test page'
            @style type: 'text/css', \"body { background:pink }\"
          @body ->
            @p 'Cupcake ipsum dolor. Sit amet I love sugar plum.'
            # And now a list of yummies
            @ol ->
              @li \"Sweet jelly fruitcake\"
              @li ->
                @a href: 'http://recipe.com/marzipan', 'Marzipan'
        """
    @javaScriptSource "http://js2coffee.org/scripts/coffeescript.min.js"
    @javaScriptSource "htmlcup.js"
    @coffeeScript ->
      rmTag = (x) -> x.parentNode.removeChild(x)

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
          x.replace(/^<[^>]*>/, "").replace(/^<[^>]*>$/, "")
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
      update = ->
        { body, headTitle, headStyles } = CoffeeScript.eval(sourcePane.value)
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
      sourcePane.onchange = update
      sourcePane.onkeyup = -> update(); false

      do update
      
      # Remove page loading message
      clearLoadTimeout = ->
        if (t = window.htmlcupProtoLoadTimeout)?
          window.clearTimeout t
        delete window.htmlcupProtoLoadTimeout
        rmTag t if t = document.getElementById "loadmsg"
      do clearLoadTimeout

