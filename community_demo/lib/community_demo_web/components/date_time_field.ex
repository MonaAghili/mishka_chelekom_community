defmodule CommunityDemoWeb.Components.DateTimeField do
  @moduledoc """
  The `CommunityDemoWeb.Components.DateTimeField` module provides a reusable component for rendering
  various types of date and time inputs in Phoenix applications.

  It includes options for customization, validation, and styling, supporting different
  use cases in forms and interactive interfaces.

  ## Features:
  - Supports multiple input types: `date`, `datetime-local`, `time`, `week`, and `month`.
  - Configurable appearance with various styles, border options, and rounded corners.
  - Flexible error handling with the ability to display custom error messages and icons.
  - Optional floating label support, allowing labels to animate based on user interaction.
  - Integration with Phoenix form fields for seamless form data management.
  """

  use Phoenix.Component

  @variants ["outline", "default", "bordered", "shadow", "transparent"]

  @colors [
    "natural",
    "white",
    "primary",
    "secondary",
    "dark",
    "success",
    "warning",
    "danger",
    "info",
    "silver",
    "misc",
    "dawn"
  ]

  @doc """
  The `date_time_field` component is used to create a customizable date, time, or datetime input field with various options such as `type`, `color`, and `size`. It supports floating labels, descriptions, and error messages, making it suitable for form validation and enhanced UX.

  ## Examples

  ```elixir
  <.date_time_field name="name" type="date" space="small" color="dark" floating="outer"/>
  <.date_time_field name="name" type="time" space="small" color="danger" floating="outer"/>
  <.date_time_field name="name1" type="week" space="small" color="success" floating="outer"/>

  <.date_time_field
    name="name"
    type="month"
    space="small"
    color="warning"
    description="This is description"
    label="This is label month"
    floating="outer"
  />

  <.date_time_field
    name="name"
    type="datetime-local"
    space="small"
    color="primary"
    description="This is description"
    label="This is label datetime-local"
    floating="outer"
  />

  <.date_time_field
    name="name"
    type="week"
    space="large"
    color="secondary"
    description="This is description"
    label="This is label week"
    size="medium"
  />

  <.date_time_field
    name="name"
    type="date"
    space="large"
    color="misc"
    description="This is description"
    label="This is label date"
    size="small"
  />

  <.date_time_field
    name="name"
    type="month"
    space="large"
    color="dawn"
    description="This is description"
    label="This is label month"
    size="large"
  />
  ```
  """
  @doc type: :component
  attr :id, :string,
    default: nil,
    doc: "A unique identifier is used to manage state and interaction"

  attr :class, :string, default: nil, doc: "Custom CSS class for additional styling"
  attr :color, :string, values: @colors, default: "natural", doc: "Determines color theme"

  attr :type, :string,
    values: ["date", "datetime-local", "time", "week", "month"],
    default: "date",
    doc: "Determines type of input"

  attr :border, :string, default: "extra_small", doc: "Determines border style"
  attr :rounded, :string, default: "small", doc: "Determines the border radius"
  attr :variant, :string, values: @variants, default: "outline", doc: "Determines the style"
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

  attr :floating, :string, default: "none", doc: "none, inner, outer"
  attr :error_icon, :string, default: nil, doc: "Icon to be displayed alongside error messages"
  attr :label, :string, default: "Specifies text for the label"

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
    include: ~w(disabled form min max readonly required step autofocus),
    doc:
      "Global attributes can define defaults which are merged with attributes provided by the caller"

  @spec date_time_field(map()) :: Phoenix.LiveView.Rendered.t()
  def date_time_field(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    errors = if Phoenix.Component.used_input?(field), do: field.errors, else: []

    assigns
    |> assign(field: nil, id: assigns.id || field.id)
    |> assign(:errors, Enum.map(errors, &translate_error(&1)))
    |> assign_new(:name, fn -> field.name end)
    |> assign_new(:value, fn -> field.value end)
    |> date_time_field()
  end

  def date_time_field(%{floating: floating} = assigns) when floating in ["inner", "outer"] do
    ~H"""
    <div class={[
      color_variant(@variant, @color, @floating),
      rounded_size(@rounded),
      border_class(@border, @variant),
      size_class(@size),
      space_class(@space),
      @ring && "[&_.date-time-field-wrapper]:focus-within:ring-[0.03rem]",
      @class
    ]}>
      <div :if={!is_nil(@description)} class="text-xs pb-2">
        {@description}
      </div>
      <div class={[
        "date-time-field-wrapper transition-all ease-in-out duration-200 w-full flex flex-nowrap",
        @errors != [] && "date-time-field-error"
      ]}>
        <div
          :if={@start_section}
          class={[
            "flex items-center justify-center shrink-0 ps-2 h-[inherit]",
            @start_section[:class]
          ]}
        >
          {render_slot(@start_section)}
        </div>
        <div class="relative w-full z-[2]">
          <input
            type={@type}
            name={@name}
            id={@id}
            value={@value}
            class={[
              "disabled:opacity-80 block w-full z-[2] focus:ring-0 placeholder:text-transparent pb-1 pt-2.5 px-2",
              "text-[16px] sm:font-inherit appearance-none bg-transparent border-0 focus:outline-none peer"
            ]}
            placeholder="select a date "
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
          class={["flex items-center justify-center shrink-0 pe-2 h-[inherit]", @end_section[:class]]}
        >
          {render_slot(@end_section)}
        </div>
      </div>

      <.error :for={msg <- @errors} icon={@error_icon}>{msg}</.error>
    </div>
    """
  end

  def date_time_field(assigns) do
    ~H"""
    <div class={[
      color_variant(@variant, @color, @floating),
      rounded_size(@rounded),
      border_class(@border, @variant),
      size_class(@size),
      space_class(@space),
      @ring && "[&_.date-time-field-wrapper]:focus-within:ring-[0.03rem]",
      @class
    ]}>
      <div>
        <.label for={@id}>{@label}</.label>
        <div :if={!is_nil(@description)} class="text-xs">
          {@description}
        </div>
      </div>

      <div class={[
        "date-time-field-wrapper overflow-hidden transition-all ease-in-out duration-200 flex flex-nowrap",
        @errors != [] && "date-time-field-error"
      ]}>
        <div
          :if={@start_section}
          class={[
            "flex items-center justify-center shrink-0 ps-2 h-[inherit]",
            @start_section[:class]
          ]}
        >
          {render_slot(@start_section)}
        </div>

        <input
          type={@type}
          name={@name}
          id={@id}
          value={@value}
          class={[
            "flex-1 py-1 px-2 text-sm disabled:opacity-80 block w-full appearance-none",
            "bg-transparent border-0 focus:outline-none focus:ring-0"
          ]}
          {@rest}
        />

        <div
          :if={@end_section}
          class={["flex items-center justify-center shrink-0 pe-2 h-[inherit]", @end_section[:class]]}
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

  defp size_class("extra_small") do
    [
      "[&_.date-time-field-wrapper_input]:h-7 [&_.date-time-field-wrapper>.date-time-field-icon]:size-3.5"
    ]
  end

  defp size_class("small") do
    [
      "[&_.date-time-field-wrapper_input]:h-8 [&_.date-time-field-wrapper>.date-time-field-icon]:size-4"
    ]
  end

  defp size_class("medium") do
    [
      "[&_.date-time-field-wrapper_input]:h-9 [&_.date-time-field-wrapper>.date-time-field-icon]:size-5"
    ]
  end

  defp size_class("large") do
    [
      "[&_.date-time-field-wrapper_input]:h-10 [&_.date-time-field-wrapper>.date-time-field-icon]:size-6"
    ]
  end

  defp size_class("extra_large") do
    [
      "[&_.date-time-field-wrapper_input]:h-12 [&_.date-time-field-wrapper>.date-time-field-icon]:size-7"
    ]
  end

  defp size_class(_), do: size_class("medium")

  defp rounded_size("extra_small"), do: "[&_.date-time-field-wrapper]:rounded-sm"

  defp rounded_size("small"), do: "[&_.date-time-field-wrapper]:rounded"

  defp rounded_size("medium"), do: "[&_.date-time-field-wrapper]:rounded-md"

  defp rounded_size("large"), do: "[&_.date-time-field-wrapper]:rounded-lg"

  defp rounded_size("extra_large"), do: "[&_.date-time-field-wrapper]:rounded-xl"

  defp rounded_size("full"), do: "[&_.date-time-field-wrapper]:rounded-full"

  defp rounded_size(_), do: "[&_.date-time-field-wrapper]:rounded-none"

  defp border_class(_, variant) when variant in ["default", "shadow", "transparent"],
    do: nil

  defp border_class("none", _), do: "[&_.date-time-field-wrapper]:border-0"

  defp border_class("extra_small", _), do: "[&_.date-time-field-wrapper]:border"

  defp border_class("small", _), do: "[&_.date-time-field-wrapper]:border-2"

  defp border_class("medium", _), do: "[&_.date-time-field-wrapper]:border-[3px]"

  defp border_class("large", _), do: "[&_.date-time-field-wrapper]:border-4"

  defp border_class("extra_large", _), do: "[&_.date-time-field-wrapper]:border-[5px]"

  defp border_class(params, _) when is_binary(params), do: params

  defp border_class(_, _), do: border_class("extra_small", nil)

  defp space_class("extra_small"), do: "space-y-1"

  defp space_class("small"), do: "space-y-1.5"

  defp space_class("medium"), do: "space-y-2"

  defp space_class("large"), do: "space-y-2.5"

  defp space_class("extra_large"), do: "space-y-3"

  defp space_class(params) when is_binary(params), do: params

  defp space_class(_), do: space_class("medium")

  defp color_variant("outline", "natural", floating) do
    [
      "text-[#4B4B4B] dark:text-[#DDDDDD] [&_.date-time-field-wrapper:not(:has(.date-time-field-error))]:border-[#4B4B4B]",
      "dark:[&_.date-time-field-wrapper:not(:has(.date-time-field-error))]:border-[#DDDDDD]",
      "[&_.date-time-field-wrapper.date-time-field-error]:border-rose-700",
      "[&_.date-time-field-wrapper>input]:placeholder:text-[#4B4B4B] dark:[&_.date-time-field-wrapper>input]:placeholder:text-[#DDDDDD]",
      "focus-within:[&_.date-time-field-wrapper]:ring-[#4B4B4B] dark:focus-within:[&_.date-time-field-wrapper]:ring-[#DDDDDD]",
      floating == "outer" &&
        "[&_.date-time-field-wrapper_.floating-label]:bg-white dark:[&_.date-time-field-wrapper_.floating-label]:bg-[#282828]"
    ]
  end

  defp color_variant("outline", "primary", floating) do
    [
      "text-[#007F8C] dark:text-[#01B8CA] [&_.date-time-field-wrapper:not(:has(.date-time-field-error))]:border-[#007F8C]",
      "dark:[&_.date-time-field-wrapper:not(:has(.date-time-field-error))]:border-[#01B8CA]",
      "[&_.date-time-field-wrapper.date-time-field-error]:border-rose-700",
      "[&_.date-time-field-wrapper>input]:placeholder:text-[#007F8C] dark:[&_.date-time-field-wrapper>input]:placeholder:text-[#01B8CA]",
      "focus-within:[&_.date-time-field-wrapper]:ring-[#007F8C] dark:focus-within:[&_.date-time-field-wrapper]:ring-[#01B8CA]",
      floating == "outer" &&
        "[&_.date-time-field-wrapper_.floating-label]:bg-white dark:[&_.date-time-field-wrapper_.floating-label]:bg-[#282828]"
    ]
  end

  defp color_variant("outline", "secondary", floating) do
    [
      "text-[#266EF1] dark:text-[#6DAAFB] [&_.date-time-field-wrapper:not(:has(.date-time-field-error))]:border-[#266EF1]",
      "dark:[&_.date-time-field-wrapper:not(:has(.date-time-field-error))]:border-[#6DAAFB]",
      "[&_.date-time-field-wrapper.date-time-field-error]:border-rose-700",
      "[&_.date-time-field-wrapper>input]:placeholder:text-[#266EF1] dark:[&_.date-time-field-wrapper>input]:placeholder:text-[#6DAAFB]",
      "focus-within:[&_.date-time-field-wrapper]:ring-[#266EF1] dark:focus-within:[&_.date-time-field-wrapper]:ring-[#6DAAFB]",
      floating == "outer" &&
        "[&_.date-time-field-wrapper_.floating-label]:bg-white dark:[&_.date-time-field-wrapper_.floating-label]:bg-[#282828]"
    ]
  end

  defp color_variant("outline", "success", floating) do
    [
      "text-[#0E8345] dark:text-[#06C167] [&_.date-time-field-wrapper:not(:has(.date-time-field-error))]:border-[#0E8345]",
      "dark:[&_.date-time-field-wrapper:not(:has(.date-time-field-error))]:border-[#06C167]",
      "[&_.date-time-field-wrapper.date-time-field-error]:border-rose-700",
      "[&_.date-time-field-wrapper>input]:placeholder:text-[#0E8345] dark:[&_.date-time-field-wrapper>input]:placeholder:text-[#06C167]",
      "focus-within:[&_.date-time-field-wrapper]:ring-[#0E8345] dark:focus-within:[&_.date-time-field-wrapper]:ring-[#06C167]",
      floating == "outer" &&
        "[&_.date-time-field-wrapper_.floating-label]:bg-white dark:[&_.date-time-field-wrapper_.floating-label]:bg-[#282828]"
    ]
  end

  defp color_variant("outline", "warning", floating) do
    [
      "text-[#CA8D01] dark:text-[#FDC034] [&_.date-time-field-wrapper:not(:has(.date-time-field-error))]:border-[#CA8D01]",
      "dark:[&_.date-time-field-wrapper:not(:has(.date-time-field-error))]:border-[#FDC034]",
      "[&_.date-time-field-wrapper.date-time-field-error]:border-rose-700",
      "[&_.date-time-field-wrapper>input]:placeholder:text-[#CA8D01] dark:[&_.date-time-field-wrapper>input]:placeholder:text-[#FDC034]",
      "focus-within:[&_.date-time-field-wrapper]:ring-[#CA8D01] dark:focus-within:[&_.date-time-field-wrapper]:ring-[#FDC034]",
      floating == "outer" &&
        "[&_.date-time-field-wrapper_.floating-label]:bg-white dark:[&_.date-time-field-wrapper_.floating-label]:bg-[#282828]"
    ]
  end

  defp color_variant("outline", "danger", floating) do
    [
      "text-[#CA8D01] dark:text-[#FC7F79] [&_.date-time-field-wrapper:not(:has(.date-time-field-error))]:border-[#CA8D01]",
      "dark:[&_.date-time-field-wrapper:not(:has(.date-time-field-error))]:border-[#FC7F79]",
      "[&_.date-time-field-wrapper.date-time-field-error]:border-rose-700",
      "[&_.date-time-field-wrapper>input]:placeholder:text-[#CA8D01] dark:[&_.date-time-field-wrapper>input]:placeholder:text-[#FC7F79]",
      "focus-within:[&_.date-time-field-wrapper]:ring-[#DE1135] dark:focus-within:[&_.date-time-field-wrapper]:ring-[#FC7F79]",
      floating == "outer" &&
        "[&_.date-time-field-wrapper_.floating-label]:bg-white dark:[&_.date-time-field-wrapper_.floating-label]:bg-[#282828]"
    ]
  end

  defp color_variant("outline", "info", floating) do
    [
      "text-[#0B84BA] dark:text-[#3EB7ED] [&_.date-time-field-wrapper:not(:has(.date-time-field-error))]:border-[#0B84BA]",
      "dark:[&_.date-time-field-wrapper:not(:has(.date-time-field-error))]:border-[#3EB7ED]",
      "[&_.date-time-field-wrapper.date-time-field-error]:border-rose-700",
      "[&_.date-time-field-wrapper>input]:placeholder:text-[#0B84BA] dark:[&_.date-time-field-wrapper>input]:placeholder:text-[#3EB7ED]",
      "focus-within:[&_.date-time-field-wrapper]:ring-[#0B84BA] dark:focus-within:[&_.date-time-field-wrapper]:ring-[#3EB7ED]",
      floating == "outer" &&
        "[&_.date-time-field-wrapper_.floating-label]:bg-white dark:[&_.date-time-field-wrapper_.floating-label]:bg-[#282828]"
    ]
  end

  defp color_variant("outline", "misc", floating) do
    [
      "text-[#8750C5] dark:text-[#BA83F9] [&_.date-time-field-wrapper:not(:has(.date-time-field-error))]:border-[#8750C5]",
      "dark:[&_.date-time-field-wrapper:not(:has(.date-time-field-error))]:border-[#BA83F9]",
      "[&_.date-time-field-wrapper.date-time-field-error]:border-rose-700",
      "[&_.date-time-field-wrapper>input]:placeholder:text-[#8750C5] dark:[&_.date-time-field-wrapper>input]:placeholder:text-[#BA83F9]",
      "focus-within:[&_.date-time-field-wrapper]:ring-[#8750C5] dark:focus-within:[&_.date-time-field-wrapper]:ring-[#BA83F9]",
      floating == "outer" &&
        "[&_.date-time-field-wrapper_.floating-label]:bg-white dark:[&_.date-time-field-wrapper_.floating-label]:bg-[#282828]"
    ]
  end

  defp color_variant("outline", "dawn", floating) do
    [
      "text-[#A86438] dark:text-[#DB976B] [&_.date-time-field-wrapper:not(:has(.date-time-field-error))]:border-[#A86438]",
      "dark:[&_.date-time-field-wrapper:not(:has(.date-time-field-error))]:border-[#DB976B]",
      "[&_.date-time-field-wrapper.date-time-field-error]:border-rose-700",
      "[&_.date-time-field-wrapper>input]:placeholder:text-[#A86438] dark:[&_.date-time-field-wrapper>input]:placeholder:text-[#DB976B]",
      "focus-within:[&_.date-time-field-wrapper]:ring-[#A86438] dark:focus-within:[&_.date-time-field-wrapper]:ring-[#DB976B]",
      floating == "outer" &&
        "[&_.date-time-field-wrapper_.floating-label]:bg-white dark:[&_.date-time-field-wrapper_.floating-label]:bg-[#282828]"
    ]
  end

  defp color_variant("outline", "silver", floating) do
    [
      "text-[#868686] dark:text-[#A6A6A6] [&_.date-time-field-wrapper:not(:has(.date-time-field-error))]:border-[#868686]",
      "dark:[&_.date-time-field-wrapper:not(:has(.date-time-field-error))]:border-[#A6A6A6]",
      "[&_.date-time-field-wrapper.date-time-field-error]:border-rose-700",
      "[&_.date-time-field-wrapper>input]:placeholder:text-[#868686] dark:[&_.date-time-field-wrapper>input]:placeholder:text-[#A6A6A6]",
      "focus-within:[&_.date-time-field-wrapper]:ring-[#868686] dark:focus-within:[&_.date-time-field-wrapper]:ring-[#A6A6A6]",
      floating == "outer" &&
        "[&_.date-time-field-wrapper_.floating-label]:bg-white dark:[&_.date-time-field-wrapper_.floating-label]:bg-[#282828]"
    ]
  end

  defp color_variant("default", "white", floating) do
    [
      "[&_.date-time-field-wrapper]:bg-white text-[#3E3E3E]",
      "[&_.date-time-field-wrapper.date-time-field-error]:border-rose-700",
      "[&_.date-time-field-wrapper>input]:placeholder:text-[#3E3E3E] focus-within:[&_.date-time-field-wrapper]:ring-[#DADADA]",
      floating == "outer" && "[&_.date-time-field-wrapper_.floating-label]:bg-white"
    ]
  end

  defp color_variant("default", "natural", floating) do
    [
      "text-black dark:text-white [&_.date-time-field-wrapper:not(:has(.date-time-field-error))]:bg-[#4B4B4B]",
      "dark:[&_.date-time-field-wrapper:not(:has(.date-time-field-error))]:bg-[#DDDDDD]",
      "[&_.date-time-field-wrapper.date-time-field-error]:bg-rose-700",
      "[&_.date-time-field-wrapper>input]:placeholder:text-white dark:[&_.date-time-field-wrapper>input]:placeholder:text-black",
      "[&_.date-time-field-wrapper>input]:text-white dark:[&_.date-time-field-wrapper>input]:text-black",
      "focus-within:[&_.date-time-field-wrapper]:ring-[#4B4B4B] dark:focus-within:[&_.date-time-field-wrapper]:ring-[#DDDDDD]",
      floating == "outer" &&
        "[&_.date-time-field-wrapper_.floating-label]:bg-[#4B4B4B] dark:[&_.date-time-field-wrapper_.floating-label]:bg-[#DDDDDD]"
    ]
  end

  defp color_variant("default", "primary", floating) do
    [
      "text-black dark:text-white [&_.date-time-field-wrapper:not(:has(.date-time-field-error))]:bg-[#007F8C]",
      "dark:[&_.date-time-field-wrapper:not(:has(.date-time-field-error))]:bg-[#01B8CA]",
      "[&_.date-time-field-wrapper.date-time-field-error]:bg-rose-700",
      "[&_.date-time-field-wrapper>input]:placeholder:text-white dark:[&_.date-time-field-wrapper>input]:placeholder:text-black",
      "[&_.date-time-field-wrapper>input]:text-white dark:[&_.date-time-field-wrapper>input]:text-black",
      "focus-within:[&_.date-time-field-wrapper]:ring-[#007F8C] dark:focus-within:[&_.date-time-field-wrapper]:ring-[#01B8CA]",
      floating == "outer" &&
        "[&_.date-time-field-wrapper_.floating-label]:bg-[#007F8C] dark:[&_.date-time-field-wrapper_.floating-label]:bg-[#01B8CA]"
    ]
  end

  defp color_variant("default", "secondary", floating) do
    [
      "text-black dark:text-white [&_.date-time-field-wrapper:not(:has(.date-time-field-error))]:bg-[#266EF1]",
      "dark:[&_.date-time-field-wrapper:not(:has(.date-time-field-error))]:bg-[#6DAAFB]",
      "[&_.date-time-field-wrapper.date-time-field-error]:bg-rose-700",
      "[&_.date-time-field-wrapper>input]:placeholder:text-white dark:[&_.date-time-field-wrapper>input]:placeholder:text-black",
      "[&_.date-time-field-wrapper>input]:text-white dark:[&_.date-time-field-wrapper>input]:text-black",
      "focus-within:[&_.date-time-field-wrapper]:ring-[#266EF1] dark:focus-within:[&_.date-time-field-wrapper]:ring-[#6DAAFB]",
      floating == "outer" &&
        "[&_.date-time-field-wrapper_.floating-label]:bg-[#266EF1] dark:[&_.date-time-field-wrapper_.floating-label]:bg-[#6DAAFB]"
    ]
  end

  defp color_variant("default", "success", floating) do
    [
      "text-black dark:text-white [&_.date-time-field-wrapper:not(:has(.date-time-field-error))]:bg-[#0E8345]",
      "dark:[&_.date-time-field-wrapper:not(:has(.date-time-field-error))]:bg-[#06C167]",
      "[&_.date-time-field-wrapper.date-time-field-error]:bg-rose-700",
      "[&_.date-time-field-wrapper>input]:placeholder:text-white dark:[&_.date-time-field-wrapper>input]:placeholder:text-black",
      "[&_.date-time-field-wrapper>input]:text-white dark:[&_.date-time-field-wrapper>input]:text-black",
      "focus-within:[&_.date-time-field-wrapper]:ring-[#0E8345] dark:focus-within:[&_.date-time-field-wrapper]:ring-[#06C167]",
      floating == "outer" &&
        "[&_.date-time-field-wrapper_.floating-label]:bg-[#0E8345] dark:[&_.date-time-field-wrapper_.floating-label]:bg-[#06C167]"
    ]
  end

  defp color_variant("default", "warning", floating) do
    [
      "text-black dark:text-white [&_.date-time-field-wrapper:not(:has(.date-time-field-error))]:bg-[#CA8D01]",
      "dark:[&_.date-time-field-wrapper:not(:has(.date-time-field-error))]:bg-[#FDC034]",
      "[&_.date-time-field-wrapper.date-time-field-error]:bg-rose-700",
      "[&_.date-time-field-wrapper>input]:placeholder:text-white dark:[&_.date-time-field-wrapper>input]:placeholder:text-black",
      "[&_.date-time-field-wrapper>input]:text-white dark:[&_.date-time-field-wrapper>input]:text-black",
      "focus-within:[&_.date-time-field-wrapper]:ring-[#CA8D01] dark:focus-within:[&_.date-time-field-wrapper]:ring-[#FDC034]",
      floating == "outer" &&
        "[&_.date-time-field-wrapper_.floating-label]:bg-[#CA8D01] dark:[&_.date-time-field-wrapper_.floating-label]:bg-[#FDC034]"
    ]
  end

  defp color_variant("default", "danger", floating) do
    [
      "text-black dark:text-white [&_.date-time-field-wrapper:not(:has(.date-time-field-error))]:bg-[#DE1135]",
      "dark:[&_.date-time-field-wrapper:not(:has(.date-time-field-error))]:bg-[#FC7F79]",
      "[&_.date-time-field-wrapper.date-time-field-error]:bg-rose-700",
      "[&_.date-time-field-wrapper>input]:placeholder:text-white dark:[&_.date-time-field-wrapper>input]:placeholder:text-black",
      "[&_.date-time-field-wrapper>input]:text-white dark:[&_.date-time-field-wrapper>input]:text-black",
      "focus-within:[&_.date-time-field-wrapper]:ring-[#DE1135] dark:focus-within:[&_.date-time-field-wrapper]:ring-[#FC7F79]",
      floating == "outer" &&
        "[&_.date-time-field-wrapper_.floating-label]:bg-[#DE1135] dark:[&_.date-time-field-wrapper_.floating-label]:bg-[#FC7F79]"
    ]
  end

  defp color_variant("default", "info", floating) do
    [
      "text-black dark:text-white [&_.date-time-field-wrapper:not(:has(.date-time-field-error))]:bg-[#0B84BA]",
      "dark:[&_.date-time-field-wrapper:not(:has(.date-time-field-error))]:bg-[#3EB7ED]",
      "[&_.date-time-field-wrapper.date-time-field-error]:bg-rose-700",
      "[&_.date-time-field-wrapper>input]:placeholder:text-white dark:[&_.date-time-field-wrapper>input]:placeholder:text-black",
      "[&_.date-time-field-wrapper>input]:text-white dark:[&_.date-time-field-wrapper>input]:text-black",
      "focus-within:[&_.date-time-field-wrapper]:ring-[#0B84BA] dark:focus-within:[&_.date-time-field-wrapper]:ring-[#3EB7ED]",
      floating == "outer" &&
        "[&_.date-time-field-wrapper_.floating-label]:bg-[#0B84BA] dark:[&_.date-time-field-wrapper_.floating-label]:bg-[#3EB7ED]"
    ]
  end

  defp color_variant("default", "misc", floating) do
    [
      "text-black dark:text-white [&_.date-time-field-wrapper:not(:has(.date-time-field-error))]:bg-[#8750C5]",
      "dark:[&_.date-time-field-wrapper:not(:has(.date-time-field-error))]:bg-[#BA83F9]",
      "[&_.date-time-field-wrapper.date-time-field-error]:bg-rose-700",
      "[&_.date-time-field-wrapper>input]:placeholder:text-white dark:[&_.date-time-field-wrapper>input]:placeholder:text-black",
      "[&_.date-time-field-wrapper>input]:text-white dark:[&_.date-time-field-wrapper>input]:text-black",
      "focus-within:[&_.date-time-field-wrapper]:ring-[#8750C5] dark:focus-within:[&_.date-time-field-wrapper]:ring-[#BA83F9]",
      floating == "outer" &&
        "[&_.date-time-field-wrapper_.floating-label]:bg-[#8750C5] dark:[&_.date-time-field-wrapper_.floating-label]:bg-[#BA83F9]"
    ]
  end

  defp color_variant("default", "dawn", floating) do
    [
      "text-black dark:text-white [&_.date-time-field-wrapper:not(:has(.date-time-field-error))]:bg-[#A86438]",
      "dark:[&_.date-time-field-wrapper:not(:has(.date-time-field-error))]:bg-[#DB976B]",
      "[&_.date-time-field-wrapper.date-time-field-error]:bg-rose-700",
      "[&_.date-time-field-wrapper>input]:placeholder:text-white dark:[&_.date-time-field-wrapper>input]:placeholder:text-black",
      "[&_.date-time-field-wrapper>input]:text-white dark:[&_.date-time-field-wrapper>input]:text-black",
      "focus-within:[&_.date-time-field-wrapper]:ring-[#A86438] dark:focus-within:[&_.date-time-field-wrapper]:ring-[#DB976B]",
      floating == "outer" &&
        "[&_.date-time-field-wrapper_.floating-label]:bg-[#A86438] dark:[&_.date-time-field-wrapper_.floating-label]:bg-[#DB976B]"
    ]
  end

  defp color_variant("default", "silver", floating) do
    [
      "text-black dark:text-white [&_.date-time-field-wrapper:not(:has(.date-time-field-error))]:bg-[#868686]",
      "dark:[&_.date-time-field-wrapper:not(:has(.date-time-field-error))]:bg-[#A6A6A6]",
      "[&_.date-time-field-wrapper.date-time-field-error]:bg-rose-700",
      "[&_.date-time-field-wrapper>input]:placeholder:text-white dark:[&_.date-time-field-wrapper>input]:placeholder:text-black",
      "[&_.date-time-field-wrapper>input]:text-white dark:[&_.date-time-field-wrapper>input]:text-black",
      "focus-within:[&_.date-time-field-wrapper]:ring-[#868686] dark:focus-within:[&_.date-time-field-wrapper]:ring-[#A6A6A6]",
      floating == "outer" &&
        "[&_.date-time-field-wrapper_.floating-label]:bg-[#868686] dark:[&_.date-time-field-wrapper_.floating-label]:bg-[#A6A6A6]"
    ]
  end

  defp color_variant("default", "dark", floating) do
    [
      "[&_.date-time-field-wrapper]:bg-[#282828] text-[#282828] [&_.date-time-field-wrapper]:text-white",
      "[&_.date-time-field-wrapper.date-time-field-error]:border-rose-700",
      "[&_.date-time-field-wrapper>input]:placeholder:text-white focus-within:[&_.date-time-field-wrapper]:ring-[#727272]",
      floating == "outer" && "[&_.date-time-field-wrapper_.floating-label]:bg-[#282828]"
    ]
  end

  defp color_variant("bordered", "white", floating) do
    [
      "[&_.date-time-field-wrapper]:bg-white [&_.date-time-field-wrapper]:border-transparent text-[#3E3E3E]",
      "[&_.date-time-field-wrapper>input]:placeholder:text-[#3E3E3E]",
      floating == "outer" && "[&_.date-time-field-wrapper_.floating-label]:bg-white"
    ]
  end

  defp color_variant("bordered", "natural", floating) do
    [
      "text-[#282828] dark:text-[#E8E8E8] [&_.date-time-field-wrapper:not(:has(.date-time-field-error))]:border-[#282828]",
      "[&_.date-time-field-wrapper:not(:has(.date-time-field-error))]:bg-[#F3F3F3]",
      "dark:[&_.date-time-field-wrapper:not(:has(.date-time-field-error))]:bg-[#4B4B4B]",
      "dark:[&_.date-time-field-wrapper:not(:has(.date-time-field-error))]:border-[#868686]",
      "[&_.date-time-field-wrapper.date-time-field-error]:bg-rose-700",
      "[&_.date-time-field-wrapper>input]:placeholder:text-[#282828] dark:[&_.date-time-field-wrapper>input]:placeholder:text-[#E8E8E8]",
      "focus-within:[&_.date-time-field-wrapper]:ring-[#4B4B4B] dark:focus-within:[&_.date-time-field-wrapper]:ring-[#DDDDDD]",
      floating == "outer" &&
        "[&_.date-time-field-wrapper_.floating-label]:bg-[#868686] dark:[&_.date-time-field-wrapper_.floating-label]:bg-[#A6A6A6]"
    ]
  end

  defp color_variant("bordered", "primary", floating) do
    [
      "text-[#016974] dark:text-[#77D5E3] [&_.date-time-field-wrapper:not(:has(.date-time-field-error))]:border-[#016974]",
      "[&_.date-time-field-wrapper:not(:has(.date-time-field-error))]:bg-[#E2F8FB]",
      "dark:[&_.date-time-field-wrapper:not(:has(.date-time-field-error))]:bg-[#4B4B4B]",
      "dark:[&_.date-time-field-wrapper:not(:has(.date-time-field-error))]:border-[#77D5E3]",
      "[&_.date-time-field-wrapper.date-time-field-error]:bg-rose-700",
      "[&_.date-time-field-wrapper>input]:placeholder:text-[#016974] dark:[&_.date-time-field-wrapper>input]:placeholder:text-[#77D5E3]",
      "focus-within:[&_.date-time-field-wrapper]:ring-[#007F8C] dark:focus-within:[&_.date-time-field-wrapper]:ring-[#01B8CA]",
      floating == "outer" &&
        "[&_.date-time-field-wrapper_.floating-label]:bg-[#868686] dark:[&_.date-time-field-wrapper_.floating-label]:bg-[#A6A6A6]"
    ]
  end

  defp color_variant("bordered", "secondary", floating) do
    [
      "text-[#175BCC] dark:text-[#A9C9FF] [&_.date-time-field-wrapper:not(:has(.date-time-field-error))]:border-[#175BCC]",
      "[&_.date-time-field-wrapper:not(:has(.date-time-field-error))]:bg-[#EFF4FE]",
      "dark:[&_.date-time-field-wrapper:not(:has(.date-time-field-error))]:bg-[#002661]",
      "dark:[&_.date-time-field-wrapper:not(:has(.date-time-field-error))]:border-[#A9C9FF]",
      "[&_.date-time-field-wrapper.date-time-field-error]:bg-rose-700",
      "[&_.date-time-field-wrapper>input]:placeholder:text-[#175BCC] dark:[&_.date-time-field-wrapper>input]:placeholder:text-[#A9C9FF]",
      "focus-within:[&_.date-time-field-wrapper]:ring-[#266EF1] dark:focus-within:[&_.date-time-field-wrapper]:ring-[#6DAAFB]",
      floating == "outer" &&
        "[&_.date-time-field-wrapper_.floating-label]:bg-[#868686] dark:[&_.date-time-field-wrapper_.floating-label]:bg-[#A6A6A6]"
    ]
  end

  defp color_variant("bordered", "success", floating) do
    [
      "text-[#166C3B] dark:text-[#7FD99A] [&_.date-time-field-wrapper:not(:has(.date-time-field-error))]:border-[#166C3B]",
      "[&_.date-time-field-wrapper:not(:has(.date-time-field-error))]:bg-[#EAF6ED]",
      "dark:[&_.date-time-field-wrapper:not(:has(.date-time-field-error))]:bg-[#002F14]",
      "dark:[&_.date-time-field-wrapper:not(:has(.date-time-field-error))]:border-[#7FD99A]",
      "[&_.date-time-field-wrapper.date-time-field-error]:bg-rose-700",
      "[&_.date-time-field-wrapper>input]:placeholder:text-[#166C3B] dark:[&_.date-time-field-wrapper>input]:placeholder:text-[#7FD99A]",
      "focus-within:[&_.date-time-field-wrapper]:ring-[#0E8345] dark:focus-within:[&_.date-time-field-wrapper]:ring-[#06C167]",
      floating == "outer" &&
        "[&_.date-time-field-wrapper_.floating-label]:bg-[#868686] dark:[&_.date-time-field-wrapper_.floating-label]:bg-[#A6A6A6]"
    ]
  end

  defp color_variant("bordered", "warning", floating) do
    [
      "text-[#976A01] dark:text-[#FDD067] [&_.date-time-field-wrapper:not(:has(.date-time-field-error))]:border-[#976A01]",
      "[&_.date-time-field-wrapper:not(:has(.date-time-field-error))]:bg-[#FFF7E6]",
      "dark:[&_.date-time-field-wrapper:not(:has(.date-time-field-error))]:bg-[#322300]",
      "dark:[&_.date-time-field-wrapper:not(:has(.date-time-field-error))]:border-[#FDD067]",
      "[&_.date-time-field-wrapper.date-time-field-error]:bg-rose-700",
      "[&_.date-time-field-wrapper>input]:placeholder:text-[#976A01] dark:[&_.date-time-field-wrapper>input]:placeholder:text-[#FDD067]",
      "focus-within:[&_.date-time-field-wrapper]:ring-[#CA8D01] dark:focus-within:[&_.date-time-field-wrapper]:ring-[#FDC034]",
      floating == "outer" &&
        "[&_.date-time-field-wrapper_.floating-label]:bg-[#868686] dark:[&_.date-time-field-wrapper_.floating-label]:bg-[#A6A6A6]"
    ]
  end

  defp color_variant("bordered", "danger", floating) do
    [
      "text-[#BB032A] dark:text-[#FFB2AB] [&_.date-time-field-wrapper:not(:has(.date-time-field-error))]:border-[#BB032A]",
      "[&_.date-time-field-wrapper:not(:has(.date-time-field-error))]:bg-[#FFF0EE]",
      "dark:[&_.date-time-field-wrapper:not(:has(.date-time-field-error))]:bg-[#221431]",
      "dark:[&_.date-time-field-wrapper:not(:has(.date-time-field-error))]:border-[#FFB2AB]",
      "[&_.date-time-field-wrapper.date-time-field-error]:bg-rose-700",
      "[&_.date-time-field-wrapper>input]:placeholder:text-[#BB032A] dark:[&_.date-time-field-wrapper>input]:placeholder:text-[#FFB2AB]",
      "focus-within:[&_.date-time-field-wrapper]:ring-[#DE1135] dark:focus-within:[&_.date-time-field-wrapper]:ring-[#FC7F79]",
      floating == "outer" &&
        "[&_.date-time-field-wrapper_.floating-label]:bg-[#868686] dark:[&_.date-time-field-wrapper_.floating-label]:bg-[#A6A6A6]"
    ]
  end

  defp color_variant("bordered", "info", floating) do
    [
      "text-[#0B84BA] dark:text-[#6EC9F2] [&_.date-time-field-wrapper:not(:has(.date-time-field-error))]:border-[#0B84BA]",
      "[&_.date-time-field-wrapper:not(:has(.date-time-field-error))]:bg-[#E7F6FD]",
      "dark:[&_.date-time-field-wrapper:not(:has(.date-time-field-error))]:bg-[#03212F]",
      "dark:[&_.date-time-field-wrapper:not(:has(.date-time-field-error))]:border-[#6EC9F2]",
      "[&_.date-time-field-wrapper.date-time-field-error]:bg-rose-700",
      "[&_.date-time-field-wrapper>input]:placeholder:text-[#0B84BA] dark:[&_.date-time-field-wrapper>input]:placeholder:text-[#6EC9F2]",
      "focus-within:[&_.date-time-field-wrapper]:ring-[#0B84BA] dark:focus-within:[&_.date-time-field-wrapper]:ring-[#3EB7ED]",
      floating == "outer" &&
        "[&_.date-time-field-wrapper_.floating-label]:bg-[#868686] dark:[&_.date-time-field-wrapper_.floating-label]:bg-[#A6A6A6]"
    ]
  end

  defp color_variant("bordered", "misc", floating) do
    [
      "text-[#653C94] dark:text-[#CBA2FA] [&_.date-time-field-wrapper:not(:has(.date-time-field-error))]:border-[#653C94]",
      "[&_.date-time-field-wrapper:not(:has(.date-time-field-error))]:bg-[#F6F0FE]",
      "dark:[&_.date-time-field-wrapper:not(:has(.date-time-field-error))]:bg-[#221431]",
      "dark:[&_.date-time-field-wrapper:not(:has(.date-time-field-error))]:border-[#CBA2FA]",
      "[&_.date-time-field-wrapper.date-time-field-error]:bg-rose-700",
      "[&_.date-time-field-wrapper>input]:placeholder:text-[#653C94] dark:[&_.date-time-field-wrapper>input]:placeholder:text-[#CBA2FA]",
      "focus-within:[&_.date-time-field-wrapper]:ring-[#8750C5] dark:focus-within:[&_.date-time-field-wrapper]:ring-[#BA83F9]",
      floating == "outer" &&
        "[&_.date-time-field-wrapper_.floating-label]:bg-[#868686] dark:[&_.date-time-field-wrapper_.floating-label]:bg-[#A6A6A6]"
    ]
  end

  defp color_variant("bordered", "dawn", floating) do
    [
      "text-[#7E4B2A] dark:text-[#E4B190] [&_.date-time-field-wrapper:not(:has(.date-time-field-error))]:border-[#7E4B2A]",
      "[&_.date-time-field-wrapper:not(:has(.date-time-field-error))]:bg-[#FBF2ED]",
      "dark:[&_.date-time-field-wrapper:not(:has(.date-time-field-error))]:bg-[#2A190E]",
      "dark:[&_.date-time-field-wrapper:not(:has(.date-time-field-error))]:border-[#E4B190]",
      "[&_.date-time-field-wrapper.date-time-field-error]:bg-rose-700",
      "[&_.date-time-field-wrapper>input]:placeholder:text-[#7E4B2A] dark:[&_.date-time-field-wrapper>input]:placeholder:text-[#E4B190]",
      "focus-within:[&_.date-time-field-wrapper]:ring-[#A86438] dark:focus-within:[&_.date-time-field-wrapper]:ring-[#DB976B]",
      floating == "outer" &&
        "[&_.date-time-field-wrapper_.floating-label]:bg-[#868686] dark:[&_.date-time-field-wrapper_.floating-label]:bg-[#A6A6A6]"
    ]
  end

  defp color_variant("bordered", "silver", floating) do
    [
      "text-[#727272] dark:text-[#BBBBBB] [&_.date-time-field-wrapper:not(:has(.date-time-field-error))]:border-[#727272]",
      "[&_.date-time-field-wrapper:not(:has(.date-time-field-error))]:bg-[#F3F3F3]",
      "dark:[&_.date-time-field-wrapper:not(:has(.date-time-field-error))]:bg-[#4B4B4B]",
      "dark:[&_.date-time-field-wrapper:not(:has(.date-time-field-error))]:border-[#BBBBBB]",
      "[&_.date-time-field-wrapper.date-time-field-error]:bg-rose-700",
      "[&_.date-time-field-wrapper>input]:placeholder:text-[#727272] dark:[&_.date-time-field-wrapper>input]:placeholder:text-[#BBBBBB]",
      "focus-within:[&_.date-time-field-wrapper]:ring-[#868686] dark:focus-within:[&_.date-time-field-wrapper]:ring-[#A6A6A6]",
      floating == "outer" &&
        "[&_.date-time-field-wrapper_.floating-label]:bg-[#868686] dark:[&_.date-time-field-wrapper_.floating-label]:bg-[#A6A6A6]"
    ]
  end

  defp color_variant("bordered", "dark", floating) do
    [
      "[&_.date-time-field-wrapper]:bg-[#282828] text-[#282828] [&_.date-time-field-wrapper]:border-[#727272] text-white",
      "[&_.date-time-field-wrapper>input]:placeholder:text-white focus-within:[&_.date-time-field-wrapper]:ring-[#727272]",
      floating == "outer" && "[&_.date-time-field-wrapper_.floating-label]:bg-[#282828]"
    ]
  end

  defp color_variant("shadow", "natural", floating) do
    [
      "text-black dark:text-white [&_.date-time-field-wrapper:not(:has(.date-time-field-error))]:bg-[#4B4B4B]",
      "dark:[&_.date-time-field-wrapper:not(:has(.date-time-field-error))]:bg-[#DDDDDD]",
      "[&_.date-time-field-wrapper.date-time-field-error]:bg-rose-700",
      "[&_.date-time-field-wrapper>input]:placeholder:text-white dark:[&_.date-time-field-wrapper>input]:placeholder:text-black",
      "[&_.date-time-field-wrapper>input]:text-white dark:[&_.date-time-field-wrapper>input]:text-black",
      "focus-within:[&_.date-time-field-wrapper]:ring-[#4B4B4B] dark:focus-within:[&_.date-time-field-wrapper]:ring-[#DDDDDD]",
      "[&_.date-time-field-wrapper]:shadow-[0px_4px_6px_-4px_rgba(134,134,134,0.5)] [&_.date-time-field-wrapper]:shadow-[0px_10px_15px_-3px_rgba(134,134,134,0.5)]",
      "dark:[&_.date-time-field-wrapper]:shadow-none",
      floating == "outer" &&
        "[&_.date-time-field-wrapper_.floating-label]:bg-[#4B4B4B] dark:[&_.date-time-field-wrapper_.floating-label]:bg-[#DDDDDD]"
    ]
  end

  defp color_variant("shadow", "primary", floating) do
    [
      "text-black dark:text-white [&_.date-time-field-wrapper:not(:has(.date-time-field-error))]:bg-[#007F8C]",
      "dark:[&_.date-time-field-wrapper:not(:has(.date-time-field-error))]:bg-[#01B8CA]",
      "[&_.date-time-field-wrapper.date-time-field-error]:bg-rose-700",
      "[&_.date-time-field-wrapper>input]:placeholder:text-white dark:[&_.date-time-field-wrapper>input]:placeholder:text-black",
      "[&_.date-time-field-wrapper>input]:text-white dark:[&_.date-time-field-wrapper>input]:text-black",
      "focus-within:[&_.date-time-field-wrapper]:ring-[#007F8C] dark:focus-within:[&_.date-time-field-wrapper]:ring-[#01B8CA]",
      "[&_.date-time-field-wrapper]:shadow-[0px_4px_6px_-4px_rgba(0,149,164,0.5)] [&_.date-time-field-wrapper]:shadow-[0px_10px_15px_-3px_rgba(0,149,164,0.5)]",
      "dark:[&_.date-time-field-wrapper]:shadow-none",
      floating == "outer" &&
        "[&_.date-time-field-wrapper_.floating-label]:bg-[#007F8C] dark:[&_.date-time-field-wrapper_.floating-label]:bg-[#01B8CA]"
    ]
  end

  defp color_variant("shadow", "secondary", floating) do
    [
      "text-black dark:text-white [&_.date-time-field-wrapper:not(:has(.date-time-field-error))]:bg-[#266EF1]",
      "dark:[&_.date-time-field-wrapper:not(:has(.date-time-field-error))]:bg-[#6DAAFB]",
      "[&_.date-time-field-wrapper.date-time-field-error]:bg-rose-700",
      "[&_.date-time-field-wrapper>input]:placeholder:text-white dark:[&_.date-time-field-wrapper>input]:placeholder:text-black",
      "[&_.date-time-field-wrapper>input]:text-white dark:[&_.date-time-field-wrapper>input]:text-black",
      "focus-within:[&_.date-time-field-wrapper]:ring-[#266EF1] dark:focus-within:[&_.date-time-field-wrapper]:ring-[#6DAAFB]",
      "[&_.date-time-field-wrapper]:shadow-[0px_4px_6px_-4px_rgba(6,139,238,0.5)] [&_.date-time-field-wrapper]:shadow-[0px_10px_15px_-3px_rgba(6,139,238,0.5)]",
      "dark:[&_.date-time-field-wrapper]:shadow-none",
      floating == "outer" &&
        "[&_.date-time-field-wrapper_.floating-label]:bg-[#266EF1] dark:[&_.date-time-field-wrapper_.floating-label]:bg-[#6DAAFB]"
    ]
  end

  defp color_variant("shadow", "success", floating) do
    [
      "text-black dark:text-white [&_.date-time-field-wrapper:not(:has(.date-time-field-error))]:bg-[#0E8345]",
      "dark:[&_.date-time-field-wrapper:not(:has(.date-time-field-error))]:bg-[#06C167]",
      "[&_.date-time-field-wrapper.date-time-field-error]:bg-rose-700",
      "[&_.date-time-field-wrapper>input]:placeholder:text-white dark:[&_.date-time-field-wrapper>input]:placeholder:text-black",
      "[&_.date-time-field-wrapper>input]:text-white dark:[&_.date-time-field-wrapper>input]:text-black",
      "focus-within:[&_.date-time-field-wrapper]:ring-[#0E8345] dark:focus-within:[&_.date-time-field-wrapper]:ring-[#06C167]",
      "[&_.date-time-field-wrapper]:shadow-[0px_4px_6px_-4px_rgba(0,154,81,0.5)] [&_.date-time-field-wrapper]:shadow-[0px_10px_15px_-3px_rgba(0,154,81,0.5)]",
      "dark:[&_.date-time-field-wrapper]:shadow-none",
      floating == "outer" &&
        "[&_.date-time-field-wrapper_.floating-label]:bg-[#0E8345] dark:[&_.date-time-field-wrapper_.floating-label]:bg-[#06C167]"
    ]
  end

  defp color_variant("shadow", "warning", floating) do
    [
      "text-black dark:text-white [&_.date-time-field-wrapper:not(:has(.date-time-field-error))]:bg-[#CA8D01]",
      "dark:[&_.date-time-field-wrapper:not(:has(.date-time-field-error))]:bg-[#FDC034]",
      "[&_.date-time-field-wrapper.date-time-field-error]:bg-rose-700",
      "[&_.date-time-field-wrapper>input]:placeholder:text-white dark:[&_.date-time-field-wrapper>input]:placeholder:text-black",
      "[&_.date-time-field-wrapper>input]:text-white dark:[&_.date-time-field-wrapper>input]:text-black",
      "focus-within:[&_.date-time-field-wrapper]:ring-[#CA8D01] dark:focus-within:[&_.date-time-field-wrapper]:ring-[#FDC034]",
      "[&_.date-time-field-wrapper]:shadow-[0px_4px_6px_-4px_rgba(252,176,1,0.5)] [&_.date-time-field-wrapper]:shadow-[0px_10px_15px_-3px_rgba(252,176,1,0.5)]",
      "dark:[&_.date-time-field-wrapper]:shadow-none",
      floating == "outer" &&
        "[&_.date-time-field-wrapper_.floating-label]:bg-[#CA8D01] dark:[&_.date-time-field-wrapper_.floating-label]:bg-[#FDC034]"
    ]
  end

  defp color_variant("shadow", "danger", floating) do
    [
      "text-black dark:text-white [&_.date-time-field-wrapper:not(:has(.date-time-field-error))]:bg-[#DE1135]",
      "dark:[&_.date-time-field-wrapper:not(:has(.date-time-field-error))]:bg-[#FC7F79]",
      "[&_.date-time-field-wrapper.date-time-field-error]:bg-rose-700",
      "[&_.date-time-field-wrapper>input]:placeholder:text-white dark:[&_.date-time-field-wrapper>input]:placeholder:text-black",
      "[&_.date-time-field-wrapper>input]:text-white dark:[&_.date-time-field-wrapper>input]:text-black",
      "focus-within:[&_.date-time-field-wrapper]:ring-[#DE1135] dark:focus-within:[&_.date-time-field-wrapper]:ring-[#FC7F79]",
      "[&_.date-time-field-wrapper]:shadow-[0px_4px_6px_-4px_rgba(248,52,70,0.5)] [&_.date-time-field-wrapper]:shadow-[0px_10px_15px_-3px_rgba(248,52,70,0.5)]",
      "dark:[&_.date-time-field-wrapper]:shadow-none",
      floating == "outer" &&
        "[&_.date-time-field-wrapper_.floating-label]:bg-[#DE1135] dark:[&_.date-time-field-wrapper_.floating-label]:bg-[#FC7F79]"
    ]
  end

  defp color_variant("shadow", "info", floating) do
    [
      "text-black dark:text-white [&_.date-time-field-wrapper:not(:has(.date-time-field-error))]:bg-[#0B84BA]",
      "dark:[&_.date-time-field-wrapper:not(:has(.date-time-field-error))]:bg-[#3EB7ED]",
      "[&_.date-time-field-wrapper.date-time-field-error]:bg-rose-700",
      "[&_.date-time-field-wrapper>input]:placeholder:text-white dark:[&_.date-time-field-wrapper>input]:placeholder:text-black",
      "[&_.date-time-field-wrapper>input]:text-white dark:[&_.date-time-field-wrapper>input]:text-black",
      "focus-within:[&_.date-time-field-wrapper]:ring-[#0B84BA] dark:focus-within:[&_.date-time-field-wrapper]:ring-[#3EB7ED]",
      "[&_.date-time-field-wrapper]:shadow-[0px_4px_6px_-4px_rgba(14,165,233,0.5)] [&_.date-time-field-wrapper]:shadow-[0px_10px_15px_-3px_rgba(14,165,233,0.5)]",
      "dark:[&_.date-time-field-wrapper]:shadow-none",
      floating == "outer" &&
        "[&_.date-time-field-wrapper_.floating-label]:bg-[#0B84BA] dark:[&_.date-time-field-wrapper_.floating-label]:bg-[#3EB7ED]"
    ]
  end

  defp color_variant("shadow", "misc", floating) do
    [
      "text-black dark:text-white [&_.date-time-field-wrapper:not(:has(.date-time-field-error))]:bg-[#8750C5]",
      "dark:[&_.date-time-field-wrapper:not(:has(.date-time-field-error))]:bg-[#BA83F9]",
      "[&_.date-time-field-wrapper.date-time-field-error]:bg-rose-700",
      "[&_.date-time-field-wrapper>input]:placeholder:text-white dark:[&_.date-time-field-wrapper>input]:placeholder:text-black",
      "[&_.date-time-field-wrapper>input]:text-white dark:[&_.date-time-field-wrapper>input]:text-black",
      "focus-within:[&_.date-time-field-wrapper]:ring-[#8750C5] dark:focus-within:[&_.date-time-field-wrapper]:ring-[#BA83F9]",
      "[&_.date-time-field-wrapper]:shadow-[0px_4px_6px_-4px_rgba(169,100,247,0.5)] [&_.date-time-field-wrapper]:shadow-[0px_10px_15px_-3px_rgba(169,100,247,0.5)]",
      "dark:[&_.date-time-field-wrapper]:shadow-none",
      floating == "outer" &&
        "[&_.date-time-field-wrapper_.floating-label]:bg-[#8750C5] dark:[&_.date-time-field-wrapper_.floating-label]:bg-[#BA83F9]"
    ]
  end

  defp color_variant("shadow", "dawn", floating) do
    [
      "text-black dark:text-white [&_.date-time-field-wrapper:not(:has(.date-time-field-error))]:bg-[#A86438]",
      "dark:[&_.date-time-field-wrapper:not(:has(.date-time-field-error))]:bg-[#DB976B]",
      "[&_.date-time-field-wrapper.date-time-field-error]:bg-rose-700",
      "[&_.date-time-field-wrapper>input]:placeholder:text-white dark:[&_.date-time-field-wrapper>input]:placeholder:text-black",
      "[&_.date-time-field-wrapper>input]:text-white dark:[&_.date-time-field-wrapper>input]:text-black",
      "focus-within:[&_.date-time-field-wrapper]:ring-[#A86438] dark:focus-within:[&_.date-time-field-wrapper]:ring-[#DB976B]",
      "[&_.date-time-field-wrapper]:shadow-[0px_4px_6px_-4px_rgba(210,125,70,0.5)] [&_.date-time-field-wrapper]:shadow-[0px_10px_15px_-3px_rgba(210,125,70,0.5)]",
      "dark:[&_.date-time-field-wrapper]:shadow-none",
      floating == "outer" &&
        "[&_.date-time-field-wrapper_.floating-label]:bg-[#A86438] dark:[&_.date-time-field-wrapper_.floating-label]:bg-[#DB976B]"
    ]
  end

  defp color_variant("shadow", "silver", floating) do
    [
      "text-black dark:text-white [&_.date-time-field-wrapper:not(:has(.date-time-field-error))]:bg-[#868686]",
      "dark:[&_.date-time-field-wrapper:not(:has(.date-time-field-error))]:bg-[#A6A6A6]",
      "[&_.date-time-field-wrapper.date-time-field-error]:bg-rose-700",
      "[&_.date-time-field-wrapper>input]:placeholder:text-white dark:[&_.date-time-field-wrapper>input]:placeholder:text-black",
      "[&_.date-time-field-wrapper>input]:text-white dark:[&_.date-time-field-wrapper>input]:text-black",
      "focus-within:[&_.date-time-field-wrapper]:ring-[#868686] dark:focus-within:[&_.date-time-field-wrapper]:ring-[#A6A6A6]",
      "[&_.date-time-field-wrapper]:shadow-[0px_4px_6px_-4px_rgba(134,134,134,0.5)] [&_.date-time-field-wrapper]:shadow-[0px_10px_15px_-3px_rgba(134,134,134,0.5)]",
      "dark:[&_.date-time-field-wrapper]:shadow-none",
      floating == "outer" &&
        "[&_.date-time-field-wrapper_.floating-label]:bg-[#868686] dark:[&_.date-time-field-wrapper_.floating-label]:bg-[#A6A6A6]"
    ]
  end

  defp color_variant("transparent", "natural", _) do
    [
      "text-[#4B4B4B] dark:text-[#DDDDDD]",
      "[&_.date-time-field-wrapper>input]:placeholder:text-[#4B4B4B]",
      "dark:[&_.date-time-field-wrapper>input]:placeholder:text-[#4363EC]",
      "focus-within:[&_.date-time-field-wrapper]:ring-transparent"
    ]
  end

  defp color_variant("transparent", "primary", _) do
    [
      "text-[#007F8C] dark:text-[#01B8CA]",
      "[&_.date-time-field-wrapper>input]:placeholder:text-[#007F8C]",
      "dark:[&_.date-time-field-wrapper>input]:placeholder:text-[#01B8CA]",
      "focus-within:[&_.date-time-field-wrapper]:ring-transparent"
    ]
  end

  defp color_variant("transparent", "secondary", _) do
    [
      "text-[#266EF1] dark:text-[#6DAAFB]",
      "[&_.date-time-field-wrapper>input]:placeholder:text-[#266EF1]",
      "dark:[&_.date-time-field-wrapper>input]:placeholder:text-[#6DAAFB]",
      "focus-within:[&_.date-time-field-wrapper]:ring-transparent"
    ]
  end

  defp color_variant("transparent", "success", _) do
    [
      "text-[#0E8345] dark:text-[#06C167]",
      "[&_.date-time-field-wrapper>input]:placeholder:text-[#0E8345]",
      "dark:[&_.date-time-field-wrapper>input]:placeholder:text-[#06C167]",
      "focus-within:[&_.date-time-field-wrapper]:ring-transparent"
    ]
  end

  defp color_variant("transparent", "warning", _) do
    [
      "text-[#CA8D01] dark:text-[#FDC034]",
      "[&_.date-time-field-wrapper>input]:placeholder:text-[#CA8D01]",
      "dark:[&_.date-time-field-wrapper>input]:placeholder:text-[#FDC034]",
      "focus-within:[&_.date-time-field-wrapper]:ring-transparent"
    ]
  end

  defp color_variant("transparent", "danger", _) do
    [
      "text-[#DE1135] dark:text-[#FC7F79]",
      "[&_.date-time-field-wrapper>input]:placeholder:text-[#DE1135]",
      "dark:[&_.date-time-field-wrapper>input]:placeholder:text-[#FC7F79]",
      "focus-within:[&_.date-time-field-wrapper]:ring-transparent"
    ]
  end

  defp color_variant("transparent", "info", _) do
    [
      "text-[#0B84BA] dark:text-[#3EB7ED]",
      "[&_.date-time-field-wrapper>input]:placeholder:text-[#0B84BA]",
      "dark:[&_.date-time-field-wrapper>input]:placeholder:text-[#3EB7ED]",
      "focus-within:[&_.date-time-field-wrapper]:ring-transparent"
    ]
  end

  defp color_variant("transparent", "misc", _) do
    [
      "text-[#8750C5] dark:text-[#BA83F9]",
      "[&_.date-time-field-wrapper>input]:placeholder:text-[#8750C5]",
      "dark:[&_.date-time-field-wrapper>input]:placeholder:text-[#BA83F9]",
      "focus-within:[&_.date-time-field-wrapper]:ring-transparent"
    ]
  end

  defp color_variant("transparent", "dawn", _) do
    [
      "text-[#A86438] dark:text-[#DB976B]",
      "[&_.date-time-field-wrapper>input]:placeholder:text-[#A86438]",
      "dark:[&_.date-time-field-wrapper>input]:placeholder:text-[#DB976B]",
      "focus-within:[&_.date-time-field-wrapper]:ring-transparent"
    ]
  end

  defp color_variant("transparent", "silver", _) do
    [
      "text-[#868686] dark:text-[#A6A6A6]",
      "[&_.date-time-field-wrapper>input]:placeholder:text-[#868686]",
      "dark:[&_.date-time-field-wrapper>input]:placeholder:text-[#A6A6A6]",
      "focus-within:[&_.date-time-field-wrapper]:ring-transparent"
    ]
  end

  defp color_variant(params, _, _) when is_binary(params), do: params

  defp color_variant(_, _, _), do: color_variant("outline", "natural", "none")

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