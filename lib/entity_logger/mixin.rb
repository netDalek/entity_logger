require 'active_support/concern'
require 'active_support/core_ext/class'
require 'active_support/core_ext/object/blank'
require 'active_support/core_ext/class/attribute'
require 'active_support/deprecation'
require 'active_support/core_ext'
require 'active_support/tagged_logging'

module EntityLogger
  module Mixin
    extend ActiveSupport::Concern

    LOG_METHODS = %w[
      debug
      error
      fatal
      info
      unknown
      warn
    ]

    included do
      def self.log(*attrs)
        self.logger = attrs.shift
        self.tags_for_logging = attrs
      end

    private
      class_attribute :tags_for_logging, :logger
    end

    def log_with_tags(&block)
      if @without_log_tags
        yield
      else
        begin
          tags = extract_tags(self.tags_for_logging)
          @without_log_tags = true
          logger.tagged(tags) { yield }
        ensure
          @without_log_tags = false
        end
      end
    end

    LOG_METHODS.each do |level|
      define_method(level) do |msg|
        log_with_tags do
          logger.send(level, msg)
        end
      end
    end

  private
    def extract_tags(attrs)
      attrs.map do |attr|
        case attr
        when Hash
          attr.values.map { |v| v.call(self) }
        when String
          attr
        when Symbol
          send(attr)
        else
          raise ArgumentError, attr
        end
      end.flatten(1)
    end
  end
end
