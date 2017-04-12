class User < ApplicationRecord
  acts_as_paranoid
  has_paper_trail ignore: [:sign_in_count, :current_sign_in_at,
      :last_sign_in_at, :current_sign_in_ip, :last_sign_in_ip]


  after_create { create_profile }

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :confirmable, :lockable, :timeoutable, :omniauthable,
         :authentication_keys => [:login]

  has_one :profile, dependent: :destroy, inverse_of: :user
  has_one :organization, through: :profile

  has_many :approvals, dependent: :destroy, inverse_of: :user
  has_many :degrees, through: :profile
  #has_many :degreeholderships, through: :profile
  has_many :dispatches, dependent: :destroy, inverse_of: :user
  has_many :publishings, dependent: :destroy, inverse_of: :user
  has_many :suggestions, dependent: :destroy, inverse_of: :user

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

#  def self.find_for_database_authentication(warden_conditions)
#    conditions = warden_conditions.dup
#    if login = conditions.delete(:login)
#      where(conditions.to_hash).joins(:profile).where(["`profiles`.username = :value OR email = :value", { :value => login.downcase }]).first
#    elsif conditions.has_key?(:username) || conditions.has_key?(:email)
#      conditions[:email].downcase! if conditions[:email]
#      where(conditions.to_hash).first
#    end
#  end

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
