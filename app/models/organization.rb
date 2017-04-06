class Organization < ApplicationRecord
  acts_as_paranoid
  has_paper_trail

  has_one :suggestion, as: :suggestable, dependent: :destroy

  has_many :profiles, dependent: :nullify, inverse_of: :profile

  def self.by_query(query)
    @organizations = Organization.where('name like ?', "%#{ query }%").order(:name)
    return @organizations.empty? ?
      [ OpenStruct.new(id: "<<<#{ query }>>>", name: "New: '#{ query }'", suggestion: false) ] : @organizations
  end

  # Params:
  #   [String] tokens
  #
  # Returns:
  #   [Integer] id or nil
  def self.id_from_tokens(tokens)
    begin
      return find(tokens).id
    rescue ActiveRecord::RecordNotFound => e
      return create_record_with_tokens(tokens)
    end
  end

  private

  def self.create_record_with_tokens(tokens)
    tokens.gsub!(/<<<(.+?)>>>/) do
      organization = create!(name: $1)
      #!!! Need to fetch proper user.
      organization.create_suggestion(user: User.first).suggestable.id
    end
  end
end

