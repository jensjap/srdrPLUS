namespace :citations_tasks do
  desc "Remove recently added citations. Use: rails citations_tasks:remove_recent_citations[project_id, days_ago]"
  task :remove_recent_citations, [:project_id, :n] => [:environment] do |t, args|
    return unless (args.project_id.present? && args.n.present?)

  	n = args.n.to_i
    project = Project.find args.project_id
    cps_to_delete = project.citations_projects.where("created_at > ?", n.days.ago)
    n_cps_to_delete = cps_to_delete.length

  	puts "are you sure you want to delete #{ n_cps_to_delete } citations in project \"#{ project.name }\" created #{ n } days ago?"
    confirm = STDIN.gets.chomp
    if confirm =~ /yes|y/i
      puts "You said yes, deleting #{ n_cps_to_delete } citations"
      cps_to_delete.each do |cp|
        # Also delete Citation if there's only 1 citations_project entry
        citation = cp.citation
        cps = CitationsProject.where(citation_id: cp.id)
        if cps.length > 1
          puts "Warning: more than 1 CitationsProject found - deleting CitationsProject with id #{ cp.id } only"
          cp.destroy
        else
          puts "Info: only 1 CitationsProject found - deleting Citation with id #{ citation.id } and CitationProject with id #{ cp.id }"
          citation.destroy
        end
      end
    else
  	  puts "You didn't say yes, nothing to see here"
    end
  end
end