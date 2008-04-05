class StepSpecr
  
  @@initial_state    = "'initial state'"
  @@path_to_temp     = "steps/temp/"
  @@required_file    = "../stepspecr_helper.rb"
  @@show_output      = false
  @@spec_step        = "'spec step'"
  @@step_group_names = [:step_specr_step]
  @@step_to_be_specd = "Then the step to be specd"
  
  class << self
    
    def run(*args, &block)
      class_eval(&block) if block_given?
      do_run
    end
    
    def setup(&block)
      class_eval(&block)
    end
    
    def initial_state
      @@initial_state
    end
    
    def required_file
      @@required_file
    end
    
    def path_to_temp
      @@path_to_temp
    end
    
    def show_output
      @@show_output
    end
    
    def spec_step
      @@spec_step
    end
    
    def step_group_names
      @@step_group_names
    end
    
    def step_to_be_specd
      @@step_to_be_specd
    end
    
    private
    
    def do_run(hash={})
      generate_story_file
      steps_for_and_run_file
      output = parsed runner_output do |summary,pendings,failures|
        unless summary[:failures] == 0
          raise failures
        end
        unless summary[:pending] == 0
          raise "Not yet implemented or not found: #{pendings}"
        end
        if summary[:sceanarios] == 0
          raise "Did not find a Scenario to run."
        end
      end
      puts output if show_output
      output
    end
    
    def generate_story_file
      File.open("#{path_to_temp}/story","w") do |file|
        file.puts <<-END 
          Story: This Story Provides the Context to Spec a Step

           As a Developer
           I want to have generic steps
           So that I can use them in my Stories

            Scenario: These Steps will be executed so that we can see if they work as we want

        END

        file.puts("Given _initial_state_")
  
        file.puts step_to_be_specd
  
        file.puts("Then _spec_step_")
      end
    end
    
    def initial(i)
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
      summary[:sceanarios] = sum[1]
      summary[:succeed]   = sum[2] 
      summary[:failures]   = sum[3] 
      summary[:pending]    = sum[4]
  
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
    
    def path(p)
      self.path_to_temp = p
    end
    
    def path_to_temp=(p)
      @@path_to_temp = p
    end
    
    def required(p)
      self.required_file = p
    end
    
    def required_file=(path)
      @@required_file = path
    end

    def runner_output
      IO.popen("ruby -W0 #{path_to_temp}/story.rb").readlines.join(" \n ")
    end
    
    def show_output=(so)
      @@show_output = so
    end
    
    def spec(s)
      self.spec_step = s
    end
    
    def spec_step=(ss)
      @@spec_step = ss
    end
    
    def step(s)
      self.step_to_be_specd = s
    end
    
    def step_group_names=(names_array)
      @@step_group_names = names_array
    end
    
    def step_to_be_specd=(stbs)
      @@step_to_be_specd = stbs
    end
    
    def steps_for(*s)
      @@step_group_names << s
      @@step_group_names.flatten!
    end

    def steps_for_and_run_file
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
  end
end 
  
