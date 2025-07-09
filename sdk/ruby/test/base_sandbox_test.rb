# frozen_string_literal: true

require "test_helper"

class BaseSandboxTest < Minitest::Test
  def test_abstract_methods
    sandbox = TestSandbox.new
    
    assert_raises(NotImplementedError) { sandbox.run("test") }
    assert_equal "test-image", sandbox.default_image
  end

  def test_initialization_with_defaults
    sandbox = TestSandbox.new
    assert_equal "http://127.0.0.1:5555", sandbox.server_url
    assert_equal "default", sandbox.namespace
    assert_nil sandbox.api_key
    assert_match(/\Asandbox-[0-9a-f]{8}\z/, sandbox.name)
    refute sandbox.started?
  end

  def test_initialization_with_custom_values
    sandbox = TestSandbox.new(
      server_url: "http://custom:8080",
      namespace: "test",
      name: "custom-sandbox",
      api_key: "test-key"
    )
    
    assert_equal "http://custom:8080", sandbox.server_url
    assert_equal "test", sandbox.namespace
    assert_equal "custom-sandbox", sandbox.name
    assert_equal "test-key", sandbox.api_key
  end

  def test_command_interface
    sandbox = TestSandbox.new
    command = sandbox.command
    assert_instance_of Microsandbox::Command, command
    assert_same command, sandbox.command # Should be memoized
  end

  def test_metrics_interface
    sandbox = TestSandbox.new
    metrics = sandbox.metrics
    assert_instance_of Microsandbox::Metrics, metrics
    assert_same metrics, sandbox.metrics # Should be memoized
  end

  def test_then_method
    sandbox = TestSandbox.new
    result = sandbox.then { |sb| sb.name }
    assert_equal sandbox, result
  end

  def test_then_method_returns_self
    sandbox = TestSandbox.new
    result = sandbox.then { |sb| "ignored" }
    assert_same sandbox, result
  end

  def test_create_without_block
    sandbox = TestSandbox.create(name: "test-sandbox")
    assert_instance_of TestSandbox, sandbox
    assert_equal "test-sandbox", sandbox.name
  end

  private

  # Test implementation of BaseSandbox for testing
  class TestSandbox < Microsandbox::BaseSandbox
    def default_image
      "test-image"
    end

    def run(code)
      raise NotImplementedError, "This is a test implementation"
    end
  end
end