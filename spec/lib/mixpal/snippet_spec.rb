require 'spec_helper'

describe Mixpal::Snippet do
  let(:snippet) { 'alert("hello world");' }
  subject { described_class.new(snippet) }

  describe '#render' do
    it 'outputs the snippet string' do
      expect(subject.render).to eq 'alert("hello world");'
    end

    it 'outputs an html safe string' do
      expect(subject.render).to be_html_safe
    end
  end

  describe '#to_store' do
    it 'returns a hash with its data' do
      expect(subject.to_store).to eq('snippet' => snippet)
    end
  end

  describe '.from_store' do
    let(:result) do
      described_class.from_store('snippet' => snippet)
    end

    it 'instantiates a new instance' do
      expect(result).to be_an_instance_of(described_class)
    end

    it 'sets its snippet string from the data' do
      expect(result.snippet).to eq snippet
    end
  end
end
