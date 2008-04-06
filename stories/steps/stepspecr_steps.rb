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
  
  Then "it should fail" do 
    lambda {
      StepSpecr.spec @step do
      end
    }.should raise_error("Not yet implemented")
  end
  
end