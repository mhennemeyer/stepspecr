require 'spec'
require 'spec/matchers'
require 'spec/story'
require 'spec/story/step'

# StepSpecr provides a 'testing' framework for speccing Given/When/Then steps 
# within Rspec examples. This lets you implement GWT-steps the BDD way.
#
#   describe "Given $count articles" do
#     it "should create 5 articles for count=5" do
#       StepSpecr.spec "Given 5 articles" do
#         step_group :articles
#         before { Article.destroy_all }
#         after { Article.count.should == 5 }
#       end
#     end
#   end          
#      
#          
# * StepSpecr.config {  } lets you configure the runner and will not run the story.
#   This is likely to be done in a before block.
# * StepSpecr.spec 'step name'  {  } lets you run the story and provides the same configuration facility as 
#   StepSpecr.configure so you can configure the whole thing in a before block and 
#   then making subsequent changes to the configuration in each example.
# 
class StepSpecr
  
  @@after_expectation = lambda { true }
  @@before_expectation = lambda { true }
  @@step_group_name = :spec
  
  class << self
    
    # :call-seq:
    # after { Article.count.should == 10 }
    #
    # This will be evaluated after your step has been run.
    def after(&block)
      @@after_expectation = block
    end
    
    def after_expectation #:nodoc:
      Spec::Story::Step.new("after",&@@after_expectation)
    end
    
    # :call-seq:
    # before { Article.should_receive(:to_pdf).and_return(PDF::Writer.new) }
    #
    # This will be evaluated after your step has been run.
    def before(&block)
      @@before_expectation = block
    end
    
    def before_expectation #:nodoc:
      Spec::Story::Step.new("before",&@@before_expectation)
    end
    
    #:call-seq:
    #   StepSpecr.configure { step_group :articles }
    #
    # StepSpecr.configure must be called with a block.
    # Here is an example:
    #   StepSpecr.setup do
    #     step_group  :happy_class
    #     before do
    #       Class.should_receive(:good_news).and_return(@gratefulness)
    #     end
    #     after { Class.class_method.should return_something }
    #   end
    def configure(&block)
       class_eval(&block)
    end
    
    #:call-seq:
    #   StepSpecr.spec 'step name' {  }
    #
    # Runs the story with the options suplied by a preceeded call to StepSpecr.configure
    # and/or by options set in the block that is associated
    def spec(stepname,&block)
      configure(&block)
      type = stepname.split(/\s+/).first.to_s.downcase.to_sym
      stepname = stepname.split(/\s+/)[1,100].join(" ")
      world = Spec::Story::World.create
      step = stepgroup.find(type, stepname)
      raise Spec::Expectations::ExpectationNotMetError.new("Didn't find step: '#{stepname}'") if step == nil
      
      args = step.parse_args(stepname)
      
      before_expectation.perform world
      step.perform world, *args
      after_expectation.perform world
    end
    
    def step_group_name #:nodoc:
      @@step_group_name
    end
      
    # :call-seq:
    # step_group :api
    #
    # Tell StepSpecr the name of the stepgroup that holds the step you want to specify.
    def step_group(sym)
      @@step_group_name = sym
    end
    
    def stepgroup #:nodoc:
      steps_for @@step_group_name
    end
    
  end
end