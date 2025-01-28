defmodule CommunityDemoWeb.Demo.Community.ToastLive do
  use CommunityDemoWeb, :live_view

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(page_title: "Community - Toast")

    {:ok, socket}
  end
end