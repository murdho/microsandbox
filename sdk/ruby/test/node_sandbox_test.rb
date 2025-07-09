# frozen_string_literal: true

require "test_helper"

class NodeSandboxTest < Minitest::Test
  def test_default_image
    sandbox = Microsandbox::NodeSandbox.new
    assert_equal "microsandbox/node", sandbox.default_image
  end

  def test_initialization
    sandbox = Microsandbox::NodeSandbox.new(name: "node-test")
    assert_equal "node-test", sandbox.name
    assert_instance_of Microsandbox::NodeSandbox, sandbox
  end

  def test_run_without_start_raises_error
    sandbox = Microsandbox::NodeSandbox.new
    assert_raises(Microsandbox::NotStartedError) do
      sandbox.run("console.log('hello')")
    end
  end

  def test_inheritance
    sandbox = Microsandbox::NodeSandbox.new
    assert_kind_of Microsandbox::BaseSandbox, sandbox
    assert_instance_of Microsandbox::NodeSandbox, sandbox
  end

  def test_create_class_method
    sandbox = Microsandbox::NodeSandbox.create(name: "test-node")
    assert_instance_of Microsandbox::NodeSandbox, sandbox
    assert_equal "test-node", sandbox.name
  end
end