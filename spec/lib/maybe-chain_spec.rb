$: << File.join(File.dirname(File.expand_path(__FILE__)), "..", "..", "lib")

require "maybe-chain"

describe MaybeChain do
  describe "Object Extension" do
    subject { "a".to_maybe }
    it { should be_a(MaybeChain::MaybeWrapper) }
  end

  describe "method delegation" do
    subject { "a".to_maybe.upcase }
    its(:value) { should eq "A" }

    context "method returns nil" do
      let(:string) { "a".tap {|s| s.extend(MaybeChain::TestMethod)} }

      subject { string.to_maybe.return_nil.upcase }
      its(:value) { should be_nil }
    end
  end

  describe "maybe extraction" do
    include Kernel

    context "maybe is just" do
      let(:maybe_obj) { "a".to_maybe.upcase }
      it "execute block" do
        i = 0
        expect { maybe(maybe_obj) {i += 1} }.to change {i}.by(1)
      end
    end

    context "maybe is nothing" do
      let(:maybe_obj) { nil.to_maybe.upcase }
      it "no execute block" do
        i = 0
        expect { maybe(maybe_obj) {i += 1} }.not_to change {i}
      end

      context "with default value" do
        it "execute block" do
          i = 0
          expect { maybe(maybe_obj, "a") {i += 1} }.to change {i}.by(1)
        end
      end
    end
  end
end

module MaybeChain::TestMethod
  def return_nil
    nil
  end
end
