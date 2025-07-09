# Microsandbox Ruby SDK Examples

This directory contains examples demonstrating how to use the Microsandbox Ruby SDK.

## Running the Examples

Before running the examples, make sure you have:

1. **Microsandbox server running**:
   ```bash
   msb server start --dev
   ```

2. **Ruby SDK installed**:
   ```bash
   cd sdk/ruby
   bundle install
   ```

3. **Environment configured** (optional):
   ```bash
   export MSB_SERVER_URL="http://127.0.0.1:5555"
   export MSB_API_KEY="your-api-key"  # if authentication is enabled
   ```

## Examples

### Basic Usage (`basic_usage.rb`)

Comprehensive example showing:
- Python, Node.js, and Ruby sandboxes
- Code execution with state persistence
- Command execution
- Metrics collection
- Explicit lifecycle management
- Error handling

Run with:
```bash
ruby examples/basic_usage.rb
```

## Example Output

When you run the basic usage example, you should see output similar to:

```
Microsandbox Ruby SDK Examples
==============================

=== Python Sandbox Example ===
Output: Hello from Python!
Output: x = 42, y = [0, 1, 4, 9, 16]
Error detected: ZeroDivisionError: division by zero

=== Node.js Sandbox Example ===
Output: Hello from Node.js!
Output: x = 42, y = [1, 4, 9, 16, 25]

=== Ruby Sandbox Example ===
Output: Hello from Ruby!
Output: x = 42, y = [1, 4, 9, 16, 25]
Eval result: 4

=== Command Execution Example ===
Command output: Hello from command!
Exit code: 0
Success: true
Directory listing:
total 8
drwxr-xr-x    1 root     root          4096 Jan  1 00:00 .
drwxr-xr-x    1 root     root          4096 Jan  1 00:00 ..

=== Metrics Example ===
Full metrics: {"cpu"=>{"usage"=>0.1}, "memory"=>{"usage"=>1024}}
CPU metrics: {"usage"=>0.1}
Memory metrics: {"usage"=>1024}

=== Explicit Lifecycle Management Example ===
Sandbox started: true
Output: Sum: 15
Sandbox stopped: false

=== Examples Complete ===
```

## Troubleshooting

### Server Not Running
If you get connection errors, make sure the Microsandbox server is running:
```bash
msb server start --dev
```

### Authentication Errors
If you get authentication errors, check if you need to set an API key:
```bash
export MSB_API_KEY="$(msb server keygen)"
```

### Image Not Found
If you get image not found errors, pull the required images:
```bash
msb pull microsandbox/python
msb pull microsandbox/node
msb pull microsandbox/ruby
```

## Creating Your Own Examples

To create your own examples:

1. Create a new Ruby file in this directory
2. Require the microsandbox library:
   ```ruby
   require_relative "../lib/microsandbox"
   ```
3. Use the sandbox classes and methods as shown in the examples
4. Add proper error handling
5. Document your example in this README