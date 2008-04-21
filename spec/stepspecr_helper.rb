require 'rubygems'
require 'spec'
require 'spec/mocks'
require 'spec/story'

dir = File.dirname(__FILE__)

require File.expand_path("#{dir}/steps.rb")

Dir[File.expand_path("#{dir}/../lib/*.rb")].uniq.each do |file|
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



