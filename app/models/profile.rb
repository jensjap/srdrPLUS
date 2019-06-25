class Profile < ApplicationRecord
  include SharedProcessTokenMethods

  acts_as_paranoid
  has_paper_trail on: [:update, :destroy]

#  after_restore :restore_relationships
  after_create :create_default_abstrackr_setting

  belongs_to :organization, inverse_of: :profiles, optional: true
  belongs_to :user, inverse_of: :profile

  has_one :abstrackr_setting, dependent: :destroy

  has_many :degrees_profiles, dependent: :destroy, inverse_of: :profile
  has_many :degrees, through: :degrees_profiles, dependent: :destroy

  #accepts_nested_attributes_for :degrees, :allow_destroy => true, :reject_if => :all_blank
  #accepts_nested_attributes_for :degrees_profiles, :allow_destroy => true, :reject_if => :all_blank

  validates :user, uniqueness: true
  validates :username,
    :uniqueness => {
      :case_sensitive => false
    }
  # Only allow letter, number, underscore and punctuation.
  validates_format_of :username, with: /^[a-zA-Z0-9_+-\.]*$/, :multiline => true

  validate :validate_username

  def degree_ids=(tokens)
    tokens.map { |token|
      resource = Degree.new
      save_resource_name_with_token(resource, token)
    }
    super
  end

  def organization_id=(token)
    resource = Organization.new
    save_resource_name_with_token(resource, token)
    super
  end

  private

    def validate_username
      if User.where(email: username).exists?
        errors.add(:username, 'Username already taken!')
      end
    end

    def create_default_abstrackr_setting
      self.create_abstrackr_setting( { authors_visible: true, journal_visible: true } )
    end

#    def restore_relationships
#      # Iterate through all associated relationship records that were deleted when we called #destroy
#      deleted_relationship_associations = self.class.reflect_on_all_associations.select do |association|
#        association.options[:dependent] == :destroy
#      end
#
#      deleted_relationship_associations.each do |association|
#        restore_with_paper_trail(association)
#      end
#    end
#
#    # Use PaperTrail to restore the associations.
#    #
#    # Only restore things that were deleted within 2 minutes of the original object destruction.
#    # If user was very active and added and removed associations frequently within 2 minutes of
#    # object destruction then we need to catch the resulting ActiveRecord::RecordNotUnique
#    # exception and move continue.
#    def restore_with_paper_trail(association)
#      time_object_destroyed = get_object_destruction_time
#      relationship_resource = association.options[:through].to_s.singularize.capitalize
#      PaperTrail::Version.where(event: 'destroy', item_type: relationship_resource).\
#        where('item_id not in (?)', relationship_resource.constantize.all.pluck(:id)).\
#        where('created_at > ?', time_object_destroyed - 2.minutes).\
#        order(id: :desc).each do |deleted_version|
#        if deleted_version.reify
#          begin
#            deleted_version.reify.save!
#          rescue ActiveRecord::RecordNotUnique => e
#            next
#          end
#        end
#      end
#    end
#
#    def get_object_destruction_time
#      PaperTrail::Version.where(event: 'destroy', item_type: self.class.name, item_id: self.id).last.created_at
#    end
end

