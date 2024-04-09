# frozen_string_literal: true

require 'nokogiri'
require './lib/validators/icon_validator'

describe IconValidator do
  describe '#validate' do
    it "validates the icon's dimensions and viewbox" do
      icon_svg = Nokogiri::XML(File.open('spec/fixtures/icon.svg'))
      icon_validator = IconValidator.new(24)

      expect { icon_validator.validate(icon_svg) }.not_to raise_error
    end

    it 'raises an error if the icon has invalid dimensions' do
      icon_svg = Nokogiri::XML(File.open('spec/fixtures/icon_invalid_dimensions.svg'))
      icon_validator = IconValidator.new(24)

      expect { icon_validator.validate(icon_svg) }.to raise_error('expected icon size to be (24, 24)')
    end

    it 'raises an error if the icon has an invalid viewbox' do
      icon_svg = Nokogiri::XML(File.open('spec/fixtures/icon_invalid_viewbox.svg'))
      icon_validator = IconValidator.new(24)

      expect { icon_validator.validate(icon_svg) }.to raise_error('expected icon viewbox to be (0, 0, 24, 24)')
    end
  end
end
