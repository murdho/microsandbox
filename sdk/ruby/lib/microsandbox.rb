# frozen_string_literal: true

require_relative "microsandbox/version"
require_relative "microsandbox/errors"
require_relative "microsandbox/execution"
require_relative "microsandbox/command_execution"
require_relative "microsandbox/command"
require_relative "microsandbox/metrics"
require_relative "microsandbox/base_sandbox"
require_relative "microsandbox/python_sandbox"
require_relative "microsandbox/node_sandbox"
require_relative "microsandbox/ruby_sandbox"

# Microsandbox SDK for Ruby
#
# This module provides a Ruby interface for interacting with the Microsandbox
# secure MicroVM provisioning system. It allows you to create isolated
# environments for running untrusted code safely.
#
# @example Basic usage with Python sandbox
#   Microsandbox::PythonSandbox.create(name: "my-sandbox") do |sandbox|
#     result = sandbox.run("print('Hello, world!')")
#     puts result.output
#   end
#
# @example Explicit lifecycle management
#   sandbox = Microsandbox::PythonSandbox.new(name: "my-sandbox")
#   sandbox.start(memory: 1024, cpus: 2)
#   
#   result = sandbox.run("x = 42")
#   result = sandbox.run("print(x)")
#   puts result.output
#   
#   sandbox.stop
#
module Microsandbox
end
