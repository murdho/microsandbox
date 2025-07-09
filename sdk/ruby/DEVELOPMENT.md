# Development Guide

This guide covers development setup and processes for the Microsandbox Ruby SDK.

## Setup

1. **Clone the repository**:
   ```bash
   git clone https://github.com/microsandbox/microsandbox.git
   cd microsandbox/sdk/ruby
   ```

2. **Install dependencies**:
   ```bash
   bundle install
   ```

3. **Start the Microsandbox server** (for testing):
   ```bash
   cd ../../
   make build
   make install
   msb server start --dev
   ```

## Testing

Run the test suite:
```bash
bundle exec rake test
```

Run specific test files:
```bash
bundle exec ruby test/execution_test.rb
```

Run with verbose output:
```bash
bundle exec rake test TESTOPTS="-v"
```

## Code Style

This project uses Rubocop for code formatting and linting:

```bash
bundle exec rubocop
```

Auto-fix issues:
```bash
bundle exec rubocop --auto-correct
```

## Documentation

Generate documentation with YARD:
```bash
bundle exec yard doc
```

View documentation:
```bash
bundle exec yard server
```

## Building and Installing

Build the gem:
```bash
gem build microsandbox.gemspec
```

Install locally:
```bash
gem install microsandbox-0.2.6.gem
```

## Project Structure

```
├── lib/
│   ├── microsandbox.rb              # Main module
│   └── microsandbox/
│       ├── version.rb               # Version constant
│       ├── errors.rb                # Exception classes
│       ├── base_sandbox.rb          # Abstract base class
│       ├── python_sandbox.rb        # Python sandbox
│       ├── node_sandbox.rb          # Node.js sandbox
│       ├── ruby_sandbox.rb          # Ruby sandbox
│       ├── execution.rb             # Execution results
│       ├── command_execution.rb     # Command results
│       ├── command.rb               # Command interface
│       └── metrics.rb               # Metrics interface
├── test/
│   ├── test_helper.rb               # Test configuration
│   └── *_test.rb                    # Test files
├── examples/
│   ├── basic_usage.rb               # Usage examples
│   └── README.md                    # Example documentation
├── README.md                        # Main documentation
├── DEVELOPMENT.md                   # This file
└── microsandbox.gemspec             # Gem specification
```

## Adding New Features

1. **Create a new feature branch**:
   ```bash
   git checkout -b feature/new-feature
   ```

2. **Add implementation** in `lib/microsandbox/`

3. **Add tests** in `test/`

4. **Update documentation** in README.md if needed

5. **Run tests**:
   ```bash
   bundle exec rake test
   ```

6. **Run linting**:
   ```bash
   bundle exec rubocop
   ```

7. **Create pull request**

## Common Tasks

### Adding a New Sandbox Type

1. Create `lib/microsandbox/new_sandbox.rb`
2. Inherit from `BaseSandbox`
3. Implement `default_image` method
4. Add to `lib/microsandbox.rb` requires
5. Add tests in `test/new_sandbox_test.rb`

### Adding New Error Types

1. Add to `lib/microsandbox/errors.rb`
2. Document in README.md
3. Add tests if needed

### Updating Dependencies

1. Update `microsandbox.gemspec`
2. Run `bundle update`
3. Test thoroughly
4. Update documentation if needed

## Release Process

1. Update version in `lib/microsandbox/version.rb`
2. Update CHANGELOG.md
3. Run full test suite
4. Build and test gem locally
5. Create release PR
6. Tag release after merge
7. Push to RubyGems

## Troubleshooting

### Test Failures

- Ensure Microsandbox server is running
- Check that required images are available
- Verify environment variables are set

### Dependency Issues

- Try `bundle update`
- Check Ruby version compatibility
- Ensure all dependencies are available

### Development Server Issues

- Restart the Microsandbox server
- Check server logs for errors
- Verify server configuration
