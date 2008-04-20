require 'rubygems'
require 'spec'
require 'spec/story'

dir = File.dirname(__FILE__)

require File.expand_path("#{dir}/../spec/steps.rb")

["#{dir}/steps/*.rb", "#{dir}/../lib/*.rb"].each do |p|
  Dir[File.expand_path(p)].uniq.each do |file|
    require file
  end
end

