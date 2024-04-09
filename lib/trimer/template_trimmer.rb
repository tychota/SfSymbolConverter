# frozen_string_literal: true

# given a template SVG, remove unused icons
class TemplateTrimmer
  def trim(template_svg)
    remove_unused_template_icons(template_svg)
  end

  private

  ICON_SIZE = %w[S M L].freeze
  ICON_WEIGHTS = %w[Black Heavy Bold Semibold Medium Regular Light Thin Ultralight].freeze

  IDS_TO_KEEP = %w[Ultralight-S Regular-S Black-S].freeze

  def remove_unused_template_icons(template_svg)
    ICON_SIZE.each do |size|
      ICON_WEIGHTS.each do |weight|
        id = "#{weight}-#{size}"
        next if IDS_TO_KEEP.include?(id)

        template_svg.at_css("##{id}")&.remove
      end
    end

    template_svg
  end

  # TODO: should we also clean up margin lines ?
end
