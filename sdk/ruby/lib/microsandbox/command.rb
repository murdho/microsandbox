# frozen_string_literal: true

require "json"
require "net/http"
require "uri"
require_relative "command_execution"
require_relative "errors"

module Microsandbox
  # Command execution interface for sandboxes
  class Command
    def initialize(sandbox)
      @sandbox = sandbox
    end

    # Execute a shell command in the sandbox
    # @param command [String] the command to execute
    # @param args [Array<String>] optional command arguments
    # @param timeout [Integer] optional timeout in seconds
    # @return [CommandExecution] the command execution result
    def run(command, args: [], timeout: nil)
      raise NotStartedError, "Sandbox is not started. Call start first." unless @sandbox.started?

      request_data = {
        "jsonrpc" => "2.0",
        "method" => "sandbox.command.run",
        "params" => {
          "sandbox" => @sandbox.name,
          "namespace" => @sandbox.namespace,
          "command" => command,
          "args" => args
        },
        "id" => SecureRandom.uuid
      }

      request_data["params"]["timeout"] = timeout if timeout

      response = @sandbox.send(:make_request, request_data)
      CommandExecution.new(response["result"])
    rescue Net::HTTPError => e
      raise CommandError, "Failed to execute command: #{e.message}"
    rescue StandardError => e
      raise CommandError, "Command execution failed: #{e.message}"
    end
  end
end