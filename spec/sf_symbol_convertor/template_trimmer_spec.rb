# frozen_string_literal: true

require 'nokogiri'

require './lib/sf_symbol_converter/trimmer/template_trimmer'

describe TemplateTrimmer do
  it '#remove_unused_template_icons' do
    template_svg = Nokogiri::XML(File.open('spec/fixtures/template.svg'))
    template_trimer = TemplateTrimmer.new

    trimmed_svg = template_trimer.trim(template_svg)

    expect(trimmed_svg.css("g[id$='Symbols'] > g").count).to eq(3)
  end
end
