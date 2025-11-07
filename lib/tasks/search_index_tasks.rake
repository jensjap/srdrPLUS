namespace :search_index_tasks do
  desc "Rebuild search index for all models with rate limiting"
  task :rebuild_all, [:batch_size, :delay] => [:environment] do |t, args|
    batch_size = (args[:batch_size] || 100).to_i
    delay = (args[:delay] || 2).to_f  # delay in seconds between batches

    models = [
      { klass: CitationsProject, name: 'CitationsProject' },
      { klass: Project, name: 'Project' },
      { klass: Citation, name: 'Citation' },
      { klass: AbstractScreeningResult, name: 'AbstractScreeningResult' },
      { klass: FulltextScreeningResult, name: 'FulltextScreeningResult' }
    ]

    models.each do |model_info|
      puts "\n" + "=" * 80
      puts "Processing #{model_info[:name]}"
      puts "=" * 80

      begin
        # Delete old index
        puts "Deleting old index for #{model_info[:name]}..."
        model_info[:klass].search_index.clean_indices
        model_info[:klass].search_index.delete

        # Create new index (without importing data)
        puts "Creating new index for #{model_info[:name]}..."
        model_info[:klass].reindex(import: false)

        # Get total count
        total_count = model_info[:klass].count
        puts "Total records to reindex: #{total_count}"

        # Process in batches
        batch_cnt = 1
        total_batches = (total_count.to_f / batch_size).ceil

        model_info[:klass].find_in_batches(batch_size: batch_size) do |batch|
          puts "  Processing batch #{batch_cnt}/#{total_batches} (#{batch.size} records)..."

          # Reindex this batch
          model_info[:klass].where(id: batch.map(&:id)).reindex

          batch_cnt += 1

          # Sleep between batches to avoid rate limiting (except for last batch)
          if batch_cnt <= total_batches
            puts "    Waiting #{delay} seconds before next batch..."
            sleep(delay)
          end
        end

        puts "✓ Completed #{model_info[:name]} - #{total_count} records indexed"
      rescue => e
        puts "✗ Error processing #{model_info[:name]}: #{e.message}"
        puts e.backtrace.first(5).join("\n")
      end
    end

    puts "\n" + "=" * 80
    puts "All indices rebuilt successfully!"
    puts "=" * 80
  end

  desc "Rebuild search index for a specific model with rate limiting"
  task :rebuild_model, [:model_name, :batch_size, :delay] => [:environment] do |t, args|
    unless args[:model_name]
      puts "Error: model_name is required"
      puts "Usage: rake search_index_tasks:rebuild_model[ModelName,batch_size,delay]"
      puts "Available models: CitationsProject, Project, Citation, AbstractScreeningResult, FulltextScreeningResult"
      exit 1
    end

    batch_size = (args[:batch_size] || 100).to_i
    delay = (args[:delay] || 2).to_f

    model_map = {
      'CitationsProject' => CitationsProject,
      'Project' => Project,
      'Citation' => Citation,
      'AbstractScreeningResult' => AbstractScreeningResult,
      'FulltextScreeningResult' => FulltextScreeningResult
    }

    klass = model_map[args[:model_name]]
    unless klass
      puts "Error: Unknown model '#{args[:model_name]}'"
      puts "Available models: #{model_map.keys.join(', ')}"
      exit 1
    end

    puts "Rebuilding index for #{args[:model_name]}"
    puts "Batch size: #{batch_size}"
    puts "Delay between batches: #{delay} seconds"
    puts "=" * 80

    begin
      # Delete old index
      puts "Deleting old index..."
      klass.search_index.clean_indices
      klass.search_index.delete

      # Create new index
      puts "Creating new index..."
      klass.reindex(import: false)

      # Get total count
      total_count = klass.count
      puts "Total records to reindex: #{total_count}"

      # Process in batches
      batch_cnt = 1
      total_batches = (total_count.to_f / batch_size).ceil

      klass.find_in_batches(batch_size: batch_size) do |batch|
        puts "Processing batch #{batch_cnt}/#{total_batches} (#{batch.size} records)..."

        # Reindex this batch
        klass.where(id: batch.map(&:id)).reindex

        batch_cnt += 1

        # Sleep between batches (except for last batch)
        if batch_cnt <= total_batches
          puts "  Waiting #{delay} seconds..."
          sleep(delay)
        end
      end

      puts "=" * 80
      puts "✓ Successfully reindexed #{total_count} #{args[:model_name]} records"
    rescue => e
      puts "=" * 80
      puts "✗ Error: #{e.message}"
      puts e.backtrace.first(5).join("\n")
      exit 1
    end
  end
end