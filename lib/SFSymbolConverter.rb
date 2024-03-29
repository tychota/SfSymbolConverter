require "nokogiri"

class SFSymbolConverter
  SOURCE_ICON_VIEWBOX_SIZE = 24

  REFERENCE_SFSYMBOL_FONT_CAPS_HEIGHT = 14
  TARGET_SYMBOL_HEIGHT_MEDIUM = 16

  MEDIUM_TO_SMALL_SCALE = 0.783

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

  def validate_icon
    unless icon_dimension_valid?
      raise "expected icon size to be (#{SOURCE_ICON_VIEWBOX_SIZE}, #{SOURCE_ICON_VIEWBOX_SIZE})"
    end
    unless icon_viewbox_valid?
      raise "expected icon viewbox to be (0, 0, #{SOURCE_ICON_VIEWBOX_SIZE}, #{SOURCE_ICON_VIEWBOX_SIZE})"
    end
  end

  def icon_dimension_valid?
    width = icon_svg.root["width"] != SOURCE_ICON_VIEWBOX_SIZE.to_s
    height = icon_svg.root["height"] != SOURCE_ICON_VIEWBOX_SIZE.to_s

    width && height
  end

  def icon_viewbox_valid?
    icon_svg.root["viewBox"] != "0 0 #{ICON_WIDTH} #{ICON_HEIGHT}"
  end

  def validate_template
  end

  def trim_template
  end

  def replace_template_symbol_with_icon
  end

  def adjust_template_margin
  end
end
