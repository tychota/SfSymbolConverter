# frozen_string_literal: true

require 'nokogiri'
require './lib/utils'

require './lib/validators/icon_validator'
require './lib/validators/template_validator'
require './lib/trimmer/template_trimmer'

# Given a source SVG and a SFSymbol template, generate a SFSymbol
class SFSymbolConverter
  SOURCE_ICON_VIEWBOX_SIZE = 24

  REFERENCE_SFSYMBOL_FONT_CAPS_HEIGHT = 14
  TARGET_SYMBOL_HEIGHT_MEDIUM = 16

  SFSYMBOL_MEDIUM_TO_SMALL_SCALE = 0.783

  MARGIN_LINE_WIDTH = 0.5

  attr_accessor :template_svg
  attr_reader :icon_svg, :icon_validator, :template_validator

  def initialize(template_svg, icon_svg)
    @template_svg = template_svg
    @icon_svg = icon_svg

    @icon_validator = IconValidator.new(SOURCE_ICON_VIEWBOX_SIZE)
    @template_validator = TemplateValidator.new

    @template_trimmer = TemplateTrimmer.new

    @icon_validator.validate(icon_svg)
    @template_validator.validate(template_svg)
  end

  def convert
    @template_svg = @template_trimmer.trim(template_svg)
    replace_template_symbols_with_source_icons
    adjust_guidelines
    @template_svg
  end

  private

  def cap_height_small
    baseline_y = get_guide_value(template_svg, :y, 'Baseline-S')
    capline_y = get_guide_value(template_svg, :y, 'Capline-S')

    (baseline_y - capline_y).abs
  end

  def scale_factor_small
    cap_height_small / REFERENCE_SFSYMBOL_FONT_CAPS_HEIGHT * SFSYMBOL_MEDIUM_TO_SMALL_SCALE
  end

  def scaled_size_small
    SOURCE_ICON_VIEWBOX_SIZE * scale_factor_small
  end

  def vertical_center_small
    baseline_y = get_guide_value(template_svg, :y, 'Baseline-S')
    capline_y = get_guide_value(template_svg, :y, 'Capline-S')

    (baseline_y + capline_y) / 2
  end

  def horizontal_center(symbol)
    left_margin = get_guide_value(template_svg, :x, "left-margin-#{symbol}")
    right_margin = get_guide_value(template_svg, :x, "right-margin-#{symbol}")

    (left_margin + right_margin) / 2
  end

  def adjusted_left_margin(symbol)
    # TODO: is it really (MARGIN_LINE_WIDTH / 2) or just MARGIN_LINE_WIDTH
    horizontal_center(symbol) - scaled_size_small / 2 - (MARGIN_LINE_WIDTH / 2)
  end

  def adjusted_right_margin(symbol)
    # TODO: is it really (MARGIN_LINE_WIDTH / 2) or just MARGIN_LINE_WIDTH
    horizontal_center(symbol) + scaled_size_small / 2 + (MARGIN_LINE_WIDTH / 2)
  end

  def transform_matrix(symbol)
    translation_x = horizontal_center(symbol) - scaled_size_small / 2
    translation_y = vertical_center_small - scaled_size_small / 2

    matrix_text = '%<scale>.6f 0 0 %<scale>.6f %<trans_x>.6f %<trans_y>.6f'
    parameters = { scale: scale_factor_small, trans_x: translation_x, trans_y: translation_y }

    format(matrix_text, parameters)
  end

  IDS_TO_REPLACE = %w[Ultralight-S Regular-S Black-S].freeze

  def replace_template_symbols_with_source_icons
    IDS_TO_REPLACE.each do |symbol|
      template_symbol_node = template_svg.at_css("##{symbol}")

      template_symbol_node['transform'] = "matrix(#{transform_matrix(symbol)})"

      paths = icon_svg.dup.root.children
      paths.each do |node|
        node.delete('fill')
        node['class'] = 'SFSymbolsPreviewWireframe'
      end

      template_symbol_node.children = paths
    end
  end

  def adjust_guidelines
    IDS_TO_REPLACE.each do |symbol|
      left_margin_node = template_svg.at_css("#left-margin-#{symbol}")
      left_margin_node['x1'] = left_margin_node['x2'] = adjusted_left_margin(symbol).to_s

      right_margin_node = template_svg.at_css("#right-margin-#{symbol}")
      right_margin_node['x1'] = right_margin_node['x2'] = adjusted_right_margin(symbol).to_s
    end
  end
end
