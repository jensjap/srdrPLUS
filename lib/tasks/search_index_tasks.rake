namespace :search_index_tasks do
  desc "Tasks that handle fixing or re-indexing search indices"
  task :reindex, [:model] => [:environment] do |t, args|
    case args.model
    when "CitationsProject"
      puts "Reindex CitationsProject"
      CitationsProject.reindex(import: false)
      connection = ActiveRecord::Base.connection
      res = connection.execute('select max(id) from citations_projects')
      id = res.to_a.flatten.first.to_i
      1.upto(id) do |i|
        p = CitationsProject.find_by_id(i)
        next unless p
    
        p.reindex
      end
    end

    puts "Done."
  end  # task :rebuild_search_index, [] => [:environment] do |t, args|
end