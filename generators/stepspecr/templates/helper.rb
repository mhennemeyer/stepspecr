step_dir = "stories/steps"

dir = File.dirname(__FILE__)

require File.expand_path("#{dir}/../../spec/spec_helper.rb"

require 'spec'
require 'spec/mocks'
require 'spec/story'
require 'stepspecr'


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



