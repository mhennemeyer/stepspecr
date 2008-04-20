require 'rubygems'
require 'spec'
require 'spec/matchers'
require 'spec/story'
require 'spec/story/step'

class StepSpecr
  
  class << self
    
    def after(&block)
      @@after_expectation = block
    end
    
    def after_expectation
      Spec::Story::Step.new("after") do
        @@after_expectation.call
      end
    end
    
    def before(&block)
      @@before_expectation = block
    end
    
    def before_expectation
      Spec::Story::Step.new("before") do
        @@before_expectation.call
      end
    end
    
    def configure(&block)
       class_eval(&block)
    end
    
    def spec(step,&block)
      configure(&block)
      type = step.split(/\s+/).first.to_s.downcase.to_sym
      step = step.split(/\s+/)[1,100].join(" ")
      world = Spec::Story::World.create
      before_expectation.perform world
      stepgroup.find(type, step).perform world
      after_expectation.perform world 
    end
    
    def step_group_name
      @@step_group_name
    end
      
    def step_group(sym)
      @@step_group_name = sym
    end
    
    def stepgroup
      steps_for @@step_group_name
    end
    
  end
end