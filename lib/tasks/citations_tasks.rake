namespace :citations_tasks do
  desc "Remove recently added citations. Use: rails citations_tasks:remove_recent_citations[project_id, days_ago]"
  task :remove_recent_citations, [:project_id, :n] => [:environment] do |t, args|
    return unless (args.project_id.present? && args.n.present?)

  	n = args.n.to_i
    project = Project.find args.project_id
    citations_to_delete = project.citations.where("citations.created_at > ?", n.days.ago)
    n_citations_to_delete = citations_to_delete.length

  	puts "are you sure you want to delete #{ n_citations_to_delete } citations in project \"#{ project.name }\" created #{ n } days ago?"
    confirm = STDIN.gets.chomp
    if confirm =~ /yes|y/i
      puts "You said yes, deleting #{ n_citations_to_delete } citations"
      citations_to_delete.each do |cit|
      	cit.destroy
      end
    else
  	  puts "You didn't say yes, nothing to see here"
    end
  end
end