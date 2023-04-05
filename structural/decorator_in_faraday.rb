# frozen_string_literal: true

# 装饰模式是一种结构型设计模式， 允许你通过将对象放入包含行为的特殊封装对象中来为原对象绑定新的行为。

# TODO：Faraday使用了装饰模式来实现middleware的层层调用与层层回调，尝试复现

require 'forwardable'

module Faraday
  # Faraday::Connection.new do |builder|
  #   builder.use Faraday::Middleware::Class
  # end
  class Connection
    attr_reader :builder

    def initialize
      @builder = Faraday::RackBuilder.new

      yield(self) if block_given?
    end

    extend Forwardable

    def_delegator :builder, :use

    def http_method
      builder.build_response
    end
  end
end

module Faraday
  class RackBuilder
    attr_accessor :handlers

    def initialize
      @handlers = []
    end

    def use(klass)
      handlers << klass
    end

    def build_response
      app.call
    end

    # [M1, M2, M3, M4] reverse => [M4, M3, M2, M1]
    # @app = M1.new(M2.new(M3.new(M4.new(Adapter.new())))
    # when app.call
    # M1.on_request  => M2.on_request  => M3.on_request  => M4.on_request => Adapter
    # M1.on_complete <= M2.on_complete <= M3.on_complete <= M4.on_complete
    def app
      @app ||= @handlers.reverse.inject(Faraday::Adapter.new) { |app, handler| handler.new(app) }
    end
  end
end

module  Faraday
  class Adapter
    def call
      Response.new
    end
  end

  class Response
    def on_complete
      yield
      self
    end
  end
end

module Faraday
  class Middleware
    attr_reader :app

    def initialize(app = nil)
      @app = app
    end

    def call
      on_request if respond_to? :on_request
      app.call.on_complete do
        on_complete if respond_to?(:on_complete)
      end
    end

    def on_request; end

    def on_complete; end
  end
end

# define Faraday::M1..Faraday::M4
%w[M1 M2 M3 M4].each do |name|
  klass = Class.new(Faraday::Middleware) do
    define_method(:on_request) do
      puts "#{name} on request"
    end
    define_method(:on_complete) do
      puts "#{name} on complete"
    end
  end
  Faraday.const_set(name, klass)
end

conn = Faraday::Connection.new do |builder|
  builder.use Faraday::M1
  builder.use Faraday::M2
  builder.use Faraday::M3
  builder.use Faraday::M4
end

conn.http_method

# M1 on request
# M2 on request
# M3 on request
# M4 on request
# M4 on complete
# M3 on complete
# M2 on complete
# M1 on complete