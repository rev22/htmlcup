htmlcup
=======

```htmlcup``` is an HTML5 code generator.

Usage is intuitive, if you already use CoffeeScript and know HTML:

````coffeescript
htmlcup.html5Page ->
  @head ->
    @title 'My sweet test page'
    @style type: 'text/css',
      """
      body { background:pink }
      """
  @body ->
    @p 'Cupcake ipsum dolor. Sit amet I love sugar plum.'
    # And now a list of yummies
    @ol ->
      @li "Sweet jelly fruitcake"
      @li ->
        @a href: 'http://recipe.com/marzipan', 'Marzipan'
````

This is similar in purpose to a templating engine, but with the full power of a programming language in your hands, CoffeeScript.

You can try ```htmlcup``` here: http://rev22.github.io/htmlcup

Extending the library
=====================

```htmlcup``` is easily extensible through a reflective programming technique:

````coffeescript
# Convert a list of lines into an html list
htmlcup = htmlcup.extendObject
  numberLines: (s) ->
    @ol ->
      @li x for x in s.split /\n/
````

This extension could be used like:

````coffeescript
htmlcup.html5Page ->
  @head -> @title "A numbered list of sweets"
  @body ->
    @p "These are my favorite sweets: "
    @numberLines """
      chocolate
      liquorice
      fruitcake
      """
````

Licensing and copyright
=======================

Copyright (c) 2013 Michele Bini

The library is available under the terms of version 3 of the General Public License, which you can read in the file ```COPYING```

The contents of the files in the ```test/``` directory are additionally available with a permissive MIT-style license, which you can read in ```test/MIT-LICENSE```

The contents of the ```vendor/``` directory are separately licensed.
