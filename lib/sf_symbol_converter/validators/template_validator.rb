# frozen_string_literal: true

# given a template SVG, validate its structure and guidelines
class TemplateValidator
  def validate(template_svg)
    validate_required_sections(template_svg)
    validate_required_symbols(template_svg)
    validate_guidelines(template_svg)
    validate_margin_lines(template_svg)
  end

  private

  REQUIRED_SECTIONS = %w[Notes Symbols Guides].freeze

  def validate_required_sections(template_svg)
    REQUIRED_SECTIONS.each do |section_id|
      validate_presence(template_svg, "g##{section_id}", "Invalid template: Missing required section #{section_id}")
    end
  end

  REQUIRED_SYMBOLS = %w[Ultralight-S Regular-S Black-S].freeze

  def validate_required_symbols(template_svg)
    symbols_section = template_svg.at_css('g#Symbols')
    REQUIRED_SYMBOLS.each do |symbol_id|
      validate_presence_within(symbols_section, "g##{symbol_id}", "Invalid template: Missing symbol #{symbol_id}")
    end
  end

  REQUIRED_GUIDELINE_SCALES = %w[S L M].freeze
  REQUIRED_GUIDELINE_TYPES = %w[Baseline Capline].freeze

  def validate_guidelines(template_svg)
    REQUIRED_GUIDELINE_SCALES.each do |scale|
      REQUIRED_GUIDELINE_TYPES.each do |line_type|
        validate_presence(template_svg, "line##{line_type}-#{scale}", "Invalid template: Missing #{line_type}-#{scale}")
      end
    end
  end

  REQUIRED_MARGIN_SCALES = %w[S].freeze
  REQUIRED_MARGIN_WEIGHTS = %w[Ultralight Regular Black].freeze
  REQUIRED_MARGIN_TYPES = %w[left-margin right-margin].freeze

  def validate_margin_lines(template_svg)
    REQUIRED_MARGIN_WEIGHTS.product(REQUIRED_MARGIN_SCALES).each do |weight, scale|
      REQUIRED_MARGIN_TYPES.each do |margin_type|
        full_margin_id = "#{margin_type}-#{weight}-#{scale}"
        validate_presence(template_svg, "line##{full_margin_id}", "Invalid template: Missing #{full_margin_id}")
      end
    end
  end

  def validate_presence(root, selector, error_message)
    raise error_message unless root.at_css(selector)
  end

  def validate_presence_within(parent, selector, error_message)
    raise error_message unless parent.at_css(selector)
  end
end
