defmodule CommunityDemoWeb.Community.Components.Alerts.Alert005 do
  use Phoenix.Component
  import CommunityDemoWeb.Components.Alert

  @doc type: :component
  attr(:id, :string,
    default: nil,
    doc: "A unique identifier is used to manage state and interaction"
  )

  attr(:class, :string, default: nil, doc: "")
  attr(:title, :string, default: nil, doc: "Heading of alert")
  attr(:description, :string, default: nil, doc: "Description of alert")

  attr(:rest, :global,
    doc:
      "Global attributes can define defaults which are merged with attributes provided by the caller"
  )

  slot(:inner_block, required: false, doc: "Inner block that renders HEEx content")

  def community_alert_005(assigns) do
    ~H"""
    <.alert
      id={@id}
      variant="bg-[#DAF8E6] border-[#22AD5C]"
      border="border-s-[5px]"
      class={@class}
      icon={nil}
      rounded="large"
      padding="medium"
    >
      <div class="flex gap-5">
        <div class="size-8 shrink-0 bg-[#22AD5C] text-white rounded flex items-center justify-center">
          <svg
            xmlns="http://www.w3.org/2000/svg"
            width="24"
            height="24"
            viewBox="0 0 24 24"
            fill="none"
            stroke="currentColor"
            stroke-width="2"
            stroke-linecap="round"
            stroke-linejoin="round"
            class="size-[21px]"
          >
            <circle cx="12" cy="12" r="10" /><path d="m9 12 2 2 4-4" />
          </svg>
        </div>
        <div>
          <div :if={@title} class="text-[22px] leading-6 mb-5 text-[#004434] font-semibold">
            {@title}
          </div>
          <p :if={@description} class="text-[#637381]">
            {@description}
          </p>
          {render_slot(@inner_block)}
        </div>
      </div>
    </.alert>
    """
  end
end