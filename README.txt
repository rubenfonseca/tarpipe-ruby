= tarpipe

* http://tarpipe.rubyforge.org

== AUTHOR:

* Ruben Fonseca <root (at) cpan (dot) org>

== DESCRIPTION:

TarPipe - Ruby bridge to tarpipe.com's REST API

== FEATURES:

tarpipe is a publishing mediation and distribution platform that simplifies regular upload activities:

    * Publishing content to multiple Web locations;
    * Combining different media into a single blog post or article;
    * Transforming documents on-the-fly;
    * Managing repeatable upload actions.

== SYNOPSIS:

  require 'tarpipe'
  t = TarPipe.new(<workflow token>)
  puts t.upload("Title", "Body", foo.jpg)

== REQUIREMENTS:

* rspec >= 1.1.3
* shared-mime-info >= 0.1

== INSTALL:

* sudo gem install tarpipe

== LICENSE:

Copyright (c) 2008 Ruben Fonseca

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

