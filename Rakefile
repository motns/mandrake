require 'rake'
require 'rspec/core/rake_task'

SPEC_SUITES = [
  { :id => :comp, :title => 'components', :pattern => %w(spec/components/**/*_spec.rb) },
  { :id => :doc, :title => 'model', :pattern => %w(spec/model_spec.rb) }
]

namespace :spec do
  namespace :suite do

    rspec_tasks = []

    SPEC_SUITES.each do |suite|
      desc "Run all specs in the '#{suite[:title]}' spec suite"
      RSpec::Core::RakeTask.new(suite[:id], :format) do |t, args|
        format = args[:format] || ''
        t.pattern = suite[:pattern]

        rspec_opts = ['--color', '--fail-fast']
        rspec_opts << "--format #{format}" unless format.empty?
        t.rspec_opts = rspec_opts
      end

      rspec_tasks << "spec:suite:#{suite[:id]}"
    end

    desc "Run all spec suites"
    task :all, :format do |t, args|
      format = args[:format] || ''

      rspec_tasks.each do |rspec_task|
        Rake::Task[rspec_task].invoke(format)
      end
    end

  end


  desc "Run all specs without splitting into suites"
  RSpec::Core::RakeTask.new(:all, :format) do |t, args|
    format = args[:format] || ''
    t.pattern = %w(spec/**/*_spec.rb)

    rspec_opts = ['--color', '--fail-fast']
    rspec_opts << "--format #{format}" unless format.empty?
    t.rspec_opts = rspec_opts
  end
end

desc "Alias for spec:suite:all"
task :test => 'spec:all'

desc "Alias for running spec:all with format=documentation"
task :doc do
  Rake::Task["spec:all"].invoke("documentation")
end