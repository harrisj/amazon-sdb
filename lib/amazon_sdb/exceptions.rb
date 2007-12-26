module Amazon
  module SDB
    class Error < ::StandardError
    end
    
    ACCESS_ERROR_CODES = %w{AccessFailure}
    class AccessError < Error
    end
    
    AUTH_ERROR_CODES = %w{AuthFailure AuthMissingFailure InvalidHTTPAuthHeader}
    class AuthError < Error
    end
    
    PARAMETER_ERROR_CODES = %w(InvalidAction InvalidNextToken InvalidParameterError 
    InvalidParameterCombination InvalidParameterValue MissingAction MissingParameter NoSuchDomain
    )
    class ParameterError < Error
    end
    
    QUERY_ERROR_CODES = %w{InvalidNumberPredicates InvalidNumberValueTests InvalidQueryExpression}
    class QuerySyntaxError < Error
    end
    
    LIMIT_ERROR_CODES = %w{NumberDomainsExceeded NumberDomainAttributesExceeded NumberDomainBytesExceeded NumberDomainBytesExceeeded URITooLong}
    class LimitError < Error
    end
    
    SERVER_ERROR_CODES = %w{InternalError ServiceOverload ServiceUnavailable}
    class ServerError < Error
    end
    
    class UnknownError < Error
    end
    
    REQUEST_ERROR_CODES = %w{InvalidHttpRequest InvalidSOAPRequest InvalidURI InvalidService UnsupportedHttpVerb}
    class RequestError < Error
    end
    
    TIMEOUT_ERROR_CODES = %w{RequestExpired RequestTimeout RequestThrottled}
    class TimeoutError < Error
    end
    
    VERSION_ERROR_CODES = %w{FeatureDeprecated NoSuchVersion NotYetImplemented}
    class VersionError < Error
    end
    
    class RecordNotFoundError < Error
    end
  end
end