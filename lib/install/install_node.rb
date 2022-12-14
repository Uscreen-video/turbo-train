if Rails.root.join("yarn.lock").exist?
  say "Detected yarn.lock. Installing Turbo Train with yarn"
  run "yarn add @uscreentv/turbo-train"
elsif Rails.root.join("pnpm-lock.yaml").exist?
  say "Detected pnpm-lock.yaml. Installing Turbo Train with pnpm"
  run "pnpm add @uscreentv/turbo-train -w"
elsif Rails.root.join("package-lock.json").exist?
  say "Detected package-lock.json. Installing Turbo Train with npm"
  run "npm add @uscreentv/turbo-train"
else
  say "We could not automatically install the @uscreentv/turbo-train JS library", :red
  say "  -> You must manually install the @uscreentv/turbo-train JS package.", :red
end

if (js_entrypoint_path = Rails.root.join("app/javascript/application.js")).exist?
  say "Importing Turbo Train"
  append_to_file "app/javascript/application.js", %(import "@uscreentv/turbo-train"\n)
else
  say "We could not automatically detect your JS entrypoint (such as app/javascript/application.js)", :red
  say "  -> You must manually import @uscreentv/turbo-train in your JavaScript entrypoint file.", :red
end
