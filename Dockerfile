# Stage 1: Build the Rails application.
# Use the official Ruby image with the required Ruby version.
FROM ruby:3.3 AS build

# Set the working directory inside the container.
WORKDIR /app

# Copy dependency files first.
# This helps Docker reuse the dependency-installation layer.
COPY Gemfile Gemfile.lock ./

# Install the Ruby gems required by the application.
RUN bundle install
# Install Linux libraries needed by the Rails application.
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    default-mysql-client \
    libmariadb-dev \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*

# Copy the complete Rails application into the build container.
COPY . .

# Precompile Rails application assets for production.
RUN SECRET_KEY_BASE_DUMMY=1 bundle exec rails assets:precompile

# Stage 2: Create the production runtime image.
# Start with a fresh Ruby image instead of the build image.
FROM ruby:3.3-slim AS runtime

# Set the application directory inside the runtime container.
WORKDIR /app

# Install only the runtime libraries required to connect to MySQL.
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    default-mysql-client \
    libmariadb3 \
    && rm -rf /var/lib/apt/lists/*

# Copy installed Ruby gems from the build stage.
COPY --from=build /usr/local/bundle /usr/local/bundle

# Copy the Rails application from the build stage.
COPY --from=build /app /app

# Create a dedicated user and group for the Rails application.
RUN groupadd --system rails && \
    useradd --system --gid rails --create-home rails

# Give the application user ownership of the application directory.
RUN chown -R rails:rails /app

# Create and assign permissions to Rails runtime directories.
RUN mkdir -p tmp/pids tmp/cache log && \
    chown -R rails:rails tmp log

# Run the application without root privileges.
USER rails
# Expose port 3000 for incoming application traffic.
EXPOSE 3000

# Start the Rails application using the Puma web server.
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]