require 'test_sdb_harness'

class TestException < Test::Unit::TestCase
  def setup
    @sdb = Amazon::SDB::Base.new 'API_KEY', 'SECRET_KEY' 
  end
  
  def assert_err(code, exception_class)
    @sdb.responses << error_response(code)
    assert_raise(exception_class) { @sdb.domains }
  end
  
  def test_access_failure
    assert_err('AccessFailure', Amazon::SDB::AccessError)
  end
  
  def test_auth_failure
    assert_err('AuthFailure', Amazon::SDB::AuthError)
  end
  
  def test_auth_missing
    assert_err('AuthMissingFailure', Amazon::SDB::AuthError)
  end
  
  def test_deprecated
    assert_err('FeatureDeprecated', Amazon::SDB::VersionError)
  end
  
  def test_internal_error
    assert_err('InternalError', Amazon::SDB::ServerError)
  end
  
  def test_invalid_action
    assert_err('InvalidAction', Amazon::SDB::ParameterError)
  end
  
  def test_invalid_http_auth_header
    assert_err('InvalidHTTPAuthHeader', Amazon::SDB::AuthError)
  end

  def test_invalid_http_request
    assert_err('InvalidHttpRequest', Amazon::SDB::RequestError)
  end

  def test_invalid_param_value
    assert_err('InvalidParameterValue', Amazon::SDB::ParameterError)
  end
  
  def test_invalid_next_token
    assert_err('InvalidNextToken', Amazon::SDB::ParameterError)
  end

  def test_invalid_num_predicates
    assert_err('InvalidNumberPredicates', Amazon::SDB::QuerySyntaxError)
  end
  
  def test_invalid_number_value_tests
    assert_err('InvalidNumberValueTests', Amazon::SDB::QuerySyntaxError)
  end
  
  def test_invalid_parameter_combo
    assert_err('InvalidParameterCombination', Amazon::SDB::ParameterError)
  end
  
  def test_invalid_parameter_value
    assert_err('InvalidParameterValue', Amazon::SDB::ParameterError)
  end

  def test_invalid_query_expr
    assert_err('InvalidQueryExpression', Amazon::SDB::QuerySyntaxError)
  end
  
  def test_invalid_response_groups
    assert_err('InvalidResponseGroups', Amazon::SDB::UnknownError)
  end
  
  def test_invalid_service
    assert_err('InvalidService', Amazon::SDB::RequestError)
  end
  
  def test_soap_request
    assert_err('InvalidSOAPRequest', Amazon::SDB::RequestError)
  end
  
  def test_invalid_uri
    assert_err('InvalidURI', Amazon::SDB::RequestError)
  end
  
  def test_missing_action
    assert_err('MissingAction', Amazon::SDB::ParameterError)
  end
  
  def test_missing_parameter
    assert_err('MissingParameter', Amazon::SDB::ParameterError)
  end
  
  def test_no_such_domain
    assert_err('NoSuchDomain', Amazon::SDB::ParameterError)
  end
     
  def test_no_such_version
    assert_err('NoSuchVersion', Amazon::SDB::VersionError)
  end
  
  def test_not_yet_implemented
    assert_err('NotYetImplemented', Amazon::SDB::VersionError)
  end
  
  def test_num_domains_exceeded
    assert_err('NumberDomainsExceeded', Amazon::SDB::LimitError)
  end
  
  def test_num_domain_attributes_exceed
    assert_err('NumberDomainAttributesExceeded', Amazon::SDB::LimitError)
  end
  
  def test_num_domain_bytes_exceed
    assert_err('NumberDomainBytesExceeded', Amazon::SDB::LimitError)
  end
  
  def test_num_item_attrs_exceed
    assert_err('NumberDomainBytesExceeded', Amazon::SDB::LimitError)
  end
  
  def test_request_expired
    assert_err('RequestExpired', Amazon::SDB::TimeoutError)
  end
  
  def test_request_timeout
    assert_err('RequestTimeout', Amazon::SDB::TimeoutError)
  end

  def test_request_throttle
    assert_err('RequestThrottled', Amazon::SDB::TimeoutError)
  end

  def test_service_overload
    assert_err('ServiceOverload', Amazon::SDB::ServerError)
  end
  
  def test_service_unavailable
    assert_err('ServiceUnavailable', Amazon::SDB::ServerError)
  end

  def test_unsupported_http_verb
    assert_err('UnsupportedHttpVerb', Amazon::SDB::RequestError)
  end
  
  def test_uri_too_long
    assert_err('URITooLong', Amazon::SDB::LimitError)
  end
end