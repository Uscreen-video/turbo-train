say "Import Turbo"
append_to_file "app/javascript/application.js", %(import "@uscreentv/turbo-train"\n)

say "Pin Turbo"
append_to_file "config/importmap.rb", %(pin "@uscreentv/turbo-train", to: "turbo-train.min.js", preload: true\n)
