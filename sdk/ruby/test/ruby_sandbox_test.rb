# frozen_string_literal: true

require "test_helper"

class RubySandboxTest < Minitest::Test
  def test_default_image
    sandbox = Microsandbox::RubySandbox.new
    assert_equal "microsandbox/ruby", sandbox.default_image
  end

  def test_initialization
    sandbox = Microsandbox::RubySandbox.new(name: "ruby-test")
    assert_equal "ruby-test", sandbox.name
    assert_instance_of Microsandbox::RubySandbox, sandbox
  end

  def test_run_without_start_raises_error
    sandbox = Microsandbox::RubySandbox.new
    assert_raises(Microsandbox::NotStartedError) do
      sandbox.run("puts 'hello'")
    end
  end

  def test_eval_without_start_raises_error
    sandbox = Microsandbox::RubySandbox.new
    assert_raises(Microsandbox::NotStartedError) do
      sandbox.eval("1 + 1")
    end
  end

  def test_inheritance
    sandbox = Microsandbox::RubySandbox.new
    assert_kind_of Microsandbox::BaseSandbox, sandbox
    assert_instance_of Microsandbox::RubySandbox, sandbox
  end

  def test_create_class_method
    sandbox = Microsandbox::RubySandbox.create(name: "test-ruby")
    assert_instance_of Microsandbox::RubySandbox, sandbox
    assert_equal "test-ruby", sandbox.name
  end

  def test_execute_without_block_raises_error
    sandbox = Microsandbox::RubySandbox.new
    assert_raises(ArgumentError) do
      sandbox.execute
    end
  end
end