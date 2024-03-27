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
