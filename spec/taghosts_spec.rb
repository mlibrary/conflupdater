require 'spec_helper'
require_relative '../lib/taghosts'

describe Taghosts do

  describe '#page_update' do

    subject { described_class.new(page_id: '123',space_key: 'SPC', page_version: '8', source: 'spec/fixtures/active-servers') }

    it 'returns a hash' do
      expect(subject.page_update).to be_kind_of(Hash)
    end

    it 'updates the given page version to the next major version.' do
      expect(subject.page_update[:version][:number]).to be(subject.major_version+1)
    end
  end

end
