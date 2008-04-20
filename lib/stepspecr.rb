require 'rubygems'
require 'spec'
require 'spec/matchers'
require 'spec/story'
require 'spec/story/step'

class StepSpecr
  
  @@after_expectation = lambda { true }
  @@before_expectation = lambda { true }
  
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
    
    def spec(stepname,&block)
      configure(&block)
      type = stepname.split(/\s+/).first.to_s.downcase.to_sym
      stepname = stepname.split(/\s+/)[1,100].join(" ")
      world = Spec::Story::World.create
      step = stepgroup.find(type, stepname)
      raise "Didn't find step: '#{stepname}'" if step == nil
      before_expectation.perform world
      step.perform world
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