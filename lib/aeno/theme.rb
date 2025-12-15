# frozen_string_literal: true

module Aeno
  class Theme
    # ═══════════════════════════════════════════════════════════════════════════
    # PROPERTY TYPES
    # Define how each type is rendered in the configurator
    # ═══════════════════════════════════════════════════════════════════════════
    PROPERTY_TYPES = {
      color: {
        widget: :color_picker
      },
      length: {
        widget: :slider,
        unit: "rem",
        min: 0,
        max: 2,
        step: 0.0625
      },
      multiplier: {
        widget: :slider,
        prefix: "×",
        min: 0,
        max: 3,
        step: 0.1
      },
      shadow: {
        widget: :button_group,
        options: {
          none: "none",
          sm: "0 1px 2px 0 rgb(0 0 0 / 0.05)",
          md: "0 4px 6px -1px rgb(0 0 0 / 0.1)",
          lg: "0 10px 15px -3px rgb(0 0 0 / 0.1)",
          xl: "0 20px 25px -5px rgb(0 0 0 / 0.1)"
        }
      },
      font_family: {
        widget: :select,
        options: {
          sans: "ui-sans-serif, system-ui, sans-serif",
          serif: "ui-serif, Georgia, serif",
          mono: "ui-monospace, monospace"
        }
      },
      font_weight: {
        widget: :button_group,
        options: {
          normal: "400",
          medium: "500",
          semibold: "600",
          bold: "700"
        }
      }
    }.freeze

    # ═══════════════════════════════════════════════════════════════════════════
    # PRIMITIVES
    # The foundational values. Change these → everything derives.
    # ═══════════════════════════════════════════════════════════════════════════
    PRIMITIVES = {
      # Colors
      primary:         "#475569",
      primary_hover:   "#334155",
      primary_fg:      "#ffffff",

      secondary:       "#f5f5f5",
      secondary_hover: "#e5e5e5",
      secondary_fg:    "#1a1a1a",

      destructive:       "#dc2626",
      destructive_hover: "#b91c1c",
      destructive_fg:    "#ffffff",

      background:      "#ffffff",
      foreground:      "#1a1a1a",

      muted:           "#f5f5f5",
      muted_fg:        "#737373",

      border:          "#e5e5e5",
      ring:            "#475569",

      overlay:         "#00000080",

      # Lengths
      radius_sm:       "0.25rem",
      radius_md:       "0.375rem",
      radius_lg:       "0.5rem",
      radius_xl:       "0.75rem",

      spacing_xs:      "0.25rem",
      spacing_sm:      "0.5rem",
      spacing_md:      "0.75rem",
      spacing_lg:      "1rem",
      spacing_xl:      "1.5rem",
      spacing_2xl:     "2rem",

      # Shadows
      shadow_none:     "none",
      shadow_sm:       "0 1px 2px 0 rgb(0 0 0 / 0.05)",
      shadow_md:       "0 4px 6px -1px rgb(0 0 0 / 0.1)",
      shadow_lg:       "0 10px 15px -3px rgb(0 0 0 / 0.1)",
      shadow_xl:       "0 20px 25px -5px rgb(0 0 0 / 0.1)",

      # Fonts
      font_sans:       "ui-sans-serif, system-ui, sans-serif",
      font_mono:       "ui-monospace, monospace",

      weight_normal:   "400",
      weight_medium:   "500",
      weight_semibold: "600",
      weight_bold:     "700"
    }.freeze

    # ═══════════════════════════════════════════════════════════════════════════
    # CORNERSTONES
    # Component-level tokens, defaults reference primitives
    # ═══════════════════════════════════════════════════════════════════════════
    CORNERSTONES = {
      button: {
        label: "Button",
        properties: {
          bg:          { var: "--ui-button-bg",          type: :color,       default: :primary },
          bg_hover:    { var: "--ui-button-bg-hover",    type: :color,       default: :primary_hover },
          fg:          { var: "--ui-button-fg",          type: :color,       default: :primary_fg },
          border:      { var: "--ui-button-border",      type: :color,       default: :primary },
          radius:      { var: "--ui-button-radius",      type: :length,      default: :radius_md, max: 1 },
          padding_x:   { var: "--ui-button-px",          type: :length,      default: :spacing_md, max: 2 },
          padding_y:   { var: "--ui-button-py",          type: :length,      default: :spacing_sm, max: 1.5 },
          font_weight: { var: "--ui-button-weight",      type: :font_weight, default: :weight_semibold }
        }
      },

      input: {
        label: "Input",
        properties: {
          bg:           { var: "--ui-input-bg",           type: :color,  default: :background },
          fg:           { var: "--ui-input-fg",           type: :color,  default: :foreground },
          border:       { var: "--ui-input-border",       type: :color,  default: :border },
          border_focus: { var: "--ui-input-border-focus", type: :color,  default: :primary },
          ring:         { var: "--ui-input-ring",         type: :color,  default: :ring },
          placeholder:  { var: "--ui-input-placeholder",  type: :color,  default: :muted_fg },
          radius:       { var: "--ui-input-radius",       type: :length, default: :radius_md, max: 1 },
          padding_x:    { var: "--ui-input-px",           type: :length, default: :spacing_md, max: 1.5 },
          padding_y:    { var: "--ui-input-py",           type: :length, default: :spacing_sm, max: 1 }
        }
      },

      card: {
        label: "Card",
        properties: {
          bg:      { var: "--ui-card-bg",      type: :color,  default: :background },
          fg:      { var: "--ui-card-fg",      type: :color,  default: :foreground },
          border:  { var: "--ui-card-border",  type: :color,  default: :border },
          radius:  { var: "--ui-card-radius",  type: :length, default: :radius_lg, max: 1.5 },
          padding: { var: "--ui-card-padding", type: :length, default: :spacing_xl, max: 3 },
          shadow:  { var: "--ui-card-shadow",  type: :shadow, default: :shadow_sm }
        }
      },

      sheet: {
        label: "Sheet",
        properties: {
          bg:      { var: "--ui-sheet-bg",      type: :color,  default: :background },
          fg:      { var: "--ui-sheet-fg",      type: :color,  default: :foreground },
          border:  { var: "--ui-sheet-border",  type: :color,  default: :border },
          overlay: { var: "--ui-sheet-overlay", type: :color,  default: :overlay },
          radius:  { var: "--ui-sheet-radius",  type: :length, default: :radius_xl, max: 2 },
          padding: { var: "--ui-sheet-padding", type: :length, default: :spacing_xl, max: 3 },
          shadow:  { var: "--ui-sheet-shadow",  type: :shadow, default: :shadow_xl }
        }
      },

      area: {
        label: "Area",
        properties: {
          bg:      { var: "--ui-area-bg",      type: :color,  default: :muted },
          fg:      { var: "--ui-area-fg",      type: :color,  default: :foreground },
          border:  { var: "--ui-area-border",  type: :color,  default: :border },
          radius:  { var: "--ui-area-radius",  type: :length, default: :radius_xl, max: 2 },
          padding: { var: "--ui-area-padding", type: :length, default: :spacing_2xl, max: 4 }
        }
      },

      table: {
        label: "Table",
        properties: {
          bg:           { var: "--ui-table-bg",           type: :color,  default: :background },
          fg:           { var: "--ui-table-fg",           type: :color,  default: :foreground },
          border:       { var: "--ui-table-border",       type: :color,  default: :border },
          header_bg:    { var: "--ui-table-header-bg",    type: :color,  default: :muted },
          header_fg:    { var: "--ui-table-header-fg",    type: :color,  default: :muted_fg },
          row_hover:    { var: "--ui-table-row-hover",    type: :color,  default: :muted },
          row_stripe:   { var: "--ui-table-row-stripe",   type: :color,  default: :muted },
          radius:       { var: "--ui-table-radius",       type: :length, default: :radius_lg, max: 1 },
          cell_padding: { var: "--ui-table-cell-padding", type: :length, default: :spacing_md, max: 1.5 }
        }
      },

      typography: {
        label: "Typography",
        properties: {
          heading:        { var: "--ui-heading-color",  type: :color,       default: :foreground },
          body:           { var: "--ui-body-color",     type: :color,       default: :foreground },
          muted:          { var: "--ui-muted-color",    type: :color,       default: :muted_fg },
          link:           { var: "--ui-link-color",     type: :color,       default: :primary },
          link_hover:     { var: "--ui-link-hover",     type: :color,       default: :primary_hover },
          code_bg:        { var: "--ui-code-bg",        type: :color,       default: :muted },
          code_fg:        { var: "--ui-code-fg",        type: :color,       default: :foreground },
          font_sans:      { var: "--ui-font-sans",      type: :font_family, default: :font_sans },
          font_mono:      { var: "--ui-font-mono",      type: :font_family, default: :font_mono },
          heading_weight: { var: "--ui-heading-weight", type: :font_weight, default: :weight_semibold }
        }
      },

      menu: {
        label: "Menu",
        properties: {
          bg:        { var: "--ui-menu-bg",        type: :color,  default: :background },
          fg:        { var: "--ui-menu-fg",        type: :color,  default: :foreground },
          border:    { var: "--ui-menu-border",    type: :color,  default: :border },
          radius:    { var: "--ui-menu-radius",    type: :length, default: :radius_md },
          shadow:    { var: "--ui-menu-shadow",    type: :shadow, default: :shadow_lg },
          padding:   { var: "--ui-menu-padding",   type: :length, default: :spacing_xs },
          item_radius: { var: "--ui-menu-item-radius", type: :length, default: :radius_sm }
        }
      }
    }.freeze

    # ═══════════════════════════════════════════════════════════════════════════
    # API METHODS
    # ═══════════════════════════════════════════════════════════════════════════

    class << self
      # All CSS variable names (for JS)
      def css_variables
        vars = []
        CORNERSTONES.each_value do |cornerstone|
          cornerstone[:properties].each_value do |prop|
            vars << prop[:var]
          end
        end
        vars
      end

      # For JS: array of var names
      def to_js_array
        css_variables.map { |v| %("#{v}") }.join(", ")
      end

      # Resolve a default value (symbol → primitive value)
      def resolve_default(default_key)
        return default_key unless default_key.is_a?(Symbol)
        PRIMITIVES[default_key] || default_key.to_s
      end

      # Get property config with resolved default
      def property_config(cornerstone, property)
        prop = CORNERSTONES.dig(cornerstone, :properties, property)
        return nil unless prop

        type_config = PROPERTY_TYPES[prop[:type]] || {}
        resolved = type_config.merge(prop)
        resolved[:resolved_default] = resolve_default(prop[:default])
        resolved
      end

      # Full config for JS configurator
      def to_js_config
        config = {}
        CORNERSTONES.each do |key, cornerstone|
          config[key] = {
            label: cornerstone[:label],
            properties: {}
          }
          cornerstone[:properties].each do |prop_key, prop|
            type_config = PROPERTY_TYPES[prop[:type]] || {}
            config[key][:properties][prop_key] = type_config
              .merge(prop)
              .merge(resolved_default: resolve_default(prop[:default]))
          end
        end
        config.to_json
      end

      # Generate CSS with defaults
      def to_default_css
        lines = [":root {"]
        CORNERSTONES.each_value do |cornerstone|
          cornerstone[:properties].each_value do |prop|
            value = resolve_default(prop[:default])
            lines << "  #{prop[:var]}: #{value};"
          end
        end
        lines << "}"
        lines.join("\n")
      end
    end

    # ═══════════════════════════════════════════════════════════════════════════
    # INSTANCE METHODS (for runtime theming)
    # ═══════════════════════════════════════════════════════════════════════════

    def initialize
      @values = {}
    end

    def set(var_name, value)
      @values[var_name] = value
    end

    def to_css
      return "" if @values.empty?

      vars = @values.map { |k, v| "  #{k}: #{v};" }.join("\n")
      ":root {\n#{vars}\n}"
    end

    def to_style_tag
      css = to_css
      return "" if css.empty?

      "<style>#{css}</style>".html_safe
    end
  end
end
