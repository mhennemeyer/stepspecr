require 'rake'
require 'spec/rake/spectask'
require 'rake/rdoctask'

desc 'Default: run examples.'
task :default => :spec

desc 'Run the specs - stephelper plugin.'
Spec::Rake::SpecTask.new(:spec) do |t|
  t.libs << 'lib'
  t.pattern = 'spec/*_spec.rb'
  t.verbose = true
end

desc 'Generate documentation for the stephelper plugin.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'Stephelper'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include('lib/*.rb')
end
