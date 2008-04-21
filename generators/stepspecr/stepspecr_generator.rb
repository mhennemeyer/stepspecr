require 'rbconfig'

# This generator bootstraps a Rails project for use with StepSpecr
class StepSpecrGenerator < Rails::Generator::Base

  def initialize(runtime_args, runtime_options = {})
    super
  end

  def manifest
    record do |m|
      m.directory 'spec/steps'
      m.file      'helper.rb'                      'spec/steps/stepspecr_helper.rb'
      m.file      'example_steps.rb'               'spec/steps/example_steps.rb'
      m.file      'example_step_spec.rb'           'spec/steps/example_step_spec.rb'
    
    end
  end

protected

  def banner
    "Usage: #{$0} stepspecr"
  end

end
