# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string(255)      default(""), not null
#  encrypted_password     :string(255)      default(""), not null
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string(255)
#  last_sign_in_ip        :string(255)
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  deleted_at             :datetime
#  confirmation_token     :string(255)
#  confirmed_at           :datetime
#  confirmation_sent_at   :datetime
#  unconfirmed_email      :string(255)
#  failed_attempts        :integer          default(0), not null
#  unlock_token           :string(255)
#  locked_at              :datetime
#  user_type_id           :integer
#  provider               :string(255)
#  uid                    :string(255)
#  token                  :string(255)
#  expires_at             :integer
#  expires                :boolean
#  refresh_token          :string(255)
#

class User < ApplicationRecord
  acts_as_paranoid
  has_paper_trail ignore: [:sign_in_count, :current_sign_in_at,
      :last_sign_in_at, :current_sign_in_ip, :last_sign_in_ip]

  devise :omniauthable, :omniauth_providers => [:google_oauth2]

  after_create :ensure_profile_username_uniqueness
  before_validation { self.user_type = UserType.where(user_type: 'Member').first if self.user_type.nil? }

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :confirmable, :lockable, :timeoutable, :omniauthable,
         :authentication_keys => [:login]

  belongs_to :user_type

  has_one :profile, dependent: :destroy, inverse_of: :user
  has_one :organization, through: :profile

  has_many :actions, dependent: :destroy, inverse_of: :user

  has_many :approvals, dependent: :destroy, inverse_of: :user

  #has_many :assignments, dependent: :destroy, inverse_of: :user

  has_many :degrees, through: :profile

  has_many :dispatches, dependent: :destroy, inverse_of: :user

  has_many :imported_file, through: :projects_users, dependent: :destroy

  has_many :projects_users, dependent: :destroy, inverse_of: :user
  has_many :projects_users_roles, through: :projects_users
  has_many :projects, through: :projects_users, dependent: :destroy

  has_many :publishings, dependent: :destroy, inverse_of: :user

  has_many :suggestions, dependent: :destroy, inverse_of: :user

  #has_many :notes, dependent: :destroy, inverse_of: :user

  has_many :taggings, through: :projects_users, dependent: :destroy
  has_many :tags, through: :taggings, dependent: :destroy

  def highest_role_in_project(project)
    Role.joins(:projects_users).where(projects_users: { user: self, project: project }).first.try(:name)
  end

  def handle
    ret_value = ""
    if (profile.present? && [profile.first_name, profile.middle_name, profile.last_name].any?(&:present?))
      ret_value += "#{ profile.first_name } "  if profile.first_name.present?
      ret_value += "#{ profile.middle_name } " if profile.middle_name.present?
      ret_value += "#{ profile.last_name } "   if profile.last_name.present?
      return ret_value
    elsif (profile.present? && profile.username.present?)
      return profile.username
    else
      return email
    end
  end

  def self.current
    Thread.current[:user]
  end

  def self.current=(user)
    Thread.current[:user] = user
  end

  def login=(login)
    @login = login
  end

  def login
    @login || email
  end

  def self.find_first_by_auth_conditions(warden_conditions)
    conditions = warden_conditions.dup
    if login = conditions.delete(:login)
      where(conditions).joins(:profile).where(["`profiles`.username = :value OR email = :value", { :value => login.downcase }]).first
    else
      if conditions[:username].nil?
        conditions[:email].downcase! if conditions[:email]
        where(conditions).first
      else
        where(username: conditions[:username]).first
      end
    end
  end


  def self.from_omniauth(auth)
    # Either create a User record or update it based on the provider (Google) and the UID
    #
    # This is not quite what we want though, we want to add Google to existing users, no? - Birol
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.token = auth.credentials.token
      user.expires = auth.credentials.expires
      user.expires_at = auth.credentials.expires_at
      user.refresh_token = auth.credentials.refresh_token
    end
  end

  def admin?
    user_type.user_type == 'Admin'
  end

  private

  def ensure_profile_username_uniqueness
    _username = self.email.gsub(/@/, '_at_')
    if Profile.find_by(username: _username)
      i = 0
      loop do
        i += 1
        _username = _username + i.to_s
        break unless Profile.find_by(username: _username)
      end
    end

    create_profile(username: _username)
  end
end
