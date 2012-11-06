require "maybe-chain/version"
require "delegate"
require "singleton"

module MaybeChain
  class MaybeWrapper < Delegator
    def initialize(obj)
      if obj.nil?
        @obj = Nothing.instance
      else
        @obj = obj
      end
    end

    def __getobj__
      @obj
    end

    def method_missing(m, *args, &block)
      if nothing?
        self.__getobj__.__send__(m, *args, &block)
      else
        MaybeWrapper.new(super)
      end
    end

    def nothing?
      @obj.class == MaybeChain::Nothing
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

    def method_missing(method, *args, &block)
      MaybeWrapper.new(self)
    end
  end

  module ObjectExtend
    def to_maybe
      MaybeChain::MaybeWrapper.new(self)
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
