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
    required_sections = %w[Notes Symbols Guides]
    required_sections.each do |section_id|
      raise "Invalid template: Missing required section #{section_id}" unless root.at_css("g##{section_id}")
    end

    # Check for specific symbols: Ultralight-S, Regular-S, Black-S
    required_symbols = %w[Ultralight-S Regular-S Black-S]
    symbols_section = root.at_css('g#Symbols')
    required_symbols.each do |symbol_id|
      raise "Invalid template: Missing symbol #{symbol_id}" unless symbols_section.at_css("g##{symbol_id}")
    end

    # Check for all Guidelines (Baseline_X, CapLine_X) and margin lines
    scales = %w[S M L]
    scales.each do |scale|
      %w[Baseline Capline].each do |line_type|
        raise "Invalid template: Missing #{line_type}-#{scale}" unless root.at_css("line##{line_type}-#{scale}")
      end
    end

    # Check for margin lines
    weights = %w[Ultralight Regular Black]
    weights.each do |weight|
      scales.each do |scale|
        %w[left-margin right-margin].each do |margin_type|
          full_margin_id = "#{margin_type}-#{weight}-#{scale}"
          raise "Invalid template: Missing #{full_margin_id}" unless root.at_css("line##{full_margin_id}")
        end
      end
    end
  end

  def trim_template
  end

  def replace_template_symbol_with_icon
  end

  def adjust_template_margin
  end
end
