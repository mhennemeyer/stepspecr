require File.dirname(__FILE__) + '/stepspecr_helper'


describe StepSpecr do
  
  describe ".configure" do
 
    it "should set the before-expectation" do
      block = lambda { true }
      before_step = Spec::Story::Step.new("before",&block)
      Spec::Story::Step.should_receive(:new).and_return before_step
      StepSpecr.configure do
        before(&block)
      end
      StepSpecr.before_expectation.should === before_step
    end
    
    it "should set the after-expectation" do
      block = lambda { true }
      after_step = Spec::Story::Step.new("after",&block)
      Spec::Story::Step.should_receive(:new).and_return after_step
      StepSpecr.configure do
        after(&block)
      end
      StepSpecr.after_expectation.should === after_step
    end
    
    it "should set the step group name" do
      StepSpecr.configure do
        step_group :step_group_name
      end
      StepSpecr.step_group_name.should == :step_group_name
    end
  end
  
  describe ".stepgroup"do
    it "should find the steps in step_group" do
      StepSpecr.configure do
        step_group :spec
      end
      StepSpecr.stepgroup.find(:given, "trivial failing step").should_not be_nil
      StepSpecr.stepgroup.find(:given, "trivial passing step").should_not be_nil
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
    
    it "should pass if step is 'nontrivial passing'" do
      lambda do
        StepSpecr.spec "Given nontrivial passing step" do
          step_group :spec
          before do
            class SpecificModel 
            end 
            SpecificModel.should_receive(:create)
          end
        end
      end.should_not raise_error
    end
    
    it "should pass if step is 'nontrivial failing'" do
      lambda do
        StepSpecr.spec "Given nontrivial passing step" do
          step_group :spec
          before do
            class SpecificModel 
            end 
            SpecificModel.should_receive(:never_called)
          end
        end
      end.should raise_error
    end

  end
end