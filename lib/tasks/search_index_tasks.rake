namespace :search_index_tasks do
  desc "Tasks that handle fixing or re-indexing search indices"
  task :reindex, [:model] => [:environment] do |t, args|
    case args.model
    when "CitationsProject"
      puts "Reindex CitationsProject"
      CitationsProject.reindex(import: false)
      connection = ActiveRecord::Base.connection
      res = connection.execute('select max(id) from citations_projects')
      max_id = res.to_a.flatten.first.to_i
      CitationsProject.where(id: 1..max_id).find_in_batches(batch_size: 500) do |batch|
        CitationsProject.where(id: batch.map(&:id)).reindex
      end
    end

    puts "Done."
  end  # task :rebuild_search_index, [] => [:environment] do |t, args|
end