# encoding: utf-8
require 'pg_array_parser'

class MockClass
  include PgArrayParser
end

describe 'pg_array_parser' do
  context 'with a class that has included PgArrayParser' do
    describe '#parse_pg_array' do
      it 'should convert a pg array formatted string to an array' do
        expect( MockClass.new.parse_pg_array('{"ABC","123"}') ).to eq ['ABC', '123']
      end
    end
  end
end
