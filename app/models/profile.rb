class Profile < ApplicationRecord
  acts_as_paranoid
  has_paper_trail on: [:update, :destroy]

#  after_restore :restore_relationships

  belongs_to :organization, inverse_of: :profiles, optional: true
  belongs_to :user, inverse_of: :profile

  has_many :degreeholderships, dependent: :destroy, inverse_of: :profile
  has_many :degrees, through: :degreeholderships, dependent: :destroy

  accepts_nested_attributes_for :degrees, :allow_destroy => true, :reject_if => :all_blank
  accepts_nested_attributes_for :degreeholderships, :allow_destroy => true, :reject_if => :all_blank

  validates :user_id, uniqueness: true
  validates :username,
    :uniqueness => {
      :case_sensitive => false
    }
  # Only allow letter, number, underscore and punctuation.
  validates_format_of :username, with: /^[a-zA-Z0-9_\.]*$/, :multiline => true

  validate :validate_username

  def validate_username
    if User.where(email: username).exists?
      errors.add(:username, 'Username already taken!')
    end
  end

  def degree_ids=(tokens)
    tokens.map { |token| process_token(token, :degree) }
    super
  end

  def organization_id=(token)
    process_token(token, :organization)
    super
  end

  private

  def process_token(token, resource_type)
    ActiveRecord::Base.transaction do
      token.gsub!(/<<<(.+?)>>>/) { resource_type.to_s.capitalize.constantize.create!(name: $1).id }
    end
  end

#  def restore_relationships
#    # Iterate through all associated relationship records that were deleted when we called #destroy
#    deleted_relationship_associations = self.class.reflect_on_all_associations.select do |association|
#      association.options[:dependent] == :destroy
#    end
#
#    deleted_relationship_associations.each do |association|
#      restore_with_paper_trail(association)
#    end
#  end
#
#  # Use PaperTrail to restore the associations.
#  #
#  # Only restore things that were deleted within 2 minutes of the original object destruction.
#  # If user was very active and added and removed associations frequently within 2 minutes of
#  # object destruction then we need to catch the resulting ActiveRecord::RecordNotUnique
#  # exception and move continue.
#  def restore_with_paper_trail(association)
#    time_object_destroyed = get_object_destruction_time
#    relationship_resource = association.options[:through].to_s.singularize.capitalize
#    PaperTrail::Version.where(event: 'destroy', item_type: relationship_resource).\
#      where('item_id not in (?)', relationship_resource.constantize.all.pluck(:id)).\
#      where('created_at > ?', time_object_destroyed - 2.minutes).\
#      order(id: :desc).each do |deleted_version|
#      if deleted_version.reify
#        begin
#          deleted_version.reify.save!
#        rescue ActiveRecord::RecordNotUnique => e
#          next
#        end
#      end
#    end
#  end
#
#  def get_object_destruction_time
#    PaperTrail::Version.where(event: 'destroy', item_type: self.class.name, item_id: self.id).last.created_at
#  end
end

