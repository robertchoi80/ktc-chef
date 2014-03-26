# rubocop:disable all

require 'rubygems'

gem 'amqp', '1.0.0'
gem 'eventmachine', '1.0.3'

require 'uri'
require 'net/http'
require 'amqp'

class Chef
  class Handler
    class Sensu
      class RabbitMQError < StandardError; end

      class RabbitMQ
        attr_reader :channel

        def initialize
          @on_error = proc {}
          @before_reconnect = proc {}
          @after_reconnect = proc {}
        end

        def on_error(&block)
          @on_error = block
        end

        def before_reconnect(&block)
          @before_reconnect = block
        end

        def after_reconnect(&block)
          @after_reconnect = block
        end

        def connect(options = {})
          timeout = EM::Timer.new(10) do
            error = RabbitMQError.new('timed out while attempting to connect')
            @on_error.call(error)
          end
          on_failure = proc do
            error = RabbitMQError.new('failed to connect')
            @on_error.call(error)
          end
          @connection = AMQP.connect(
              options,
              on_tcp_connection_failure: on_failure,
              on_possible_authentication_failure: on_failure
          )
          @connection.on_open do
            timeout.cancel
          end
          reconnect = proc do
            unless @connection.reconnecting?
              @before_reconnect.call
              @connection.periodically_reconnect(5)
            end
          end
          @connection.on_tcp_connection_loss(&reconnect)
          @connection.on_skipped_heartbeats(&reconnect)
          @channel = AMQP::Channel.new(@connection)

          @channel.auto_recovery = true
          @channel.on_error do |channel, channel_close|
            error = RabbitMQError.new('rabbitmq channel closed')
            @on_error.call(error)
          end
          prefetch = 1
          if options.is_a?(Hash)
            prefetch = options[:prefetch] || 1
          end
          @channel.on_recovery do
            @after_reconnect.call
            @channel.prefetch(prefetch)
          end
          @channel.prefetch(prefetch)
        end

        def connected?
          @connection.connected?
        end

        def close
          @connection.close
        end

        def self.connect(options = {})
          options ||= {}
          rabbitmq = new
          rabbitmq.connect(options)
          rabbitmq
        end
      end
    end
  end
end
