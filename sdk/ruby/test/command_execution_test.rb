# frozen_string_literal: true

require "test_helper"

class CommandExecutionTest < Minitest::Test
  def test_initialize_with_nil_data
    execution = Microsandbox::CommandExecution.new
    assert_nil execution.exit_code
    assert_nil execution.command
    assert_equal [], execution.args
    assert_equal "", execution.output
    assert_equal "", execution.error
    refute execution.success?
    assert execution.failure?
  end

  def test_initialize_with_output_data
    output_data = {
      "exit_code" => 0,
      "command" => "echo",
      "args" => ["hello", "world"],
      "stdout" => "hello world\n",
      "stderr" => ""
    }

    execution = Microsandbox::CommandExecution.new(output_data)
    assert_equal 0, execution.exit_code
    assert_equal "echo", execution.command
    assert_equal ["hello", "world"], execution.args
    assert_equal "hello world\n", execution.output
    assert_equal "hello world\n", execution.stdout
    assert_equal "", execution.error
    assert_equal "", execution.stderr
    assert execution.success?
    refute execution.failure?
  end

  def test_failed_command
    output_data = {
      "exit_code" => 1,
      "command" => "false",
      "args" => [],
      "stdout" => "",
      "stderr" => "command failed\n"
    }

    execution = Microsandbox::CommandExecution.new(output_data)
    assert_equal 1, execution.exit_code
    refute execution.success?
    assert execution.failure?
    assert_equal "command failed\n", execution.error
  end

  def test_full_command_with_args
    output_data = {
      "command" => "ls",
      "args" => ["-la", "/tmp"]
    }

    execution = Microsandbox::CommandExecution.new(output_data)
    assert_equal "ls -la /tmp", execution.full_command
  end

  def test_full_command_without_args
    output_data = {
      "command" => "pwd",
      "args" => []
    }

    execution = Microsandbox::CommandExecution.new(output_data)
    assert_equal "pwd", execution.full_command
  end

  def test_to_h
    output_data = {
      "exit_code" => 0,
      "command" => "echo",
      "args" => ["test"],
      "stdout" => "test\n",
      "stderr" => ""
    }

    execution = Microsandbox::CommandExecution.new(output_data)
    result = execution.to_h
    assert_equal output_data, result
    refute_same output_data, result # Should be a copy
  end
end