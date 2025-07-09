#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../lib/microsandbox"

def demonstrate_python_sandbox
  puts "=== Python Sandbox Example ==="
  
  begin
    Microsandbox::PythonSandbox.create(name: "python-demo") do |sandbox|
      # Basic Python code execution
      result = sandbox.run("print('Hello from Python!')")
      puts "Output: #{result.output}"
      
      # Python with variables
      sandbox.run("x = 42")
      sandbox.run("y = [i**2 for i in range(5)]")
      result = sandbox.run("print(f'x = {x}, y = {y}')")
      puts "Output: #{result.output}"
      
      # Error handling
      result = sandbox.run("print(1 / 0)")
      if result.error?
        puts "Error detected: #{result.error}"
      end
    end
  rescue Microsandbox::Error => e
    puts "Error: #{e.message}"
  end
end

def demonstrate_node_sandbox
  puts "\n=== Node.js Sandbox Example ==="
  
  begin
    Microsandbox::NodeSandbox.create(name: "node-demo") do |sandbox|
      # Basic JavaScript code execution
      result = sandbox.run("console.log('Hello from Node.js!')")
      puts "Output: #{result.output}"
      
      # JavaScript with variables
      sandbox.run("const x = 42")
      sandbox.run("const y = [1, 2, 3, 4, 5].map(i => i * i)")
      result = sandbox.run("console.log(`x = ${x}, y = [${y.join(', ')}]`)")
      puts "Output: #{result.output}"
    end
  rescue Microsandbox::Error => e
    puts "Error: #{e.message}"
  end
end

def demonstrate_ruby_sandbox
  puts "\n=== Ruby Sandbox Example ==="
  
  begin
    Microsandbox::RubySandbox.create(name: "ruby-demo") do |sandbox|
      # Basic Ruby code execution
      result = sandbox.run("puts 'Hello from Ruby!'")
      puts "Output: #{result.output}"
      
      # Ruby with variables
      sandbox.run("x = 42")
      sandbox.run("y = (1..5).map { |i| i ** 2 }")
      result = sandbox.run("puts \"x = #{x}, y = #{y}\"")
      puts "Output: #{result.output}"
      
      # Ruby-specific eval method
      result = sandbox.eval("2 + 2")
      puts "Eval result: #{result}"
    end
  rescue Microsandbox::Error => e
    puts "Error: #{e.message}"
  end
end

def demonstrate_commands
  puts "\n=== Command Execution Example ==="
  
  begin
    Microsandbox::PythonSandbox.create(name: "command-demo") do |sandbox|
      # Execute shell commands
      result = sandbox.command.run("echo", args: ["Hello from command!"])
      puts "Command output: #{result.output}"
      puts "Exit code: #{result.exit_code}"
      puts "Success: #{result.success?}"
      
      # List directory contents
      result = sandbox.command.run("ls", args: ["-la"])
      puts "Directory listing:"
      puts result.output
    end
  rescue Microsandbox::Error => e
    puts "Error: #{e.message}"
  end
end

def demonstrate_metrics
  puts "\n=== Metrics Example ==="
  
  begin
    Microsandbox::PythonSandbox.create(name: "metrics-demo") do |sandbox|
      # Run some code first
      sandbox.run("import time; time.sleep(0.1)")
      
      # Get metrics
      metrics = sandbox.metrics.get
      puts "Full metrics: #{metrics}"
      
      # Get specific metrics
      cpu_metrics = sandbox.metrics.cpu
      memory_metrics = sandbox.metrics.memory
      
      puts "CPU metrics: #{cpu_metrics}"
      puts "Memory metrics: #{memory_metrics}"
    end
  rescue Microsandbox::Error => e
    puts "Error: #{e.message}"
  end
end

def demonstrate_explicit_lifecycle
  puts "\n=== Explicit Lifecycle Management Example ==="
  
  begin
    sandbox = Microsandbox::PythonSandbox.new(name: "lifecycle-demo")
    
    # Start with custom configuration
    sandbox.start(memory: 1024, cpus: 2)
    puts "Sandbox started: #{sandbox.started?}"
    
    # Execute multiple code blocks
    sandbox.run("data = [1, 2, 3, 4, 5]")
    sandbox.run("total = sum(data)")
    result = sandbox.run("print(f'Sum: {total}')")
    puts "Output: #{result.output}"
    
    # Stop the sandbox
    sandbox.stop
    puts "Sandbox stopped: #{sandbox.started?}"
  rescue Microsandbox::Error => e
    puts "Error: #{e.message}"
  end
end

# Run all examples
if __FILE__ == $0
  puts "Microsandbox Ruby SDK Examples"
  puts "=============================="
  
  demonstrate_python_sandbox
  demonstrate_node_sandbox
  demonstrate_ruby_sandbox
  demonstrate_commands
  demonstrate_metrics
  demonstrate_explicit_lifecycle
  
  puts "\n=== Examples Complete ==="
end