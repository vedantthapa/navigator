defmodule ValentineWeb.WorkspaceLive.Evidence.Show do
  use ValentineWeb, :live_view
  use PrimerLive

  alias Valentine.Composer

  @impl true
  def mount(%{"workspace_id" => workspace_id} = _params, _session, socket) do
    workspace = get_workspace(workspace_id)
    ValentineWeb.Endpoint.subscribe("workspace_" <> workspace.id)

    {:ok,
     socket
     |> assign(:workspace_id, workspace_id)
     |> assign(:workspace, workspace)
     |> assign(:evidence, nil)
     |> assign(:json_content, "")}
  end

  @impl true
  def handle_params(%{"id" => id}, _url, socket) do
    evidence = Composer.get_evidence!(id, [:assumptions, :threats, :mitigations])

    {:noreply,
     socket
     |> assign(:page_title, evidence.name)
     |> assign(:evidence, evidence)
     |> assign(:json_content, format_json_content(evidence))}
  end

  @impl true
  def handle_info({"assumptions", :selected_item, selected_item}, socket) do
    assumption = Composer.get_assumption!(selected_item.id)

    case Composer.add_assumption_to_evidence(socket.assigns.evidence, assumption) do
      {:ok, evidence} -> {:noreply, reload_evidence(socket, evidence.id)}
      {:error, _} -> {:noreply, socket}
    end
  end

  @impl true
  def handle_info({"threats", :selected_item, selected_item}, socket) do
    threat = Composer.get_threat!(selected_item.id)

    case Composer.add_threat_to_evidence(socket.assigns.evidence, threat) do
      {:ok, evidence} -> {:noreply, reload_evidence(socket, evidence.id)}
      {:error, _} -> {:noreply, socket}
    end
  end

  @impl true
  def handle_info({"mitigations", :selected_item, selected_item}, socket) do
    mitigation = Composer.get_mitigation!(selected_item.id)

    case Composer.add_mitigation_to_evidence(socket.assigns.evidence, mitigation) do
      {:ok, evidence} -> {:noreply, reload_evidence(socket, evidence.id)}
      {:error, _} -> {:noreply, socket}
    end
  end

  @impl true
  def handle_event("unlink_assumption", %{"id" => id}, socket) do
    assumption = Composer.get_assumption!(id)

    case Composer.remove_assumption_from_evidence(socket.assigns.evidence, assumption) do
      {:ok, evidence} -> {:noreply, reload_evidence(socket, evidence.id)}
      {:error, _} -> {:noreply, socket}
    end
  end

  @impl true
  def handle_event("unlink_threat", %{"id" => id}, socket) do
    threat = Composer.get_threat!(id)

    case Composer.remove_threat_from_evidence(socket.assigns.evidence, threat) do
      {:ok, evidence} -> {:noreply, reload_evidence(socket, evidence.id)}
      {:error, _} -> {:noreply, socket}
    end
  end

  @impl true
  def handle_event("unlink_mitigation", %{"id" => id}, socket) do
    mitigation = Composer.get_mitigation!(id)

    case Composer.remove_mitigation_from_evidence(socket.assigns.evidence, mitigation) do
      {:ok, evidence} -> {:noreply, reload_evidence(socket, evidence.id)}
      {:error, _} -> {:noreply, socket}
    end
  end

  defp reload_evidence(socket, evidence_id) do
    evidence = Composer.get_evidence!(evidence_id, [:assumptions, :threats, :mitigations])

    socket
    |> assign(:evidence, evidence)
    |> assign(:json_content, format_json_content(evidence))
  end

  defp format_json_content(%{evidence_type: :json_data, content: content}) when is_map(content) do
    Jason.encode!(content, pretty: true)
  end

  defp format_json_content(_), do: ""

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
