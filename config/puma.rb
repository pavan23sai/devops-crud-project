
# Puma is the web server that runs our Rails application.

# Set the number of threads used by each Puma worker.
# More threads allow the server to handle more requests concurrently.
threads_count = ENV.fetch("RAILS_MAX_THREADS", 3).to_i
threads threads_count, threads_count

# Set the number of worker processes.
# We start with one worker to keep memory usage low.
workers ENV.fetch("WEB_CONCURRENCY", 1).to_i

# The port on which Puma receives HTTP requests.
port ENV.fetch("PORT", 3000)

# Allow Rails to restart Puma using the restart command.
plugin :tmp_restart
