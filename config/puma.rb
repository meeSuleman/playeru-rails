# frozen_string_literal: true

# Maximum and minimum threads per worker
max_threads_count = ENV.fetch('RAILS_MAX_THREADS', 5).to_i
min_threads_count = ENV.fetch('RAILS_MIN_THREADS', max_threads_count).to_i
threads min_threads_count, max_threads_count

# Worker timeout in development
worker_timeout 3600 if ENV.fetch('RAILS_ENV', 'development') == 'development'

# Port and environment configuration
port ENV.fetch('PORT', 3000)
environment ENV.fetch('RAILS_ENV', 'development')

# Specify the PID file
pidfile ENV.fetch('PIDFILE', 'tmp/pids/server.pid')

# Number of workers (processes)
workers ENV.fetch('WEB_CONCURRENCY', 3).to_i

# Preload the app for Copy-On-Write memory savings
preload_app!

# Allow puma to be restarted by `bin/rails restart` command
plugin :tmp_restart

on_worker_boot do
  # Reconnect ActiveRecord after worker boots
  ActiveRecord::Base.establish_connection if defined?(ActiveRecord)
end
