require File.expand_path(File.dirname(__FILE__) + "/stepspecr_helper.rb")

describe "Given $count $models" do 
  it "should create the specified model" do
    StepSpecr.run do
      steps_for :example
      initial   "class SpecificModel;end; SpecificModel.should_receive(:create)"
      step      "Given 1 specific_model"
    end
  end
end

