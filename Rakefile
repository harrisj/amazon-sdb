# -*- ruby -*-

require 'rubygems'
require 'hoe'
require './lib/amazon_sds.rb'

Hoe.new('amazon_sds', Amazon::SDS::VERSION) do |p|
  p.rubyforge_name = 'amazon_sds'
  p.author = 'Jacob Harris'
  p.email = 'harrisj@nytimes.com'
  p.summary = 'A ruby wrapper to Amazon\'s SDS service'
  # p.description = p.paragraphs_of('README.txt', 2..5).join("\n\n")
  # p.url = p.paragraphs_of('README.txt', 0).first.split(/\n/)[1..-1]
  p.changes = p.paragraphs_of('History.txt', 0..1).join("\n\n")
  p.extra_deps << ['hpricot', '>= 0.6']
end

# vim: syntax=Ruby
