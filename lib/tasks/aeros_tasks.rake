# desc "Explaining what the task does"
namespace :aeros do
  desc "run tailwind"
  task :tailwind_engine_watch do
    require "tailwindcss-rails"

    command = [
      Tailwindcss::Commands.compile_command.first,
      "-i", Aeros::Engine.root.join("app/assets/stylesheets/aeros/application.tailwind.css").to_s,
      "-o", Aeros::Engine.root.join("app/assets/stylesheets/aeros/tailwind.css").to_s,
      "-w",
      "--content", [
        Aeros::Engine.root.join("app/components/**/*.rb").to_s,
        Aeros::Engine.root.join("app/components/**/*.erb").to_s
      ].join(",")
    ]

    p command
    system(*command)
  end
end
