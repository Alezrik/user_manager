defmodule CreateFacebookProfileTest do
  use ExUnit.Case

  test "process facebook profile" do
    token = "AQAmksW2zL90KMYXwsURgyWbE5WMsoRr7z4kL5--F7Oj6gNenSoX900kv3IHbdxOh28dq0GGrm6btNWw76gpge5n7S4EBrpdcxR6vG6EMVWVfsDFBuoBYdOYTZXosNYYwyoqYE_brpOkA4kEfWz65BMGy4Qeyed_Oh8ecP_GpEBzKZjLuV1rr6DI654vd35PHYNh1QtVgzWxxq0rxHJ9ywkPzUGDaUX1XlvLgiI_aMwzEslBXzYLSXWJFKKmBGGmAJHRqzb3bKX_ZYzxdq-Em3xrx5epbjt-_rAyd_cZxNmpFXFoUQpX02VrQsyaYvAYQV7B3XkIMfGf41f16sHT74Pt#_=_"
    {:ok, user} = UserManager.UserManagerApi.create_user(Faker.Name.first_name <> Faker.Name.last_name, "fdsafdsafdsa", Faker.Internet.email)
    {:facebook_create_success, client_token, expire_time, user_id} = UserManager.UserManagerApi.create_facebook_profile(user.id, token)
  end
end
