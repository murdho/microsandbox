# frozen_string_literal: true

require "test_helper"

class ExecutionTest < Minitest::Test
  def test_initialize_with_nil_data
    execution = Microsandbox::Execution.new
    assert_equal "", execution.output
    assert_equal "", execution.error
    assert_equal "unknown", execution.status
    assert_equal "unknown", execution.language
    refute execution.error?
    refute execution.success?
  end

  def test_initialize_with_output_data
    output_data = {
      "output" => [
        { "stream" => "stdout", "text" => "Hello, world!\n" },
        { "stream" => "stderr", "text" => "Warning: something\n" }
      ],
      "status" => "success",
      "language" => "python"
    }

    execution = Microsandbox::Execution.new(output_data)
    assert_equal "Hello, world!", execution.output
    assert_equal "Warning: something", execution.error
    assert_equal "success", execution.status
    assert_equal "python", execution.language
    assert execution.error?
    refute execution.success?
  end

  def test_success_execution
    output_data = {
      "output" => [
        { "stream" => "stdout", "text" => "Success!\n" }
      ],
      "status" => "success",
      "language" => "python"
    }

    execution = Microsandbox::Execution.new(output_data)
    assert execution.success?
    refute execution.error?
  end

  def test_error_status
    output_data = {
      "output" => [],
      "status" => "error",
      "language" => "python"
    }

    execution = Microsandbox::Execution.new(output_data)
    refute execution.success?
    assert execution.error?
  end

  def test_exception_status
    output_data = {
      "output" => [],
      "status" => "exception",
      "language" => "python"
    }

    execution = Microsandbox::Execution.new(output_data)
    refute execution.success?
    assert execution.error?
  end

  def test_output_lines
    output_data = {
      "output" => [
        { "stream" => "stdout", "text" => "Line 1\n" },
        { "stream" => "stdout", "text" => "Line 2\n" }
      ]
    }

    execution = Microsandbox::Execution.new(output_data)
    lines = execution.output_lines
    assert_equal 2, lines.length
    assert_equal "stdout", lines[0]["stream"]
    assert_equal "Line 1\n", lines[0]["text"]
  end
end