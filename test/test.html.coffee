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

# This test file is additionally available with a MIT-style license.
# Please consult the MIT-LICENSE file in this directory.

{ htmlcup } = require '../htmlcup'

title = "Test page for htmlcup library"
version = "0.2.3"

htmlcup.html5Page ->
  @head ->
    @title "My sweet page"
    @style type: "text/css",
      """
      body { background:pink }
      """
  @body ->
    @p 'Cupcake ipsum dolor. Sit amet I love sugar plum.'
    # And now a list
    @ol ->
      @li "Sweet jelly fruitcake"
      @li ->
        @a href: 'http://recipe.com/marzipan', 'Marzipan'
    @h2 "Loops: print cubes of numbers from 1 to 150"
    @span "#{x*x*x}" for x in [1..150]
