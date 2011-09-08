require 'helper'

class BaseTest < MiniTest::Unit::TestCase
  def test_initialization_sets_client_id_and_client_secret
    assert_includes runkeeper.instance_variables, :@client_id
    assert_includes runkeeper.instance_variables, :@client_secret
  end

  def test_fitness_activities_with_a_valid_token_returns_an_array
    stub_successful_runkeeper_fitness_activities_request
    assert_instance_of Array, runkeeper.fitness_activities('valid_token')
  end

  def test_fitness_activities_with_a_valid_token_returns_runkeeper_activities
    stub_successful_runkeeper_fitness_activities_request
    runkeeper.fitness_activities('valid_token').each do |klass|
      assert_instance_of RunKeeper::Activity, klass
    end
  end

  def test_user_returns_an_instance_of_user
    stub_successful_runkeeper_user_request
    assert_instance_of RunKeeper::User, runkeeper.user('valid_token')
  end

  def test_profile_returns_and_instance_of_profile
    stub_successful_runkeeper_profile_request
    assert_instance_of RunKeeper::Profile, runkeeper.profile('valid_token')
  end

  def test_parse_response_raises_exception_unless_response_status_is_200_or_304
    assert_raises RunKeeper::Error do
      runkeeper.send :parse_response, mock_response(400)
    end
  end

  def test_parse_response_returns_response_when_status_200
    response = mock_response 200
    assert_equal response, runkeeper.send(:parse_response, response)
  end

  def test_parse_response_returns_response_when_status_304
    response = mock_response 304
    assert_equal response, runkeeper.send(:parse_response, response)
  end

private
  def mock_response status
    Object.new.tap do |response|
      response.extend Module.new {
        define_method :status do
          status
        end
        def error=(value); end
        def parsed; end
      }
    end
  end

  def runkeeper
    Base.new 'client_id', 'client_secret'
  end
end
