# -*- ruby -*-

require 'rubygems'
require 'hoe'
require './lib/amazon_sdb.rb'
require 'rcov/rcovtask'
Hoe.new('amazon_sdb', Amazon::SDB::VERSION) do |p|
  p.rubyforge_name = 'nytimes'
  p.author = 'Jacob Harris'
  p.email = 'harrisj@nytimes.com'
  p.summary = 'A ruby wrapper to Amazon\'s sdb service'
  p.description = 'A ruby wrapper to Amazon\'s sdb service'
  p.url = "http://nytimes.rubyforge.org/amazon_sdb"
  p.changes = p.paragraphs_of('History.txt', 0..1).join("\n\n")
  p.extra_deps << ['hpricot', '>= 0.6']
end

Rcov::RcovTask.new do |t|
  t.test_files = FileList['test/test*.rb']
  t.rcov_opts << "-Ilib:test"
  t.verbose = true     # uncomment to see the executed command
end
# vim: syntax=Ruby
