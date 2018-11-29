class User < ApplicationRecord
  acts_as_paranoid
  has_paper_trail ignore: [:sign_in_count, :current_sign_in_at,
      :last_sign_in_at, :current_sign_in_ip, :last_sign_in_ip]


  after_create { create_profile(username: email.gsub(/@/, '_at_')) }
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

  has_many :assignments, dependent: :destroy, inverse_of: :user

  has_many :degrees, through: :profile

  has_many :dispatches, dependent: :destroy, inverse_of: :user

  has_many :projects_users, dependent: :destroy, inverse_of: :user
  has_many :projects_users_roles, through: :projects_users
  has_many :projects, through: :projects_users, dependent: :destroy

  has_many :publishings, dependent: :destroy, inverse_of: :user

  has_many :suggestions, dependent: :destroy, inverse_of: :user

  has_many :notes, dependent: :destroy, inverse_of: :user

  has_many :taggings, through: :projects_users, dependent: :destroy
  has_many :tags, through: :taggings, dependent: :destroy

  def handle
    profile.username || email
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
end
