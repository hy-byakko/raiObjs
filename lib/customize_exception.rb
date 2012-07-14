class CustomizeException < Exception
  attr_accessor :info
  def initialize(str = nil, info = nil)
    @info = info
    super(str)
  end
end

class ErrorException < CustomizeException

end

class WarningException < CustomizeException

end