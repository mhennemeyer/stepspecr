dir = File.dirname(__FILE__)
require File.expand_path(dir +  '/../spec_helper.rb')
require File.expand_path(dir +  '/../../stories/helper.rb')

StepSpecr.setup do
  path File.expand_path(dir +  '/temp/')
end

Dir[File.expand_path("#{dir}/../../stories/steps/*.rb")].uniq.each do |file|
  require file
end

# This is for the example_step

require File.expand_path(dir +  '/temp/example_step.rb')