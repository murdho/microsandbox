# frozen_string_literal: true

require_relative "errors"

module Microsandbox
  # Represents a code execution result in a sandbox environment
  class Execution
    attr_reader :status, :language

    def initialize(output_data = nil)
      @output_lines = []
      @status = "unknown"
      @language = "unknown"
      @has_error = false

      process_output_data(output_data) if output_data
    end

    # Get the standard output from the execution
    # @return [String] the stdout output
    def output
      @output_lines
        .select { |line| line.is_a?(Hash) && line["stream"] == "stdout" }
        .map { |line| line["text"] }
        .join
        .chomp
    end

    # Get the error output from the execution
    # @return [String] the stderr output
    def error
      @output_lines
        .select { |line| line.is_a?(Hash) && line["stream"] == "stderr" }
        .map { |line| line["text"] }
        .join
        .chomp
    end

    # Check if the execution contains an error
    # @return [Boolean] true if there was an error
    def error?
      @has_error
    end

    # Check if the execution was successful
    # @return [Boolean] true if successful
    def success?
      !@has_error && @status == "success"
    end

    # Get all output lines as an array
    # @return [Array<Hash>] array of output line hashes
    def output_lines
      @output_lines.dup
    end

    private

    def process_output_data(output_data)
      return unless output_data.is_a?(Hash)

      @output_lines = output_data["output"] || []
      @status = output_data["status"] || "unknown"
      @language = output_data["language"] || "unknown"

      # Check for errors
      if @status == "error" || @status == "exception"
        @has_error = true
      else
        # Check stderr output for errors
        @has_error = @output_lines.any? do |line|
          line.is_a?(Hash) && line["stream"] == "stderr" && !line["text"].to_s.empty?
        end
      end
    end
  end
end