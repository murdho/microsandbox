# frozen_string_literal: true

require "json"
require "securerandom"
require_relative "base_sandbox"
require_relative "execution"
require_relative "errors"

module Microsandbox
  # Ruby-specific sandbox implementation
  class RubySandbox < BaseSandbox
    # Get the default Docker image for Ruby sandbox
    # @return [String] the default Docker image name
    def default_image
      "microsandbox/ruby"
    end

    # Execute Ruby code in the sandbox
    # @param code [String] Ruby code to execute
    # @return [Execution] the execution result
    def run(code)
      raise NotStartedError, "Sandbox is not started. Call start first." unless started?

      request_data = {
        "jsonrpc" => "2.0",
        "method" => "sandbox.repl.run",
        "params" => {
          "sandbox" => @name,
          "namespace" => @namespace,
          "language" => "ruby",
          "code" => code
        },
        "id" => SecureRandom.uuid
      }

      response = make_request(request_data)
      Execution.new(response["result"])
    rescue NotStartedError
      raise
    rescue Net::HTTPError => e
      raise ExecutionError, "Failed to execute Ruby code: #{e.message}"
    rescue StandardError => e
      raise ExecutionError, "Ruby execution failed: #{e.message}"
    end

    # Ruby-specific convenience method to evaluate code and return the result
    # @param code [String] Ruby code to evaluate
    # @return [Object] the evaluated result
    def eval(code)
      execution = run(code)
      raise ExecutionError, execution.error if execution.error?

      execution.output
    end

    # Execute a Ruby block in the sandbox (convenience method)
    # @param block [Proc] Ruby block to execute
    # @return [Execution] the execution result
    def execute(&block)
      raise ArgumentError, "Block is required" unless block_given?

      # Convert the block to a string representation
      # This is a simplified approach - in practice, you might want to use
      # more sophisticated code serialization
      code = block.source rescue block.to_s
      run(code)
    end
  end
end