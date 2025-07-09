# frozen_string_literal: true

require "json"
require "net/http"
require "uri"
require_relative "errors"

module Microsandbox
  # Metrics interface for sandboxes
  class Metrics
    def initialize(sandbox)
      @sandbox = sandbox
    end

    # Get sandbox metrics
    # @return [Hash] the metrics data
    def get
      raise NotStartedError, "Sandbox is not started. Call start first." unless @sandbox.started?

      request_data = {
        "jsonrpc" => "2.0",
        "method" => "sandbox.metrics.get",
        "params" => {
          "sandbox" => @sandbox.name,
          "namespace" => @sandbox.namespace
        },
        "id" => SecureRandom.uuid
      }

      response = @sandbox.send(:make_request, request_data)
      response["result"]
    rescue Net::HTTPError => e
      raise ClientError, "Failed to get metrics: #{e.message}"
    rescue StandardError => e
      raise Error, "Metrics retrieval failed: #{e.message}"
    end

    # Get CPU usage metrics
    # @return [Hash] CPU usage data
    def cpu
      metrics = get
      metrics["cpu"] || {}
    end

    # Get memory usage metrics
    # @return [Hash] memory usage data
    def memory
      metrics = get
      metrics["memory"] || {}
    end

    # Get network metrics
    # @return [Hash] network usage data
    def network
      metrics = get
      metrics["network"] || {}
    end

    # Get disk I/O metrics
    # @return [Hash] disk I/O data
    def disk
      metrics = get
      metrics["disk"] || {}
    end
  end
end