# desc "Explaining what the task does"
namespace :aeros do
  desc "build tailwind css once"
  task tailwind_build: :environment do
    require "tailwindcss-rails"

    command = [
      Tailwindcss::Commands.compile_command.first,
      "-i", Aeros::Engine.root.join("app/assets/stylesheets/aeros/application.tailwind.css").to_s,
      "-o", Aeros::Engine.root.join("app/assets/stylesheets/aeros/tailwind.css").to_s
    ]

    puts "Building Tailwind CSS..."
    puts "Input:  #{Aeros::Engine.root.join("app/assets/stylesheets/aeros/application.tailwind.css")}"
    puts "Output: #{Aeros::Engine.root.join("app/assets/stylesheets/aeros/tailwind.css")}"
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
      "-i", Aeros::Engine.root.join("app/assets/stylesheets/aeros/application.tailwind.css").to_s,
      "-o", Aeros::Engine.root.join("app/assets/stylesheets/aeros/tailwind.css").to_s,
      "-w"
    ]

    p command
    system(*command)
  end
end
