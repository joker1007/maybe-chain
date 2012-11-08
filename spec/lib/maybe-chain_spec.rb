$: << File.join(File.dirname(File.expand_path(__FILE__)), "..", "..", "lib")

require "maybe-chain"

describe MaybeChain do
  before do
    String.__send__ :include, MaybeChain::TestMethod
  end

  describe "Object Extension" do
    subject { "a".to_maybe }
    it { should be_a(MaybeChain::MaybeWrapper) }
  end

  describe "method delegation" do
    subject { "a".to_maybe.upcase }
    its(:value) { should eq "A" }

    context "method returns nil" do
      let(:string) { "a" }

      subject { string.to_maybe.return_nil.upcase }
      its(:value) { should be_nil }
    end

    context "given block" do
      let(:array) { [1, 2, 3] }

      subject { array.to_maybe.map {|i| i*2}.reject {|i| i > 5} }
      its(:value) { should eq [2, 4] }
    end

    context "method raise Exception" do
      context "to_maybe given rescuable Exception" do
        let(:string) { "a" }

        subject { string.to_maybe(NotImplementedError).raise_no_implement_error.upcase }
        its(:value) { should be_nil }
      end

      context "to_maybe given Exception List" do
        let(:string) { "a" }

        subject { string.to_maybe([NotImplementedError, ArgumentError]).raise_no_implement_error.upcase }
        its(:value) { should be_nil }
      end

      context "to_maybe given Exception List, and forward method raises Exception" do
        let(:string) { "a" }

        subject { string.to_maybe(NotImplementedError).upcase.raise_no_implement_error.downcase }
        its(:value) { should be_nil }
      end

      context "to_maybe given Exception List, but different Exception raised" do
        let(:string) { "a" }

        it do
          expect { string.to_maybe([ArgumentError]).raise_no_implement_error.upcase }.to raise_error(NotImplementedError)
        end
      end
    end
  end

  describe

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

  def raise_no_implement_error
    raise NotImplementedError
  end
end
