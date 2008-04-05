          require File.dirname(__FILE__) + "/../stepspecr_helper.rb"

          steps_for(:_spec_steps_) do
            Given("_initial_state_") do
              'initial state'
            end
            Then("_spec_step_") do
              false.should be_true
            end
          end
      
          with_steps_for(:step_specr_step,:_spec_steps_) do
            run("/Users/iMac/Projekte/stephelper/spec/temp//story", :type => RailsStory)
          end
