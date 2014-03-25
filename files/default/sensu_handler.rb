require 'rubygems'

gem 'oj', '2.0.9'

require File.join(File.dirname(__FILE__), '_rabbitmq')
require 'json'
require 'oj'

Oj.default_options = { mode: :compat, symbol_keys: true }

class Chef
  class Handler
    class Sensu
      class RabbitAPI
        def initialize(host, port, config_file)
          @settings = {}
          @check = {}

          load_sensu_config(config_file)
          @settings[:rabbitmq][:host] = host
          @settings[:rabbitmq][:port] = port

          @check['name'] = 'chef_report'
          @check['handlers'] = 'default'
          @check['standalone'] = true
        end

        def load_sensu_config(file)
          if File.file?(file) && File.readable?(file)
            begin
              contents = File.open(file, 'r').read
              @settings = Oj.load(contents)
              Chef::Log.info("Loaded Config:\n#{@settings[:rabbitmq]}")
            rescue Oj::ParseError => error
              Chef::Log.error('config file is invalid. Ignoring config file..')
            end
          else
            Chef::Log.error('config file does not exist or is not readable')
          end
        end

        def setup_rabbitmq
          Chef::Log.info("connecting to rabbitmq: \
            #{@settings[:rabbitmq][:host]}:#{@settings[:rabbitmq][:port]}")
          @rabbitmq = RabbitMQ.connect(@settings[:rabbitmq])
          @rabbitmq.on_error do |error|
            Chef::Log.info("rabbitmq connection error: #{error.to_s}")
            close
          end
          @rabbitmq.before_reconnect do
            Chef::Log.debug('reconnecting to rabbitmq')
          end
          @rabbitmq.after_reconnect do
            Chef::Log.info('reconnected to rabbitmq')
          end
          @amq = @rabbitmq.channel
          Chef::Log.info("established channel: #{@amq.conn.broker_endpoint}")
        end

        def send_report(node, run_status)
          if run_status.failed?
            @check['output'] = "Chef run failed on #{node['fqdn']}.."
            @check['output'] << "#{run_status.formatted_exception}"
            @check['status'] = 2
          else
            @check['output'] = "Chef run converged on #{node['fqdn']} in #{run_status.elapsed_time} secs."
            @check['status'] = 0
          end

          payload = {
            'client' => node['fqdn'],
            'check' => @check
          }

          Chef::Log.info("publishing payload: #{payload}")

          result_ = @amq.direct('results').publish(Oj.dump(payload))
        end

        def close
          EM::Timer.new(1) do
            @rabbitmq.close
            EM.stop_event_loop
          end
        end
      end

      class ReportSensu < Chef::Handler
        def initialize(config = {})
          @rabbit_api = Chef::Handler::Sensu::RabbitAPI.new(
              config[:rabbit_host],
              config[:rabbit_port],
              config[:config_file]
          )
          EM.threadpool_size = 14
        end

        def report
          EM.run do
            @rabbit_api.setup_rabbitmq
            @rabbit_api.send_report(node, run_status)
            @rabbit_api.close
          end
        end
      end
    end
  end
end
