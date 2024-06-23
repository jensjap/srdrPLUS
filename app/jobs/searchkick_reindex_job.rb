class SearchkickReindexJob < ApplicationJob
  rescue_from(StandardError) do |exception|
    # Do something with the exception
    puts exception.message
  end

  def perform(*_args)
    Project.reindex
    Citation.reindex
  end
end
