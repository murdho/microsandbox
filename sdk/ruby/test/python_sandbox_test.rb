# frozen_string_literal: true

require "test_helper"

class PythonSandboxTest < Minitest::Test
  def test_default_image
    sandbox = Microsandbox::PythonSandbox.new
    assert_equal "microsandbox/python", sandbox.default_image
  end

  def test_initialization
    sandbox = Microsandbox::PythonSandbox.new(name: "python-test")
    assert_equal "python-test", sandbox.name
    assert_instance_of Microsandbox::PythonSandbox, sandbox
  end

  def test_run_without_start_raises_error
    sandbox = Microsandbox::PythonSandbox.new
    assert_raises(Microsandbox::NotStartedError) do
      sandbox.run("print('hello')")
    end
  end

  def test_inheritance
    sandbox = Microsandbox::PythonSandbox.new
    assert_kind_of Microsandbox::BaseSandbox, sandbox
    assert_instance_of Microsandbox::PythonSandbox, sandbox
  end

  def test_create_class_method
    sandbox = Microsandbox::PythonSandbox.create(name: "test-python")
    assert_instance_of Microsandbox::PythonSandbox, sandbox
    assert_equal "test-python", sandbox.name
  end
end