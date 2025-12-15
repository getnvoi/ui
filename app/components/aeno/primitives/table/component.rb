module Aeno::Primitives::Table
  class Component < ::Aeno::ApplicationViewComponent
    prop :id, description: "HTML id attribute", optional: true

    renders_one :header, Aeno::Primitives::Table::Header
    renders_many :rows, Aeno::Primitives::Table::Row

    examples("Table", description: "Data table with header and rows") do |b|
      b.example(:default, title: "Default") do |e|
        e.preview
      end
    end
  end
end
