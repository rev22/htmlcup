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

{ htmlcup } = require './htmlcup'

title = "Test page for htmlcup library"
version = "0.1.3"

htmlcup.html5Page ->
  @head ->
    @title title
    @style type: "text/css",
      """
      body { background:#ddd }
      """
  @body ->
    @p 'Cupcake ipsum dolor. Sit amet I love sugar plum. Tart lollipop topping sugar plum jujubes. Gummi bears marzipan liquorice sweet roll jelly-o applicake topping. Marzipan jelly-o wafer I love gummies marzipan I love fruitcake. Caramels candy canes jelly beans. Sugar plum sesame snaps chupa chups sweet roll. Ice cream candy canes cupcake bonbon wafer. Pastry cotton candy I love. Jujubes pudding jelly beans gummies. Gummies marzipan fruitcake fruitcake pie sweet roll. Sweet jelly fruitcake.'
