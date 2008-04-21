steps_for :stepspecr do
  
  Given "trivial failing step" do
    false.should be_true
  end

  Given "trivial passing step" do
    true.should be_true
  end
  
  Given "nontrivial passing step" do
    SpecificModel.create
  end
  
  Given "step '$step'" do |step|
    @step = step
  end
  
  When "I add before-expectation: $expectation" do |expectation|
    StepSpecr.configure do
      before do
        eval "expectation"
      end
    end
  end
  
  When "I add step group $step_group" do |group|
    StepSpecr.configure do
      step_group group.to_sym
    end
  end
  
  Then "it should fail" do
    lambda {
      StepSpecr.spec @step do
      end
    }.should raise_error
  end
  
  Then "it should pass" do
    puts @step.class
    puts StepSpecr.step_group_name
    lambda {
      StepSpecr.spec @step do
      end
    }.should_not raise_error
  end
  
end