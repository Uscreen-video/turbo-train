# frozen_string_literal: true

say 'Creating Caddyfile'
create_file Rails.root.join('Caddyfile') do
  %(
localhost

route {
    mercure {
        publisher_jwt testing
        subscriber_jwt test
        cors_origins "*"
    }

    respond "Not Found" 404
}
  )
end
