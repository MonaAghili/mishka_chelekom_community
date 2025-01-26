defmodule CommunityDemoWeb.Components.NumberField do
  @moduledoc """
  The `CommunityDemoWeb.Components.NumberField` module provides a versatile and customizable
  number input component for Phoenix LiveView applications. This component offers
  extensive options for theming, styling, and layout configurations, including border styles,
  color variants, rounded corners, and size settings.

  With support for custom slots and icon placements, it allows for enhanced user
  interactions and detailed input structures. The module also includes advanced features
  like floating labels, control visibility options, and error handling, making it an ideal
  solution for creating dynamic and user-friendly forms in web applications.
  """

  use Phoenix.Component

  @doc """
  Renders a customizable `number_input` field with various options such as labels, descriptions,
  and error messages.
  It supports different sizes, colors, and styles, and can include additional sections and icons.

  ## Examples

  ```elixir
  <.number_field
    name="name"
    value=""
    space="small"
    color="danger"
    controls="hide"
    description="This is description"
    label="This is outline label Number"
    placeholder="This is Number placeholder"
    floating="outer"
  />

  <.number_field
    name="name"
    value="The value of input"
    space="small"
    label="This is label Number"
    placeholder="This is Number placeholder"
    errors={["Enter name"]}
  >
    <:end_section>
      <button><.icon name="hero-clipboard-document" class="size-6" /></button>
    </:end_section>
  </.number_field>
  ```
  """
  @doc type: :component
  attr :id, :string,
    default: nil,
    doc: "A unique identifier is used to manage state and interaction"

  attr :class, :string, default: nil, doc: "Custom CSS class for additional styling"
  attr :color, :string, default: "base", doc: "Determines color theme"
  attr :border, :string, default: "extra_small", doc: "Determines border style"
  attr :rounded, :string, default: "small", doc: "Determines the border radius"
  attr :variant, :string, default: "base", doc: "Determines the style"
  attr :description, :string, default: nil, doc: "Determines a short description"
  attr :space, :string, default: "medium", doc: "Space between items"

  attr :size, :string,
    default: "extra_large",
    doc:
      "Determines the overall size of the elements, including padding, font size, and other items"

  attr :ring, :boolean,
    default: true,
    doc:
      "Determines a ring border on focused input, utilities for creating outline rings with box-shadows."

  attr :controls, :string, default: "default", doc: "fixed, hide, default"
  attr :floating, :string, default: "none", doc: "none, inner, outer"
  attr :error_icon, :string, default: nil, doc: "Icon to be displayed alongside error messages"
  attr :label, :string, default: nil, doc: "Specifies text for the label"

  slot :start_section, required: false, doc: "Renders heex content in start of an element" do
    attr :class, :string, doc: "Custom CSS class for additional styling"
    attr :icon, :string, doc: "Icon displayed alongside of an item"
  end

  slot :end_section, required: false, doc: "Renders heex content in end of an element" do
    attr :class, :string, doc: "Custom CSS class for additional styling"
    attr :icon, :string, doc: "Icon displayed alongside of an item"
  end

  attr :errors, :list, default: [], doc: "List of error messages to be displayed"
  attr :name, :any, doc: "Name of input"
  attr :value, :any, doc: "Value of input"

  attr :field, Phoenix.HTML.FormField, doc: "a form field struct retrieved from the form"

  attr :rest, :global,
    include: ~w(autocomplete disabled form list min max pattern placeholder
        readonly required size inputmode inputmode step title autofocus),
    doc:
      "Global attributes can define defaults which are merged with attributes provided by the caller"

  @spec number_field(map()) :: Phoenix.LiveView.Rendered.t()
  def number_field(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    errors = if Phoenix.Component.used_input?(field), do: field.errors, else: []

    assigns
    |> assign(field: nil, id: assigns.id || field.id)
    |> assign(:errors, Enum.map(errors, &translate_error(&1)))
    |> assign_new(:name, fn -> field.name end)
    |> assign_new(:value, fn -> field.value end)
    |> number_field()
  end

  def number_field(%{floating: floating} = assigns) when floating in ["inner", "outer"] do
    ~H"""
    <div class={[
      color_variant(@variant, @color, @floating),
      rounded_size(@rounded),
      border_class(@border, @variant),
      size_class(@size),
      space_class(@space),
      @ring && "[&_.number-field-wrapper]:focus-within:ring-[0.03rem]",
      @class
    ]}>
      <div :if={!is_nil(@description)} class="text-xs pb-2">
        {@description}
      </div>
      <div class={[
        "number-field-wrapper transition-all ease-in-out duration-200 w-full flex flex-nowrap",
        @errors != [] && "number-field-error"
      ]}>
        <div
          :if={@start_section}
          class={[
            "flex items-center justify-center shrink-0 ps-2",
            @start_section[:class]
          ]}
        >
          {render_slot(@start_section)}
        </div>
        <div class="relative w-full z-[2]">
          <input
            type="number"
            name={@name}
            id={@id}
            value={@value}
            class={[
              "disabled:opacity-80 block w-full z-[2] focus:ring-0 placeholder:text-transparent pb-1 pt-2.5 px-2",
              "text-[16px] sm:font-inherit appearance-none bg-transparent border-0 focus:outline-none peer",
              @controls == "fixed" &&
                "[&::-webkit-outer-spin-button]:opacity-100 [&::-webkit-inner-spin-button]:opacity-100",
              @controls == "hide" &&
                "[appearance:textfield] [&::-webkit-outer-spin-button]:appearance-none [&::-webkit-inner-spin-button]:appearance-none"
            ]}
            placeholder=" "
            {@rest}
          />

          <label
            class={[
              "floating-label px-1 start-1 -z-[1] absolute text-xs duration-300 transform scale-75 origin-[0]",
              variant_label_position(@floating)
            ]}
            for={@id}
          >
            {@label}
          </label>
        </div>

        <div
          :if={@end_section}
          class={["flex items-center justify-center shrink-0 pe-2", @end_section[:class]]}
        >
          {render_slot(@end_section)}
        </div>
      </div>

      <.error :for={msg <- @errors} icon={@error_icon}>{msg}</.error>
    </div>
    """
  end

  def number_field(assigns) do
    ~H"""
    <div class={[
      color_variant(@variant, @color, @floating),
      rounded_size(@rounded),
      border_class(@border, @variant),
      size_class(@size),
      space_class(@space),
      @ring && "[&_.number-field-wrapper]:focus-within:ring-[0.03rem]",
      @class
    ]}>
      <div>
        <.label for={@id}>{@label}</.label>
        <div :if={!is_nil(@description)} class="text-xs">
          {@description}
        </div>
      </div>

      <div class={[
        "number-field-wrapper overflow-hidden transition-all ease-in-out duration-200 flex items-center flex-nowrap",
        @errors != [] && "number-field-error"
      ]}>
        <div
          :if={@start_section}
          class={[
            "flex items-center justify-center shrink-0 ps-2",
            @start_section[:class]
          ]}
        >
          {render_slot(@start_section)}
        </div>

        <input
          type="number"
          name={@name}
          id={@id}
          value={@value}
          class={[
            "flex-1 py-1 px-2 text-sm disabled:opacity-80 block w-full appearance-none",
            "bg-transparent border-0 focus:outline-none focus:ring-0",
            @controls == "fixed" &&
              "[&::-webkit-outer-spin-button]:opacity-100 [&::-webkit-inner-spin-button]:opacity-100",
            @controls == "hide" &&
              "[appearance:textfield] [&::-webkit-outer-spin-button]:appearance-none [&::-webkit-inner-spin-button]:appearance-none"
          ]}
          {@rest}
        />

        <div
          :if={@end_section}
          class={["flex items-center justify-center shrink-0 pe-2", @end_section[:class]]}
        >
          {render_slot(@end_section)}
        </div>
      </div>

      <.error :for={msg <- @errors} icon={@error_icon}>{msg}</.error>
    </div>
    """
  end

  @doc type: :component
  attr :for, :string, default: nil, doc: "Specifies the form which is associated with"
  attr :class, :string, default: nil, doc: "Custom CSS class for additional styling"
  slot :inner_block, required: true, doc: "Inner block that renders HEEx content"

  defp label(assigns) do
    ~H"""
    <label for={@for} class={["block text-sm font-semibold leading-6", @class]}>
      {render_slot(@inner_block)}
    </label>
    """
  end

  @doc type: :component
  attr :icon, :string, default: nil, doc: "Icon displayed alongside of an item"
  slot :inner_block, required: true, doc: "Inner block that renders HEEx content"

  defp error(assigns) do
    ~H"""
    <p class="mt-3 flex items-center gap-3 text-sm leading-6 text-rose-700">
      <.icon :if={!is_nil(@icon)} name={@icon} class="shrink-0" />
      {render_slot(@inner_block)}
    </p>
    """
  end

  defp variant_label_position("outer") do
    [
      "-translate-y-4 top-2 origin-[0] peer-focus:px-1 peer-placeholder-shown:scale-100",
      "peer-placeholder-shown:-translate-y-1/2 peer-placeholder-shown:top-1/2 peer-focus:top-2 peer-focus:scale-75 peer-focus:-translate-y-4",
      "rtl:peer-focus:translate-x-1/4 rtl:peer-focus:left-auto"
    ]
  end

  defp variant_label_position("inner") do
    [
      "-translate-y-4 scale-75 top-4 origin-[0] peer-placeholder-shown:scale-100 peer-placeholder-shown:translate-y-0",
      "peer-focus:scale-75 peer-focus:-translate-y-4 rtl:peer-focus:translate-x-1/4 rtl:peer-focus:left-auto"
    ]
  end

  defp size_class("extra_small"),
    do:
      "[&_.number-field-wrapper_input]:h-7 [&_.number-field-wrapper_.password-field-icon]:size-3"

  defp size_class("small"),
    do:
      "[&_.number-field-wrapper_input]:h-8 [&_.number-field-wrapper_.password-field-icon]:size-3.5"

  defp size_class("medium"),
    do:
      "[&_.number-field-wrapper_input]:h-9 [&_.number-field-wrapper_.password-field-icon]:size-4"

  defp size_class("large"),
    do:
      "[&_.number-field-wrapper_input]:h-10 [&_.number-field-wrapper_.password-field-icon]:size-5"

  defp size_class("extra_large"),
    do:
      "[&_.number-field-wrapper_input]:h-11 [&_.number-field-wrapper_.password-field-icon]:size-6"

  defp size_class(params) when is_binary(params), do: params

  defp rounded_size("extra_small"), do: "[&_.number-field-wrapper]:rounded-sm"

  defp rounded_size("small"), do: "[&_.number-field-wrapper]:rounded"

  defp rounded_size("medium"), do: "[&_.number-field-wrapper]:rounded-md"

  defp rounded_size("large"), do: "[&_.number-field-wrapper]:rounded-lg"

  defp rounded_size("extra_large"), do: "[&_.number-field-wrapper]:rounded-xl"

  defp rounded_size("full"), do: "[&_.number-field-wrapper]:rounded-full"

  defp rounded_size("none"), do: nil

  defp rounded_size(params) when is_binary(params), do: params

  defp border_class(_, variant) when variant in ["default", "shadow", "transparent"],
    do: nil

  defp border_class("none", _), do: "[&_.number-field-wrapper]:border-0"
  defp border_class("extra_small", _), do: "[&_.number-field-wrapper]:border"
  defp border_class("small", _), do: "[&_.number-field-wrapper]:border-2"
  defp border_class("medium", _), do: "[&_.number-field-wrapper]:border-[3px]"
  defp border_class("large", _), do: "[&_.number-field-wrapper]:border-4"
  defp border_class("extra_large", _), do: "[&_.number-field-wrapper]:border-[5px]"
  defp border_class(params, _) when is_binary(params), do: params

  defp space_class("none"), do: nil

  defp space_class("extra_small"), do: "space-y-1"

  defp space_class("small"), do: "space-y-1.5"

  defp space_class("medium"), do: "space-y-2"

  defp space_class("large"), do: "space-y-2.5"

  defp space_class("extra_large"), do: "space-y-3"

  defp space_class(params) when is_binary(params), do: params

  defp color_variant("base", "base", floating) do
    [
      "[&_.number-field-wrapper:not(:has(.number-field-error))]:bg-white",
      "dark:[&_.number-field-wrapper:not(:has(.number-field-error))]:bg-[#18181B]",
      "text-[#09090b] dark:text-[#FAFAFA] [&_.number-field-wrapper:not(:has(.number-field-error))]:border-[#e4e4e7]",
      "dark:[&_.number-field-wrapper:not(:has(.number-field-error))]:border-[#27272a]",
      "[&_.number-field-wrapper.number-field-error]:border-rose-700",
      "[&_.number-field-wrapper>input]:placeholder:text-[#09090b] dark:[&_.number-field-wrapper>input]:placeholder:text-[#FAFAFA]",
      "focus-within:[&_.number-field-wrapper]:ring-[#e4e4e7] dark:focus-within:[&_.number-field-wrapper]:ring-[#e4e4e7]",
      "[&_.number-field-wrapper]:shadow-sm",
      floating == "outer" &&
        "[&_.number-field-wrapper_.floating-label]:bg-white dark:[&_.number-field-wrapper_.floating-label]:bg-[#27272a]"
    ]
  end

  defp color_variant("outline", "natural", floating) do
    [
      "text-[#4B4B4B] dark:text-[#DDDDDD] [&_.number-field-wrapper:not(:has(.text-field-error))]:border-[#4B4B4B]",
      "dark:[&_.number-field-wrapper:not(:has(.text-field-error))]:border-[#DDDDDD]",
      "[&_.number-field-wrapper.text-field-error]:border-rose-700",
      "[&_.number-field-wrapper>input]:placeholder:text-[#4B4B4B] dark:[&_.number-field-wrapper>input]:placeholder:text-[#DDDDDD]",
      "focus-within:[&_.number-field-wrapper]:ring-white",
      floating == "outer" &&
        "[&_.number-field-wrapper_.floating-label]:bg-white dark:[&_.number-field-wrapper_.floating-label]:bg-[#282828]"
    ]
  end

  defp color_variant("outline", "primary", floating) do
    [
      "text-[#007F8C] dark:text-[#01B8CA] [&_.number-field-wrapper:not(:has(.text-field-error))]:border-[#007F8C]",
      "dark:[&_.number-field-wrapper:not(:has(.text-field-error))]:border-[#01B8CA]",
      "[&_.number-field-wrapper.text-field-error]:border-rose-700",
      "[&_.number-field-wrapper>input]:placeholder:text-[#007F8C] dark:[&_.number-field-wrapper>input]:placeholder:text-[#01B8CA]",
      "focus-within:[&_.number-field-wrapper]:ring-white",
      floating == "outer" &&
        "[&_.number-field-wrapper_.floating-label]:bg-white dark:[&_.number-field-wrapper_.floating-label]:bg-[#282828]"
    ]
  end

  defp color_variant("outline", "secondary", floating) do
    [
      "text-[#266EF1] dark:text-[#6DAAFB] [&_.number-field-wrapper:not(:has(.text-field-error))]:border-[#266EF1]",
      "dark:[&_.number-field-wrapper:not(:has(.text-field-error))]:border-[#6DAAFB]",
      "[&_.number-field-wrapper.text-field-error]:border-rose-700",
      "[&_.number-field-wrapper>input]:placeholder:text-[#266EF1] dark:[&_.number-field-wrapper>input]:placeholder:text-[#6DAAFB]",
      "focus-within:[&_.number-field-wrapper]:ring-white",
      floating == "outer" &&
        "[&_.number-field-wrapper_.floating-label]:bg-white dark:[&_.number-field-wrapper_.floating-label]:bg-[#282828]"
    ]
  end

  defp color_variant("outline", "success", floating) do
    [
      "text-[#0E8345] dark:text-[#06C167] [&_.number-field-wrapper:not(:has(.text-field-error))]:border-[#0E8345]",
      "dark:[&_.number-field-wrapper:not(:has(.text-field-error))]:border-[#06C167]",
      "[&_.number-field-wrapper.text-field-error]:border-rose-700",
      "[&_.number-field-wrapper>input]:placeholder:text-[#0E8345] dark:[&_.number-field-wrapper>input]:placeholder:text-[#06C167]",
      "focus-within:[&_.number-field-wrapper]:ring-white",
      floating == "outer" &&
        "[&_.number-field-wrapper_.floating-label]:bg-white dark:[&_.number-field-wrapper_.floating-label]:bg-[#282828]"
    ]
  end

  defp color_variant("outline", "warning", floating) do
    [
      "text-[#CA8D01] dark:text-[#FDC034] [&_.number-field-wrapper:not(:has(.text-field-error))]:border-[#CA8D01]",
      "dark:[&_.number-field-wrapper:not(:has(.text-field-error))]:border-[#FDC034]",
      "[&_.number-field-wrapper.text-field-error]:border-rose-700",
      "[&_.number-field-wrapper>input]:placeholder:text-[#CA8D01] dark:[&_.number-field-wrapper>input]:placeholder:text-[#FDC034]",
      "focus-within:[&_.number-field-wrapper]:ring-white",
      floating == "outer" &&
        "[&_.number-field-wrapper_.floating-label]:bg-white dark:[&_.number-field-wrapper_.floating-label]:bg-[#282828]"
    ]
  end

  defp color_variant("outline", "danger", floating) do
    [
      "text-[#CA8D01] dark:text-[#FC7F79] [&_.number-field-wrapper:not(:has(.text-field-error))]:border-[#CA8D01]",
      "dark:[&_.number-field-wrapper:not(:has(.text-field-error))]:border-[#FC7F79]",
      "[&_.number-field-wrapper.text-field-error]:border-rose-700",
      "[&_.number-field-wrapper>input]:placeholder:text-[#CA8D01] dark:[&_.number-field-wrapper>input]:placeholder:text-[#FC7F79]",
      "focus-within:[&_.number-field-wrapper]:ring-white",
      floating == "outer" &&
        "[&_.number-field-wrapper_.floating-label]:bg-white dark:[&_.number-field-wrapper_.floating-label]:bg-[#282828]"
    ]
  end

  defp color_variant("outline", "info", floating) do
    [
      "text-[#0B84BA] dark:text-[#3EB7ED] [&_.number-field-wrapper:not(:has(.text-field-error))]:border-[#0B84BA]",
      "dark:[&_.number-field-wrapper:not(:has(.text-field-error))]:border-[#3EB7ED]",
      "[&_.number-field-wrapper.text-field-error]:border-rose-700",
      "[&_.number-field-wrapper>input]:placeholder:text-[#0B84BA] dark:[&_.number-field-wrapper>input]:placeholder:text-[#3EB7ED]",
      "focus-within:[&_.number-field-wrapper]:ring-white",
      floating == "outer" &&
        "[&_.number-field-wrapper_.floating-label]:bg-white dark:[&_.number-field-wrapper_.floating-label]:bg-[#282828]"
    ]
  end

  defp color_variant("outline", "misc", floating) do
    [
      "text-[#8750C5] dark:text-[#BA83F9] [&_.number-field-wrapper:not(:has(.text-field-error))]:border-[#8750C5]",
      "dark:[&_.number-field-wrapper:not(:has(.text-field-error))]:border-[#BA83F9]",
      "[&_.number-field-wrapper.text-field-error]:border-rose-700",
      "[&_.number-field-wrapper>input]:placeholder:text-[#8750C5] dark:[&_.number-field-wrapper>input]:placeholder:text-[#BA83F9]",
      "focus-within:[&_.number-field-wrapper]:ring-white",
      floating == "outer" &&
        "[&_.number-field-wrapper_.floating-label]:bg-white dark:[&_.number-field-wrapper_.floating-label]:bg-[#282828]"
    ]
  end

  defp color_variant("outline", "dawn", floating) do
    [
      "text-[#A86438] dark:text-[#DB976B] [&_.number-field-wrapper:not(:has(.text-field-error))]:border-[#A86438]",
      "dark:[&_.number-field-wrapper:not(:has(.text-field-error))]:border-[#DB976B]",
      "[&_.number-field-wrapper.text-field-error]:border-rose-700",
      "[&_.number-field-wrapper>input]:placeholder:text-[#A86438] dark:[&_.number-field-wrapper>input]:placeholder:text-[#DB976B]",
      "focus-within:[&_.number-field-wrapper]:ring-white",
      floating == "outer" &&
        "[&_.number-field-wrapper_.floating-label]:bg-white dark:[&_.number-field-wrapper_.floating-label]:bg-[#282828]"
    ]
  end

  defp color_variant("outline", "silver", floating) do
    [
      "text-[#868686] dark:text-[#A6A6A6] [&_.number-field-wrapper:not(:has(.text-field-error))]:border-[#868686]",
      "dark:[&_.number-field-wrapper:not(:has(.text-field-error))]:border-[#A6A6A6]",
      "[&_.number-field-wrapper.text-field-error]:border-rose-700",
      "[&_.number-field-wrapper>input]:placeholder:text-[#868686] dark:[&_.number-field-wrapper>input]:placeholder:text-[#A6A6A6]",
      "focus-within:[&_.number-field-wrapper]:ring-white",
      floating == "outer" &&
        "[&_.number-field-wrapper_.floating-label]:bg-white dark:[&_.number-field-wrapper_.floating-label]:bg-[#282828]"
    ]
  end

  defp color_variant("default", "white", floating) do
    [
      "[&_.number-field-wrapper]:bg-white text-[#3E3E3E]",
      "[&_.number-field-wrapper.text-field-error]:border-rose-700",
      "[&_.number-field-wrapper>input]:placeholder:text-[#3E3E3E] focus-within:[&_.number-field-wrapper]:ring-[#DADADA]",
      floating == "outer" && "[&_.number-field-wrapper_.floating-label]:bg-white"
    ]
  end

  defp color_variant("default", "natural", floating) do
    [
      "text-black dark:text-white [&_.number-field-wrapper:not(:has(.text-field-error))]:bg-[#4B4B4B]",
      "dark:[&_.number-field-wrapper:not(:has(.text-field-error))]:bg-[#DDDDDD]",
      "[&_.number-field-wrapper.text-field-error]:bg-rose-700",
      "[&_.number-field-wrapper>input]:placeholder:text-white dark:[&_.number-field-wrapper>input]:placeholder:text-black",
      "[&_.number-field-wrapper>input]:text-white dark:[&_.number-field-wrapper>input]:text-black",
      "focus-within:[&_.number-field-wrapper]:ring-[#4B4B4B] dark:focus-within:[&_.number-field-wrapper]:ring-[#DDDDDD]",
      floating == "outer" &&
        "[&_.number-field-wrapper_.floating-label]:bg-[#4B4B4B] dark:[&_.number-field-wrapper_.floating-label]:bg-[#DDDDDD]"
    ]
  end

  defp color_variant("default", "primary", floating) do
    [
      "text-black dark:text-white [&_.number-field-wrapper:not(:has(.text-field-error))]:bg-[#007F8C]",
      "dark:[&_.number-field-wrapper:not(:has(.text-field-error))]:bg-[#01B8CA]",
      "[&_.number-field-wrapper.text-field-error]:bg-rose-700",
      "[&_.number-field-wrapper>input]:placeholder:text-white dark:[&_.number-field-wrapper>input]:placeholder:text-black",
      "[&_.number-field-wrapper>input]:text-white dark:[&_.number-field-wrapper>input]:text-black",
      "focus-within:[&_.number-field-wrapper]:ring-[#007F8C] dark:focus-within:[&_.number-field-wrapper]:ring-[#01B8CA]",
      floating == "outer" &&
        "[&_.number-field-wrapper_.floating-label]:bg-[#007F8C] dark:[&_.number-field-wrapper_.floating-label]:bg-[#01B8CA]"
    ]
  end

  defp color_variant("default", "secondary", floating) do
    [
      "text-black dark:text-white [&_.number-field-wrapper:not(:has(.text-field-error))]:bg-[#266EF1]",
      "dark:[&_.number-field-wrapper:not(:has(.text-field-error))]:bg-[#6DAAFB]",
      "[&_.number-field-wrapper.text-field-error]:bg-rose-700",
      "[&_.number-field-wrapper>input]:placeholder:text-white dark:[&_.number-field-wrapper>input]:placeholder:text-black",
      "[&_.number-field-wrapper>input]:text-white dark:[&_.number-field-wrapper>input]:text-black",
      "focus-within:[&_.number-field-wrapper]:ring-[#266EF1] dark:focus-within:[&_.number-field-wrapper]:ring-[#6DAAFB]",
      floating == "outer" &&
        "[&_.number-field-wrapper_.floating-label]:bg-[#266EF1] dark:[&_.number-field-wrapper_.floating-label]:bg-[#6DAAFB]"
    ]
  end

  defp color_variant("default", "success", floating) do
    [
      "text-black dark:text-white [&_.number-field-wrapper:not(:has(.text-field-error))]:bg-[#0E8345]",
      "dark:[&_.number-field-wrapper:not(:has(.text-field-error))]:bg-[#06C167]",
      "[&_.number-field-wrapper.text-field-error]:bg-rose-700",
      "[&_.number-field-wrapper>input]:placeholder:text-white dark:[&_.number-field-wrapper>input]:placeholder:text-black",
      "[&_.number-field-wrapper>input]:text-white dark:[&_.number-field-wrapper>input]:text-black",
      "focus-within:[&_.number-field-wrapper]:ring-[#0E8345] dark:focus-within:[&_.number-field-wrapper]:ring-[#06C167]",
      floating == "outer" &&
        "[&_.number-field-wrapper_.floating-label]:bg-[#0E8345] dark:[&_.number-field-wrapper_.floating-label]:bg-[#06C167]"
    ]
  end

  defp color_variant("default", "warning", floating) do
    [
      "text-black dark:text-white [&_.number-field-wrapper:not(:has(.text-field-error))]:bg-[#CA8D01]",
      "dark:[&_.number-field-wrapper:not(:has(.text-field-error))]:bg-[#FDC034]",
      "[&_.number-field-wrapper.text-field-error]:bg-rose-700",
      "[&_.number-field-wrapper>input]:placeholder:text-white dark:[&_.number-field-wrapper>input]:placeholder:text-black",
      "[&_.number-field-wrapper>input]:text-white dark:[&_.number-field-wrapper>input]:text-black",
      "focus-within:[&_.number-field-wrapper]:ring-[#CA8D01] dark:focus-within:[&_.number-field-wrapper]:ring-[#FDC034]",
      floating == "outer" &&
        "[&_.number-field-wrapper_.floating-label]:bg-[#CA8D01] dark:[&_.number-field-wrapper_.floating-label]:bg-[#FDC034]"
    ]
  end

  defp color_variant("default", "danger", floating) do
    [
      "text-black dark:text-white [&_.number-field-wrapper:not(:has(.text-field-error))]:bg-[#DE1135]",
      "dark:[&_.number-field-wrapper:not(:has(.text-field-error))]:bg-[#FC7F79]",
      "[&_.number-field-wrapper.text-field-error]:bg-rose-700",
      "[&_.number-field-wrapper>input]:placeholder:text-white dark:[&_.number-field-wrapper>input]:placeholder:text-black",
      "[&_.number-field-wrapper>input]:text-white dark:[&_.number-field-wrapper>input]:text-black",
      "focus-within:[&_.number-field-wrapper]:ring-[#DE1135] dark:focus-within:[&_.number-field-wrapper]:ring-[#FC7F79]",
      floating == "outer" &&
        "[&_.number-field-wrapper_.floating-label]:bg-[#DE1135] dark:[&_.number-field-wrapper_.floating-label]:bg-[#FC7F79]"
    ]
  end

  defp color_variant("default", "info", floating) do
    [
      "text-black dark:text-white [&_.number-field-wrapper:not(:has(.text-field-error))]:bg-[#0B84BA]",
      "dark:[&_.number-field-wrapper:not(:has(.text-field-error))]:bg-[#3EB7ED]",
      "[&_.number-field-wrapper.text-field-error]:bg-rose-700",
      "[&_.number-field-wrapper>input]:placeholder:text-white dark:[&_.number-field-wrapper>input]:placeholder:text-black",
      "[&_.number-field-wrapper>input]:text-white dark:[&_.number-field-wrapper>input]:text-black",
      "focus-within:[&_.number-field-wrapper]:ring-[#0B84BA] dark:focus-within:[&_.number-field-wrapper]:ring-[#3EB7ED]",
      floating == "outer" &&
        "[&_.number-field-wrapper_.floating-label]:bg-[#0B84BA] dark:[&_.number-field-wrapper_.floating-label]:bg-[#3EB7ED]"
    ]
  end

  defp color_variant("default", "misc", floating) do
    [
      "text-black dark:text-white [&_.number-field-wrapper:not(:has(.text-field-error))]:bg-[#8750C5]",
      "dark:[&_.number-field-wrapper:not(:has(.text-field-error))]:bg-[#BA83F9]",
      "[&_.number-field-wrapper.text-field-error]:bg-rose-700",
      "[&_.number-field-wrapper>input]:placeholder:text-white dark:[&_.number-field-wrapper>input]:placeholder:text-black",
      "[&_.number-field-wrapper>input]:text-white dark:[&_.number-field-wrapper>input]:text-black",
      "focus-within:[&_.number-field-wrapper]:ring-[#8750C5] dark:focus-within:[&_.number-field-wrapper]:ring-[#BA83F9]",
      floating == "outer" &&
        "[&_.number-field-wrapper_.floating-label]:bg-[#8750C5] dark:[&_.number-field-wrapper_.floating-label]:bg-[#BA83F9]"
    ]
  end

  defp color_variant("default", "dawn", floating) do
    [
      "text-black dark:text-white [&_.number-field-wrapper:not(:has(.text-field-error))]:bg-[#A86438]",
      "dark:[&_.number-field-wrapper:not(:has(.text-field-error))]:bg-[#DB976B]",
      "[&_.number-field-wrapper.text-field-error]:bg-rose-700",
      "[&_.number-field-wrapper>input]:placeholder:text-white dark:[&_.number-field-wrapper>input]:placeholder:text-black",
      "[&_.number-field-wrapper>input]:text-white dark:[&_.number-field-wrapper>input]:text-black",
      "focus-within:[&_.number-field-wrapper]:ring-[#A86438] dark:focus-within:[&_.number-field-wrapper]:ring-[#DB976B]",
      floating == "outer" &&
        "[&_.number-field-wrapper_.floating-label]:bg-[#A86438] dark:[&_.number-field-wrapper_.floating-label]:bg-[#DB976B]"
    ]
  end

  defp color_variant("default", "silver", floating) do
    [
      "text-black dark:text-white [&_.number-field-wrapper:not(:has(.text-field-error))]:bg-[#868686]",
      "dark:[&_.number-field-wrapper:not(:has(.text-field-error))]:bg-[#A6A6A6]",
      "[&_.number-field-wrapper.text-field-error]:bg-rose-700",
      "[&_.number-field-wrapper>input]:placeholder:text-white dark:[&_.number-field-wrapper>input]:placeholder:text-black",
      "[&_.number-field-wrapper>input]:text-white dark:[&_.number-field-wrapper>input]:text-black",
      "focus-within:[&_.number-field-wrapper]:ring-[#868686] dark:focus-within:[&_.number-field-wrapper]:ring-[#A6A6A6]",
      floating == "outer" &&
        "[&_.number-field-wrapper_.floating-label]:bg-[#868686] dark:[&_.number-field-wrapper_.floating-label]:bg-[#A6A6A6]"
    ]
  end

  defp color_variant("default", "dark", floating) do
    [
      "[&_.number-field-wrapper]:bg-[#1E1E1E] text-[#1E1E1E] [&_.number-field-wrapper]:text-white",
      "[&_.number-field-wrapper.text-field-error]:border-rose-700",
      "[&_.number-field-wrapper>input]:placeholder:text-white focus-within:[&_.number-field-wrapper]:ring-[#050404]",
      floating == "outer" && "[&_.number-field-wrapper_.floating-label]:bg-[#1E1E1E]"
    ]
  end

  defp color_variant("bordered", "white", floating) do
    [
      "[&_.number-field-wrapper]:bg-white [&_.number-field-wrapper]:border-transparent text-[#3E3E3E]",
      "[&_.number-field-wrapper>input]:placeholder:text-[#3E3E3E]",
      floating == "outer" && "[&_.number-field-wrapper_.floating-label]:bg-white"
    ]
  end

  defp color_variant("bordered", "natural", floating) do
    [
      "text-[#282828] dark:text-[#E8E8E8] [&_.number-field-wrapper:not(:has(.text-field-error))]:border-[#282828]",
      "[&_.number-field-wrapper:not(:has(.text-field-error))]:bg-[#F3F3F3]",
      "dark:[&_.number-field-wrapper:not(:has(.text-field-error))]:bg-[#4B4B4B]",
      "dark:[&_.number-field-wrapper:not(:has(.text-field-error))]:border-[#868686]",
      "[&_.number-field-wrapper.text-field-error]:bg-rose-700",
      "[&_.number-field-wrapper>input]:placeholder:text-[#282828] dark:[&_.number-field-wrapper>input]:placeholder:text-[#E8E8E8]",
      "focus-within:[&_.number-field-wrapper]:ring-black dark:focus-within:[&_.number-field-wrapper]:ring-white",
      floating == "outer" &&
        "[&_.number-field-wrapper_.floating-label]:bg-[#868686] dark:[&_.number-field-wrapper_.floating-label]:bg-[#A6A6A6]"
    ]
  end

  defp color_variant("bordered", "primary", floating) do
    [
      "text-[#016974] dark:text-[#77D5E3] [&_.number-field-wrapper:not(:has(.text-field-error))]:border-[#016974]",
      "[&_.number-field-wrapper:not(:has(.text-field-error))]:bg-[#E2F8FB]",
      "dark:[&_.number-field-wrapper:not(:has(.text-field-error))]:bg-[#4B4B4B]",
      "dark:[&_.number-field-wrapper:not(:has(.text-field-error))]:border-[#77D5E3]",
      "[&_.number-field-wrapper.text-field-error]:bg-rose-700",
      "[&_.number-field-wrapper>input]:placeholder:text-[#016974] dark:[&_.number-field-wrapper>input]:placeholder:text-[#77D5E3]",
      "focus-within:[&_.number-field-wrapper]:ring-black dark:focus-within:[&_.number-field-wrapper]:ring-white",
      floating == "outer" &&
        "[&_.number-field-wrapper_.floating-label]:bg-[#868686] dark:[&_.number-field-wrapper_.floating-label]:bg-[#A6A6A6]"
    ]
  end

  defp color_variant("bordered", "secondary", floating) do
    [
      "text-[#175BCC] dark:text-[#A9C9FF] [&_.number-field-wrapper:not(:has(.text-field-error))]:border-[#175BCC]",
      "[&_.number-field-wrapper:not(:has(.text-field-error))]:bg-[#EFF4FE]",
      "dark:[&_.number-field-wrapper:not(:has(.text-field-error))]:bg-[#002661]",
      "dark:[&_.number-field-wrapper:not(:has(.text-field-error))]:border-[#A9C9FF]",
      "[&_.number-field-wrapper.text-field-error]:bg-rose-700",
      "[&_.number-field-wrapper>input]:placeholder:text-[#175BCC] dark:[&_.number-field-wrapper>input]:placeholder:text-[#A9C9FF]",
      "focus-within:[&_.number-field-wrapper]:ring-black dark:focus-within:[&_.number-field-wrapper]:ring-white",
      floating == "outer" &&
        "[&_.number-field-wrapper_.floating-label]:bg-[#868686] dark:[&_.number-field-wrapper_.floating-label]:bg-[#A6A6A6]"
    ]
  end

  defp color_variant("bordered", "success", floating) do
    [
      "text-[#166C3B] dark:text-[#7FD99A] [&_.number-field-wrapper:not(:has(.text-field-error))]:border-[#166C3B]",
      "[&_.number-field-wrapper:not(:has(.text-field-error))]:bg-[#EAF6ED]",
      "dark:[&_.number-field-wrapper:not(:has(.text-field-error))]:bg-[#002F14]",
      "dark:[&_.number-field-wrapper:not(:has(.text-field-error))]:border-[#7FD99A]",
      "[&_.number-field-wrapper.text-field-error]:bg-rose-700",
      "[&_.number-field-wrapper>input]:placeholder:text-[#166C3B] dark:[&_.number-field-wrapper>input]:placeholder:text-[#7FD99A]",
      "focus-within:[&_.number-field-wrapper]:ring-black dark:focus-within:[&_.number-field-wrapper]:ring-white",
      floating == "outer" &&
        "[&_.number-field-wrapper_.floating-label]:bg-[#868686] dark:[&_.number-field-wrapper_.floating-label]:bg-[#A6A6A6]"
    ]
  end

  defp color_variant("bordered", "warning", floating) do
    [
      "text-[#976A01] dark:text-[#FDD067] [&_.number-field-wrapper:not(:has(.text-field-error))]:border-[#976A01]",
      "[&_.number-field-wrapper:not(:has(.text-field-error))]:bg-[#FFF7E6]",
      "dark:[&_.number-field-wrapper:not(:has(.text-field-error))]:bg-[#322300]",
      "dark:[&_.number-field-wrapper:not(:has(.text-field-error))]:border-[#FDD067]",
      "[&_.number-field-wrapper.text-field-error]:bg-rose-700",
      "[&_.number-field-wrapper>input]:placeholder:text-[#976A01] dark:[&_.number-field-wrapper>input]:placeholder:text-[#FDD067]",
      "focus-within:[&_.number-field-wrapper]:ring-black dark:focus-within:[&_.number-field-wrapper]:ring-white",
      floating == "outer" &&
        "[&_.number-field-wrapper_.floating-label]:bg-[#868686] dark:[&_.number-field-wrapper_.floating-label]:bg-[#A6A6A6]"
    ]
  end

  defp color_variant("bordered", "danger", floating) do
    [
      "text-[#BB032A] dark:text-[#FFB2AB] [&_.number-field-wrapper:not(:has(.text-field-error))]:border-[#BB032A]",
      "[&_.number-field-wrapper:not(:has(.text-field-error))]:bg-[#FFF0EE]",
      "dark:[&_.number-field-wrapper:not(:has(.text-field-error))]:bg-[#322300]",
      "dark:[&_.number-field-wrapper:not(:has(.text-field-error))]:border-[#FFB2AB]",
      "[&_.number-field-wrapper.text-field-error]:bg-rose-700",
      "[&_.number-field-wrapper>input]:placeholder:text-[#BB032A] dark:[&_.number-field-wrapper>input]:placeholder:text-[#FFB2AB]",
      "focus-within:[&_.number-field-wrapper]:ring-black dark:focus-within:[&_.number-field-wrapper]:ring-white",
      floating == "outer" &&
        "[&_.number-field-wrapper_.floating-label]:bg-[#868686] dark:[&_.number-field-wrapper_.floating-label]:bg-[#A6A6A6]"
    ]
  end

  defp color_variant("bordered", "info", floating) do
    [
      "text-[#0B84BA] dark:text-[#6EC9F2] [&_.number-field-wrapper:not(:has(.text-field-error))]:border-[#0B84BA]",
      "[&_.number-field-wrapper:not(:has(.text-field-error))]:bg-[#E7F6FD]",
      "dark:[&_.number-field-wrapper:not(:has(.text-field-error))]:bg-[#03212F]",
      "dark:[&_.number-field-wrapper:not(:has(.text-field-error))]:border-[#6EC9F2]",
      "[&_.number-field-wrapper.text-field-error]:bg-rose-700",
      "[&_.number-field-wrapper>input]:placeholder:text-[#0B84BA] dark:[&_.number-field-wrapper>input]:placeholder:text-[#6EC9F2]",
      "focus-within:[&_.number-field-wrapper]:ring-black dark:focus-within:[&_.number-field-wrapper]:ring-white",
      floating == "outer" &&
        "[&_.number-field-wrapper_.floating-label]:bg-[#868686] dark:[&_.number-field-wrapper_.floating-label]:bg-[#A6A6A6]"
    ]
  end

  defp color_variant("bordered", "misc", floating) do
    [
      "text-[#653C94] dark:text-[#CBA2FA] [&_.number-field-wrapper:not(:has(.text-field-error))]:border-[#653C94]",
      "[&_.number-field-wrapper:not(:has(.text-field-error))]:bg-[#F6F0FE]",
      "dark:[&_.number-field-wrapper:not(:has(.text-field-error))]:bg-[#221431]",
      "dark:[&_.number-field-wrapper:not(:has(.text-field-error))]:border-[#CBA2FA]",
      "[&_.number-field-wrapper.text-field-error]:bg-rose-700",
      "[&_.number-field-wrapper>input]:placeholder:text-[#653C94] dark:[&_.number-field-wrapper>input]:placeholder:text-[#CBA2FA]",
      "focus-within:[&_.number-field-wrapper]:ring-black dark:focus-within:[&_.number-field-wrapper]:ring-white",
      floating == "outer" &&
        "[&_.number-field-wrapper_.floating-label]:bg-[#868686] dark:[&_.number-field-wrapper_.floating-label]:bg-[#A6A6A6]"
    ]
  end

  defp color_variant("bordered", "dawn", floating) do
    [
      "text-[#7E4B2A] dark:text-[#E4B190] [&_.number-field-wrapper:not(:has(.text-field-error))]:border-[#7E4B2A]",
      "[&_.number-field-wrapper:not(:has(.text-field-error))]:bg-[#FBF2ED]",
      "dark:[&_.number-field-wrapper:not(:has(.text-field-error))]:bg-[#2A190E]",
      "dark:[&_.number-field-wrapper:not(:has(.text-field-error))]:border-[#E4B190]",
      "[&_.number-field-wrapper.text-field-error]:bg-rose-700",
      "[&_.number-field-wrapper>input]:placeholder:text-[#7E4B2A] dark:[&_.number-field-wrapper>input]:placeholder:text-[#E4B190]",
      "focus-within:[&_.number-field-wrapper]:ring-black dark:focus-within:[&_.number-field-wrapper]:ring-white",
      floating == "outer" &&
        "[&_.number-field-wrapper_.floating-label]:bg-[#868686] dark:[&_.number-field-wrapper_.floating-label]:bg-[#A6A6A6]"
    ]
  end

  defp color_variant("bordered", "silver", floating) do
    [
      "text-[#727272] dark:text-[#BBBBBB] [&_.number-field-wrapper:not(:has(.text-field-error))]:border-[#727272]",
      "[&_.number-field-wrapper:not(:has(.text-field-error))]:bg-[#F3F3F3]",
      "dark:[&_.number-field-wrapper:not(:has(.text-field-error))]:bg-[#4B4B4B]",
      "dark:[&_.number-field-wrapper:not(:has(.text-field-error))]:border-[#BBBBBB]",
      "[&_.number-field-wrapper.text-field-error]:bg-rose-700",
      "[&_.number-field-wrapper>input]:placeholder:text-[#727272] dark:[&_.number-field-wrapper>input]:placeholder:text-[#BBBBBB]",
      "focus-within:[&_.number-field-wrapper]:ring-black dark:focus-within:[&_.number-field-wrapper]:ring-white",
      floating == "outer" &&
        "[&_.number-field-wrapper_.floating-label]:bg-[#868686] dark:[&_.number-field-wrapper_.floating-label]:bg-[#A6A6A6]"
    ]
  end

  defp color_variant("bordered", "dark", floating) do
    [
      "[&_.number-field-wrapper]:bg-[#1E1E1E] text-[#1E1E1E] [&_.number-field-wrapper]:border-transparent text-white",
      "[&_.number-field-wrapper>input]:placeholder:text-white",
      floating == "outer" && "[&_.number-field-wrapper_.floating-label]:bg-[#1E1E1E]"
    ]
  end

  defp color_variant("shadow", "natural", floating) do
    [
      "text-black dark:text-white [&_.number-field-wrapper:not(:has(.text-field-error))]:bg-[#4B4B4B]",
      "dark:[&_.number-field-wrapper:not(:has(.text-field-error))]:bg-[#DDDDDD]",
      "[&_.number-field-wrapper.text-field-error]:bg-rose-700",
      "[&_.number-field-wrapper>input]:placeholder:text-white dark:[&_.number-field-wrapper>input]:placeholder:text-black",
      "[&_.number-field-wrapper>input]:text-white dark:[&_.number-field-wrapper>input]:text-black",
      "focus-within:[&_.number-field-wrapper]:ring-[#4B4B4B] dark:focus-within:[&_.number-field-wrapper]:ring-[#DDDDDD]",
      "[&_.number-field-wrapper]:shadow-[0px_4px_6px_-4px_rgba(134,134,134,0.5)] [&_.number-field-wrapper]:shadow-[0px_10px_15px_-3px_rgba(134,134,134,0.5)]",
      "dark:[&_.number-field-wrapper]:shadow-none",
      floating == "outer" &&
        "[&_.number-field-wrapper_.floating-label]:bg-[#4B4B4B] dark:[&_.number-field-wrapper_.floating-label]:bg-[#DDDDDD]"
    ]
  end

  defp color_variant("shadow", "primary", floating) do
    [
      "text-black dark:text-white [&_.number-field-wrapper:not(:has(.text-field-error))]:bg-[#007F8C]",
      "dark:[&_.number-field-wrapper:not(:has(.text-field-error))]:bg-[#01B8CA]",
      "[&_.number-field-wrapper.text-field-error]:bg-rose-700",
      "[&_.number-field-wrapper>input]:placeholder:text-white dark:[&_.number-field-wrapper>input]:placeholder:text-black",
      "[&_.number-field-wrapper>input]:text-white dark:[&_.number-field-wrapper>input]:text-black",
      "focus-within:[&_.number-field-wrapper]:ring-[#007F8C] dark:focus-within:[&_.number-field-wrapper]:ring-[#01B8CA]",
      "[&_.number-field-wrapper]:shadow-[0px_4px_6px_-4px_rgba(0,149,164,0.5)] [&_.number-field-wrapper]:shadow-[0px_10px_15px_-3px_rgba(0,149,164,0.5)]",
      "dark:[&_.number-field-wrapper]:shadow-none",
      floating == "outer" &&
        "[&_.number-field-wrapper_.floating-label]:bg-[#007F8C] dark:[&_.number-field-wrapper_.floating-label]:bg-[#01B8CA]"
    ]
  end

  defp color_variant("shadow", "secondary", floating) do
    [
      "text-black dark:text-white [&_.number-field-wrapper:not(:has(.text-field-error))]:bg-[#266EF1]",
      "dark:[&_.number-field-wrapper:not(:has(.text-field-error))]:bg-[#6DAAFB]",
      "[&_.number-field-wrapper.text-field-error]:bg-rose-700",
      "[&_.number-field-wrapper>input]:placeholder:text-white dark:[&_.number-field-wrapper>input]:placeholder:text-black",
      "[&_.number-field-wrapper>input]:text-white dark:[&_.number-field-wrapper>input]:text-black",
      "focus-within:[&_.number-field-wrapper]:ring-[#266EF1] dark:focus-within:[&_.number-field-wrapper]:ring-[#6DAAFB]",
      "[&_.number-field-wrapper]:shadow-[0px_4px_6px_-4px_rgba(6,139,238,0.5)] [&_.number-field-wrapper]:shadow-[0px_10px_15px_-3px_rgba(6,139,238,0.5)]",
      "dark:[&_.number-field-wrapper]:shadow-none",
      floating == "outer" &&
        "[&_.number-field-wrapper_.floating-label]:bg-[#266EF1] dark:[&_.number-field-wrapper_.floating-label]:bg-[#6DAAFB]"
    ]
  end

  defp color_variant("shadow", "success", floating) do
    [
      "text-black dark:text-white [&_.number-field-wrapper:not(:has(.text-field-error))]:bg-[#0E8345]",
      "dark:[&_.number-field-wrapper:not(:has(.text-field-error))]:bg-[#06C167]",
      "[&_.number-field-wrapper.text-field-error]:bg-rose-700",
      "[&_.number-field-wrapper>input]:placeholder:text-white dark:[&_.number-field-wrapper>input]:placeholder:text-black",
      "[&_.number-field-wrapper>input]:text-white dark:[&_.number-field-wrapper>input]:text-black",
      "focus-within:[&_.number-field-wrapper]:ring-[#0E8345] dark:focus-within:[&_.number-field-wrapper]:ring-[#06C167]",
      "[&_.number-field-wrapper]:shadow-[0px_4px_6px_-4px_rgba(0,154,81,0.5)] [&_.number-field-wrapper]:shadow-[0px_10px_15px_-3px_rgba(0,154,81,0.5)]",
      "dark:[&_.number-field-wrapper]:shadow-none",
      floating == "outer" &&
        "[&_.number-field-wrapper_.floating-label]:bg-[#0E8345] dark:[&_.number-field-wrapper_.floating-label]:bg-[#06C167]"
    ]
  end

  defp color_variant("shadow", "warning", floating) do
    [
      "text-black dark:text-white [&_.number-field-wrapper:not(:has(.text-field-error))]:bg-[#CA8D01]",
      "dark:[&_.number-field-wrapper:not(:has(.text-field-error))]:bg-[#FDC034]",
      "[&_.number-field-wrapper.text-field-error]:bg-rose-700",
      "[&_.number-field-wrapper>input]:placeholder:text-white dark:[&_.number-field-wrapper>input]:placeholder:text-black",
      "[&_.number-field-wrapper>input]:text-white dark:[&_.number-field-wrapper>input]:text-black",
      "focus-within:[&_.number-field-wrapper]:ring-[#CA8D01] dark:focus-within:[&_.number-field-wrapper]:ring-[#FDC034]",
      "[&_.number-field-wrapper]:shadow-[0px_4px_6px_-4px_rgba(252,176,1,0.5)] [&_.number-field-wrapper]:shadow-[0px_10px_15px_-3px_rgba(252,176,1,0.5)]",
      "dark:[&_.number-field-wrapper]:shadow-none",
      floating == "outer" &&
        "[&_.number-field-wrapper_.floating-label]:bg-[#CA8D01] dark:[&_.number-field-wrapper_.floating-label]:bg-[#FDC034]"
    ]
  end

  defp color_variant("shadow", "danger", floating) do
    [
      "text-black dark:text-white [&_.number-field-wrapper:not(:has(.text-field-error))]:bg-[#DE1135]",
      "dark:[&_.number-field-wrapper:not(:has(.text-field-error))]:bg-[#FC7F79]",
      "[&_.number-field-wrapper.text-field-error]:bg-rose-700",
      "[&_.number-field-wrapper>input]:placeholder:text-white dark:[&_.number-field-wrapper>input]:placeholder:text-black",
      "[&_.number-field-wrapper>input]:text-white dark:[&_.number-field-wrapper>input]:text-black",
      "focus-within:[&_.number-field-wrapper]:ring-[#DE1135] dark:focus-within:[&_.number-field-wrapper]:ring-[#FC7F79]",
      "[&_.number-field-wrapper]:shadow-[0px_4px_6px_-4px_rgba(248,52,70,0.5)] [&_.number-field-wrapper]:shadow-[0px_10px_15px_-3px_rgba(248,52,70,0.5)]",
      "dark:[&_.number-field-wrapper]:shadow-none",
      floating == "outer" &&
        "[&_.number-field-wrapper_.floating-label]:bg-[#DE1135] dark:[&_.number-field-wrapper_.floating-label]:bg-[#FC7F79]"
    ]
  end

  defp color_variant("shadow", "info", floating) do
    [
      "text-black dark:text-white [&_.number-field-wrapper:not(:has(.text-field-error))]:bg-[#0B84BA]",
      "dark:[&_.number-field-wrapper:not(:has(.text-field-error))]:bg-[#3EB7ED]",
      "[&_.number-field-wrapper.text-field-error]:bg-rose-700",
      "[&_.number-field-wrapper>input]:placeholder:text-white dark:[&_.number-field-wrapper>input]:placeholder:text-black",
      "[&_.number-field-wrapper>input]:text-white dark:[&_.number-field-wrapper>input]:text-black",
      "focus-within:[&_.number-field-wrapper]:ring-[#0B84BA] dark:focus-within:[&_.number-field-wrapper]:ring-[#3EB7ED]",
      "[&_.number-field-wrapper]:shadow-[0px_4px_6px_-4px_rgba(14,165,233,0.5)] [&_.number-field-wrapper]:shadow-[0px_10px_15px_-3px_rgba(14,165,233,0.5)]",
      "dark:[&_.number-field-wrapper]:shadow-none",
      floating == "outer" &&
        "[&_.number-field-wrapper_.floating-label]:bg-[#0B84BA] dark:[&_.number-field-wrapper_.floating-label]:bg-[#3EB7ED]"
    ]
  end

  defp color_variant("shadow", "misc", floating) do
    [
      "text-black dark:text-white [&_.number-field-wrapper:not(:has(.text-field-error))]:bg-[#8750C5]",
      "dark:[&_.number-field-wrapper:not(:has(.text-field-error))]:bg-[#BA83F9]",
      "[&_.number-field-wrapper.text-field-error]:bg-rose-700",
      "[&_.number-field-wrapper>input]:placeholder:text-white dark:[&_.number-field-wrapper>input]:placeholder:text-black",
      "[&_.number-field-wrapper>input]:text-white dark:[&_.number-field-wrapper>input]:text-black",
      "focus-within:[&_.number-field-wrapper]:ring-[#8750C5] dark:focus-within:[&_.number-field-wrapper]:ring-[#BA83F9]",
      "[&_.number-field-wrapper]:shadow-[0px_4px_6px_-4px_rgba(169,100,247,0.5)] [&_.number-field-wrapper]:shadow-[0px_10px_15px_-3px_rgba(169,100,247,0.5)]",
      "dark:[&_.number-field-wrapper]:shadow-none",
      floating == "outer" &&
        "[&_.number-field-wrapper_.floating-label]:bg-[#8750C5] dark:[&_.number-field-wrapper_.floating-label]:bg-[#BA83F9]"
    ]
  end

  defp color_variant("shadow", "dawn", floating) do
    [
      "text-black dark:text-white [&_.number-field-wrapper:not(:has(.text-field-error))]:bg-[#A86438]",
      "dark:[&_.number-field-wrapper:not(:has(.text-field-error))]:bg-[#DB976B]",
      "[&_.number-field-wrapper.text-field-error]:bg-rose-700",
      "[&_.number-field-wrapper>input]:placeholder:text-white dark:[&_.number-field-wrapper>input]:placeholder:text-black",
      "[&_.number-field-wrapper>input]:text-white dark:[&_.number-field-wrapper>input]:text-black",
      "focus-within:[&_.number-field-wrapper]:ring-[#A86438] dark:focus-within:[&_.number-field-wrapper]:ring-[#DB976B]",
      "[&_.number-field-wrapper]:shadow-[0px_4px_6px_-4px_rgba(210,125,70,0.5)] [&_.number-field-wrapper]:shadow-[0px_10px_15px_-3px_rgba(210,125,70,0.5)]",
      "dark:[&_.number-field-wrapper]:shadow-none",
      floating == "outer" &&
        "[&_.number-field-wrapper_.floating-label]:bg-[#A86438] dark:[&_.number-field-wrapper_.floating-label]:bg-[#DB976B]"
    ]
  end

  defp color_variant("shadow", "silver", floating) do
    [
      "text-black dark:text-white [&_.number-field-wrapper:not(:has(.text-field-error))]:bg-[#868686]",
      "dark:[&_.number-field-wrapper:not(:has(.text-field-error))]:bg-[#A6A6A6]",
      "[&_.number-field-wrapper.text-field-error]:bg-rose-700",
      "[&_.number-field-wrapper>input]:placeholder:text-white dark:[&_.number-field-wrapper>input]:placeholder:text-black",
      "[&_.number-field-wrapper>input]:text-white dark:[&_.number-field-wrapper>input]:text-black",
      "focus-within:[&_.number-field-wrapper]:ring-[#868686] dark:focus-within:[&_.number-field-wrapper]:ring-[#A6A6A6]",
      "[&_.number-field-wrapper]:shadow-[0px_4px_6px_-4px_rgba(134,134,134,0.5)] [&_.number-field-wrapper]:shadow-[0px_10px_15px_-3px_rgba(134,134,134,0.5)]",
      "dark:[&_.number-field-wrapper]:shadow-none",
      floating == "outer" &&
        "[&_.number-field-wrapper_.floating-label]:bg-[#868686] dark:[&_.number-field-wrapper_.floating-label]:bg-[#A6A6A6]"
    ]
  end

  defp color_variant("transparent", "natural", _) do
    [
      "text-[#4B4B4B] dark:text-[#DDDDDD]",
      "[&_.number-field-wrapper>input]:placeholder:text-[#4B4B4B]",
      "dark:[&_.number-field-wrapper>input]:placeholder:text-[#4363EC]",
      "focus-within:[&_.number-field-wrapper]:ring-transparent"
    ]
  end

  defp color_variant("transparent", "primary", _) do
    [
      "text-[#007F8C] dark:text-[#01B8CA]",
      "[&_.number-field-wrapper>input]:placeholder:text-[#007F8C]",
      "dark:[&_.number-field-wrapper>input]:placeholder:text-[#01B8CA]",
      "focus-within:[&_.number-field-wrapper]:ring-transparent"
    ]
  end

  defp color_variant("transparent", "secondary", _) do
    [
      "text-[#266EF1] dark:text-[#6DAAFB]",
      "[&_.number-field-wrapper>input]:placeholder:text-[#266EF1]",
      "dark:[&_.number-field-wrapper>input]:placeholder:text-[#6DAAFB]",
      "focus-within:[&_.number-field-wrapper]:ring-transparent"
    ]
  end

  defp color_variant("transparent", "success", _) do
    [
      "text-[#0E8345] dark:text-[#06C167]",
      "[&_.number-field-wrapper>input]:placeholder:text-[#0E8345]",
      "dark:[&_.number-field-wrapper>input]:placeholder:text-[#06C167]",
      "focus-within:[&_.number-field-wrapper]:ring-transparent"
    ]
  end

  defp color_variant("transparent", "warning", _) do
    [
      "text-[#CA8D01] dark:text-[#FDC034]",
      "[&_.number-field-wrapper>input]:placeholder:text-[#CA8D01]",
      "dark:[&_.number-field-wrapper>input]:placeholder:text-[#FDC034]",
      "focus-within:[&_.number-field-wrapper]:ring-transparent"
    ]
  end

  defp color_variant("transparent", "danger", _) do
    [
      "text-[#DE1135] dark:text-[#FC7F79]",
      "[&_.number-field-wrapper>input]:placeholder:text-[#DE1135]",
      "dark:[&_.number-field-wrapper>input]:placeholder:text-[#FC7F79]",
      "focus-within:[&_.number-field-wrapper]:ring-transparent"
    ]
  end

  defp color_variant("transparent", "info", _) do
    [
      "text-[#0B84BA] dark:text-[#3EB7ED]",
      "[&_.number-field-wrapper>input]:placeholder:text-[#0B84BA]",
      "dark:[&_.number-field-wrapper>input]:placeholder:text-[#3EB7ED]",
      "focus-within:[&_.number-field-wrapper]:ring-transparent"
    ]
  end

  defp color_variant("transparent", "misc", _) do
    [
      "text-[#8750C5] dark:text-[#BA83F9]",
      "[&_.number-field-wrapper>input]:placeholder:text-[#8750C5]",
      "dark:[&_.number-field-wrapper>input]:placeholder:text-[#BA83F9]",
      "focus-within:[&_.number-field-wrapper]:ring-transparent"
    ]
  end

  defp color_variant("transparent", "dawn", _) do
    [
      "text-[#A86438] dark:text-[#DB976B]",
      "[&_.number-field-wrapper>input]:placeholder:text-[#A86438]",
      "dark:[&_.number-field-wrapper>input]:placeholder:text-[#DB976B]",
      "focus-within:[&_.number-field-wrapper]:ring-transparent"
    ]
  end

  defp color_variant("transparent", "silver", _) do
    [
      "text-[#868686] dark:text-[#A6A6A6]",
      "[&_.number-field-wrapper>input]:placeholder:text-[#868686]",
      "dark:[&_.number-field-wrapper>input]:placeholder:text-[#A6A6A6]",
      "focus-within:[&_.number-field-wrapper]:ring-transparent"
    ]
  end

  defp color_variant(params, _, _) when is_binary(params), do: params

  defp translate_error({msg, opts}) do
    # When using gettext, we typically pass the strings we want
    # to translate as a static argument:
    #
    #     # Translate the number of files with plural rules
    #     dngettext("errors", "1 file", "%{count} files", count)
    #
    # However the error messages in our forms and APIs are generated
    # dynamically, so we need to translate them by calling Gettext
    # with our gettext backend as first argument. Translations are
    # available in the errors.po file (as we use the "errors" domain).
    if count = opts[:count] do
      Gettext.dngettext(CommunityDemoWeb.Gettext, "errors", msg, msg, count, opts)
    else
      Gettext.dgettext(CommunityDemoWeb.Gettext, "errors", msg, opts)
    end
  end

  attr :name, :string, required: true, doc: "Specifies the name of the element"
  attr :class, :any, default: nil, doc: "Custom CSS class for additional styling"

  defp icon(%{name: "hero-" <> _, class: class} = assigns) when is_list(class) do
    ~H"""
    <span class={[@name] ++ @class} />
    """
  end

  defp icon(%{name: "hero-" <> _} = assigns) do
    ~H"""
    <span class={[@name, @class]} />
    """
  end
end
