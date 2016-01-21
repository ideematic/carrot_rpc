
class CarrotRpc::CLI
  # Class methods
  class << self
    def self.run!(argv = ARGV)
      parse_options(argv)
    end

    def parse_options(args = ARGV)
      # Set defaults below.
      version             = "1.0.0"
      daemonize_help      = "run daemonized in the background (default: false)"
      runloop_sleep_help  = "Configurable sleep time in the runloop"
      pidfile_help        = "the pid filename"
      include_help        = "an additional $LOAD_PATH"
      debug_help          = "set $DEBUG to true"
      warn_help           = "enable warnings"
      autoload_rails_help = "loads rails env by default. Uses Rails Logger by default."
      logfile_help        = "relative path and name for Log file. Overrides Rails logger."
      loglevel_help       = "levels of loggin: DEBUG < INFO < WARN < ERROR < FATAL < UNKNOWN"
      rabbitmq_url_help   = "connection string to RabbitMQ 'amqp://user:pass@host:10000/vhost'"

      op = OptionParser.new
      op.banner =  "RPC Server Runner for RabbitMQ RPC Services."
      op.separator ""
      op.separator "Usage: server [options]"
      op.separator ""

      op.separator "Process options:"
      op.on("-d", "--daemonize", daemonize_help) do
        CarrotRpc.configuration.daemonize = true
      end

      op.on(" ", "--pidfile PIDFILE", pidfile_help) do |value|
        CarrotRpc.configuration.pidfile = value
      end

      op.on("-s", "--runloop_sleep VALUE", Float, runloop_sleep_help) do |value|
        CarrotRpc.configuration.runloop_sleep = value
      end

      op.on(" ", "--autoload_rails value", autoload_rails_help) do |value|
        pv = value == "false" ? false : true
        CarrotRpc.configuration.autoload_rails = pv
      end

      op.on(" ", "--logfile VALUE", logfile_help) do |value|
        CarrotRpc.configuration.logfile = File.expand_path("../../#{value}", __FILE__)
      end

      op.on(" ", "--loglevel VALUE", loglevel_help) do |value|
        level = eval(["Logger", value].join("::")) || 0
        CarrotRpc.configuration.loglevel = level
      end

      # Optional. Defaults to using the ENV['RABBITMQ_URL']
      op.on(" ", "--rabbitmq_url VALUE", rabbitmq_url_help) do |value|
        CarrotRpc.configuration.bunny = Bunny.new(value)
      end

      op.separator ""

      op.separator "Ruby options:"
      op.on("-I", "--include PATH", include_help) do |value|
        $LOAD_PATH.unshift(*value.split(":").map { |v| File.expand_path(v) })
      end
      op.on("--debug",        debug_help)   { $DEBUG = true }
      op.on("--warn",         warn_help)    { $-w = true    }
      op.separator ""

      op.separator "Common options:"
      op.on("-h", "--help") do
        puts op.to_s
        exit
      end
      op.on("-v", "--version") do
        puts version
        exit
      end
      op.separator ""
      op.parse!(args)
    end
  end
end
