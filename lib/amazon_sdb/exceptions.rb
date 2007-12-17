module Amazon
  module SDB
    class InvalidParameterError < ArgumentError
    end
    
    class LimitError < Exception
    end
    
    class DomainLimitError < LimitError
    end
    
    class UnknownError < Exception
    end
    
    class RecordNotFoundError < Exception
    end
  end
end