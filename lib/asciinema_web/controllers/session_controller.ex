defmodule AsciinemaWeb.SessionController do
  use AsciinemaWeb, :controller
  alias Asciinema.Accounts
  alias AsciinemaWeb.Auth
  alias Asciinema.Accounts.User

  def new(conn, %{"t" => login_token}) do
    conn
    |> put_session(:login_token, login_token)
    |> redirect(to: Enum.join(["/", System.get_env("RAILS_RELATIVE_URL_ROOT"), (session_path(conn, :new))],""))
  end
  def new(conn, _params) do
    render(conn, "new.html")
  end

  def create(conn, _params) do
    login_token = get_session(conn, :login_token)
    conn = delete_session(conn, :login_token)

    case Accounts.verify_login_token(login_token) do
      {:ok, user} ->
        conn
        |> Auth.log_in(user)
        |> put_rails_flash(:notice, "Welcome back!")
        |> redirect_to_profile
      {:error, :token_invalid} ->
        conn
        |> put_flash(:error, "Invalid login link.")
        |> redirect(to: Enum.join(["/", System.get_env("RAILS_RELATIVE_URL_ROOT"), (login_path(conn, :new))],""))
      {:error, :token_expired} ->
        conn
        |> put_flash(:error, "This login link has expired, sorry.")
        |> redirect(to: Enum.join(["/", System.get_env("RAILS_RELATIVE_URL_ROOT"), (login_path(conn, :new))],""))
      {:error, :user_not_found} ->
        conn
        |> put_flash(:error, "This account has been removed.")
        |> redirect(to: Enum.join(["/", System.get_env("RAILS_RELATIVE_URL_ROOT"), (login_path(conn, :new))],""))
    end
  end

  defp redirect_to_profile(conn) do
    case conn.assigns.current_user do
      %User{username: nil} ->
        redirect(conn, to: Enum.join(["/", System.get_env("RAILS_RELATIVE_URL_ROOT"), "/username/new"],""))
      %User{} = user ->
        redirect_back_or(conn, to: Enum.join(["/", System.get_env("RAILS_RELATIVE_URL_ROOT"), (profile_path(user))],""))
    end
  end
end
