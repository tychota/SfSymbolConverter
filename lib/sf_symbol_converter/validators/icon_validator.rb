# frozen_string_literal: true

# given an icon SVG, validate its dimensions and viewbox
class IconValidator
  attr_reader :viewbox_size

  def initialize(viewbox_size)
    @viewbox_size = viewbox_size
  end

  def validate(icon_svg)
    raise "expected icon size to be (#{viewbox_size}, #{viewbox_size})" unless icon_dimension_valid?(icon_svg)
    raise "expected icon viewbox to be (0, 0, #{viewbox_size}, #{viewbox_size})" unless icon_viewbox_valid?(icon_svg)
  end

  private

  def icon_dimension_valid?(icon_svg)
    is_width_ok = icon_svg.root['width'] == viewbox_size.to_s
    is_height_ok = icon_svg.root['height'] == viewbox_size.to_s

    is_width_ok && is_height_ok
  end

  def icon_viewbox_valid?(icon_svg)
    icon_svg.root['viewBox'] == "0 0 #{viewbox_size} #{viewbox_size}"
  end
end
