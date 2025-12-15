# desc "Explaining what the task does"
namespace :aeno do
  desc "build tailwind css once"
  task tailwind_build: :environment do
    require "tailwindcss-rails"

    command = [
      Tailwindcss::Commands.compile_command.first,
      "-i", Aeno::Engine.root.join("app/assets/stylesheets/aeno/application.tailwind.css").to_s,
      "-o", Aeno::Engine.root.join("app/assets/stylesheets/aeno/tailwind.css").to_s
    ]

    puts "Building Tailwind CSS..."
    puts "Input:  #{Aeno::Engine.root.join("app/assets/stylesheets/aeno/application.tailwind.css")}"
    puts "Output: #{Aeno::Engine.root.join("app/assets/stylesheets/aeno/tailwind.css")}"
    puts "Command: #{command.join(' ')}"
    puts ""

    system(*command)

    puts ""
    puts "Build complete!"
  end

  desc "run tailwind in watch mode"
  task tailwind_engine_watch: :environment do
    require "tailwindcss-rails"

    command = [
      Tailwindcss::Commands.compile_command.first,
      "-i", Aeno::Engine.root.join("app/assets/stylesheets/aeno/application.tailwind.css").to_s,
      "-o", Aeno::Engine.root.join("app/assets/stylesheets/aeno/tailwind.css").to_s,
      "-w"
    ]

    p command
    system(*command)
  end
end
