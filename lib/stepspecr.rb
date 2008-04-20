require 'rubygems'
require 'spec/story'

class StepSpecr
  
  class << self
    
    def before(&block)
      @@before_expectation = block
    end
    
    def before_expectation
      @@before_expectation
    end
    
    def configure(&block)
       class_eval(&block)
    end
    
    def spec(step,&block)
      #configure(&block)
      world = Spec::Story::World::create
      world.instance_eval do
        Given 'before' do
          eval before_expectation
        end
        
        # find the step-to-be-specd by step

        #   Then 'after' do
        #     eval after_expectation
        #   end
      end
    end
    
    def step_group
      @@step_group_name
    end
      
    def steps_for(sym)
      @@step_group_name = sym
    end
    
  end
end