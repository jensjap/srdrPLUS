namespace :sample_tasks do
  desc "Template for creating tasks with arguments.
        Use: rails sample_tasks:task_name[arg_n, arg_m]"
  task :task_name, [:arg_m, :arg_n] => [:environment] do |t, args|
    return unless (args.arg_m.present? && args.arg_n.present?)

    arg_m, arg_n = args.arg_m, args.arg_n
    p arg_m
    p arg_n

  end
end
