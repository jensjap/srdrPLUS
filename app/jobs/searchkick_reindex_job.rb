class SearchkickReindexJob < ApplicationJob
  queue_as :low

  rescue_from(StandardError) do |exception|
    # Do something with the exception
    puts exception.message
  end

  def perform(*args)
    Project.reindex  
    Citation.reindex  
  end
end

