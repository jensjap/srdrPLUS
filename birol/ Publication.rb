class Publication < ApplicationRecord
    has_one :publication_type
    has_one :title
    has_many :authors
    has_one :publication_date
    has_one :pmid
    has_one :refman
    has_one :journal
    has_many :keywords
    has_one :abstract

    #SRDR stuff
    has_many :extractions

    #Abstrackr stuff
    has_many :tasks
    has_many :labels
    has_one :priority
end

class Journal < ApplicationRecord
    belongs_to :publication
    has_one :year
    has_one :volume
    has_one :issue
end