# Ruby SDK Image

This directory contains the Docker image definition for the Ruby execution environment in microsandbox.

## What's Included

The Ruby SDK image provides:

- **Ruby 3.3**: Latest stable Ruby runtime with YJIT enabled
- **Core Development Tools**: bundler, pry, rspec, rubocop, yard, debug, rake, minitest
- **Build Tools**: build-essential, git, curl, wget, SSL support
- **Security**: Non-root user execution
- **Microsandbox Portal**: Built-in portal binary with Ruby feature enabled

## Building the Image

To build the Ruby SDK image:

```bash
# From the root of the microsandbox repository
docker build -f sdk-images/ruby/Dockerfile -t microsandbox/ruby .
```

## Using the Image

### With Docker directly

```bash
# Run the Ruby environment
docker run -it --rm microsandbox/ruby ruby --version

# Run a Ruby script
docker run -it --rm -v $(pwd):/home/ruby-user/work microsandbox/ruby ruby script.rb
```

### With Microsandbox SDK

```ruby
require 'microsandbox'

# The RubySandbox will automatically use the microsandbox/ruby image
Microsandbox::RubySandbox.create do |sandbox|
  result = sandbox.run("puts 'Hello from Ruby!'")
  puts result.output
end
```

## Features

- **YJIT Enabled**: Just-In-Time compilation for better performance
- **Interactive Development**: Includes pry for enhanced REPL experience
- **Testing Framework**: RSpec and Minitest for test-driven development
- **Code Quality**: Rubocop for linting and style checking
- **Documentation**: YARD for generating documentation
- **Debugging**: Built-in debug gem for debugging capabilities

## Security

The image follows security best practices:
- Runs as non-root user (`ruby-user`)
- Minimal attack surface with slim base image
- No unnecessary packages installed
- Proper file permissions and ownership

## Environment Variables

- `RUBY_YJIT_ENABLE=1`: Enables YJIT for better performance
- `BUNDLE_SILENCE_ROOT_WARNING=1`: Suppresses bundler warnings
- `DEBIAN_FRONTEND=noninteractive`: Non-interactive package installation

## Ports

The portal service listens on the default port for communication with the microsandbox server.

## Volumes

- `/home/ruby-user/work`: Default working directory for code execution
- `/etc/microsandbox/portal`: Portal configuration directory