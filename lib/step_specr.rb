# StepSpecr provides a 'testing' framework for speccing Given/When/Then steps 
# within Rspec examples. This lets you implement GWT-steps the BDD way.
#
#   describe "Given $count articles" do
#     it "should create 5 articles for count=5" do
#       StepSpecr.run do
#         steps_for :articles
#         step "Given 5 articles"
#         spec "Article.count.should >= 5"
#       end
#     end
#   end          
#      
#          
# * StepSpecr.setup {  } lets you configure the runner and will not run the story.
#   This is likely to be done in a before block.
# * StepSpecr.run {  } lets you run the story and provides the same configuration facility as 
#   StepSpecr.setup so you can configure the whole thing in before block and 
#   then making subsequent changes to the configuration in each example.
#   (It's likely that you will change the spec-step-implementation in each example.)
# 
# These are the configuration options with their defaults: (Just call the methods in the blocks associated with 
# the calls to .run or .setup)
#
# * required    "../stepspecr_helper.rb"
# * path        "steps/temp/"
# * steps_for   :step_specr_step
# * initial     "'initial state'"
# * step        "Then the step to be specd"
# * spec        "'spec step'"
# * show_output false
class StepSpecr
  
  @@initial_state      = "'initial state'"
  @@path_to_temp       = "steps/temp/"
  @@required_file      = "../stepspecr_helper.rb"
  @@show_runner_output = false
  @@spec_step          = "'spec step'"
  @@step_group_names   = [:step_specr_step]
  @@step_to_be_specd   = "Then the step to be specd"
  
  class << self
    
    #:call-seq:
    #   StepSpecr.run { spec      "Article.count.should >= 5" }
    #
    # Runs the story with the options suplied by a preceeded call to StepSpecr.setup
    # and/or by options set in a block that can be associated with this method 
    # and the default options.
    def run(*args, &block)
      class_eval(&block) if block_given?
      do_run
    end
    
    #:call-seq:
    #   StepSpecr.setup { steps_for :articles }
    #
    # StepSpecr.setup must be called with a block.
    # Here is an example with all possible options.
    #   StepSpecr.setup do
    #     required    File.expand_path(File.dirname(__FILE__) +  '/helper_file.rb')
    #     path        "/path/to/spec/steps/temp"
    #     steps_for   :happy_class
    #     initial     "Class.should_receive(:good_news).and_return(@gratefulness)"
    #     step        "When I call it a Ruby Class"
    #     spec        "Class.class_method.should return_something"
    #     show_output true
    #   end
    def setup(&block)
      class_eval(&block)
    end
    
    def initial_state #:nodoc:
      @@initial_state
    end
    
    def required_file #:nodoc:
      @@required_file
    end
    
    def path_to_temp #:nodoc:
      @@path_to_temp
    end
    
    def show_runner_output #:nodoc:
      @@show_runner_output
    end
    
    def spec_step #:nodoc:
      @@spec_step
    end
    
    def step_group_names #:nodoc:
      @@step_group_names
    end
    
    def step_to_be_specd #:nodoc:
      @@step_to_be_specd
    end
    
    private
    
    def do_run(hash={})
      generate_story_file
      generate_steps_for_and_run_file
      output = parsed runner_output do |summary,pendings,failures|
        unless summary[:failures] == 0
          raise StandardError.new(failures)
        end
        unless summary[:pending] == 0
          raise StandardError.new("Not yet implemented or not found: #{pendings}")
        end
        if summary[:scenarios] == 0
          raise StandardError.new("Did not find a Scenario to run.")
        end
      end
      puts output if show_runner_output
      output
    end
    
    def generate_steps_for_and_run_file
      steps_string = ":" + step_group_names.join(",:")
      File.open("#{path_to_temp}/story.rb","w") do |file|
        file.puts <<-END
          require File.dirname(__FILE__) + "/#{required_file}"

          steps_for(:_spec_steps_) do
            Given("_initial_state_") do
              #{initial_state}
            end
            Then("_spec_step_") do
              #{spec_step}
            end
          end
      
          with_steps_for(#{steps_string},:_spec_steps_) do
            run("#{path_to_temp}/story", :type => RailsStory)
          end
        END
      end
    end
    
    def generate_story_file
      File.open("#{path_to_temp}/story","w") do |file|
        file.puts <<-END 
          Story: StepSpecr Story

           As a Developer
           I want to have generic steps
           So that I can use them in my Stories

            Scenario: StepSpecr Scenario

        END

        file.puts("Given _initial_state_")
  
        file.puts step_to_be_specd
  
        file.puts("Then _spec_step_")
      end
    end
    
    # :call-seq:
    # initial "Article.should_receive(:to_pdf).and_return(PDF::Writer.new)"
    #
    # This will be evaluated before your step runs.  
    def initial(i) # :doc:
      self.initial_state = i
    end
    
    def initial_state=(is)
      @@initial_state = is
    end
    
    def parsed(runner_output,&block)
      # The Summary Line:  1 scenarios: 0 succeeded, 1 failed, 0 pending
      re = /(\d+)\s*scenarios:\s*  (?# Number of scenarios)
            (\d+)\D*               (?# Number of succeeded sceanarios)
            (\d+)\D*               (?# Number of failing sceanarios)
            (\d+)\D*\n             (?# Number of pending sceanarios)
           /x
      sum = re.match(runner_output) || [""]
      summary = {}
      summary[:scenarios]  = sum[1].to_i
      summary[:succeed]    = sum[2].to_i
      summary[:failures]   = sum[3].to_i 
      summary[:pending]    = sum[4].to_i
  
      # Pending Steps:
      re = /Pending\s*Steps:\s*                (?# The Names of the Pending Steps are display) 
            (\s*(\d+).*:\s*pending\n)\s*       (?# in paranthesis followed by ': pending')  
           /x
      pen = re.match(runner_output) || [""] # I don't want to have nil but an empty string
      pendings = pen[0]  
  
      # Failures:
      re = /FAILURES:\s*   (?# Failure Messages consists of: )
            (\s*           (?# arbitrary leading white space  start group ... )
              (\d+\))+     (?#   a number followed by a paranth )
              [\S\s]*      (?#   arbitrary content )
            )\s*           (?# ... end group )
           /x
      fail = re.match(runner_output)  || [""] # I don't want to have nil but an empty string
      failures = fail[0]
  
  
      yield summary, pendings, failures
      runner_output
    end
    
    # :call-seq:
    # path "path/to/temp"
    #
    # Tell StepSpecr the path to the temp directory (if not PROJECT_HOME/spec/steps/temp).
    # This directory is generated by script/generate stephelper and must contain 
    # story and story.rb files (empty).
    def path(p) # :doc:
      self.path_to_temp = p
    end
    
    def path_to_temp=(p)
      @@path_to_temp = p
    end
    
    # :call-seq:
    # required "/path/to/required/file"
    #
    # Tell StepSpecr where your helper file lives 
    # (if you prefer to not use the generated one: PROJECT_HOME/spec/steps/stepspecr_helper.rb). 
    def required(p) # :doc:
      self.required_file = p
    end
    
    def required_file=(path)
      @@required_file = path
    end

    def runner_output
      IO.popen("ruby -W0 #{path_to_temp}/story.rb").readlines.join(" \n ")
    end
    
    # :call-seq:
    # show_output true
    #
    # Show the output of the story runner.
    def show_output(so) # :doc:
      self.show_runner_output = so
    end
    
    def show_runner_output=(sro)
      @@show_runner_output = sro
    end
    
    # :call-seq:
    # spec "Article.count.should == 10"
    #
    # This will be evaluated after your step was run. Set expectations on the state after your step. 
    def spec(s) # :doc:
      self.spec_step = s
    end
    
    def spec_step=(ss)
      @@spec_step = ss
    end
    
    # :call-seq:
    # step "Given 5 articles"
    #
    # The 'call' to the step you want to specify as it would appear in a plaintext story file.
    def step(s) # :doc:
      self.step_to_be_specd = s
    end
    
    def step_group_names=(names_array)
      @@step_group_names = names_array
    end
    
    def step_to_be_specd=(stbs)
      @@step_to_be_specd = stbs
    end
    
    # :call-seq:
    # steps_for :api
    #
    # Tell StepSpecr the name of the stepgroup that holds the step you want to specify.
    def steps_for(*s) # :doc:
      @@step_group_names << s
      @@step_group_names.flatten!
    end

  end
end 
  
