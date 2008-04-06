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
      
    end
    
    def step_group
      @@step_group_name
    end
      
    def steps_for(sym)
      @@step_group_name = sym
    end
    
  end
end