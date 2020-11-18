namespace :extractions_tasks do
  desc "Associate all key questions with every extraction. Use: rails extractions_tasks:associate_all_kqs_with_extractions[project_id]"
  task :associate_all_kqs_with_extractions, [:project_id] => [:environment] do |t, args|
    return unless (args.project_id.present?)

    project = Project.find args.project_id
    kqps = KeyQuestionsProject.where(project_id: project.id)
    extractions = project.extractions
    n_non_consolidated_extractions = extractions.reject { |ex| ex.consolidated }.length
    n_consolidated_extractions = extractions.length - n_non_consolidated_extractions

    puts "Found the following (#{ kqps.length }) Key Questions:"
    kqps.each do |kqp|
      puts kqp.key_question.name
    end

  	puts "Are you sure you want to associate all (#{ extractions.length }, #{ n_non_consolidated_extractions } non-consolidated | #{ n_consolidated_extractions } consolidated) extractions in Project ID #{ project.id } with all (#{ kqps.length }) Key Questions?"
    confirm = STDIN.gets.chomp
    if confirm =~ /yes|y/i
      puts "You said yes, proceeding to add all Key Questions in Project ID #{ project.id } to every extraction."
      extractions.each do |extraction|
        puts "  Start Extraction ID #{ extraction.id } in Project ID #{ project.id }"
        extraction.key_questions_projects = kqps
        puts "  End Extraction ID #{ extraction.id }"
        puts ""
      end
    else
  	  puts "You didn't say yes, nothing to see here"
    end
  end
end