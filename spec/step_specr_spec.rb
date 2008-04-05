require File.dirname(__FILE__) + '/stepspecr_helper'


describe StepSpecr do
  
  before(:all) do
    dir = File.dirname(__FILE__)
    @path = File.expand_path(dir) + "/temp/"
    @steps = [:step_specr_step]
  end
  
  
  describe "state" do
    it "should maintain the path to the directory with the temporary files: story, story.rb and step_specr_spec_step.rb" do
      StepSpecr.send(:path_to_temp=, "/path")
      StepSpecr.path_to_temp.should == "/path"
    end
    
    it "should maintain an array of step_group names" do
      StepSpecr.send(:step_group_names=, [:api])
      StepSpecr.step_group_names.should == [:api]
    end
    
    it "should maintain the 'Given initial_state' step" do
      StepSpecr.send(:initial_state=, "@x = 'y'")
      StepSpecr.initial_state.should == "@x = 'y'"
    end
    
    it "should maintain the 'Then spec_step step'" do
      StepSpecr.send(:spec_step=, "true.should be_true")
      StepSpecr.spec_step.should == "true.should be_true"
    end
    
    it "should maintain the name of the 'Step To Be Specd'" do
      StepSpecr.send(:step_to_be_specd=, "Given name")
      StepSpecr.step_to_be_specd.should == "Given name"
    end
    
    it "should maintain the path to the required_file (spec_helper.rb)" do
      StepSpecr.send(:required_file=, "spec_helper.rb")
      StepSpecr.required_file.should == "spec_helper.rb"
    end
    
    it "should maintain the show_runner_output predicate" do
      StepSpecr.send(:show_runner_output=, true)
      StepSpecr.show_runner_output.should == true
    end
    
    describe "defaults" do
      
      before(:each) do
        ## 
        # Reload the class definition to have fresh defaults.
        reload_stepspecr
      end
      
      it "path_to_temp = steps/temp/" do
        StepSpecr.path_to_temp.should == "steps/temp/"
      end
      
      it "step_group_names = [:step_specr_step]" do
        StepSpecr.step_group_names.should == [:step_specr_step]
      end
      
      it "initial_state = 'initial_state'" do
        StepSpecr.initial_state.should == "'initial state'"
      end
      
      it "step_to_be_specd = 'Then the step to be specd'" do
        StepSpecr.step_to_be_specd.should == "Then the step to be specd"
      end
      
      it "required_file = '../stepspecr_helper.rb'" do
        StepSpecr.required_file.should == '../stepspecr_helper.rb'
      end
      
      it "show_runner_output = false" do
        StepSpecr.show_runner_output.should == false
      end
      
    end
  end


  describe ".runner_output" do
    
    before(:each) do
      @story = <<-END 
        Story: This Story Provides the Context to Spec a Step

         As a Developer
         I want to have generic steps
         So that I can use them in my Stories

          Scenario: These Steps will be executed so that we can see if they work as we want

           Given initial

        END

      File.open("#{@path}story","w") do |file|
        file.puts @story
      end
      @run = <<-END 
        require 'rubygems'
        require 'spec/story'    

        steps_for :steps do
          Given "initial" do
          end
        end

        with_steps_for :steps  do
          run "#{@path}story"
        end
      END

      File.open("#{@path}story.rb","w") do |file|
        file.puts @run
      end
    end
    
    it "should run a story file with the ruby command as a subprocess and return the output" do
      io = Object.new
      io.stub!(:readlines).and_return(["Out"])
      IO.should_receive(:popen).and_return(io)
      StepSpecr.send(:runner_output).should =~ /Out/
    end
    
    it "'full stack' - with real story file" do
      StepSpecr.send(:path_to_temp=, @path)
      StepSpecr.send(:runner_output).should =~ /Running/
    end
  end
  
  describe ".parsed(runner_output) {|summary,pending,failures| ... }" do
      
      before(:all) do
        @runner_output = <<-END
          Running 1 scenarios
  
          Story: This Story Provides the Context to Spec a Step
  
            As a Developer
            I want to have generic steps
            So that I can use them in my Stories
  
            Scenario: These Steps will be executed so that we can see if they work as we want
  
              Given initial 
              When failing (FAILED)
              And pending (PENDING)
  
          1 scenarios: 0 succeeded, 1 failed, 0 pending
  
          Pending Steps:
          1) This Story Provides the Context to Spec a Step (These Steps will be executed so that we can see if they work as we want): pending
  
          FAILURES:
          1) This Story Provides the Context to Spec a Step (These Steps will be executed so that we can see if they work as we want) FAILED
          Spec::Expectations::ExpectationNotMetError: expected true, got false
          method initial in test_with_steps.rb at line 13
          /Users/Matthias/Projects/StepSpecr/test_with_steps.rb:35
          2) failing FAILED
        END
  
      end
      
      it "should find the summary and parse succeeded scenarios" do
        StepSpecr.send(:parsed, @runner_output) do |summary,pendings,failures|
          summary[:succeed].should == 0
        end
      end
      
      it "should find the summary and parse pending scenarios" do
        StepSpecr.send(:parsed, @runner_output) do |summary,pendings,failures|
          summary[:pending].should == 0
        end
      end
      
      it "should find the summary and parse failed scenarios" do
        StepSpecr.send(:parsed, @runner_output) do |summary,pendings,failures|
          summary[:failures].should == 1
        end
      end
      
      it "should find pending steps" do
        StepSpecr.send(:parsed, @runner_output) do |summary,pendings,failures|
          pendings.should =~ /Pending\s*Steps:\s*1\)\s*/x
        end
      end
      
      it "should find failure message" do
        StepSpecr.send(:parsed, @runner_output) do |summary,pendings,failures|
          failures.should =~ /FAILURES:\s*1\)\s*/x
        end
      end
    end
    
    describe ".generate_story_file" do
      
      before(:each) do
        StepSpecr.send(:path_to_temp=, @path)
      end
      
      it "should generate a plain text story file" do
        StepSpecr.send(:generate_story_file)
        
        File.open(@path + "story","r") do |f|
          f.readlines.to_s.should =~ /Story: /
        end
      end
      
      it "should write 'Given _initial_state_' as the first step" do
        StepSpecr.send(:generate_story_file)
        
        File.open(@path + "story","r") do |f|
          f.readlines.to_s.should =~ /Scenario: StepSpecr Scenario\s*Given _initial_state_/
        end
      end
      
      it "should write the step to be specd as the second step" do
        StepSpecr.send(:generate_story_file)
        
        File.open(@path + "story","r") do |f|
          f.readlines.to_s.should =~ /Given _initial_state_\s*Then the step to be specd/
        end
      end
      
      it "should write 'Then _spec_step_' as the last step" do
         StepSpecr.send(:generate_story_file)
  
         File.open(@path + "story","r") do |f|
           f.readlines.to_s.should =~ /Then _spec_step_\s*\z/
         end
       end
       
    end
    
    describe ".generate_steps_for_and_run_file" do
      
      it "should generate a runnable file" do
        StepSpecr.send(:generate_steps_for_and_run_file)
        
        File.open(@path + "story.rb","r") do |f|
          f.readlines.to_s.should =~ /with_steps_for\(:#{@steps.join(",:")},:_spec_steps_\).*do.*run\(.*\).*end/m
        end
      end
      
      it "should define step_group_names" do
        StepSpecr.send(:generate_steps_for_and_run_file)
        
        File.open(@path + "story.rb","r") do |f|
          f.readlines.to_s.should =~ /steps_for\(:_spec_steps_\)\s*do.*end/m
        end
      end
      
      it "should set initial state" do
        StepSpecr.send(:generate_steps_for_and_run_file)
        
        File.open(@path + "story.rb","r") do |f|
          f.readlines.to_s.should =~ /Given\("_initial_state_"\)\s*do\s*'initial\sstate'\s*end/
        end
      end
      
      it "should set spec step" do
        StepSpecr.send(:generate_steps_for_and_run_file)
        
        File.open(@path + "story.rb","r") do |f|
          f.readlines.to_s.should =~ /Then\(.*_spec_step_.*\)\s*do\s*'spec\sstep'\s*end/
        end
      end
      
      it "should set the require for the spec_helper" do
        StepSpecr.send(:generate_steps_for_and_run_file)
              
        File.open(@path + "story.rb","r") do |f|
          f.readlines.to_s.should =~ %r{require \s* File\.dirname\(__FILE__\)}x
        end
      end
    end
    
    describe ".do_run" do

          it "should generate a story file" do
            StepSpecr.send(:do_run)
            
            File.open(@path + "story","r") do |f|
              f.readlines.to_s.should =~ /Story: StepSpecr Story/
            end
          end
          
          it "should write the step to be specified in the story file" do
            StepSpecr.send(:do_run)
            
            File.open(@path + "story","r") do |f|
              f.readlines.to_s.should =~ /Then\sthe\sstep\sto\sbe\sspecd/
            end
          end
          
          it "should generate a story.rb file" do
            StepSpecr.send(:do_run)
            
            File.open(@path + "story.rb","r") do |f|
              f.readlines.to_s.should =~ /with_steps_for\(:#{@steps.join(",:")},:_spec_steps_\)/
            end
          end
          
          it "should set initial state" do
            StepSpecr.send(:do_run)
            
            File.open(@path + "story.rb","r") do |f|
              f.readlines.to_s.should =~ /Given\("_initial_state_"\)\s*do\s*'initial state'\s*end/
            end
          end
          
          it "should set spec step" do
            StepSpecr.send(:do_run)
            
            File.open(@path + "story.rb","r") do |f|
              f.readlines.to_s.should =~ /Then\("_spec_step_"\)\s*do\s*'spec\sstep'\s*end/
            end
          end
          
          it "should run the story and expect no failures (passing spec_steps)" do
            lambda do
              StepSpecr.send(:do_run)
            end.should_not raise_error
          end
          
          it "should run the story and expect failures (failing spec_step)" do
            StepSpecr.send(:spec_step=, "false.should be_true")
            lambda do
              StepSpecr.send(:do_run)
            end.should raise_error
          end
          
          describe "failure messages" do
            before(:all) do
              @output = <<-END
                Running 1 scenarios

                Story: This Story Provides the Context to Spec a Step

                  As a Developer
                  I want to have generic steps
                  So that I can use them in my Stories

                  Scenario: These Steps will be executed so that we can see if they work as we want

                    Given initial 
                    When failing (FAILED)
                    And pending (PENDING)

                1 scenarios: 0 succeeded, 1 failed, 0 pending

                Pending Steps:
                1) This Story Provides the Context to Spec a Step (These Steps will be executed so that we can see if they work as we want): pending

                FAILURES:
                1) This Story Provides the Context to Spec a Step (These Steps will be executed so that we can see if they work as we want) FAILED
                Spec::Expectations::ExpectationNotMetError: expected true, got false
                method initial in test_with_steps.rb at line 13
                /Users/Matthias/Projects/StepSpecr/test_with_steps.rb:35
                2) failing FAILED
              END
            end
            
            before(:each) do
              StepSpecr.stub!(:generate_story_file)
              StepSpecr.stub!(:generate_steps_for_and_run_file)
              StepSpecr.stub!(:runner_output).and_return @output
            end
            
            it "should provide the storyrunner failure message on failing step" do
              lambda do
                StepSpecr.send(:do_run)
              end.should raise_error(StandardError, 
                  /FAILED\s*Spec::Expectations::ExpectationNotMetError:\s*expected\s*true,\s*got\s*false/x)
            end
          end
          
          describe "pending messages" do
            before(:all) do
              @output = <<-END
                Running 1 scenarios

                Story: This Story Provides the Context to Spec a Step

                  As a Developer
                  I want to have generic steps
                  So that I can use them in my Stories

                  Scenario: These Steps will be executed so that we can see if they work as we want

                    Given initial 
                    When not yet implemented (PENDING)
                    

                1 scenarios: 0 succeeded, 0 failed, 1 pending

                Pending Steps:
                1) not yet implemented: pending
              END
            end
            
            before(:each) do
              StepSpecr.stub!(:generate_story_file)
              StepSpecr.stub!(:generate_steps_for_and_run_file)
              StepSpecr.stub!(:runner_output).and_return @output
            end
          
            it "should provide a 'not yet impl.' message if a step is pending" do
              lambda do
                StepSpecr.send(:do_run)
              end.should raise_error(StandardError, 
                  /Not\s*yet\s*implemented\s*or\s*not\s*found:\s*Pending\s*Steps:\s*1\)\s*not\s*yet\s*implemented:\s*pending/x)
                   
            end
          end
        end
    
    describe ".setup" do
      
      it "should evaluate the associated block in class context" do
        block = lambda { say "Hello?" }
        StepSpecr.should_receive(:say).with("Hello?")
        StepSpecr.setup(&block)
      end
      
      describe "{ path '/brandnew/temp_path' }" do
        it "should set path_to_temp to '/brandnew/temp_path'" do
          StepSpecr.setup do
            path "/brandnew/temp_path"
          end
          StepSpecr.path_to_temp.should == '/brandnew/temp_path'
        end
      end
      
      describe "{ initial '@x = 1' }" do
        it "should set initial_state to '@x = 1'" do
          StepSpecr.setup do
            initial '@x = 1'
          end
          StepSpecr.initial_state.should == '@x = 1'
        end
      end
      
      describe "{ spec '@x.should be(1)' }" do
        it "should set spec_step to '@x.should be(1)'" do
          StepSpecr.setup do
            spec '@x.should be(1)'
          end
          StepSpecr.spec_step.should == '@x.should be(1)'
        end
      end
      
      describe "{ steps_for :api }" do
        it "should append :api to step_group_names" do
          StepSpecr.send(:step_group_names=, [:steps])
          StepSpecr.setup do
            steps_for :api
          end
          StepSpecr.step_group_names.should == [:steps, :api]
        end
      end
      
      describe "{ steps_for :api, :resource }" do
        it "should append :api and :resource to step_group_names" do
          StepSpecr.send(:step_group_names=, [:steps])
          StepSpecr.setup do
            steps_for :api, :resource
          end
          StepSpecr.step_group_names.should == [:steps, :api, :resource]
        end
      end
      
      describe "{ step 'When some event' }" do
        it "should set step_to_be_specd to 'When some event'" do
          StepSpecr.setup do
            step 'When some event'
          end
          StepSpecr.step_to_be_specd.should == 'When some event'
        end
      end
      
      describe "{ required 'spec_helper.rb' }" do
        it "should set required_file to 'spec_helper.rb'" do
          StepSpecr.setup do
            required 'spec_helper.rb'
          end
          StepSpecr.required_file.should == 'spec_helper.rb'
        end
      end
      
      describe "{ show_output true }" do
        it "should set show_runner_output to true" do
          StepSpecr.setup do
            show_output true
          end
          StepSpecr.show_runner_output.should == true
        end
      end
      
    end
    
    describe ".run" do
      
      before(:all) do
        reload_stepspecr
      end
      
      it "should (first) evaluate the associated block in class context" do
        block = lambda { say "Hello?" }
        StepSpecr.stub!(:do_run)
        StepSpecr.should_receive(:say).with("Hello?")
        StepSpecr.run(&block)
      end
      
      it "and then run the story" do
        StepSpecr.should_receive(:do_run)
        StepSpecr.run
      end
    end
  
end