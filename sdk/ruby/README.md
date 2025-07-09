# Microsandbox Ruby SDK

A Ruby SDK for the Microsandbox project - secure MicroVM provisioning for running untrusted code.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'microsandbox'
```

And then execute:

```bash
bundle install
```

Or install it yourself as:

```bash
gem install microsandbox
```

## Usage

### Basic Usage with Block Syntax

```ruby
require 'microsandbox'

# Python sandbox with automatic cleanup
Microsandbox::PythonSandbox.create(name: "my-python-sandbox") do |sandbox|
  result = sandbox.run("print('Hello from Python!')")
  puts result.output  # => "Hello from Python!"
end

# Node.js sandbox
Microsandbox::NodeSandbox.create(name: "my-node-sandbox") do |sandbox|
  result = sandbox.run("console.log('Hello from Node.js!')")
  puts result.output  # => "Hello from Node.js!"
end

# Ruby sandbox
Microsandbox::RubySandbox.create(name: "my-ruby-sandbox") do |sandbox|
  result = sandbox.run("puts 'Hello from Ruby!'")
  puts result.output  # => "Hello from Ruby!"
end
```

### Explicit Lifecycle Management

```ruby
require 'microsandbox'

# Create and configure a sandbox
sandbox = Microsandbox::PythonSandbox.new(name: "data-analysis")
sandbox.start(memory: 1024, cpus: 2)

# Execute code with state persistence
sandbox.run("import numpy as np")
sandbox.run("data = np.array([1, 2, 3, 4, 5])")
result = sandbox.run("print(f'Mean: {data.mean()}')")

puts result.output  # => "Mean: 3.0"

# Clean up
sandbox.stop
```

### Command Execution

```ruby
Microsandbox::PythonSandbox.create do |sandbox|
  # Execute shell commands
  result = sandbox.command.run("ls", args: ["-la"])
  puts result.output
  puts "Exit code: #{result.exit_code}"
  puts "Success: #{result.success?}"
end
```

### Metrics

```ruby
Microsandbox::PythonSandbox.create do |sandbox|
  # Get sandbox metrics
  metrics = sandbox.metrics.get
  puts "CPU usage: #{metrics.dig('cpu', 'usage')}"
  puts "Memory usage: #{metrics.dig('memory', 'usage')}"
  
  # Or get specific metrics
  cpu_metrics = sandbox.metrics.cpu
  memory_metrics = sandbox.metrics.memory
end
```

### Error Handling

```ruby
require 'microsandbox'

begin
  Microsandbox::PythonSandbox.create do |sandbox|
    result = sandbox.run("1 / 0")  # This will cause a Python error
    
    if result.error?
      puts "Error occurred: #{result.error}"
    else
      puts "Output: #{result.output}"
    end
  end
rescue Microsandbox::ExecutionError => e
  puts "Execution failed: #{e.message}"
rescue Microsandbox::StartError => e
  puts "Failed to start sandbox: #{e.message}"
end
```

### Ruby-Specific Features

```ruby
# Ruby sandbox has additional convenience methods
Microsandbox::RubySandbox.create do |sandbox|
  # Use eval for simple expressions
  result = sandbox.eval("2 + 2")
  puts result  # => "4"
  
  # Execute blocks (experimental)
  result = sandbox.execute do
    puts "This is executed in the sandbox"
    42
  end
end
```

### Configuration

You can configure the SDK using environment variables:

```bash
export MSB_SERVER_URL="http://localhost:5555"
export MSB_API_KEY="your-api-key"
```

Or pass them explicitly:

```ruby
sandbox = Microsandbox::PythonSandbox.new(
  server_url: "http://localhost:5555",
  api_key: "your-api-key",
  namespace: "production",
  name: "my-sandbox"
)
```

### Method Chaining

```ruby
result = Microsandbox::PythonSandbox.new(name: "chained")
  .start(memory: 512)
  .then { |sb| sb.run("x = 42") }
  .then { |sb| sb.run("print(x)") }
  
puts result.output  # => "42"
```

## Development

After checking out the repo, run `bundle install` to install dependencies. Then, run `rake test` to run the tests.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/microsandbox/microsandbox.

## License

[Apache 2.0](https://www.apache.org/licenses/LICENSE-2.0)
