defmodule UserManager.Struct.NotificationResponse do
  @moduledoc false
  defstruct notification_id: -1,
            workflow: :authenticate,
            notification_type: :user_not_found_error,
            session_reference_metadata: %{},
            response_parameters: %{}
end
