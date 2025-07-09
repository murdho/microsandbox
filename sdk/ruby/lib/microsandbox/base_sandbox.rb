# frozen_string_literal: true

require "json"
require "net/http"
require "uri"
require "dotenv"
require "securerandom"
require_relative "errors"
require_relative "command"
require_relative "metrics"

module Microsandbox
  # Base abstract class for all sandbox implementations
  class BaseSandbox
    DEFAULT_SERVER_URL = "http://127.0.0.1:5555"

    attr_reader :server_url, :namespace, :name, :api_key

    def initialize(server_url: nil, namespace: "default", name: nil, api_key: nil)
      # Load environment variables from .env file if MSB_API_KEY is not set
      load_env_if_needed

      @server_url = server_url || ENV["MSB_SERVER_URL"] || DEFAULT_SERVER_URL
      @namespace = namespace
      @name = name || generate_sandbox_name
      @api_key = api_key || ENV["MSB_API_KEY"]
      @started = false
    end

    # Abstract method to get the default image for this sandbox type
    # @return [String] the default Docker image name
    def default_image
      raise NotImplementedError, "Subclasses must implement #default_image"
    end

    # Create a sandbox with automatic cleanup using a block
    # @param kwargs [Hash] initialization parameters
    # @yield [BaseSandbox] the sandbox instance
    def self.create(**kwargs, &block)
      sandbox = new(**kwargs)
      return sandbox unless block_given?

      begin
        sandbox.start
        yield sandbox
      ensure
        sandbox.stop if sandbox.started?
      end
    end

    # Start the sandbox
    # @param image [String] Docker image to use (defaults to language-specific image)
    # @param memory [Integer] memory limit in MB
    # @param cpus [Integer] CPU limit
    # @param timeout [Float] timeout in seconds
    def start(image: nil, memory: 512, cpus: 1, timeout: 180.0)
      raise AlreadyStartedError, "Sandbox is already started" if @started

      sandbox_image = image || default_image
      request_data = {
        "jsonrpc" => "2.0",
        "method" => "sandbox.start",
        "params" => {
          "namespace" => @namespace,
          "sandbox" => @name,
          "config" => {
            "image" => sandbox_image,
            "memory" => memory,
            "cpus" => cpus.to_i
          }
        },
        "id" => SecureRandom.uuid
      }

      response = make_request(request_data, timeout: timeout)
      result = response["result"]

      # Check if the result indicates a timeout warning
      if result.is_a?(String) && result.include?("timed out waiting")
        warn "Sandbox start warning: #{result}"
      end

      @started = true
      self
    rescue Net::HTTPError => e
      raise StartError, "Failed to start sandbox: #{e.message}"
    rescue StandardError => e
      raise StartError, "Sandbox start failed: #{e.message}"
    end

    # Stop the sandbox
    def stop
      return self unless @started

      request_data = {
        "jsonrpc" => "2.0",
        "method" => "sandbox.stop",
        "params" => {
          "namespace" => @namespace,
          "sandbox" => @name
        },
        "id" => SecureRandom.uuid
      }

      make_request(request_data)
      @started = false
      self
    rescue Net::HTTPError => e
      raise StopError, "Failed to stop sandbox: #{e.message}"
    rescue StandardError => e
      raise StopError, "Sandbox stop failed: #{e.message}"
    end

    # Abstract method to run code in the sandbox
    # @param code [String] the code to execute
    # @return [Execution] the execution result
    def run(code)
      raise NotImplementedError, "Subclasses must implement #run"
    end

    # Check if the sandbox is started
    # @return [Boolean] true if started
    def started?
      @started
    end

    # Get the command interface
    # @return [Command] command execution interface
    def command
      @command ||= Command.new(self)
    end

    # Get the metrics interface
    # @return [Metrics] metrics interface
    def metrics
      @metrics ||= Metrics.new(self)
    end

    # Enable method chaining after start
    # @return [BaseSandbox] self for method chaining
    def then(&block)
      block.call(self) if block_given?
      self
    end

    private

    def load_env_if_needed
      return if ENV["MSB_API_KEY"]

      begin
        Dotenv.load
      rescue StandardError
        # Ignore errors if .env file doesn't exist
      end
    end

    def generate_sandbox_name
      "sandbox-#{SecureRandom.hex(4)}"
    end

    def make_request(request_data, timeout: 30)
      uri = URI("#{@server_url}/api/v1/rpc")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme == "https"
      http.read_timeout = timeout
      http.open_timeout = timeout

      request = Net::HTTP::Post.new(uri)
      request["Content-Type"] = "application/json"
      request["Authorization"] = "Bearer #{@api_key}" if @api_key
      request.body = JSON.generate(request_data)

      response = http.request(request)

      unless response.is_a?(Net::HTTPSuccess)
        raise Net::HTTPError, "HTTP #{response.code}: #{response.body}"
      end

      response_data = JSON.parse(response.body)

      if response_data["error"]
        error = response_data["error"]
        raise APIError.new(error["code"], error["message"])
      end

      response_data
    rescue Net::TimeoutError => e
      raise TimeoutError, "Request timed out: #{e.message}"
    rescue JSON::ParserError => e
      raise ClientError, "Invalid JSON response: #{e.message}"
    rescue StandardError => e
      raise ClientError, "HTTP request failed: #{e.message}"
    end
  end
end