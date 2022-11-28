# == Schema Information
#
# Table name: profiles
#
#  id                    :integer          not null, primary key
#  user_id               :integer
#  organization_id       :integer
#  time_zone             :string(255)      default("UTC")
#  username              :string(255)
#  first_name            :string(255)
#  middle_name           :string(255)
#  last_name             :string(255)
#  advanced_mode         :boolean          default(FALSE)
#  deleted_at            :datetime
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  projects_paginate_per :integer
#

class Profile < ApplicationRecord
  include SharedProcessTokenMethods

  acts_as_paranoid
  #before_destroy :really_destroy_children!
  def really_destroy_children!
    degrees_profiles.with_deleted.each do |child|
      child.really_destroy!
    end
  end

  #  after_restore :restore_relationships
  after_create :create_default_abstrackr_setting

  belongs_to :organization, inverse_of: :profiles, optional: true
  belongs_to :user, inverse_of: :profile

  has_one :abstrackr_setting, dependent: :destroy

  has_many :degrees_profiles, dependent: :destroy, inverse_of: :profile
  has_many :degrees, through: :degrees_profiles, dependent: :destroy

  # accepts_nested_attributes_for :degrees, :allow_destroy => true, :reject_if => :all_blank
  # accepts_nested_attributes_for :degrees_profiles, :allow_destroy => true, :reject_if => :all_blank

  validates :user, uniqueness: true
  validates :username,
            uniqueness: {
              case_sensitive: false
            }
  # Only allow letter, number, underscore and punctuation.
  validates_format_of :username, with: /^[a-zA-Z0-9_+-.]*$/, multiline: true

  validate :validate_username

  def degree_ids=(tokens)
    tokens.map do |token|
      resource = Degree.new
      save_resource_name_with_token(resource, token)
    end
    super
  end

  def organization_id=(token)
    resource = Organization.new
    save_resource_name_with_token(resource, token)
    super
  end

  private

  def validate_username
    errors.add(:username, 'Username already taken!') if User.where(email: username).exists?
  end

  def create_default_abstrackr_setting
    create_abstrackr_setting({ authors_visible: true, journal_visible: true })
  end
end
