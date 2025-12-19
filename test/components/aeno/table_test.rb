require "test_helper"

class Aeno::TableTest < ViewComponent::TestCase
  # ============================================================================
  # BASIC RENDERING
  # ============================================================================

  def test_renders_basic_table
    render_inline Aeno::Table::Component.new do |t|
      t.with_header do |h|
        h.with_column { "Name" }
        h.with_column { "Email" }
      end

      t.with_row do |r|
        r.with_cell { "John Doe" }
        r.with_cell { "john@example.com" }
      end
    end

    assert_selector "table"
    assert_selector "thead"
    assert_selector "tbody"
    assert_selector "th", text: "Name"
    assert_selector "th", text: "Email"
    assert_selector "td", text: "John Doe"
    assert_selector "td", text: "john@example.com"
  end

  def test_applies_overflow_wrapper
    render_inline Aeno::Table::Component.new do |t|
      t.with_header do |h|
        h.with_column { "Name" }
      end
    end

    assert_selector "div.overflow-x-auto table"
  end

  def test_renders_multiple_rows
    render_inline Aeno::Table::Component.new do |t|
      t.with_header do |h|
        h.with_column { "Name" }
      end

      t.with_row do |r|
        r.with_cell { "John" }
      end

      t.with_row do |r|
        r.with_cell { "Jane" }
      end
    end

    assert_selector "tbody tr", count: 2
    assert_selector "td", text: "John"
    assert_selector "td", text: "Jane"
  end

  # ============================================================================
  # DEFAULT TRUNCATION
  # ============================================================================

  def test_cells_have_truncate_class_by_default
    render_inline Aeno::Table::Component.new do |t|
      t.with_header do |h|
        h.with_column { "Name" }
      end

      t.with_row do |r|
        r.with_cell { "John Doe" }
      end
    end

    assert_selector "td div.truncate"
  end

  def test_truncates_long_content
    long_text = "This is a very long description that should be truncated with ellipsis when it exceeds the maximum width"

    render_inline Aeno::Table::Component.new do |t|
      t.with_header do |h|
        h.with_column { "Description" }
      end

      t.with_row do |r|
        r.with_cell { long_text }
      end
    end

    assert_selector "td div.truncate", text: long_text
  end

  # ============================================================================
  # STICKY COLUMNS
  # ============================================================================

  def test_sticky_first_column
    render_inline Aeno::Table::Component.new(sticky: :first) do |t|
      t.with_header do |h|
        h.with_column { "ID" }
        h.with_column { "Name" }
        h.with_column { "Email" }
      end

      t.with_row do |r|
        r.with_cell { "1" }
        r.with_cell { "John" }
        r.with_cell { "john@example.com" }
      end
    end

    # First header column should be sticky
    first_th = page.all("th").first
    assert first_th[:class].include?("sticky")
    assert first_th[:class].include?("left-0")
    assert first_th[:class].include?("z-20")
    assert first_th[:class].include?("bg-white")

    # Other header columns should not be sticky
    other_th = page.all("th")[1]
    refute other_th[:class].include?("sticky")

    # First body cell should be sticky
    first_td = page.all("td").first
    assert first_td[:class].include?("sticky")
    assert first_td[:class].include?("left-0")

    # Other body cells should not be sticky
    other_td = page.all("td")[1]
    refute other_td[:class].include?("sticky")
  end

  def test_sticky_last_column
    render_inline Aeno::Table::Component.new(sticky: :last) do |t|
      t.with_header do |h|
        h.with_column { "Name" }
        h.with_column { "Email" }
        h.with_column { "Actions" }
      end

      t.with_row do |r|
        r.with_cell { "John" }
        r.with_cell { "john@example.com" }
        r.with_cell { "Edit" }
      end
    end

    # Last header column should be sticky right
    last_th = page.all("th").last
    assert last_th[:class].include?("sticky")
    assert last_th[:class].include?("right-0")
    assert last_th[:class].include?("z-20")

    # Other header columns should not be sticky
    first_th = page.all("th").first
    refute first_th[:class].include?("sticky")

    # Last body cell should be sticky right
    last_td = page.all("td").last
    assert last_td[:class].include?("sticky")
    assert last_td[:class].include?("right-0")

    # Other body cells should not be sticky
    first_td = page.all("td").first
    refute first_td[:class].include?("sticky")
  end

  def test_sticky_both_columns
    render_inline Aeno::Table::Component.new(sticky: :both) do |t|
      t.with_header do |h|
        h.with_column { "ID" }
        h.with_column { "Name" }
        h.with_column { "Email" }
        h.with_column { "Actions" }
      end

      t.with_row do |r|
        r.with_cell { "1" }
        r.with_cell { "John" }
        r.with_cell { "john@example.com" }
        r.with_cell { "Edit" }
      end
    end

    all_th = page.all("th")
    all_td = page.all("td")

    # First column sticky left
    assert all_th.first[:class].include?("sticky")
    assert all_th.first[:class].include?("left-0")
    assert all_td.first[:class].include?("sticky")
    assert all_td.first[:class].include?("left-0")

    # Last column sticky right
    assert all_th.last[:class].include?("sticky")
    assert all_th.last[:class].include?("right-0")
    assert all_td.last[:class].include?("sticky")
    assert all_td.last[:class].include?("right-0")

    # Middle columns not sticky
    refute all_th[1][:class].include?("sticky")
    refute all_td[1][:class].include?("sticky")
  end

  def test_no_sticky_columns_by_default
    render_inline Aeno::Table::Component.new do |t|
      t.with_header do |h|
        h.with_column { "Name" }
        h.with_column { "Email" }
      end
    end

    page.all("th").each do |th|
      refute th[:class].include?("sticky")
    end
  end

  # ============================================================================
  # ROW SELECTION
  # ============================================================================

  def test_selectable_table_has_stimulus_controller
    render_inline Aeno::Table::Component.new(selectable: true) do |t|
      t.with_header do |h|
        h.with_column { "Name" }
      end

      t.with_row(id: "1") do |r|
        r.with_cell { "John" }
      end
    end

    assert_selector "[data-controller='aeno--table']"
  end

  def test_non_selectable_table_has_stimulus_controller
    render_inline Aeno::Table::Component.new do |t|
      t.with_header do |h|
        h.with_column { "Name" }
      end
    end

    assert_selector "[data-controller='aeno--table']"
  end

  def test_selectable_embeds_checkbox_in_first_header_cell
    render_inline Aeno::Table::Component.new(selectable: true) do |t|
      t.with_header do |h|
        h.with_column { "Name" }
        h.with_column { "Email" }
      end
    end

    first_th = page.all("th").first
    assert_selector "th:first-child input[type='checkbox']"
    assert_selector "th:first-child input[data-action='change->aeno--table#toggleAll']"
    assert_selector "th:first-child input[data-aeno--table-target='headerCheckbox']"
    assert first_th.text.include?("Name")
  end

  def test_selectable_embeds_checkbox_in_first_body_cell
    render_inline Aeno::Table::Component.new(selectable: true) do |t|
      t.with_header do |h|
        h.with_column { "Name" }
      end

      t.with_row(id: "1") do |r|
        r.with_cell { "John Doe" }
      end
    end

    first_td = page.all("td").first
    assert_selector "td:first-child input[type='checkbox']"
    assert_selector "td:first-child input[data-action='change->aeno--table#toggleRow']"
    assert_selector "td:first-child input[data-aeno--table-target='rowCheckbox']"
    assert_selector "td:first-child input[data-row-id='1']"
    assert first_td.text.include?("John Doe")
  end

  def test_selectable_requires_row_id
    error = assert_raises(ArgumentError) do
      render_inline Aeno::Table::Component.new(selectable: true) do |t|
        t.with_header do |h|
          h.with_column { "Name" }
        end

        t.with_row do |r|  # Missing id
          r.with_cell { "John" }
        end
      end
    end

    assert_match(/id.*required.*selectable/i, error.message)
  end

  def test_multiple_selectable_rows
    render_inline Aeno::Table::Component.new(selectable: true) do |t|
      t.with_header do |h|
        h.with_column { "Name" }
      end

      t.with_row(id: "1") do |r|
        r.with_cell { "John" }
      end

      t.with_row(id: "2") do |r|
        r.with_cell { "Jane" }
      end

      t.with_row(id: "3") do |r|
        r.with_cell { "Bob" }
      end
    end

    assert_selector "input[data-row-id='1']"
    assert_selector "input[data-row-id='2']"
    assert_selector "input[data-row-id='3']"
    assert_selector "input[data-aeno--table-target='rowCheckbox']", count: 3
  end

  # ============================================================================
  # BATCH ACTIONS
  # ============================================================================

  def test_batch_actions_toolbar_hidden_by_default
    render_inline Aeno::Table::Component.new(selectable: true) do |t|
      t.with_batch_action(type: :button, label: "Delete", url: "/delete")

      t.with_header do |h|
        h.with_column { "Name" }
      end

      t.with_row(id: "1") do |r|
        r.with_cell { "John" }
      end
    end

    assert_selector "[data-aeno--table-target='batchToolbar'].hidden"
  end

  def test_batch_actions_toolbar_has_selected_count
    render_inline Aeno::Table::Component.new(selectable: true) do |t|
      t.with_batch_action(type: :button, label: "Delete", url: "/delete")

      t.with_header do |h|
        h.with_column { "Name" }
      end
    end

    assert_selector "[data-aeno--table-target='selectedCount']"
  end

  def test_batch_action_button_renders
    render_inline Aeno::Table::Component.new(selectable: true) do |t|
      t.with_batch_action(
        type: :button,
        label: "Delete",
        url: "/bulk_delete",
        variant: :destructive,
        icon: "trash"
      )

      t.with_header do |h|
        h.with_column { "Name" }
      end
    end

    # Should render a button within batch toolbar
    assert_selector "[data-aeno--table-target='batchToolbar'] button", text: "Delete"
  end

  def test_batch_action_select_renders
    render_inline Aeno::Table::Component.new(selectable: true) do |t|
      t.with_batch_action(
        type: :select,
        name: "bulk_action",
        url: "/bulk_action",
        label: "Action"
      ) do |s|
        s.with_option(value: "archive", label: "Archive")
        s.with_option(value: "delete", label: "Delete")
      end

      t.with_header do |h|
        h.with_column { "Name" }
      end
    end

    # Should render a select within batch toolbar
    assert_selector "[data-aeno--table-target='batchToolbar'] select[name='bulk_action']"
    assert_selector "option[value='archive']", text: "Archive"
    assert_selector "option[value='delete']", text: "Delete"
  end

  def test_batch_action_custom_renders
    render_inline Aeno::Table::Component.new(selectable: true) do |t|
      t.with_batch_action(type: :custom) do
        '<div class="custom-action">Custom Action</div>'.html_safe
      end

      t.with_header do |h|
        h.with_column { "Name" }
      end
    end

    assert_selector ".custom-action", text: "Custom Action"
  end

  def test_multiple_batch_actions
    render_inline Aeno::Table::Component.new(selectable: true) do |t|
      t.with_batch_action(type: :button, label: "Delete", url: "/delete")
      t.with_batch_action(type: :button, label: "Export", url: "/export")
      t.with_batch_action(type: :button, label: "Archive", url: "/archive")

      t.with_header do |h|
        h.with_column { "Name" }
      end
    end

    assert_selector "[data-aeno--table-target='batchToolbar'] button", count: 3
  end

  def test_batch_action_requires_type
    error = assert_raises(KeyError) do
      render_inline Aeno::Table::Component.new(selectable: true) do |t|
        t.with_batch_action(label: "Delete", url: "/delete")  # Missing type

        t.with_header do |h|
          h.with_column { "Name" }
        end
      end
    end

    assert_match(/type.*required/i, error.message)
  end

  def test_batch_action_validates_type
    error = assert_raises(ArgumentError) do
      render_inline Aeno::Table::Component.new(selectable: true) do |t|
        t.with_batch_action(type: :invalid, label: "Delete", url: "/delete")

        t.with_header do |h|
          h.with_column { "Name" }
        end
      end
    end

    assert_match(/type.*must be one of/i, error.message)
  end

  def test_batch_actions_not_shown_when_not_selectable
    render_inline Aeno::Table::Component.new(selectable: false) do |t|
      t.with_batch_action(type: :button, label: "Delete", url: "/delete")

      t.with_header do |h|
        h.with_column { "Name" }
      end
    end

    refute_selector "[data-aeno--table-target='batchToolbar']"
  end

  # ============================================================================
  # FILTERS
  # ============================================================================

  def test_filter_search_renders
    render_inline Aeno::Table::Component.new do |t|
      t.with_filter(
        type: :search,
        name: "q",
        url: "/contacts",
        placeholder: "Search contacts...",
        debounce: 300
      )

      t.with_header do |h|
        h.with_column { "Name" }
      end
    end

    assert_selector "input[type='text'][name='q']"
    assert_selector "input[placeholder='Search contacts...']"
    # Should have debounce action
    assert_selector "input[data-action*='aeno--table#search']"
  end

  def test_filter_search_default_debounce
    render_inline Aeno::Table::Component.new do |t|
      t.with_filter(
        type: :search,
        name: "q",
        url: "/contacts"
      )

      t.with_header do |h|
        h.with_column { "Name" }
      end
    end

    assert_selector "input[name='q']"
    # Should have default 300ms debounce
  end

  def test_filter_select_renders
    render_inline Aeno::Table::Component.new do |t|
      t.with_filter(
        type: :select,
        name: "status",
        url: "/contacts",
        label: "Status"
      ) do |s|
        s.with_option(value: "", label: "All")
        s.with_option(value: "active", label: "Active")
        s.with_option(value: "archived", label: "Archived")
      end

      t.with_header do |h|
        h.with_column { "Name" }
      end
    end

    assert_selector "select[name='status']"
    assert_selector "option[value='']", text: "All"
    assert_selector "option[value='active']", text: "Active"
    assert_selector "option[value='archived']", text: "Archived"
  end

  def test_filter_button_renders
    render_inline Aeno::Table::Component.new do |t|
      t.with_filter(
        type: :button,
        label: "Clear Filters",
        url: "/contacts"
      )

      t.with_header do |h|
        h.with_column { "Name" }
      end
    end

    assert_selector "button", text: "Clear Filters"
  end

  def test_multiple_filters
    render_inline Aeno::Table::Component.new do |t|
      t.with_filter(type: :select, name: "status", url: "/contacts", label: "Status") do |s|
        s.with_option(value: "active", label: "Active")
      end

      t.with_filter(type: :select, name: "category", url: "/contacts", label: "Category") do |s|
        s.with_option(value: "tech", label: "Tech")
      end

      t.with_filter(type: :button, label: "Clear", url: "/contacts")

      t.with_header do |h|
        h.with_column { "Name" }
      end
    end

    assert_selector "select[name='status']"
    assert_selector "select[name='category']"
    assert_selector "button", text: "Clear"
  end

  def test_filters_always_visible
    render_inline Aeno::Table::Component.new do |t|
      t.with_filter(type: :button, label: "Filter", url: "/contacts")

      t.with_header do |h|
        h.with_column { "Name" }
      end
    end

    # Filters should not have hidden class
    refute_selector "button.hidden", text: "Filter"
  end

  def test_filter_requires_type
    error = assert_raises(KeyError) do
      render_inline Aeno::Table::Component.new do |t|
        t.with_filter(label: "Filter", url: "/contacts")  # Missing type

        t.with_header do |h|
          h.with_column { "Name" }
        end
      end
    end

    assert_match(/type.*required/i, error.message)
  end

  # ============================================================================
  # COMBINED FEATURES
  # ============================================================================

  def test_sticky_and_selectable_combined
    render_inline Aeno::Table::Component.new(sticky: :first, selectable: true) do |t|
      t.with_header do |h|
        h.with_column { "ID" }
        h.with_column { "Name" }
      end

      t.with_row(id: "1") do |r|
        r.with_cell { "1" }
        r.with_cell { "John" }
      end
    end

    # First column should be both sticky and have checkbox
    first_th = page.all("th").first
    assert first_th[:class].include?("sticky")
    assert_selector "th:first-child input[type='checkbox']"

    first_td = page.all("td").first
    assert first_td[:class].include?("sticky")
    assert_selector "td:first-child input[type='checkbox']"
  end

  def test_all_features_combined
    render_inline Aeno::Table::Component.new(sticky: :both, selectable: true) do |t|
      # Filters
      t.with_filter(type: :search, name: "q", url: "/contacts", placeholder: "Search...")

      t.with_filter(type: :select, name: "status", url: "/contacts", label: "Status") do |s|
        s.with_option(value: "active", label: "Active")
      end

      # Batch actions
      t.with_batch_action(type: :button, label: "Delete", url: "/bulk_delete", variant: :destructive)
      t.with_batch_action(type: :select, name: "action", url: "/bulk_action", label: "Action") do |s|
        s.with_option(value: "archive", label: "Archive")
      end

      t.with_header do |h|
        h.with_column { "ID" }
        h.with_column { "Name" }
        h.with_column { "Email" }
        h.with_column { "Actions" }
      end

      t.with_row(id: "1") do |r|
        r.with_cell { "1" }
        r.with_cell { "John" }
        r.with_cell { "john@example.com" }
        r.with_cell { "Edit" }
      end
    end

    # Has Stimulus controller
    assert_selector "[data-controller='aeno--table']"

    # Has filters
    assert_selector "input[name='q']"
    assert_selector "select[name='status']"

    # Has batch actions toolbar
    assert_selector "[data-aeno--table-target='batchToolbar']"

    # Has sticky columns
    first_th = page.all("th").first
    last_th = page.all("th").last
    assert first_th[:class].include?("sticky left-0")
    assert last_th[:class].include?("sticky right-0")

    # Has checkboxes
    assert_selector "input[data-aeno--table-target='headerCheckbox']"
    assert_selector "input[data-row-id='1']"

    # Cells truncate
    assert_selector "td div.truncate"
  end
end
