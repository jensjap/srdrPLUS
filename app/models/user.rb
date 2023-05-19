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
#  api_key                :string(255)
#

class User < ApplicationRecord
  devise :omniauthable, omniauth_providers: [:google_oauth2]
  has_secure_token :api_key

  after_create :ensure_profile_username_uniqueness
  before_validation { self.user_type = UserType.where(user_type: 'Member').first if user_type.nil? }

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :confirmable, :lockable, :timeoutable, :omniauthable,
         authentication_keys: [:login]

  belongs_to :user_type

  has_one :profile, dependent: :destroy, inverse_of: :user
  has_one :organization, through: :profile

  has_many :actions, dependent: :destroy, inverse_of: :user

  has_many :approvals, dependent: :destroy, inverse_of: :user

  has_many :degrees, through: :profile

  has_many :dispatches, dependent: :destroy, inverse_of: :user

  has_many :projects_users, dependent: :destroy, inverse_of: :user
  has_many :projects, through: :projects_users, dependent: :destroy
  has_many :citations_projects, through: :projects

  has_many :imported_files, through: :projects_users, dependent: :destroy

  has_many :publishings, dependent: :destroy, inverse_of: :user

  has_many :suggestions, dependent: :destroy, inverse_of: :user

  # has_many :notes, dependent: :destroy, inverse_of: :user

  has_many :taggings, through: :projects_users, dependent: :destroy
  has_many :tags, through: :taggings, dependent: :destroy

  delegate :username, to: :profile, allow_nil: true
  delegate :first_name, to: :profile, allow_nil: true
  delegate :middle_name, to: :profile, allow_nil: true
  delegate :last_name, to: :profile, allow_nil: true

  def handle
    if [first_name, middle_name, last_name].any?(&:present?)
      [first_name, middle_name, last_name].compact.join(' ')
    elsif username.present?
      username
    else
      email
    end
  end

  def self.current
    Thread.current[:user]
  end

  def self.current=(user)
    Thread.current[:user] = user
  end

  attr_writer :login

  def login
    @login || email
  end

  def self.find_first_by_auth_conditions(warden_conditions)
    conditions = warden_conditions.dup
    if login = conditions.delete(:login)
      where(conditions).joins(:profile).where(['`profiles`.username = :value OR email = :value',
                                               { value: login.downcase }]).first
    elsif conditions[:username].nil?
      conditions[:email].downcase! if conditions[:email]
      where(conditions).first
    else
      where(username: conditions[:username]).first
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
    _username = email.gsub(/@/, '_at_')
    if Profile.find_by(username: _username)
      i = 0
      loop do
        i += 1
        _username += i.to_s
        break unless Profile.find_by(username: _username)
      end
    end

    create_profile(username: _username)
  end
end
