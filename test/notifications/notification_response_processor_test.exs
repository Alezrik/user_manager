defmodule NotificationResponseProcessorTest do
  use ExUnit.Case
  require Logger
  test "process a notification" do
    {:ok, sub_pid} = Task.start_link(fn ->
        receive do
          msg -> msg
        end
      end)
      {:ok, _} = UserManager.Notifications.NotificationRequestInitiator.register_static_notification(:create_user, :test, sub_pid)
      n = %UserManager.Struct.Notification{destination_pid: self()}
      :ok = UserManager.Notifications.NotificationResponseProcessor.process_notification(:create_user, :test, %{"test" => "test123"}, n)
      Process.sleep(100)
      assert_receive({:notify, notification}, 1_000)
      assert Process.alive?(sub_pid) == false
  end
end
