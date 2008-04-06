require 'rubygems'
require 'spec'
require 'spec/mocks'
require 'spec/story'


dir = File.dirname(__FILE__)
Dir[File.expand_path("#{dir}/../lib/*.rb")].uniq.each do |file|
  require file
end