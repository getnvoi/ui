require "test_helper"

module Aeno
  class ShowcaseControllerTest < ActionDispatch::IntegrationTest
    include Engine.routes.url_helpers
    include ComponentDiscovery

    test "index renders successfully" do
      get root_path
      assert_response :success
    end

    # Dynamically test all components (excluding nested components)
    ShowcaseController.discover_component_paths.each do |component_name, component_path|
      component_title = component_name.titleize

      test "#{component_title} showcase page renders successfully" do
        get showcase_path(component_name)
        assert_response :success, "Expected #{component_title} showcase to render successfully"

        # Assert at least one example exists
        assert_select "[data-example-key]", { minimum: 1 }, "#{component_title} must have at least one example"

        # Assert each example has a data-controller within it
        component_class = "Aeno::#{component_path.camelize}::Component".constantize
        component_class.examples_list.each do |example|
          assert_select "[data-example-key='#{example.key}'] [data-controller]", { minimum: 1 }, "#{component_title} example '#{example.key}' must render component with data-controller"
        end
      end
    end
  end
end
