# frozen_string_literal: true

require 'nokogiri'
require 'sf_symbol_converter'

describe SFSymbolConverter do
  describe '#convert' do
    it 'returns the converted SVG' do
      template_svg = Nokogiri::XML(File.open('spec/fixtures/template.svg'))
      icon_svg = Nokogiri::XML(File.open('spec/fixtures/icon.svg'))

      converter = SFSymbolConverter.new(template_svg, icon_svg)
      converted_svg = converter.convert

      # puts Nokogiri::XML(converted_svg.to_s, &:noblanks).to_xml(indent: 2)

      expect(converted_svg).to be_instance_of(Nokogiri::XML::Document)
    end
  end
end
