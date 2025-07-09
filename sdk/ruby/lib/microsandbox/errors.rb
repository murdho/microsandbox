# frozen_string_literal: true

module Microsandbox
  # Base error class for all Microsandbox exceptions
  class Error < StandardError; end

  # Raised when a sandbox fails to start
  class StartError < Error; end

  # Raised when a sandbox fails to stop
  class StopError < Error; end

  # Raised when code execution fails
  class ExecutionError < Error; end

  # Raised when a command execution fails
  class CommandError < Error; end

  # Raised when there's an issue with the HTTP client
  class ClientError < Error; end

  # Raised when the API returns an error response
  class APIError < Error
    attr_reader :code, :message

    def initialize(code, message)
      @code = code
      @message = message
      super("API Error #{code}: #{message}")
    end
  end

  # Raised when authentication fails
  class AuthenticationError < Error; end

  # Raised when a request times out
  class TimeoutError < Error; end

  # Raised when a sandbox is not found
  class NotFoundError < Error; end

  # Raised when trying to operate on a sandbox that isn't started
  class NotStartedError < Error; end

  # Raised when trying to start a sandbox that's already started
  class AlreadyStartedError < Error; end
end