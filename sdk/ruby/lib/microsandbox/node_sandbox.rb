# frozen_string_literal: true

require "json"
require "securerandom"
require_relative "base_sandbox"
require_relative "execution"
require_relative "errors"

module Microsandbox
  # Node.js-specific sandbox implementation
  class NodeSandbox < BaseSandbox
    # Get the default Docker image for Node sandbox
    # @return [String] the default Docker image name
    def default_image
      "microsandbox/node"
    end

    # Execute JavaScript code in the sandbox
    # @param code [String] JavaScript code to execute
    # @return [Execution] the execution result
    def run(code)
      raise NotStartedError, "Sandbox is not started. Call start first." unless started?

      request_data = {
        "jsonrpc" => "2.0",
        "method" => "sandbox.repl.run",
        "params" => {
          "sandbox" => @name,
          "namespace" => @namespace,
          "language" => "javascript",
          "code" => code
        },
        "id" => SecureRandom.uuid
      }

      response = make_request(request_data)
      Execution.new(response["result"])
    rescue NotStartedError
      raise
    rescue Net::HTTPError => e
      raise ExecutionError, "Failed to execute JavaScript code: #{e.message}"
    rescue StandardError => e
      raise ExecutionError, "JavaScript execution failed: #{e.message}"
    end
  end
end