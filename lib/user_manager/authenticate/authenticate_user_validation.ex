defmodule UserManager.Authenticate.AuthenticateUserValidation do
  @moduledoc false
  use GenStage
  require Logger
  alias UserManager.Repo
  alias UserManager.Schemas.Permission
  import Ecto.Query
  alias Comeonin.Bcrypt
  def start_link(_) do
    GenStage.start_link(__MODULE__, [], [name: __MODULE__])
  end
  def init(_) do
    {:producer_consumer, [], subscribe_to: [UserManager.Authenticate.AuthenticateUserUserLookup]}
  end
  @doc"""
  validates user input vs encrypted db field

  iex>name = Faker.Name.first_name <> Faker.Name.last_name
  iex>email = Faker.Internet.email
  iex>{:notify, response} = UserManager.UserManagerApi.create_user(name, "secretpassword", email)
  iex>user = Map.fetch!(response.response_parameters, "created_object")
  iex>{:noreply, response, _state} = UserManager.Authenticate.AuthenticateUserValidation.handle_events([{:validate_user, user, "secretpassword", :browser, nil}], nil, [])
  iex> Enum.at(Tuple.to_list(Enum.at(response, 0)), 0)
  :authenticate_user

  iex>name = Faker.Name.first_name <> Faker.Name.last_name
  iex>email = Faker.Internet.email
  iex>{:notify, response} = UserManager.UserManagerApi.create_user(name, "secretpassword", email)
  iex>user = Map.fetch!(response.response_parameters, "created_object")
  iex>UserManager.Authenticate.AuthenticateUserValidation.handle_events([{:validate_user, user, "secretpassworda", :browser, nil}], nil, [])
  {:noreply, [], []}

"""
  def handle_events(events, _from, state) do
    process_events = events
    |> Flow.from_enumerable
    |> Flow.flat_map(fn e -> validate_login_permission(e) end)
    |> Flow.flat_map(fn e -> process_event(e) end)
    |> Enum.to_list
    {:noreply, process_events, state}
  end
  defp process_event({:validate_user, user, password, source, notify}) do
    encrypted_password = user.user_profile.authentication_metadata |> Map.fetch!("credentials") |> Map.fetch!("secretkey")
    case Bcrypt.checkpw(password, encrypted_password) do
      true -> [{:authenticate_user, user, source, notify}]
      false -> UserManager.Notifications.NotificationResponseProcessor.process_notification(:authenticate, :authenticate_failure, %{}, notify)
               []
    end
  end
  defp validate_login_permission({:validate_user, user, password, source, notify}) do
    [permission_id] = GenServer.call(UserManager.PermissionRepo, {:get_permission_id_by_group_name_permission_name, :authenticate, :credential})
    p = Permission
    |> where(id: ^permission_id)
    |> Repo.all
    |> Enum.map(fn p ->
      Repo.preload(p, :users) end)
    |> Enum.flat_map(fn p ->
      Enum.map(p.users, fn u -> u.id end) end)
    |> Enum.member?(user.id)
    case p do
      false -> UserManager.Notifications.NotificationResponseProcessor.process_notification(:authenticate, :authorization_failure, %{}, notify)
              []#{:authorization_failure, notify}
      true -> [{:validate_user, user, password, source, notify}]
    end
  end

end
