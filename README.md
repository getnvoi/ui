# Aeno - Rails Engine UI Component Library

A Rails engine providing reusable UI components with Tailwind CSS styling and Stimulus controllers. Built with ViewComponent and designed for easy integration into Rails engines.

## Components Library

The Aeno gem provides the following components:

### Form Components
- **`Button`** - Styled button with variants (default, white, light, outline) and sizes (xsmall, small, large)
- **`InputText`** - Text input field with wrapper and label support
- **`InputPassword`** - Password input with show/hide toggle functionality
- **`InputSelect`** - Styled select dropdown
- **`InputWrapper`** - Wrapper component for form inputs with labels

### Layout Components
- **`Page`** - Page container component
- **`Card`** - Card container with styling
- **`Table`** - Styled table component
- **`Dropdown`** - Interactive dropdown menu with Stimulus controller
- **`Empty`** - Empty state component
- **`Spinner`** - Loading spinner with size and variant options

### Usage in Views

```erb
<%= ui("button", label: "Click me", variant: :default) %>
<%= ui("input_text", name: "email", label: "Email") %>
<%= ui("input_password", name: "password", label: "Password") %>
<%= ui("card") do %>
  <h2>Card content</h2>
<% end %>
```

## Installation

Add this line to your engine's Gemfile:

```ruby
gem "aeno", path: "../ui"  # or from a gem server
```

And then execute:
```bash
$ bundle
```

## Integration with Rails Engines

The Aeno gem provides convenience helpers to quickly integrate it into your Rails engine.

### 1. Engine Setup

In your `lib/your_engine/engine.rb`:

```ruby
require "aeno"

module YourEngine
  class << self
    attr_accessor :importmap
  end

  class Engine < ::Rails::Engine
    isolate_namespace YourEngine

    # Setup assets and importmap with Aeno gem integration
    Aeno::EngineHelpers.setup_assets(self, namespace: YourEngine)
    Aeno::EngineHelpers.setup_importmap(self, namespace: YourEngine)
  end
end
```

**What this does:**
- Configures asset paths for your engine and the Aeno gem
- Sets up importmap that automatically includes Aeno gem's JavaScript and components
- Configures cache sweepers for development hot-reloading

### 2. ApplicationViewComponent

Create `app/components/your_engine/application_view_component.rb`:

```ruby
module YourEngine
  class ApplicationViewComponent < Aeno::ApplicationViewComponent
    def controller_name
      # Override to use your engine's namespace for Stimulus controllers
      name = self.class.name
        .sub(/^YourEngine::/, "")
        .sub(/::Component$/, "")
        .underscore

      "your-engine--#{name.gsub('/', '--').gsub('_', '-')}"
    end
  end
end
```

**What this provides:**
- All Aeno gem helper methods (stimulus_controller, stimulus_target, etc.)
- TailwindMerge integration for CSS class merging
- Style variants support via ViewComponentContrib
- Dry::Initializer for clean option definitions

### 3. Controller Loading

In `app/javascript/your_engine/controllers/index.js`:

```javascript
import { application } from "your_engine/controllers/application";
import { eagerLoadEngineControllersFrom } from "aeno/controllers/loader";

// Load your engine's controllers
eagerLoadEngineControllersFrom("your_engine/controllers", application);
eagerLoadEngineControllersFrom("your_engine/components", application);

// Load Aeno gem component controllers
eagerLoadEngineControllersFrom("aeno/components", application);
```

**What this does:**
- Uses the shared controller loader from Aeno gem
- Automatically registers Stimulus controllers with correct naming conventions
- Supports multiple namespaces (your engine + Aeno gem)

### 4. Layout Integration

In `app/views/layouts/your_engine/application.html.erb`:

```erb
<!DOCTYPE html>
<html>
  <head>
    <%= csrf_meta_tags %>
    <%= csp_meta_tag %>

    <!-- Include Aeno gem stylesheets -->
    <%= stylesheet_link_tag "aeno/application", media: "all" %>
    <%= stylesheet_link_tag "aeno/tailwind", media: "all" %>

    <!-- Your engine's stylesheets -->
    <%= stylesheet_link_tag "your_engine/application", media: "all" %>
    <%= stylesheet_link_tag "your_engine/tailwind", media: "all" %>

    <!-- Importmap with Aeno gem integration -->
    <%= javascript_importmap_tags "your_engine/application", importmap: YourEngine.importmap %>
  </head>
  <body>
    <%= yield %>
  </body>
</html>
```

### 5. Importmap Configuration

In `config/importmap.rb`:

```ruby
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "your_engine/application"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"

pin_all_from(
  YourEngine::Engine.root.join("app/javascript/your_engine/controllers"),
  under: "your_engine/controllers",
)

pin_all_from(
  YourEngine::Engine.root.join("app/components/your_engine"),
  under: "your_engine/components",
  to: "your_engine"
)
```

**Note:** Aeno gem's importmap is automatically included via `Aeno::EngineHelpers.setup_importmap`

## Convenience Utilities

### Ruby Helpers

#### `Aeno::EngineHelpers.setup_assets(engine_class, namespace:)`
Sets up asset paths for your engine with Propshaft/Sprockets support.

#### `Aeno::EngineHelpers.setup_importmap(engine_class, namespace:)`
Configures importmap with:
- Your engine's importmap
- Aeno gem's importmap (automatic)
- Cache sweepers for development
- Controller action integration

### JavaScript Utilities

#### `eagerLoadEngineControllersFrom(under, application)`
Intelligent Stimulus controller loader for Rails engines that:
- Parses importmap to find controllers
- Registers with correct naming conventions (e.g., `aeno--button`, `your-engine--views--index`)
- Handles both `controller.js` and `*_controller.js` naming
- Supports multiple namespaces

## Development

### Running the Demo App

```bash
cd ui
bin/rails server
```

### Watching Tailwind CSS

```bash
bundle exec rake app:aeno:tailwind_engine_watch
```

## Dependencies

- Rails >= 8.0.3
- importmap-rails ~> 2.2.2
- turbo-rails ~> 2.0
- stimulus-rails ~> 1.3
- tailwindcss-rails ~> 4.3.0
- view_component ~> 4.0
- view_component-contrib ~> 0.2.5
- dry-effects ~> 0.5.0
- tailwind_merge ~> 1.3

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
