defmodule AsciinemaWeb.LoginController do
  use AsciinemaWeb, :controller
  alias Asciinema.Accounts

  def new(conn, _params) do
    render(conn, "new.html")
  end

  def create(conn, %{"login" => %{"email" => email_or_username}}) do
    email_or_username = String.trim(email_or_username)

    case Accounts.send_login_email(email_or_username) do
      {:ok, _url} ->
        redirect(conn, to: Enum.join(["/", System.get_env("RAILS_RELATIVE_URL_ROOT"), (login_path(conn, :sent))],""))
      {:error, :user_not_found} ->
        render(conn, "new.html", error: "No user found for given username.")
      {:error, :email_invalid} ->
        render(conn, "new.html", error: "This doesn't look like a correct email address.")
      {:error, :email_missing} ->
        redirect(conn, to: Enum.join(["/", System.get_env("RAILS_RELATIVE_URL_ROOT"), (login_path(conn, :sent))],""))
    end
  end

  def sent(conn, _params) do
    render(conn, "sent.html")
  end
end
