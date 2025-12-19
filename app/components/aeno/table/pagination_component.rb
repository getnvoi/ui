module Aeno::Table
  class PaginationComponent < ::Aeno::ApplicationViewComponent
    option(:current_page, default: proc { 1 })
    option(:total_pages, default: proc { 1 })
    option(:per_page, default: proc { 20 })
    option(:total_count, default: proc { 0 })
    option(:selected_count, optional: true)
    option(:per_page_options, default: proc { [10, 20, 30, 50, 100] })
    option(:url, optional: true)
    option(:translations, default: proc {
      {
        per_page: "Per page",
        page: "Page",
        of: "of",
        selected: "selected"
      }
    })

    def page_url(page)
      base = url || helpers.request.path
      params = helpers.request.query_parameters.merge(page:)
      "#{base}?#{params.to_query}"
    end

    def per_page_url(size)
      base = url || helpers.request.path
      params = helpers.request.query_parameters.merge(per_page: size, page: 1)
      "#{base}?#{params.to_query}"
    end

    def can_previous?
      current_page > 1
    end

    def can_next?
      current_page < total_pages
    end
  end
end
