# frozen_string_literal: true

require 'thor'
require 'nokogiri'
require './lib/sf_symbol_converter'

# CLI for converting SF Symbols
class SFSymbolCli < Thor
  include Thor::Actions

  TEMPLATE_PATH = 'assets/template.svg'

  desc 'convert ICON_SVG [OUTPUT_SVG]', 'Converts an SF Symbol SVG to a template SVG'
  def convert(icon_svg_path, output_path = 'output.svg')
    template_svg = Nokogiri::XML(File.open(TEMPLATE_PATH))
    icon_svg = Nokogiri::XML(File.open(icon_svg_path))

    output_path = output_path || 'output.svg'

    converter = SFSymbolConverter.new(template_svg, icon_svg)
    converted_svg = converter.convert

    pretty_printed_svg = Nokogiri::XML(converted_svg.to_s, &:noblanks).to_xml(indent: 2)

    File.open(output_path, 'w') { |file| file.write(pretty_printed_svg) }
  end

  desc 'batch_convert INPUT_DIR OUTPUT_DIR', 'Converts all SVGs in a directory to SFSymbols'
  def batch_convert(input_dir, output_dir)
    Dir.glob("#{input_dir}/*.svg").each do |icon_svg_path|
      icon_svg = Nokogiri::XML(File.open(icon_svg_path))

      output_path = "#{output_dir}/#{File.basename(icon_svg_path)}"
      convert(icon_svg_path, output_path)
    end
  end
end