#!/usr/bin/env ruby

require "nokogiri"

# Path to file exported from the SF Symbols app
TEMPLATE_PATH = "assets/template/circle_static.svg"
# Path to one of the SVGs provided by the designers
SOURCE_SVG_PATH = "assets/source_svg/user_online_test.svg"
# Path to the SVG we are generating
DESTINATION_SVG_PATH = "assets/destination_svg/user_online_test-symbol.svg"

# Expected icon size
ICON_WIDTH = 24
ICON_HEIGHT = 24

# Additional scaling to have a size closer to Apple's provided SF Symbols
# (I just tried different values and that looked pretty close)
ADDITIONAL_SCALING = 1.7
# Width of #left-margin and #right-margin inside the SVG
MARGIN_LINE_WIDTH = 0.5
# Additional white space added on each side
ADDITIONAL_HORIZONTAL_MARGIN = 4

# Load the template.
template_svg = File.open(TEMPLATE_PATH) do |f|
  # To generate a better looking SVG, ignore whitespaces.
  Nokogiri::XML(f) { |config| config.noblanks }
end

TEMPLATE_ICON_SIZES = ["S", "M", "L"]
TEMPLATE_ICON_WEIGHTS = ["Black", "Heavy", "Bold", "Semibold", "Medium", "Regular", "Light", "Thin", "Ultralight"]

# We are only providing "Regular-S", so remove the other shapes.
TEMPLATE_ICON_SIZES.each do |size|
  TEMPLATE_ICON_WEIGHTS.each do |weight|
    id = "#{weight}-#{size}"
    next if id == "Regular-M" # TODO: Only keep the S size
    if template_svg.at_css("##{id}") != nil then
      template_svg.at_css("##{id}").remove
    end
  end
end

def get_guide_value(template_svg, axis, xml_id)
  guide_node = template_svg.at_css("##{xml_id}")
  raise "invalid axis" unless %i{x y}.include?(axis)
  val1 = guide_node["#{axis}1"]
  val2 = guide_node["#{axis}2"]
  if val1 == nil || val1 != val2
    raise "invalid #{xml_id} guide"
  end
  val1.to_f # Convert the value from string to float.
end

# Get the x1 (should be the same as x2) of the #left-margin node.
original_left_margin = get_guide_value(template_svg, :x, "left-margin-Regular-M")
# Get the x1 (should be the same as x2) of the #right-margin node.
original_right_margin = get_guide_value(template_svg, :x, "right-margin-Regular-M")
# Get the y1 (should be the same as y2) of the #Baseline-M node.
baseline_y = get_guide_value(template_svg, :y, "Baseline-M")
# Get the y1 (should be the same as y2) of the #Capline-M node.
capline_y = get_guide_value(template_svg, :y, "Capline-M")

# Load the SVG icon.
icon_svg = File.open(SOURCE_SVG_PATH) do |f|
  # To generate a better looking SVG, ignore whitespaces.
Nokogiri::XML(f) { |config| config.noblanks }
end

# The SVGs provided by designers had a fixed size of 24x24, so all the calculations below are based on this.
# If we get an unexpected size, the program ends in error.
# The SVG specs allows to specify width and height in not only numbers, but also percents, so handling a wider range of SVG files would be more complicated.
if icon_svg.root["width"] != ICON_WIDTH.to_s ||
icon_svg.root["height"] != ICON_HEIGHT.to_s ||
icon_svg.root["viewBox"] != "0 0 #{ICON_WIDTH} #{ICON_HEIGHT}"
raise "expected icon size of #{icon.source_svg_path} to be (#{ICON_WIDTH}, #{ICON_HEIGHT})"
end
