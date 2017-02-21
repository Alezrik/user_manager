defmodule CreateFacebookProfileTest do
  use ExUnit.Case
  require Logger
  test "process facebook profile" do
    token = "AQAmksW2zL90KMYXwsURgyWbE5WMsoRr7z4kL5--F7Oj6gNenSoX900kv3IHbdxOh28dq0GGrm6btNWw76gpge5n7S4EBrpdcxR6vG6EMVWVfsDFBuoBYdOYTZXosNYYwyoqYE_brpOkA4kEfWz65BMGy4Qeyed_Oh8ecP_GpEBzKZjLuV1rr6DI654vd35PHYNh1QtVgzWxxq0rxHJ9ywkPzUGDaUX1XlvLgiI_aMwzEslBXzYLSXWJFKKmBGGmAJHRqzb3bKX_ZYzxdq-Em3xrx5epbjt-_rAyd_cZxNmpFXFoUQpX02VrQsyaYvAYQV7B3XkIMfGf41f16sHT74Pt#_=_"
    {:notify, response} = UserManager.UserManagerApi.create_user(Faker.Name.first_name <> Faker.Name.last_name, "fdsafdsafdsa", Faker.Internet.email)
    user = Map.fetch!(response.response_parameters, "created_object")
    Logger.debug "user: #{inspect user}"
    {:notify, response} = UserManager.UserManagerApi.create_facebook_profile(user.id, token)
    assert response.notification_type == :success
  end
end
