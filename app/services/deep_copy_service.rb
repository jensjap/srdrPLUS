module DeepCopyService
  def self.deep_copy_in_threads(models)
    threads = []
    results = []

    models.each do |model|
      threads << Thread.new do
        begin
          # Deep copy using amoeba
          copied_model = model.amoeba_dup
          # Save the copied model to persist it in the database
          copied_model.save!
          # Store the result for later use
          results << copied_model
        rescue => e
          # Handle any exceptions that occur during the copy process
          Rails.logger.error("Error copying model #{model.id}: #{e.message}")
          next
        end
      end
    end

    # Wait for all threads to complete
    threads.each(&:join)

    results
  end
end
