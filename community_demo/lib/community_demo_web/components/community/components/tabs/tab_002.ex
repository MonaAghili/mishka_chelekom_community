defmodule CommunityDemoWeb.Community.Components.Tabs.Tab002 do
  use Phoenix.Component
  import CommunityDemoWeb.Components.Tabs

  @doc type: :component
  attr(:id, :string,
    default: nil,
    doc: "A unique identifier is used to manage state and interaction"
  )

  attr(:class, :string, default: nil, doc: "")
  attr(:color, :string, default: "primary", doc: "")
  attr(:size, :string, default: "medium", doc: "")
  attr(:padding, :string, default: "large", doc: "")

  slot :tab, required: true do
    attr :icon, :string, doc: "Icon displayed alongside of an item"
    attr :class, :string, doc: "Custom CSS class for additional styling"
    attr :padding, :string, doc: "Determines padding for items"
    attr :icon_class, :string, doc: "Determines custom class for the icon"
    attr :icon_position, :string, doc: "Determines icon position"
    attr :active, :boolean, doc: "Indicates whether the element is currently active and visible"
    attr :badge, :string, doc: "Add badge to tab"
    attr :badge_color, :string, doc: "badge color"
    attr :badge_position, :string, doc: "badge position"
    attr :badge_size, :string, doc: "badge size"
    attr :badge_variant, :string, doc: "badge color varinat"
  end

  slot :panel, required: false do
    attr :class, :string, doc: "Custom CSS class for additional styling"
  end

  attr(:rest, :global,
    doc:
      "Global attributes can define defaults which are merged with attributes provided by the caller"
  )

  slot(:inner_block, required: false, doc: "Inner block that renders HEEx content")

  def community_tab_002(assigns) do
    ~H"""
    <.tabs id={@id} padding={@padding} variant="default" color={@color} size={@size} class={@class}>
      <:tab :for={{tab, _} <- Enum.with_index(@tab, 1)} icon={tab[:icon]} class={tab[:class]}>
        {render_slot(tab)}
      </:tab>

      <:panel :for={{panel, _} <- Enum.with_index(@panel, 1)} class={panel[:class]}>
        {render_slot(panel)}
      </:panel>
    </.tabs>
    """
  end
end