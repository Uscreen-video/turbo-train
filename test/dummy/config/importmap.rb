# frozen_string_literal: true

# Use direct uploads for Active Storage (remember to import "@rails/activestorage" in your application.js)
# pin "@rails/activestorage", to: "activestorage.esm.js"

# Use node modules from a JavaScript CDN by running ./bin/importmap

pin '@hotwired/turbo-rails', to: 'turbo-rails.js'
pin '@rails/actioncable', to: 'actioncable.esm.js'
# pin "turbo-train", to: "https://unpkg.com/@goodsign/turbo-train@0.0.1/index.js"
pin 'turbo-train', to: 'turbo-train.js'
pin 'application'
