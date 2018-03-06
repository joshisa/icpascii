use Mix.Config

config :asciinema, Asciinema.Mailer,
  adapter: Bamboo.SMTPAdapter,
  server: "smtp.gmail.com",
  port: 587,
  username: System.get_env("GMAIL_USERNAME"),
  password: System.get_env("GMAIL_PASSWORD"),
  tls: :if_available, # can be `:always` or `:never`
  allowed_tls_versions: [:"tlsv1", :"tlsv1.1", :"tlsv1.2"], 
  ssl: false, # can be `true`
  retries: 1
