defmodule ValentineWeb.WorkspaceLive.Evidence.ShowTest do
  use ValentineWeb.ConnCase

  import Phoenix.LiveViewTest
  import Valentine.ComposerFixtures

  describe "Evidence detail" do
    setup [:create_workspace]

    test "renders JSON evidence content", %{conn: conn, workspace: workspace} do
      evidence =
        evidence_fixture(%{
          workspace_id: workspace.id,
          name: "JSON Evidence",
          content: %{"document_type" => "OSCAL"}
        })

      conn = conn |> Phoenix.ConnTest.init_test_session(%{user_id: workspace.owner})
      {:ok, _view, html} = live(conn, ~p"/workspaces/#{workspace.id}/evidence/#{evidence.id}")

      assert html =~ "JSON Evidence"
      assert html =~ "document_type"
      assert html =~ "OSCAL"
    end

    test "renders blob store evidence content", %{conn: conn, workspace: workspace} do
      evidence =
        blob_evidence_fixture(%{
          workspace_id: workspace.id,
          name: "Blob Evidence",
          blob_store_url: "https://example.com/evidence.pdf"
        })

      conn = conn |> Phoenix.ConnTest.init_test_session(%{user_id: workspace.owner})
      {:ok, _view, html} = live(conn, ~p"/workspaces/#{workspace.id}/evidence/#{evidence.id}")

      assert html =~ "Blob Evidence"
      assert html =~ "https://example.com/evidence.pdf"
    end

    test "links and unlinks related entities", %{conn: conn, workspace: workspace} do
      evidence = evidence_fixture(%{workspace_id: workspace.id, name: "Linked Evidence"})
      assumption = assumption_fixture(%{workspace_id: workspace.id, content: "Assumption A"})
      threat = threat_fixture(%{workspace_id: workspace.id, threat_action: "Steal"})

      conn = conn |> Phoenix.ConnTest.init_test_session(%{user_id: workspace.owner})
      {:ok, view, _html} = live(conn, ~p"/workspaces/#{workspace.id}/evidence/#{evidence.id}")

      view
      |> element("input[name=\"assumptions-dropdown\"]")
      |> render_click()

      view
      |> element("div[phx-value-id=\"#{assumption.id}\"]")
      |> render_click()

      assert has_element?(view, "#linked-assumption-#{assumption.id}")

      view
      |> element("input[name=\"threats-dropdown\"]")
      |> render_click()

      view
      |> element("div[phx-value-id=\"#{threat.id}\"]")
      |> render_click()

      assert has_element?(view, "#linked-threat-#{threat.id}")

      view
      |> element("#linked-assumption-#{assumption.id}")
      |> render_click()

      refute has_element?(view, "#linked-assumption-#{assumption.id}")

      view
      |> element("#linked-threat-#{threat.id}")
      |> render_click()

      refute has_element?(view, "#linked-threat-#{threat.id}")
    end
  end

  defp create_workspace(_) do
    workspace = workspace_fixture()
    %{workspace: workspace}
  end
end
