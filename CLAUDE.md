# AEROS UI Library - Development Guide

## Overview

Aeros is a Rails Engine-based ViewComponent UI library with:

- **ViewComponent + ViewComponentContrib** (dry-initializer pattern)
- **Stimulus.js** for interactivity
- **PostCSS** with BEM naming
- **Self-documenting showcase** system

---

## Component Structure

```
primitives/component_name/
├── component.rb          # REQUIRED - Ruby class
├── component.html.erb    # Template (or use erb_template/call)
├── styles.css            # REQUIRED - BEM CSS (enforced by tests)
└── controller.js         # Optional - Stimulus controller
```

---

## Component Patterns

### Main Component Template

```ruby
module Aeros::Primitives::MyComponent
  class Component < ::Aeros::ApplicationViewComponent
    # 1. PROPS - Documented, shown in showcase
    prop :variant, description: "Style variant", values: [:default, :alt], default: -> { :default }
    prop :size, description: "Size option", values: [:sm, :md, :lg], optional: true

    # 2. OPTIONS - Internal, not documented
    option :data, default: -> { {} }

    # 3. EXAMPLES - Required for primitives
    examples("My Component", description: "What this component does") do |b|
      b.example(:default, title: "Default") do |e|
        e.preview
      end

      b.example(:variants, title: "Variants") do |e|
        e.preview variant: :default
        e.preview variant: :alt
      end
    end

    # 4. SLOTS - For composition
    renders_one :header
    renders_many :items, Item  # Reference nested class directly

    # 5. CLASS HELPER - Use classes() for BEM generation
    def component_classes
      classes(variant:, size:)
    end

    # 6. TEMPLATE - Choose one approach
    erb_template <<~ERB
      <div class="<%= component_classes %>">
        <%= content %>
      </div>
    ERB
  end
end
```

### Nested Sub-Component Template

```ruby
module Aeros::Primitives::MyComponent
  class Item < ::Aeros::ApplicationViewComponent
    # Use option (not prop) - nested components aren't documented separately
    option :label
    option :active, default: -> { false }

    # Hardcode parent's BEM prefix - class_for() won't work correctly here
    def item_classes
      ["cp-my-component__item", active ? "cp-my-component__item--active" : nil].compact.join(" ")
    end

    erb_template <<~ERB
      <div class="<%= item_classes %>"><%= label %></div>
    ERB
  end
end
```

---

## CSS Patterns (BEM)

### File: `styles.css`

```css
.cp-my-component {
  /* Base styles */

  /* Modifiers (variants, states) */
  &--alt {
    /* variant styles */
  }

  &--disabled {
    /* state styles */
  }

  /* Elements (sub-parts) */
  &__header {
    /* header element */
  }

  &__item {
    /* nested item element */

    &--active {
      /* item modifier */
    }
  }
}
```

### Prefixes

- `cp-` = Component Primitive
- `cb-` = Component Block
- `cg-` = Component Page

### CSS Variables

Use variables defined in `lib/aeros/theme.rb` schema:

```css
background-color: var(--ui-card-bg);
border-radius: var(--ui-card-radius);
```

---

## Theming System

### Architecture

Ruby schema → CSS layers → User overrides.

**Cascade order (lowest to highest priority):**

| Layer | Source | Purpose |
|-------|--------|---------|
| `@layer aeros-base` | Gem defaults | Schema-driven defaults |
| `@layer aeros-theme` | Preset CSS (slate/zinc) | Color palette |
| `@layer aeros-config` | Ruby initializer | User configuration |
| (unlayered) | User's CSS | Final overrides |

### Schema (`lib/aeros/theme.rb`)

Ruby is the **single source of truth** for what variables exist:

- **PRIMITIVES**: Base tokens (colors, radii, spacing, shadows)
- **CORNERSTONES**: Component tokens referencing primitives

### Variable Naming

| Category | Pattern | Examples |
|----------|---------|----------|
| Global | `--ui-{name}` | `--ui-background`, `--ui-foreground` |
| Component | `--ui-{component}-{prop}` | `--ui-input-bg`, `--ui-card-radius` |

### Component CSS

Reference schema variables:

