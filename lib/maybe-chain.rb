require "maybe-chain/version"
require "delegate"
require "singleton"

module MaybeChain
  class MaybeWrapper < Delegator
    def initialize(obj, rescuables = [])
      raise ArgumentError unless (rescuables.is_a?(Class) && rescuables <= Exception) || rescuables.is_a?(Array)

      if rescuables.is_a?(Exception)
        @rescuables = [rescuables]
      else
        @rescuables = rescuables
      end

      if obj.nil?
        @obj = Nothing.instance
      else
        @obj = obj
      end
    end

    def __getobj__
      @obj
    end

    def inspect
      "<Maybe: #{@obj.inspect}>"
    end

    def to_s
      @obj.to_s
    end

    def method_missing(m, *args, &block)
      if nothing?
        self.__getobj__.__send__(m, @rescuables, &block)
      else
        MaybeWrapper.new(super, @rescuables)
      end
    rescue *@rescuables
      MaybeWrapper.new(Nothing.instance, @rescuables)
    end

    def nothing?
      @obj.is_a? Nothing
    end

    def just?
      !nothing?
    end

    def value
      if nothing?
        nil
      else
        @obj
      end
    end
  end

  class Nothing
    include Singleton

    def inspect
      "Nothing"
    end

    def to_s
      "Nothing"
    end

    def method_missing(method, *args, &block)
      rescuables = args.first || []
      MaybeWrapper.new(self, rescuables)
    end
  end

  module ObjectExtend
    def to_maybe(rescuables = [])
      MaybeChain::MaybeWrapper.new(self, rescuables)
    end
  end

  module KernelExtend
    def maybe(maybe_wrapper, default = nil, &block)
      if maybe_wrapper.just?
        block.call(maybe_wrapper.value)
      elsif default
        block.call(default)
      end
    end
  end
end

Object.__send__ :include, MaybeChain::ObjectExtend

module Kernel
  include MaybeChain::KernelExtend
end

class << self
  include MaybeChain::KernelExtend
end
