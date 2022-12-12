if (js_entrypoint_path = Rails.root.join("app/javascript/application.js")).exist?
  say "Importing Turbo Train"
  append_to_file "app/javascript/application.js", %(import "@uscreentv/turbo-train"\n)
else
  say "You must import @uscreentv/turbo-train in your JavaScript entrypoint file", :red
end

say "Installing Turbo Train"
run "yarn add @uscreentv/turbo-train"
