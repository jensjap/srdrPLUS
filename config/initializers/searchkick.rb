if defined?(Searchkick)
  Searchkick.client_options = {
    transport_options: {
      ssl: {
        ca_file: "/app/certs/ca/ca.crt"
      }
    }
  }
end
