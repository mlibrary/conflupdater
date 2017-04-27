require 'spec_helper'
require_relative '../lib/conflupdater_cli'

describe ConflupdaterCLI do

  subject { described_class.new }

  context 'print command' do
    let(:config_hash) {'dummy_config_value'}
    let(:settings) { class_double('Settings').as_stubbed_const }
    
    it 'prints the Settings' do
      allow(settings).to receive(:to_h).and_return(config_hash)

      expect{subject.print}.to output(/#{config_hash}/).to_stdout
    end
  end
end
