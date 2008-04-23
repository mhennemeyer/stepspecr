require File.dirname(__FILE__) + '/stepspecr_helper'


describe StepEval do
  
  it "should run a step in the example context" do
    @number = 1
    step_eval "Given a step that sets @number to 2", :spec
    @number.should == 2
  end
  
end