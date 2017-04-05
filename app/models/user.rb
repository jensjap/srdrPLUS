class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :confirmable, :lockable, :timeoutable, :omniauthable

  has_one :profile, dependent: :destroy, inverse_of: :user

  has_many :degrees, through: :profile
  has_many :degreeholderships, through: :profile
  has_many :suggestions, dependent: :destroy, inverse_of: :user

  has_paper_trail ignore: [:sign_in_count, :current_sign_in_at,
        :last_sign_in_at, :current_sign_in_ip, :last_sign_in_ip]
  acts_as_paranoid
end
