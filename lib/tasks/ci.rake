if !Rails.env.production? && !Rails.env.staging?
  require "rubocop/rake_task"
  require "rspec/core/rake_task"

  RuboCop::RakeTask.new
  task spec: :check_setup
  Rake::Task[:default].clear
  task default: [:rubocop, :spec]
end
