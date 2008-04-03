require 'rubygems'
require 'spec'
require 'spec/mocks'
require 'spec/story'
require 'spec/rails/story_adapter'

dir = File.dirname(__FILE__)
Dir[File.expand_path("#{dir}/../lib/*.rb")].uniq.each do |file|
  require file
end

require File.expand_path(File.dirname(__FILE__) + "/temp/step_speccer_spec_step.rb")

