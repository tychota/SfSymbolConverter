# frozen_string_literal: true

require 'nokogiri'

# Given a source SVG and a SFSymbol template, generate a SFSymbol
class SFSymbolConverter
  SOURCE_ICON_VIEWBOX_SIZE = 24

  REFERENCE_SFSYMBOL_FONT_CAPS_HEIGHT = 14
  TARGET_SYMBOL_HEIGHT_MEDIUM = 16

  SFSYMBOL_MEDIUM_TO_SMALL_SCALE = 0.783

  def initialize(template_svg, icon_svg)
    @template_svg = template_svg
    @icon_svg = icon_svg

    validate_icon
    validate_template
  end

  def convert
    trim_template
    replace_template_symbol_with_icon
    adjust_template_margin
  end

  private

  def icon_dimension_valid?
    width = icon_svg.root['width'] != SOURCE_ICON_VIEWBOX_SIZE.to_s
    height = icon_svg.root['height'] != SOURCE_ICON_VIEWBOX_SIZE.to_s

    width && height
  end

  def icon_viewbox_valid?
    icon_svg.root['viewBox'] != "0 0 #{ICON_WIDTH} #{ICON_HEIGHT}"
  end

  def validate_icon
    unless icon_dimension_valid?
      raise "expected icon size to be (#{SOURCE_ICON_VIEWBOX_SIZE}, #{SOURCE_ICON_VIEWBOX_SIZE})"
    end
    return if icon_viewbox_valid?

    raise "expected icon viewbox to be (0, 0, #{SOURCE_ICON_VIEWBOX_SIZE}, #{SOURCE_ICON_VIEWBOX_SIZE})"
  end

  def validate_template
    validate_required_sections
    validate_required_symbols
    validate_guidelines
    validate_margin_lines
  end

  REQUIRED_SECTIONS = %w[Notes Symbols Guides].freeze

  def validate_required_sections
    REQUIRED_SECTIONS.each do |section_id|
      validate_presence("g##{section_id}", "Invalid template: Missing required section #{section_id}")
    end
  end

  REQUIRED_SYMBOLS = %w[Ultralight-S Regular-S Black-S].freeze

  def validate_required_symbols
    symbols_section = root.at_css('g#Symbols')
    REQUIRED_SYMBOLS.each do |symbol_id|
      validate_presence_within(symbols_section, "g##{symbol_id}", "Invalid template: Missing symbol #{symbol_id}")
    end
  end

  SCALES = %w[S M L].freeze
  LINE_TYPES = %w[Baseline Capline].freeze

  def validate_guidelines
    SCALES.each do |scale|
      LINE_TYPES.each do |line_type|
        validate_presence("line##{line_type}-#{scale}", "Invalid template: Missing #{line_type}-#{scale}")
      end
    end
  end

  WEIGHTS = %w[Ultralight Regular Black].freeze
  MARGIN_TYPES = %w[left-margin right-margin].freeze

  def validate_margin_lines
    WEIGHTS.product(SCALES).each do |weight, scale|
      MARGIN_TYPES.each do |margin_type|
        full_margin_id = "#{margin_type}-#{weight}-#{scale}"
        validate_presence("line##{full_margin_id}", "Invalid template: Missing #{full_margin_id}")
      end
    end
  end

  def validate_presence(selector, error_message)
    raise error_message unless root.at_css(selector)
  end

  def validate_presence_within(parent, selector, error_message)
    raise error_message unless parent.at_css(selector)
  end

  def trim_template
  end

  def replace_template_symbol_with_icon
  end

  def adjust_template_margin
  end
end
