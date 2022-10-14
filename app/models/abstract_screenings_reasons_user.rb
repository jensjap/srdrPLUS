class AbstractScreeningsReasonsUser < ApplicationRecord
  belongs_to :abstract_screening
  belongs_to :reason
  belongs_to :user

  def self.custom_reasons_object(abstract_screening, user)
    asrus = AbstractScreeningsReasonsUser.where(abstract_screening:, user:).includes(:reason)
    asrus.each_with_object({}) do |asru, hash|
      hash[asru.reason.name] = false
      hash
    end
  end
end
