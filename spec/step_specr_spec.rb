require File.dirname(__FILE__) + '/stepspecr_helper'


describe StepSpecr do
  
  describe ".configure" do
 
    it "should set the before-expectation" do
      block = lambda { true }
      StepSpecr.configure do
        before(&block)
      end
      StepSpecr.before_expectation.should == block
    end
    
    it "should set the step group name" do
      StepSpecr.configure do
        steps_for :step_group_name
      end
      StepSpecr.step_group.should == :step_group_name
    end
  end
  
  describe ".spec 'step' {} " do
    it "should fail if step is not implemented" do
      lambda do
        StepSpecr.spec "Given a step" do
        end
      end.should raise_error
    end
    
    it "should fail if step is 'trivial failing'" do
      lambda do
        StepSpecr.spec "Given trivial failing step" do
        end
      end.should raise_error
    end

    it "should pass if step is 'trivial passing'" do
      lambda do
        StepSpecr.spec "Given trivial passing step" do
        end
      end.should_not raise_error
    end

  end
end