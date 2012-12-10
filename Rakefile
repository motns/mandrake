require 'rake'
require 'rspec/core/rake_task'

SPEC_SUITES = [
  { :id => :comp, :title => 'components', :pattern => %w(spec/components/**/*_spec.rb) }
]

namespace :spec do
  namespace :suite do
    SPEC_SUITES.each do |suite|
      desc "Run all specs in the '#{suite[:title]}' spec suite"
      RSpec::Core::RakeTask.new(suite[:id]) do |t|
        t.pattern = suite[:pattern]
        t.rspec_opts = '--color'
      end

      task :all => "spec:suite:#{suite[:id]}"
    end
  end
end

task :test => 'spec:suite:all'