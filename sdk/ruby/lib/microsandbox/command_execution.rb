# frozen_string_literal: true

require_relative "errors"

module Microsandbox
  # Represents a command execution result in a sandbox environment
  class CommandExecution
    attr_reader :exit_code, :command, :args

    def initialize(output_data = nil)
      @output_data = output_data || {}
      @exit_code = @output_data["exit_code"]
      @command = @output_data["command"]
      @args = @output_data["args"] || []
      @stdout = @output_data["stdout"] || ""
      @stderr = @output_data["stderr"] || ""
    end

    # Get the standard output from the command execution
    # @return [String] the stdout output
    def output
      @stdout
    end

    # Get the standard output from the command execution (alias)
    # @return [String] the stdout output
    def stdout
      @stdout
    end

    # Get the error output from the command execution
    # @return [String] the stderr output
    def error
      @stderr
    end

    # Get the error output from the command execution (alias)
    # @return [String] the stderr output
    def stderr
      @stderr
    end

    # Check if the command execution was successful
    # @return [Boolean] true if exit code is 0
    def success?
      @exit_code == 0
    end

    # Check if the command execution failed
    # @return [Boolean] true if exit code is not 0
    def failure?
      !success?
    end

    # Get the full command that was executed
    # @return [String] the command with arguments
    def full_command
      return @command.to_s if @args.empty?

      "#{@command} #{@args.join(' ')}"
    end

    # Get all output data as a hash
    # @return [Hash] the raw output data
    def to_h
      @output_data.dup
    end
  end
end