namespace :authors_citations do
  task add_orderings: [:environment] do
    citation_ids = AuthorsCitation.left_joins(:ordering).where(orderings: { id: nil }).pluck(:citation_id).uniq
    Citation.where(id: citation_ids).each do |c|
      Citation.transaction do
        AuthorsCitation.where(citation: c).each_with_index do |a_c, i|
          if a_c.ordering.present?
            puts "Ordering present for AuthorsCitation #{ a_c.id.to_s }, updating with position: #{ (i+1).to_s }"
            a_c.position = i + 1
          else
            puts "Ordering not present for AuthorsCitation #{ a_c.id.to_s }, creating with position: #{ (i+1).to_s }"
            a_c.build_ordering(position: i + 1)
            a_c.ordering.save
          end
        end
      end
    end
  end
end
