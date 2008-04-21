require 'rubygems'
require 'spec'
require 'spec/story'

dir = File.dirname(__FILE__)

#require File.expand_path("#{dir}/../spec/stepspecr_helper.rb")

["#{dir}/steps/*.rb", "#{dir}/../lib/*.rb"].each do |p|
  Dir[File.expand_path(p)].uniq.each do |file|
    require file
  end
end

