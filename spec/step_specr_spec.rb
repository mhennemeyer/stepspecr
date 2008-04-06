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
  end
  
  describe ".spec" do
    it "should run" do
      StepSpecr.spec "Given a step" do
      end
    end
  end
  
end