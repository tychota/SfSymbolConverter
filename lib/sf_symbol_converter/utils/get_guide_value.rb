# frozen_string_literal: true

def get_guide_value(template_svg, axis, xml_id)
  guide_node = template_svg.at_css("##{xml_id}")
  raise 'invalid axis' unless %i[x y].include?(axis)

  val1 = guide_node["#{axis}1"]
  val2 = guide_node["#{axis}2"]
  raise "invalid #{xml_id} guide" if val1.nil? || val1 != val2

  val1.to_f # Convert the value from string to float.
end
