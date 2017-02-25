use Amnesia

defdatabase Database do
  deftable UserDatabase, [{:id, autoincrement }, :user_schema_id]
  deftable UserProfileDatabase, [{:id, autoincrement }, :user_schema_id, :name, :secretkey, :email]
  deftable FacebookProfileDatabase, [{:id, autoincrement }, :user_schema_id, :name, :facebook_id, :email, :token, :expire]
end