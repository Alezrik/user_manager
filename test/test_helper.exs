ExUnit.configure exclude: [:profile]
ExUnit.start()

defmodule FakeFacebookProxy do
  def get_access_key_from_code(code) do
    {"{\"access_token\":\"EAASYcMvboacBAAbqxyYwydOtWxJfdsafasfopTU8ENgOfsdgrb7hHTjGqpAPXD4xNqIuifdsfasfaAtwZBfrmwmC7ZBUPWfdsas8KYGP88gZDZD\",\"token_type\":\"bearer\",\"expires_in\":5174680}", 200}
  end
  def get_server_token_from_access_key(token) do
    {"{\"access_token\":\"fdsfsafsafasfsafasfsafsafsafasfsfsafasfsadfsdaffsadfsdafsadfgfdsghfdhfdhfdhfjfghjgfsdgfdfgs\",\"token_type\":\"bearer\",\"expires_in\":5181277}", 200}
  end
  def get_me("id,email,name", token) do
    %{"email" => "ex_ra@hotmail.com", "id" => "14421562342111116660943", "name" => "Stephen Daubert"}
  end
end
