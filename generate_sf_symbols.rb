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


# Original scale calculation from the article
# scale = ((baseline_y - capline_y).abs / ICON_HEIGHT) * ADDITIONAL_SCALING

# We want the m scaled icon to be correlated with the font of size 14.
scale_m = (baseline_y - capline_y).abs / 14
horizontal_center = (original_left_margin + original_right_margin) / 2

scaled_width = ICON_WIDTH * scale_m
scaled_height = ICON_HEIGHT * scale_m

# If you use the template's margins as-is, the generated symbol's width will depend on the template chosen.
# To not have to care about the template, we move the margin based on the computed symbol size.
horizontal_margin_to_center = scaled_width / 2 + MARGIN_LINE_WIDTH + ADDITIONAL_HORIZONTAL_MARGIN
adjusted_left_margin = horizontal_center - horizontal_margin_to_center
adjusted_right_margin = horizontal_center + horizontal_margin_to_center
left_margin_node = template_svg.at_css("#left-margin-Regular-M")
left_margin_node["x1"] = adjusted_left_margin.to_s
left_margin_node["x2"] = adjusted_left_margin.to_s
right_margin_node = template_svg.at_css("#right-margin-Regular-M")
right_margin_node["x1"] = adjusted_right_margin.to_s
right_margin_node["x2"] = adjusted_right_margin.to_s

# Make a copy of the modified template.
# In this script we generate only one symbol, but if we end up generating multiple symbols at one it's safer to work on a copy.
symbol_svg = template_svg.dup

# It's finally time to handle that important #Regular-M node.
regular_m_node = symbol_svg.at_css("#Regular-M")

# Move the shape so its center is at the center of the guides.
translation_x = horizontal_center - scaled_width / 2
translation_y = (baseline_y + capline_y) / 2 - scaled_height / 2
# Prepare a transformation matrix from the values calculated above.
transform_matrix = [
  scale_m, 0,
  0, scale_m,
  translation_x, translation_y,
].map {|x| "%f" % x } # Convert numbers to strings.
regular_m_node["transform"] = "matrix(#{transform_matrix.join(" ")})"

# Replace the content of the #Regular-M node with the icon.
regular_m_node.children = icon_svg.root.children.dup

# Finish by writing the generated symbol to disk.
File.open(DESTINATION_SVG_PATH, "w") do |f|
  symbol_svg.write_to(f)
end