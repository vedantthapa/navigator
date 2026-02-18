defmodule ValentineWeb.WorkspaceLive.Evidence.FormTest do
  use ValentineWeb.ConnCase

  import Phoenix.LiveViewTest
  import Valentine.ComposerFixtures

  alias Valentine.Composer

  @create_attrs %{
    name: "UI Evidence",
    description: "Security evidence from UI",
    evidence_type: "json_data",
    json_content: ~s({"document_type":"OSCAL"}),
    tags: "ui, security",
    nist_controls: "AC-1, AU-12"
  }

  describe "Evidence form" do
    setup [:create_workspace]

    test "creates evidence from the form", %{conn: conn, workspace: workspace} do
      conn = conn |> Phoenix.ConnTest.init_test_session(%{user_id: workspace.owner})
      {:ok, view, _html} = live(conn, ~p"/workspaces/#{workspace.id}/evidence/new")

      view
      |> form("#evidence-form", evidence: Map.put(@create_attrs, :workspace_id, workspace.id))
      |> render_submit()

      [evidence] = Composer.list_evidence_by_workspace(workspace.id, %{})
      assert evidence.name == @create_attrs.name
      assert_redirect(view, ~p"/workspaces/#{workspace.id}/evidence/#{evidence.id}")
    end

    test "updates evidence from the form", %{conn: conn, workspace: workspace} do
      evidence = evidence_fixture(%{workspace_id: workspace.id, name: "Old name"})
      conn = conn |> Phoenix.ConnTest.init_test_session(%{user_id: workspace.owner})
      {:ok, view, html} = live(conn, ~p"/workspaces/#{workspace.id}/evidence/#{evidence.id}/edit")

      assert html =~ "Old name"

      update_attrs = %{
        name: "Updated evidence",
        description: evidence.description,
        evidence_type: "blob_store_link",
        blob_store_url: "https://example.com/updated.json",
        tags: "updated",
        nist_controls: "AC-1",
        workspace_id: workspace.id
      }

      view
      |> form("#evidence-form", evidence: update_attrs)
      |> render_submit()

      updated = Composer.get_evidence!(evidence.id)
      assert updated.name == "Updated evidence"
      assert_redirect(view, ~p"/workspaces/#{workspace.id}/evidence/#{updated.id}")
    end

    test "shows validation errors for invalid inputs", %{conn: conn, workspace: workspace} do
      conn = conn |> Phoenix.ConnTest.init_test_session(%{user_id: workspace.owner})
      {:ok, view, _html} = live(conn, ~p"/workspaces/#{workspace.id}/evidence/new")

      html =
        view
        |> form("#evidence-form", evidence: Map.put(@create_attrs, :json_content, "{"))
        |> render_change()

      assert html =~ "Invalid JSON"

      html =
        view
        |> form("#evidence-form", evidence: %{evidence_type: "json_data", workspace_id: workspace.id})
        |> render_submit()

      assert html =~ "can&#39;t be blank"
    end
  end

  defp create_workspace(_) do
    workspace = workspace_fixture()
    %{workspace: workspace}
  end
end
