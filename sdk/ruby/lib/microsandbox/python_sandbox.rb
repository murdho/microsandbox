# frozen_string_literal: true

require "json"
require "securerandom"
require_relative "base_sandbox"
require_relative "execution"
require_relative "errors"

module Microsandbox
  # Python-specific sandbox implementation
  class PythonSandbox < BaseSandbox
    # Get the default Docker image for Python sandbox
    # @return [String] the default Docker image name
    def default_image
      "microsandbox/python"
    end

    # Execute Python code in the sandbox
    # @param code [String] Python code to execute
    # @return [Execution] the execution result
    def run(code)
      raise NotStartedError, "Sandbox is not started. Call start first." unless started?

      request_data = {
        "jsonrpc" => "2.0",
        "method" => "sandbox.repl.run",
        "params" => {
          "sandbox" => @name,
          "namespace" => @namespace,
          "language" => "python",
          "code" => code
        },
        "id" => SecureRandom.uuid
      }

      response = make_request(request_data)
      Execution.new(response["result"])
    rescue NotStartedError
      raise
    rescue Net::HTTPError => e
      raise ExecutionError, "Failed to execute Python code: #{e.message}"
    rescue StandardError => e
      raise ExecutionError, "Python execution failed: #{e.message}"
    end
  end
end