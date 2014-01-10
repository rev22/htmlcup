{ htmlcup } = require '../htmlcup'

htmlcup.html5Page ->
  @head ->
    @title "htmlcup, caffeinated HTML"
    @cssStyle "body { background:cyan; font-size:18px; }"
  @body ->
    @h2 "@htmlcup - Generate HTML5 with CoffeeScript"
    @p "htmlcup has CoffeeScript's convenience and power, and is readily extensible"
    @h4 "Find more about:"
    @ul ->
      @li -> @a href:'http://github.com/rev22/htmlcup',  "htmlcup"
      @li -> @a href:'http://coffeescript.org',          "CoffeeScript"
    @h4 "Loops: print cubes of numbers from 1 to 10"
    @span title:"Cube of #{x}", "#{x*x*x} " for x in [1..10]
    @h4 "Scripting: simple clock"
    @p id:"clock"
    @coffeeScript ->
      updateClock = do (c = 0) -> ->
        document.getElementById("clock").innerHTML =
          "#{("｜／－＼")[c=(c+1)%4]} #{new Date}"
      setInterval updateClock, 125
