class Decorator < SimpleDelegator
  def class
    __getobj__.class
  end

  def self.decorate_collection(objects)
    objects.map { |obj| new obj }
  end
end
