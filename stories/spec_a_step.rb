require File.dirname(__FILE__) + "/helper.rb"

with_steps_for :stepspecr do
  run File.dirname(__FILE__) + "/spec_a_step"
end