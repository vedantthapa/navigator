defmodule ValentineWeb.WorkspaceLive.Evidence.Form do
  use ValentineWeb, :live_view
  use PrimerLive

  alias Valentine.Composer
  alias Valentine.Composer.Evidence

  @impl true
  def mount(%{"workspace_id" => workspace_id} = _params, _session, socket) do
    workspace = get_workspace(workspace_id)
    ValentineWeb.Endpoint.subscribe("workspace_" <> workspace.id)

    {:ok,
     socket
     |> assign(:workspace_id, workspace_id)
     |> assign(:workspace, workspace)
     |> assign(:changeset, nil)
     |> assign(:json_text, "")
     |> assign(:json_error, nil)
     |> assign(:tags_text, "")
     |> assign(:nist_controls_text, "")
     |> assign(:selected_type, :json_data)
     |> assign(:selected_assumption, nil)
     |> assign(:selected_threat, nil)
     |> assign(:selected_mitigation, nil)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :new, _params) do
    evidence = %Evidence{workspace_id: socket.assigns.workspace_id}
    selected_type = evidence.evidence_type || :json_data

    socket
    |> assign(:page_title, gettext("New Evidence"))
    |> assign(:evidence, evidence)
    |> assign(:selected_type, selected_type)
    |> assign(:changeset, Composer.change_evidence(evidence, %{evidence_type: selected_type}))
    |> assign(:json_text, "")
    |> assign(:json_error, nil)
    |> assign(:tags_text, "")
    |> assign(:nist_controls_text, "")
    |> assign(:selected_assumption, nil)
    |> assign(:selected_threat, nil)
    |> assign(:selected_mitigation, nil)
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    evidence = Composer.get_evidence!(id, [:assumptions, :threats, :mitigations])
    selected_type = evidence.evidence_type || :json_data

    socket
    |> assign(:page_title, gettext("Edit Evidence"))
    |> assign(:evidence, evidence)
    |> assign(:selected_type, selected_type)
    |> assign(:changeset, Composer.change_evidence(evidence))
    |> assign(:json_text, format_json_content(evidence.content))
    |> assign(:json_error, nil)
    |> assign(:tags_text, Enum.join(evidence.tags || [], ", "))
    |> assign(:nist_controls_text, Enum.join(evidence.nist_controls || [], ", "))
    |> assign(:selected_assumption, nil)
    |> assign(:selected_threat, nil)
    |> assign(:selected_mitigation, nil)
  end

  @impl true
  def handle_event("validate", %{"evidence" => evidence_params}, socket) do
    {params, assigns} = normalize_params(evidence_params, socket)

    changeset =
      socket.assigns.evidence
      |> Composer.change_evidence(params)
      |> Map.put(:action, :validate)

    {:noreply,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("save", %{"evidence" => evidence_params}, socket) do
    {params, assigns} = normalize_params(evidence_params, socket)

    if assigns.json_error do
      changeset =
        socket.assigns.evidence
        |> Composer.change_evidence(params)
        |> Map.put(:action, :validate)

      {:noreply,
       socket
       |> assign(assigns)
       |> assign(:changeset, changeset)}
    else
      socket
      |> assign(assigns)
      |> save_evidence(socket.assigns.live_action, params)
    end
  end

  @impl true
  def handle_info({"assumptions", :selected_item, selected_item}, socket) do
    {:noreply, assign(socket, :selected_assumption, selected_item)}
  end

  @impl true
  def handle_info({"threats", :selected_item, selected_item}, socket) do
    {:noreply, assign(socket, :selected_threat, selected_item)}
  end

  @impl true
  def handle_info({"mitigations", :selected_item, selected_item}, socket) do
    {:noreply, assign(socket, :selected_mitigation, selected_item)}
  end

  defp save_evidence(socket, :new, params) do
    case Composer.create_evidence_with_linking(params, build_linking_opts(socket)) do
      {:ok, evidence} ->
        log(
          :info,
          socket.assigns.current_user,
          "create",
          %{evidence: evidence.id, workspace: evidence.workspace_id},
          "evidence"
        )

        {:noreply,
         socket
         |> put_flash(:info, gettext("Evidence created successfully"))
         |> push_navigate(to: ~p"/workspaces/#{evidence.workspace_id}/evidence/#{evidence.id}")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_evidence(socket, :edit, params) do
    case Composer.update_evidence(socket.assigns.evidence, params) do
      {:ok, evidence} ->
        evidence = maybe_apply_linking(evidence, build_linking_opts(socket))

        log(
          :info,
          socket.assigns.current_user,
          "update",
          %{evidence: evidence.id, workspace: evidence.workspace_id},
          "evidence"
        )

        {:noreply,
         socket
         |> put_flash(:info, gettext("Evidence updated successfully"))
         |> push_navigate(to: ~p"/workspaces/#{evidence.workspace_id}/evidence/#{evidence.id}")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_evidence(socket, _action, _params), do: {:noreply, socket}

  defp build_linking_opts(socket) do
    %{}
    |> maybe_put_link(:assumption_id, socket.assigns.selected_assumption)
    |> maybe_put_link(:threat_id, socket.assigns.selected_threat)
    |> maybe_put_link(:mitigation_id, socket.assigns.selected_mitigation)
  end

  defp maybe_put_link(opts, _key, nil), do: opts

  defp maybe_put_link(opts, key, %{id: id}) when is_binary(id) do
    Map.put(opts, key, id)
  end

  defp maybe_apply_linking(evidence, linking_opts) do
    if map_size(linking_opts) == 0 do
      evidence
    else
      Composer.apply_evidence_linking(evidence, linking_opts)
    end
  end

  defp normalize_params(params, socket) do
    tags_text = fetch_param(params, "tags") || ""
    nist_controls_text = fetch_param(params, "nist_controls") || ""
    json_text = fetch_param(params, "json_content") || ""
    selected_type =
      parse_evidence_type(fetch_param(params, "evidence_type")) || socket.assigns.selected_type
    {content, json_error} = parse_json_content(selected_type, json_text)

    parsed_params =
      params
      |> Map.put("tags", parse_list(tags_text))
      |> Map.put("nist_controls", parse_list(nist_controls_text))
      |> Map.put("content", content)
      |> Map.delete("json_content")

    {
      parsed_params,
      %{
        json_text: json_text,
        json_error: json_error,
        tags_text: tags_text,
        nist_controls_text: nist_controls_text,
        selected_type: selected_type
      }
    }
  end

  defp fetch_param(params, "tags"), do: Map.get(params, "tags") || Map.get(params, :tags)
  defp fetch_param(params, "nist_controls"),
    do: Map.get(params, "nist_controls") || Map.get(params, :nist_controls)

  defp fetch_param(params, "json_content"),
    do: Map.get(params, "json_content") || Map.get(params, :json_content)

  defp fetch_param(params, "evidence_type"),
    do: Map.get(params, "evidence_type") || Map.get(params, :evidence_type)

  defp fetch_param(params, key) when is_map(params) and is_binary(key), do: Map.get(params, key)

  defp parse_list(value) when is_binary(value) do
    value
    |> String.split(",")
    |> Enum.map(&String.trim/1)
    |> Enum.reject(&(&1 == ""))
  end

  defp parse_list(_), do: []

  defp parse_evidence_type(nil), do: nil
  defp parse_evidence_type(""), do: nil

  defp parse_evidence_type(type) when is_binary(type) do
    case type do
      "json_data" -> :json_data
      "blob_store_link" -> :blob_store_link
      _ -> nil
    end
  end

  defp parse_evidence_type(type) when is_atom(type), do: type

  defp parse_json_content(:json_data, json_text) when is_binary(json_text) do
    trimmed = String.trim(json_text)

    if trimmed == "" do
      {nil, nil}
    else
      case Jason.decode(trimmed) do
        {:ok, decoded} when is_map(decoded) -> {decoded, nil}
        {:ok, _} -> {nil, gettext("JSON content must be an object")}
        {:error, _} -> {nil, gettext("Invalid JSON")}
      end
    end
  end

  defp parse_json_content(_type, _json_text), do: {nil, nil}

  defp format_json_content(nil), do: ""

  defp format_json_content(content) do
    Jason.encode!(content, pretty: true)
  end

  defp format_evidence_type(:json_data), do: gettext("JSON Data")
  defp format_evidence_type(:blob_store_link), do: gettext("Blob Store Link")

  defp format_evidence_type(type) do
    type
    |> Atom.to_string()
    |> String.replace("_", " ")
    |> String.capitalize()
  end

  defp get_workspace(id) do
    Composer.get_workspace!(id, [:assumptions, :threats, :mitigations])
  end
end
