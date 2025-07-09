# frozen_string_literal: true

require "test_helper"

class MicrosandboxTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Microsandbox::VERSION
  end

  def test_module_structure
    assert_equal "0.2.6", ::Microsandbox::VERSION
  end

  def test_sandbox_classes_exist
    assert ::Microsandbox::PythonSandbox
    assert ::Microsandbox::NodeSandbox
    assert ::Microsandbox::RubySandbox
    assert ::Microsandbox::BaseSandbox
  end

  def test_execution_classes_exist
    assert ::Microsandbox::Execution
    assert ::Microsandbox::CommandExecution
    assert ::Microsandbox::Command
    assert ::Microsandbox::Metrics
  end

  def test_error_classes_exist
    assert ::Microsandbox::Error
    assert ::Microsandbox::StartError
    assert ::Microsandbox::StopError
    assert ::Microsandbox::ExecutionError
    assert ::Microsandbox::CommandError
    assert ::Microsandbox::ClientError
    assert ::Microsandbox::APIError
    assert ::Microsandbox::AuthenticationError
    assert ::Microsandbox::TimeoutError
    assert ::Microsandbox::NotFoundError
    assert ::Microsandbox::NotStartedError
    assert ::Microsandbox::AlreadyStartedError
  end
end
