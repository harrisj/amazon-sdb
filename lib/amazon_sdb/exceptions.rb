module Amazon
  module SDB
    class Error < ::StandardError
    end
    
    ACCESS_ERROR_CODES = %w{AccessFailure}

    ##
    # The AccessError represents access problems connecting to SimpleDB
    class AccessError < Error
    end
    
    AUTH_ERROR_CODES = %w{AuthFailure AuthMissingFailure InvalidHTTPAuthHeader OptInRequired}

    ##
    # AuthError represents several different authentication problems that may occur when connecting to Amazon SimpleDB. See the
    # message for details.
    class AuthError < Error
    end
    
    PARAMETER_ERROR_CODES = %w(InvalidAction InvalidNextToken InvalidParameterError 
    InvalidParameterCombination InvalidParameterValue MissingAction MissingParameter NoSuchDomain
    )

    ## 
    # ParameterError is returned when a parameter to SimpleDB is invalid or missing. See the error for details.
    class ParameterError < Error
    end
    
    QUERY_ERROR_CODES = %w{InvalidNumberPredicates InvalidNumberValueTests InvalidQueryExpression}
    
    ##
    # The QuerySyntaxError covers several errors that may result from an invalid <tt>:expr</tt> passed into the Domain#Query method.
    class QuerySyntaxError < Error
    end
    
    LIMIT_ERROR_CODES = %w{NumberDomainsExceeded NumberDomainAttributesExceeded NumberDomainBytesExceeded NumberDomainBytesExceeeded URITooLong}
  
    ##
    # A LimitError is returned when you hit one of the fundamental limits for SimpleDB accounts. See the message content for details.
    class LimitError < Error
    end
    
    SERVER_ERROR_CODES = %w{InternalError ServiceOverload ServiceUnavailable}
    
    ##
    # ServerErrors represent server problems on SimpleDB.
    class ServerError < Error
    end
    
    ##
    # Huh? What? For when SimpleDB sends me an error code I've never seen before (and isn't in the docs)
    class UnknownError < Error
    end
    
    REQUEST_ERROR_CODES = %w{InvalidHttpRequest InvalidSOAPRequest InvalidURI InvalidService UnsupportedHttpVerb}
    
    ##
    # For incorrectly constructed HTTP queries against the SimpleDB server. If you see this error, it's my fault, and let me know
    # the command that caused it.
    class RequestError < Error
    end
    
    TIMEOUT_ERROR_CODES = %w{RequestExpired RequestTimeout RequestThrottled}
    
    ##
    # Amazon SimpleDB times out any operation that lasts more than 5 seconds. This error will be returned.
    class TimeoutError < Error
    end
    
    VERSION_ERROR_CODES = %w{FeatureDeprecated NoSuchVersion NotYetImplemented}
    
    ##
    # For when there is a mismatch between this gem and the API being called.
    class VersionError < Error
    end
    
    ##
    # When GetAttributes doesn't match, Amazon returns an empty record. I prefer to raise an exception instead, so there will be no
    # confusion.
    class RecordNotFoundError < Error
    end
  end
end