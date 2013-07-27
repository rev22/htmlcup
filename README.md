htmlcup
=======

A htmlcup is an HTML5 code generator.

Usage is quite intuitive, if you already use CoffeeScript and know HTML:

````coffeescript
{ htmlcup } = require './htmlcup'

htmlcup.html5Page ->
  @head ->
    @title 'My sweet test page'
    @style type: 'text/css', """
body { background:pink }
"""
  @body ->
    @p 'Cupcake ipsum dolor. Sit amet I love sugar plum.'
````

This is similar in purpose to a templating engine, but more powerful as you have a full programming language in your hands, CoffeeScript.
