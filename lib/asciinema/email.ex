defmodule Asciinema.Email do
  use Bamboo.Phoenix, view: AsciinemaWeb.EmailView
  import Bamboo.Email

  def signup_email(email_address, signup_url) do
    base_email()
    |> to(email_address)
    |> subject("Welcome to #{instance_hostname()}")
    |> render("signup.text", signup_url: signup_url)
    |> render("signup.html", signup_url: signup_url)
  end

  def login_email(email_address, login_url) do
    base_email()
    |> to(email_address)
    |> subject("Login request")
    |> render("login.text", login_url: login_url)
    |> render("login.html", login_url: login_url)
  end

  defp base_email do
    new_email()
    |> from({"asciinema", from_address()})
    |> put_header("Reply-To", reply_to_address())
    |> put_html_layout({AsciinemaWeb.LayoutView, "email.html"})
  end

  defp from_address do
    System.get_env("SMTP_FROM_ADDRESS") || "hello@#{instance_hostname()}"
  end

  defp reply_to_address do
    System.get_env("SMTP_REPLY_TO_ADDRESS") || "support@asciinema.org"
  end

  defp instance_hostname do
    System.get_env("URL_HOST") || "asciinema.org"
  end
end
