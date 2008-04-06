steps_for :stepspecr do
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
  
  When "I add step group $step_group" do |step_group|
    StepSpecr.configure do
      steps_for step_group.to_sym
    end
  end
  
  Then "it should fail with '$message'" do |msg|
    lambda {
      StepSpecr.spec @step do
      end
    }.should raise_error(msg)
  end
  
end