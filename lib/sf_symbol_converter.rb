# frozen_string_literal: true

require 'nokogiri'

# Given a source SVG and a SFSymbol template, generate a SFSymbol
class SFSymbolConverter
  SOURCE_ICON_VIEWBOX_SIZE = 24

  REFERENCE_SFSYMBOL_FONT_CAPS_HEIGHT = 14
  TARGET_SYMBOL_HEIGHT_MEDIUM = 16

  SFSYMBOL_MEDIUM_TO_SMALL_SCALE = 0.783

  attr_reader :template_svg, :icon_svg, :icon_validator, :template_validator

  def initialize(template_svg, icon_svg)
    @template_svg = template_svg
    @icon_svg = icon_svg

    @icon_validator = IconValidator.new(SOURCE_ICON_VIEWBOX_SIZE)
    @template_validator = TemplateValidator.new

    @icon_validator.validate(icon_svg)
    @template_validator.validate(template_svg)
  end

  def convert
    trim_template
    replace_template_symbol_with_icon
    adjust_template_margin
  end

  private

  def trim_template
  end

  def replace_template_symbol_with_icon
  end

  def adjust_template_margin
  end
end
