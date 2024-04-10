# frozen_string_literal: true

require 'nokogiri'
require 'sf_symbol_converter'

describe TemplateValidator do # rubocop:disable Metrics/BlockLength
  describe '#validate' do # rubocop:disable Metrics/BlockLength
    it 'validates the template' do
      template_svg = Nokogiri::XML(File.open('spec/fixtures/template.svg'))
      template_validator = TemplateValidator.new

      expect { template_validator.validate(template_svg) }.not_to raise_error
    end

    it 'raises an error if the template is missing a required section' do
      template_svg = Nokogiri::XML(File.open('spec/fixtures/template_missing_section.svg'))
      template_validator = TemplateValidator.new

      expect do
        template_validator.validate(template_svg)
      end.to raise_error('Invalid template: Missing required section Notes')
    end

    it 'raises an error if the template is missing a required symbol' do
      template_svg = Nokogiri::XML(File.open('spec/fixtures/template_missing_symbol.svg'))
      template_validator = TemplateValidator.new

      expect do
        template_validator.validate(template_svg)
      end.to raise_error('Invalid template: Missing symbol Ultralight-S')
    end

    it 'raises an error if the template is missing a guideline' do
      template_svg = Nokogiri::XML(File.open('spec/fixtures/template_missing_guideline.svg'))
      template_validator = TemplateValidator.new

      expect do
        template_validator.validate(template_svg)
      end.to raise_error('Invalid template: Missing Baseline-S')
    end

    it 'raises an error if the template is missing a margin line' do
      template_svg = Nokogiri::XML(File.open('spec/fixtures/template_missing_margin.svg'))
      template_validator = TemplateValidator.new

      expect do
        template_validator.validate(template_svg)
      end.to raise_error('Invalid template: Missing left-margin-Ultralight-S')
    end
  end
end
