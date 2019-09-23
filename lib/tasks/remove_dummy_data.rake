namespace :dummy_data do 
  task remove: [:environment] do
    #TODO: Put correct date here
    DUMMY_DATA_CREATION_TIME = DateTime.now.ago(5.years)
    BEGINNING_OF_TIME = DateTime.new(0)

    Project.where(id: (1..20).to_a).destroy_all

    #Organization.where(name: ['Red Hair Pirates', 'Straw Hat Pirates', 'Roger Pirates']).destroy_all

    Citation.where(id: (1..200).to_a).destroy_all
    Journal.where(id: (1..200).to_a).destroy_all
    Keyword.where(id: (1..1000).to_a).destroy_all
    Author.where(id: (1..1000).to_a).destroy_all
    Message.where(id: (1..100).to_a).destroy_all

    Tag.where(created_at: BEGINNING_OF_TIME..DUMMY_DATA_CREATION_TIME).destroy_all
    Reason.where(created_at: BEGINNING_OF_TIME..DUMMY_DATA_CREATION_TIME).destroy_all

  end
end
