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

# This file is released with a MIT-style license.
# Please read MIT-LICENSE in this directory.

{ htmlcup } = require '../htmlcup'

htmlcup = htmlcup.extendObject
  numberLines: (s) ->
    @ol ->
      @li x for x in s.split /\n/

htmlcup.html5Page ->
  @head -> @title "A numbered list of sweets"
  @body ->
    @p "These are my favorite sweets: "
    @numberLines """
      chocolate
      liquorice
      fruitcake
      """