```css
.cp-input-text__input {
  background: var(--ui-input-bg);
  border: 1px solid var(--ui-input-border);
  color: var(--ui-input-fg);
}
```

### User Configuration (Ruby)

```ruby
# config/initializers/aeros.rb
Aeros.configure do |config|
  config.theme do |t|
    t.input_bg = "#fafafa"
    t.input_border = "#d1d5db"
  end
end
```

### Theme Tag

```erb
<%# In layout <head> %>
<%= aeros_theme_tag %>
```

Outputs (compressed, in correct layer):

```html
<style>@layer aeros-config{:root{--ui-input-bg:#fafafa;--ui-input-border:#d1d5db}}</style>
```

### User CSS Override

User CSS (loaded last, no layer) always wins:

```css
/* app/assets/stylesheets/my-overrides.css */
:root {
  --ui-input-bg: #fff;
}
```

### Theme Presets

Presets via `data-theme` attribute:

```html
<html data-theme="slate" data-mode="light">
```

Available: `slate`, `zinc`

---

## DO

### Required

1. **Create `styles.css`** with `.cp-{component-name}` as root class
2. **Use `prop` DSL** for all user-facing options with descriptions
3. **Define `examples()` block** with at least one example for primitives
4. **Use `classes()` helper** for main component BEM generation
5. **Use lambdas for defaults**: `default: -> { :value }`

### Slots

```ruby
# Simple class reference (preferred)
renders_one :header, Header
renders_many :items, Aeros::Primitives::Table::Row

# Content-only slot (no component)
renders_one :actions_area

# Polymorphic slots (multiple types)
renders_many :items, types: {
  item: { renders: ->(**opts) { Item.new(**opts) }, as: :item },
  separator: { renders: -> { Separator.new }, as: :separator }
}

# Lambda (only when parent context needed)
renders_many :items, ->(value:, **opts) {
  RadioItem.new(name: name, checked: self.value == value, **opts)
}
```

### Templates (all valid)

- Separate `.erb` file - complex templates
- `erb_template <<~ERB` - simple inline templates
- `#call` method - exceptional cases (pure Ruby rendering)
- `tag.div` helpers - fine within any template approach

---

## DON'T

1. **Don't use `.name`** on class references:

   ```ruby
   # BAD
   renders_many :items, Item.name

   # GOOD
   renders_many :items, Item
   ```

2. **Don't use `proc { }` for defaults** (use lambdas):

   ```ruby
   # BAD
   default: proc { false }

   # GOOD
   default: -> { false }
   ```

3. **Don't create separate BEM blocks for nested components**:

   ```css
   /* BAD - separate block */
   .cp-sidebar-item {
   }

   /* GOOD - element of parent */
   .cp-sidebar {
     &__item {
     }
   }
   ```

4. **Don't use `option` for main component user-facing props** - use `prop` for documentation

5. **Don't skip examples** for primitive components

---

## Stimulus Controllers

### File: `controller.js`

```javascript
import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["content", "trigger"];
  static values = { open: { type: Boolean, default: false } };

  connect() {}
  disconnect() {}

  toggle() {
    this.openValue = !this.openValue;
  }
}
```

### Ruby Helpers

```ruby
# In component
stimulus_controller        # { controller: "aeros--my-component" }
stimulus_target("menu")    # { "aeros--my-component-target" => "menu" }
stimulus_action("click")   # { action: "click->aeros--my-component#click" }
stimulus_value("open", v)  # { "aeros--my-component-open-value" => v }
```

---

## Helpers

```ruby
# Render primitive
ui("button", label: "Click", variant: :primary)

# Render block
block("component_preview", title: "Demo")

# Render page
page("showcase/show", component_class: klass)
```

---

## Tests

Tests automatically verify:

- All components can be instantiated
- All primitives have examples defined
- All components have `styles.css`
- CSS uses correct BEM prefix (`cp-`, `cb-`)
- Rendered HTML contains BEM class
- Component CSS only uses variables defined in schema (`theme.rb`)
- Theme presets (`themes/*.css`) define all schema variables

Run: `bundle exec rails test test/components/aeros/components_test.rb`

---

## Build

CSS compilation: `npm run build:css`

Compiles `source.css` → `application.css` using PostCSS (nested syntax, imports).
