require 'rubygems'
require 'spec'
require 'spec/mocks'
require 'spec/story'

step_dir = "stories/steps"

dir = File.dirname(__FILE__)

Dir[File.expand_path("#{dir}/../../#{step_dir}/*.rb")].uniq.each do |file|
  require file
end

module Spec
  module Matchers
    def fail
      raise_error(Spec::Expectations::ExpectationNotMetError)
    end

    def fail_with(message)
      raise_error(Spec::Expectations::ExpectationNotMetError, message)
    end
  end
end



