amazon_sdb
by Jacob Harris
jharris@nytimes.com
http://open.nytimes.com/

== SOURCE CODE:

http://code.nytimes.com/svn/ruby/gems/amazon_sdb

== DESCRIPTION:
  
Amazon SDB is a Ruby wrapper to Amazon's new Simple Database Service. Amazon sdb is a different type of database:

* Accessed over the network via RESTful calls
* No schemas or types
* Each SimpleDB account can have up to 100 domains for data.
* Domains can hold objects referenced by unique keys
* Each object can hold up to 256 name/value attributes.
* Only name/value pairs must be unique in an objects attributes, there can be multiple name/value attributes with the same name.
* In addition to key-driven accessors, objects can also be searched with a basic query language.
* All value are stored as strings and comparisons use lexical order. Thus, it is necessary to pad integers and floats with 0s and save dates in ISO 8601 format for query comparisons to work

== FEATURES:
  
* A basic interface to Amazon SimpleDB
* Includes a class for representing attribute sets in SimpleDB
* Automatic conversion to/from SimpleDB representations for integers and dates (for floats, it's suggested you use the Multimap#numeric function)
* The beginnings of mock-based tests for methods derived from Amazon's docs

== CAVEATS

* Not all features are tested yet (sorry!)
* Amazon has not actually opened up access to the 2007-11-07 API on which this gem is based (and my tests are for). Some things may work differently in real life.
* Errors still need to be figured out / tested.
* I don't process the data usage/costs info from Amazon yet.

== FUTURE WORK:

* Some sort of fake SQL-esque query language
* Some sort of AR/Datamapper/Ambition connection layer fun (with schema overlays)

== SYNOPSIS:

  b = Amazon::SDB::Base.new(aws_public_key, aws_secret_key)
	b.domains #=> list of domain
	domain = b.create_domain 'my domain'
	
	m = Multimap.new {:first_name => "Jacob", :last_name => "Harris"}
	domain.put_attributes "Jacob Harris", m
	resultset = domain.query "['first_name' begins-with 'Harris']"

== REQUIREMENTS:

* An Amazon Web Services account
* hpricot

== INSTALL:

* sudo gem install amazon_sdb

== LICENSE:

(The MIT License)

Copyright (c) 2007 FIX

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
