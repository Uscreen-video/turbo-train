say "Import Turbo"
append_to_file "app/javascript/application.js", %(import "@goodsign/turbo-train"\n)

say "Pin Turbo"
append_to_file "config/importmap.rb", %(pin "@goodsign/turbo-train", to: "turbo.min.js", preload: true\n)
