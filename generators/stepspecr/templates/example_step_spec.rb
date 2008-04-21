require File.dirname(__FILE__) + '/stepspecr_helper'
require File.dirname(__FILE__) + '/example_steps.rb'

describe "Given $count $models" do
  it "should create 1 article for count=1, models=article" do
    StepSpecr.spec "Given 1 article" do
      
      before do
        class Article
        end
        Article.should_receive(:create)
      end
      
    end
  end
end