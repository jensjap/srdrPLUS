namespace :search_index_tasks do
  desc "Tasks that handle fixing or re-indexing search indices"
  task :reindex, [:model, :id] => [:environment] do |t, args|
    case args.model
    when "CitationsProject"
      # puts "Delete old index"
      # CitationsProject.search_index.clean_indices
      # CitationsProject.search_index.delete
      puts "Reindex CitationsProject"
      CitationsProject.reindex(import: false)
      connection = ActiveRecord::Base.connection
      res = connection.execute('select max(id) from citations_projects')
      max_id = res.to_a.flatten.first.to_i
      batch_cnt = 1
      puts "Reindexing project id #{args.id.to_s}"
      CitationsProject.where(id: 1..max_id, project_id: args.id.to_i).find_in_batches(batch_size: 1000) do |batch|
        puts "  Working on batch ##{batch_cnt}"
        batch_cnt = batch_cnt + 1
        CitationsProject.where(id: batch.map(&:id)).reindex
      end
    end

    puts "Done."
  end  # task :rebuild_search_index, [] => [:environment] do |t, args|
end