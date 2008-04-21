steps_for :example do
   Given "$count $models" do |count, name|
     # klass = eval "#{name.singularize.camelize}"
     # count.to_i.times { klass.create }
   end
 end