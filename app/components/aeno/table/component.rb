module Aeno::Table
  class Component < ::Aeno::ApplicationViewComponent
    option(:css, optional: true)
    option(:id, optional: true)
    option(:sticky, optional: true)  # nil, :first, :last, :both
    option(:selectable, default: proc { false })

    attr_reader :filter_names

    def initialize(**options)
      super
      @filter_names = []
    end

    renders_one :header, lambda { |&block|
      HeaderComponent.new(
        table: self,
        selectable:,
        sticky:,
        &block
      )
    }

    renders_many :rows, lambda { |id: nil, css: nil, &block|
      if selectable && id.nil?
        raise ArgumentError, "Row id is required when table is selectable"
      end

      RowComponent.new(
        table: self,
        id:,
        css:,
        selectable:,
        sticky:,
        &block
      )
    }

    renders_many :batch_actions, lambda { |**options, &block|
      Aeno::Table::ActionComponent.new(**options, &block)
    }

    renders_many :filters, lambda { |**options, &block|
      @filter_names << options[:name] if options[:name] && options[:type] != :clear_filters
      Aeno::Table::ActionComponent.new(**options.merge(filter_names: @filter_names), &block)
    }

    renders_one :pagination, "Aeno::Table::PaginationComponent"

    class HeaderComponent < Aeno::ApplicationViewComponent
      attr_reader :table, :selectable, :sticky

      def initialize(table:, selectable:, sticky:, &block)
        @table = table
        @selectable = selectable
        @sticky = sticky
        super()
      end

      renders_many :columns, lambda { |css: nil, &block|
        ColumnComponent.new(
          selectable:,
          sticky:,
          css:,
          &block
        )
      }

      class ColumnComponent < Aeno::ApplicationViewComponent
        option(:selectable)
        option(:sticky)
        option(:css, optional: true)

        attr_accessor :is_first, :is_last

        def call
          is_first = @is_first || false
          is_last = @is_last || false

          sticky_classes = []
          if sticky == :first && is_first
            sticky_classes << "sticky left-0 z-20 bg-white relative after:absolute after:right-0 after:top-0 after:bottom-0 after:w-px after:bg-gray-200"
          elsif sticky == :last && is_last
            sticky_classes << "sticky right-0 z-20 bg-white relative before:absolute before:left-0 before:top-0 before:bottom-0 before:w-px before:bg-gray-200"
          elsif sticky == :both
            if is_first
              sticky_classes << "sticky left-0 z-20 bg-white relative after:absolute after:right-0 after:top-0 after:bottom-0 after:w-px after:bg-gray-200"
            elsif is_last
              sticky_classes << "sticky right-0 z-20 bg-white relative before:absolute before:left-0 before:top-0 before:bottom-0 before:w-px before:bg-gray-200"
            end
          end

          classes = ["px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider", sticky_classes, css].flatten.compact.join(" ")

          content_tag(:th, scope: "col", class: classes) do
            if selectable && is_first
              content_tag(:div, class: "flex items-center") do
                safe_join([
                  content_tag(:div, class: "mr-2 flex-shrink-0") do
                    render Aeno::Checkbox::Component.new(
                      name: "select_all",
                      value: "all",
                      data: {
                        action: "change->aeno--table#toggleAll",
                        "aeno--table-target": "headerCheckbox"
                      }
                    )
                  end,
                  content_tag(:div, content, class: "truncate w-full min-w-0")
                ])
              end
            else
              content_tag(:div, content, class: "truncate w-full min-w-0")
            end
          end
        end
      end

      def call
        total = columns.length

        content_tag(:thead, class: "bg-gray-50") do
          content_tag(:tr) do
            columns.each_with_index.map do |column, idx|
              column.is_first = (idx == 0)
              column.is_last = (idx == total - 1)
              column.to_s
            end.join.html_safe
          end
        end
      end
    end

    class RowComponent < Aeno::ApplicationViewComponent
      attr_reader :table, :row_id, :selectable, :sticky

      def initialize(table:, id: nil, css: nil, selectable:, sticky:, &block)
        @table = table
        @row_id = id
        @css = css
        @selectable = selectable
        @sticky = sticky
        super()
      end

      renders_many :cells, lambda { |css: nil, &block|
        CellComponent.new(
          selectable:,
          sticky:,
          row_id:,
          css:,
          &block
        )
      }

      class CellComponent < Aeno::ApplicationViewComponent
        option(:selectable)
        option(:sticky)
        option(:row_id)
        option(:css, optional: true)

        attr_accessor :is_first, :is_last

        def call
          is_first = @is_first || false
          is_last = @is_last || false
          is_sticky = false

          sticky_classes = []
          if sticky == :first && is_first
            sticky_classes << "sticky left-0 z-20 bg-white relative after:absolute after:right-0 after:top-0 after:bottom-0 after:w-px after:bg-gray-200"
            is_sticky = true
          elsif sticky == :last && is_last
            sticky_classes << "sticky right-0 z-20 bg-white relative before:absolute before:left-0 before:top-0 before:bottom-0 before:w-px before:bg-gray-200"
            is_sticky = true
          elsif sticky == :both
            if is_first
              sticky_classes << "sticky left-0 z-20 bg-white relative after:absolute after:right-0 after:top-0 after:bottom-0 after:w-px after:bg-gray-200"
              is_sticky = true
            elsif is_last
              sticky_classes << "sticky right-0 z-20 bg-white relative before:absolute before:left-0 before:top-0 before:bottom-0 before:w-px before:bg-gray-200"
              is_sticky = true
            end
          end

          base_classes = ["px-6 py-4 text-sm text-gray-900 min-w-32 max-w-0"]
          base_classes << "overflow-hidden" unless is_sticky
          classes = [base_classes, sticky_classes, css].flatten.compact.join(" ")

          content_tag(:td, class: classes) do
            if selectable && is_first
              content_tag(:div, class: "flex items-center") do
                safe_join([
                  content_tag(:div, class: "mr-2 flex-shrink-0") do
                    render Aeno::Checkbox::Component.new(
                      name: "row_ids[]",
                      value: row_id,
                      data: {
                        action: "change->aeno--table#toggleRow",
                        "aeno--table-target": "rowCheckbox",
                        "row-id": row_id
                      }
                    )
                  end,
                  content_tag(:div, content, class: "truncate w-full min-w-0 overflow-hidden")
                ])
              end
            else
              content_tag(:div, content, class: "truncate w-full min-w-0 overflow-hidden")
            end
          end
        end
      end

      def call
        total = cells.length

        content_tag(:tr, class: @css) do
          cells.each_with_index.map do |cell, idx|
            cell.is_first = (idx == 0)
            cell.is_last = (idx == total - 1)
            cell.to_s
          end.join.html_safe
        end
      end
    end

    def table_classes
      [
        "min-w-full divide-y divide-gray-200 table-fixed",
        css
      ].compact.join(" ")
    end

    examples("Table", description: "Data tables with selection, filters, and sticky columns") do |b|
      # BASIC TABLES
      b.example(:basic, title: "Basic Table") do |e|
        e.preview do |table|
          table.with_header do |h|
            h.with_column { "Name" }
            h.with_column { "Email" }
          end
          table.with_row do |r|
            r.with_cell { "John Doe" }
            r.with_cell { "john@example.com" }
          end
          table.with_row do |r|
            r.with_cell { "Jane Smith" }
            r.with_cell { "jane@example.com" }
          end
          table.with_row do |r|
            r.with_cell { "Bob Wilson" }
            r.with_cell { "bob@example.com" }
          end
        end

        e.preview(css: "border border-gray-300") do |table|
          table.with_header do |h|
            h.with_column { "Product" }
            h.with_column { "Price" }
          end
          table.with_row do |r|
            r.with_cell { "Widget" }
            r.with_cell { "$10.00" }
          end
        end
      end

      b.example(:truncation, title: "Content Truncation") do |e|
        e.preview do |table|
          table.with_header do |h|
            h.with_column { "Name" }
            h.with_column { "Description" }
          end
          table.with_row do |r|
            r.with_cell { "Product A" }
            r.with_cell { "Short description" }
          end
          table.with_row do |r|
            r.with_cell { "Product B" }
            r.with_cell { "This is an extremely long product description that will demonstrate the truncation behavior when text exceeds the available space in the table cell and should show ellipsis" }
          end
        end
      end

      # STICKY COLUMNS
      b.example(:sticky_first, title: "Sticky First Column") do |e|
        e.preview(sticky: :first) do |table|
          table.with_header do |h|
            h.with_column { "ID" }
            h.with_column { "Name" }
            h.with_column { "Email" }
            h.with_column { "Phone" }
            h.with_column { "Address" }
            h.with_column { "City" }
            h.with_column { "State" }
          end
          5.times do |i|
            table.with_row do |r|
              r.with_cell { (i + 1).to_s }
              r.with_cell { "Person #{i + 1}" }
              r.with_cell { "person#{i + 1}@example.com" }
              r.with_cell { "(555) 123-#{1000 + i}" }
              r.with_cell { "#{100 + i} Main St" }
              r.with_cell { "Springfield" }
              r.with_cell { "IL" }
            end
          end
        end
      end

      b.example(:sticky_last, title: "Sticky Last Column") do |e|
        e.preview(sticky: :last) do |table|
          table.with_header do |h|
            h.with_column { "Name" }
            h.with_column { "Email" }
            h.with_column { "Phone" }
            h.with_column { "Address" }
            h.with_column { "City" }
            h.with_column { "State" }
            h.with_column { "ZIP" }
            h.with_column { "Country" }
            h.with_column { "Department" }
            h.with_column { "Status" }
            h.with_column { "Actions" }
          end
          5.times do |i|
            table.with_row do |r|
              r.with_cell { "Person #{i + 1}" }
              r.with_cell { "person#{i + 1}@example.com" }
              r.with_cell { "(555) 123-#{1000 + i}" }
              r.with_cell { "#{100 + i} Main Street" }
              r.with_cell { "Springfield" }
              r.with_cell { "IL" }
              r.with_cell { "62701" }
              r.with_cell { "United States" }
              r.with_cell { "Engineering" }
              r.with_cell { "Active" }
              r.with_cell { "Edit | Delete" }
            end
          end
        end
      end

      b.example(:sticky_both, title: "Sticky First and Last") do |e|
        e.preview(sticky: :both) do |table|
          table.with_header do |h|
            h.with_column { "ID" }
            h.with_column { "Name" }
            h.with_column { "Email" }
            h.with_column { "Phone" }
            h.with_column { "Address" }
            h.with_column { "City" }
            h.with_column { "State" }
            h.with_column { "Status" }
            h.with_column { "Actions" }
          end
          10.times do |i|
            table.with_row do |r|
              r.with_cell { (i + 1).to_s }
              r.with_cell { "Person #{i + 1}" }
              r.with_cell { "person#{i + 1}@example.com" }
              r.with_cell { "(555) 123-#{1000 + i}" }
              r.with_cell { "#{100 + i} Main St" }
              r.with_cell { "Springfield" }
              r.with_cell { "IL" }
              r.with_cell { ["Active", "Inactive"].sample }
              r.with_cell { "Edit | Delete" }
            end
          end
        end
      end

      # ROW SELECTION
      b.example(:selectable, title: "Selectable Rows") do |e|
        e.preview(selectable: true) do |table|
          table.with_header do |h|
            h.with_column { "Name" }
            h.with_column { "Email" }
          end
          3.times do |i|
            table.with_row(id: (i + 1).to_s) do |r|
              r.with_cell { "Person #{i + 1}" }
              r.with_cell { "person#{i + 1}@example.com" }
            end
          end
        end

        e.preview(selectable: true) do |table|
          table.with_header do |h|
            h.with_column { "Name" }
            h.with_column { "Email" }
            h.with_column { "Status" }
          end
          10.times do |i|
            table.with_row(id: (i + 1).to_s) do |r|
              r.with_cell { "Person #{i + 1}" }
              r.with_cell { "person#{i + 1}@example.com" }
              r.with_cell { ["Active", "Inactive"].sample }
            end
          end
        end
      end

      b.example(:selectable_sticky, title: "Selectable + Sticky") do |e|
        e.preview(selectable: true, sticky: :first) do |table|
          table.with_header do |h|
            h.with_column { "Name" }
            h.with_column { "Email" }
            h.with_column { "Phone" }
            h.with_column { "City" }
          end
          5.times do |i|
            table.with_row(id: (i + 1).to_s) do |r|
              r.with_cell { "Person #{i + 1}" }
              r.with_cell { "person#{i + 1}@example.com" }
              r.with_cell { "(555) 123-#{1000 + i}" }
              r.with_cell { "Springfield" }
            end
          end
        end

        e.preview(selectable: true, sticky: :both) do |table|
          table.with_header do |h|
            h.with_column { "Name" }
            h.with_column { "Email" }
            h.with_column { "Phone" }
            h.with_column { "Actions" }
          end
          5.times do |i|
            table.with_row(id: (i + 1).to_s) do |r|
              r.with_cell { "Person #{i + 1}" }
              r.with_cell { "person#{i + 1}@example.com" }
              r.with_cell { "(555) 123-#{1000 + i}" }
              r.with_cell { "Edit | Delete" }
            end
          end
        end
      end

      # BATCH ACTIONS
      b.example(:batch_button, title: "Batch Actions - Buttons") do |e|
        e.preview(selectable: true) do |table|
          table.with_batch_action(type: :button, label: "Delete", url: "/bulk_delete", variant: :destructive, icon: "trash")

          table.with_header do |h|
            h.with_column { "Name" }
            h.with_column { "Email" }
          end
          5.times do |i|
            table.with_row(id: (i + 1).to_s) do |r|
              r.with_cell { "Person #{i + 1}" }
              r.with_cell { "person#{i + 1}@example.com" }
            end
          end
        end

        e.preview(selectable: true) do |table|
          table.with_batch_action(type: :button, label: "Delete", url: "/bulk_delete", variant: :destructive, icon: "trash")
          table.with_batch_action(type: :button, label: "Export", url: "/export", variant: :secondary, icon: "download")

          table.with_header do |h|
            h.with_column { "Name" }
            h.with_column { "Email" }
          end
          5.times do |i|
            table.with_row(id: (i + 1).to_s) do |r|
              r.with_cell { "Person #{i + 1}" }
              r.with_cell { "person#{i + 1}@example.com" }
            end
          end
        end
      end

      b.example(:batch_select, title: "Batch Actions - Select") do |e|
        e.preview(selectable: true) do |table|
          table.with_batch_action(type: :select, name: "bulk_action", url: "/bulk_action", label: "Mark as") do |s|
            s.with_option(value: "read", label: "Read")
            s.with_option(value: "unread", label: "Unread")
          end

          table.with_header do |h|
            h.with_column { "Name" }
            h.with_column { "Email" }
          end
          5.times do |i|
            table.with_row(id: (i + 1).to_s) do |r|
              r.with_cell { "Person #{i + 1}" }
              r.with_cell { "person#{i + 1}@example.com" }
            end
          end
        end
      end

      # FILTERS
      b.example(:filter_search, title: "Filter - Search") do |e|
        e.preview do |table|
          table.with_filter(type: :search, name: "q", placeholder: "Search contacts...")

          table.with_header do |h|
            h.with_column { "Name" }
            h.with_column { "Email" }
          end
          5.times do |i|
            table.with_row do |r|
              r.with_cell { "Person #{i + 1}" }
              r.with_cell { "person#{i + 1}@example.com" }
            end
          end
        end
      end

      b.example(:filter_select, title: "Filter - Select") do |e|
        e.preview do |table|
          table.with_filter(type: :select, name: "status", label: "Status") do |s|
            s.with_option(value: "", label: "All")
            s.with_option(value: "active", label: "Active")
            s.with_option(value: "archived", label: "Archived")
          end

          table.with_header do |h|
            h.with_column { "Name" }
            h.with_column { "Status" }
          end
          5.times do |i|
            table.with_row do |r|
              r.with_cell { "Person #{i + 1}" }
              r.with_cell { ["Active", "Archived"].sample }
            end
          end
        end
      end

      # COMBINED
      b.example(:combined_all, title: "Combined - All Features") do |e|
        e.preview(sticky: :both, selectable: true) do |table|
          table.with_filter(type: :search, name: "q", placeholder: "Search...")
          table.with_filter(type: :select, name: "status", label: "Status") do |s|
            s.with_option(value: "", label: "All")
            s.with_option(value: "active", label: "Active")
          end
          table.with_filter(type: :clear_filters, label: "Clear all")

          table.with_batch_action(type: :button, label: "Delete", url: "/bulk_delete", variant: :destructive, icon: "trash")
          table.with_batch_action(type: :select, name: "action", url: "/bulk_action", label: "Action") do |s|
            s.with_option(value: "archive", label: "Archive")
            s.with_option(value: "delete", label: "Delete")
          end

          table.with_pagination(
            current_page: 1,
            total_pages: 10,
            per_page: 15,
            total_count: 150,
            selected_count: 3
          )

          table.with_header do |h|
            h.with_column { "ID" }
            h.with_column { "Name" }
            h.with_column { "Email" }
            h.with_column { "Phone" }
            h.with_column { "Address" }
            h.with_column { "City" }
            h.with_column { "State" }
            h.with_column { "ZIP" }
            h.with_column { "Department" }
            h.with_column { "Status" }
            h.with_column { "Actions" }
          end

          15.times do |i|
            table.with_row(id: (i + 1).to_s) do |r|
              r.with_cell { (i + 1).to_s }
              r.with_cell { "Person #{i + 1}" }
              r.with_cell { "person#{i + 1}@example.com" }
              r.with_cell { "(555) 123-#{1000 + i}" }
              r.with_cell { "#{100 + i} Main Street" }
              r.with_cell { "Springfield" }
              r.with_cell { "IL" }
              r.with_cell { "62701" }
              r.with_cell { "Engineering" }
              r.with_cell { ["Active", "Inactive"].sample }
              r.with_cell { "Edit | Delete" }
            end
          end
        end
      end
    end
  end
end
