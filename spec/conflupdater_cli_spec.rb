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

  context 'taghosts command' do
    let(:taghosts_instance) {double('taghost', page_update: nil )}
    let(:taghosts_class) {class_double('Taghosts', new: taghosts_instance)}

    it 'creates a new Taghosts instance' do
      taghosts_class.as_stubbed_const
      expect(taghosts_class).to receive(:new)
      subject.taghosts
    end

    it 'invokes #page_update of the taghost instance' do
      taghosts_class.as_stubbed_const
      expect(taghosts_instance).to receive(:page_update)
      subject.taghosts
    end
  end

end
