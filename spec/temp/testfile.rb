        require 'rubygems'
        require 'spec/story'    

        steps_for :steps do
          Given "initial" do
          end
        end

        with_steps_for :steps  do
          run "/Users/iMac/Projekte/stephelper/spec/temp/testfile"
        end
