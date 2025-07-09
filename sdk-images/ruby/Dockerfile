# First stage: Build the portal binary with Ruby feature enabled
FROM rust:slim AS builder

# Install dependencies and build the portal binary
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    pkg-config \
    libssl-dev \
    && apt-get clean && rm -rf /var/lib/apt/lists/* \
    && mkdir -p /usr/src/microsandbox

WORKDIR /usr/src/microsandbox
COPY . .
RUN cargo build --release --bin portal --features ruby

# Second stage: Create the Ruby image
FROM ruby:3.3-slim

# Set environment variables
ENV RUBY_YJIT_ENABLE=1 \
    BUNDLE_SILENCE_ROOT_WARNING=1 \
    DEBIAN_FRONTEND=noninteractive

ARG USER_NAME="ruby-user"
ARG USER_UID="1000"
ARG USER_GID="100"

# Install system dependencies, create user, set up directories, and install Ruby gems in one layer
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    curl \
    git \
    wget \
    libssl-dev \
    ca-certificates \
    && apt-get clean && rm -rf /var/lib/apt/lists/* \
    # Create non-root user and necessary directories
    && useradd -m -s /bin/bash -N -u $USER_UID $USER_NAME \
    && mkdir -p /home/$USER_NAME/work \
    && chown -R $USER_NAME:$USER_GID /home/$USER_NAME \
    && mkdir -p /etc/microsandbox/portal \
    && chown -R $USER_NAME:$USER_GID /etc/microsandbox \
    # Install core Ruby gems
    && gem install --no-document \
        bundler \
        pry \
        rspec \
        rubocop \
        yard \
        debug \
        rake \
        minitest

# Copy the portal binary from the builder stage and set permissions
COPY --from=builder /usr/src/microsandbox/target/release/portal /usr/local/bin/
RUN chmod +x /usr/local/bin/portal

# Switch to the non-root user
USER $USER_NAME
WORKDIR /home/$USER_NAME/work

# Set a command that starts portal and keeps the container running
CMD ["bash", "-c", "echo 'Ruby environment with microsandbox-portal ready' && RUST_LOG=debug portal & tail -f /dev/null"]