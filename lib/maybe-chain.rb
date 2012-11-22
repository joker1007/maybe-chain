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

      @obj = obj.nil? ? Nothing.instance : obj
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
      build_nothing
    end

    def nothing?
      @obj.is_a? Nothing
    end

    def just?
      !nothing?
    end

    def value
      nothing? ? nil : @obj
    end

    def lift(method_name, *args, &block)
      return build_nothing if nothing?
      return build_nothing if args.any?(&:nothing?)

      extracts = args.map {|arg| arg.is_a?(MaybeChain::MaybeWrapper) ? arg.value : arg}
      MaybeWrapper.new(value.__send__(method_name, *extracts, &block), @rescuables)
    rescue *@rescuables
      build_nothing
    end

    private
    def build_nothing
      self.class.new(Nothing.instance, @rescuables)
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
  end
end

Object.__send__ :include, MaybeChain::ObjectExtend

module Kernel
  def maybe(maybe_wrapper, default = nil, &block)
    if maybe_wrapper.just?
      block.call(maybe_wrapper.value)
    elsif default
      block.call(default)
    end
  end
end
