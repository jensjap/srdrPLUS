module SharedOrderableMethods
  extend ActiveSupport::Concern

  included do
    scope :ordered, -> do
      joins(:ordering).merge(Ordering.order(position: :asc))
    end

    # Params:
    #   symbol - Scope of the ordering. Each orderable is grouped by some parameter.
    #
    # Returns:
    #   nil
    #
    # Determines and adds ordering to the object within the object's scope.
    def set_ordering_scoped_by(object_scope)
      position = self.class.where("#{ object_scope }": self.send(object_scope)).count + 1
      build_ordering(position: position) unless self.ordering.present?
    end

    def position=(new_position)
      return if self.ordering.position == new_position
      self.ordering.update(position: new_position) unless self.ordering.nil?
    end
  end

  class_methods do
  end
end
