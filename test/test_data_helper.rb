module TestData
  def self.extended(object)
    object.instance_exec do
      debugger
    end
  end
end
