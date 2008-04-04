require 'rbconfig'

# This generator bootstraps a Rails/Rspec project for use with stephelper
class StephelperGenerator < Rails::Generator::Base
  DEFAULT_SHEBANG = File.join(Config::CONFIG['bindir'],
                              Config::CONFIG['ruby_install_name'])

  def initialize(runtime_args, runtime_options = {})
    super
  end

  def manifest
    record do |m|

      m.directory 'spec/steps'
      m.file      'stories_helper.rb',             'stories/spec/step_spec_helper.rb'
      
      m.directory 'spec/steps/temp'
      m.file      'story'
      m.file      'story.rb'
      
    end
  end

protected

  def banner
    "Usage: #{$0} stephelper"
  end

end
