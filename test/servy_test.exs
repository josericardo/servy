defmodule ServyHandlerTest do
  use ExUnit.Case

  test "Parses a request" do
    request = """
    GET /wildthings HTTP/1.1
    Host: example.com
    User-Agent: ExampleBrowser/1.0
    Accept: */*

    """

    expected = %{
      method: "GET",
      resp_body:  "",
      path: "/wildthings",
      status: nil
    }

    assert Servy.Handler.parse(request) == expected
  end

  test "Handles redirections" do
    conv = %{
      method: "GET",
      resp_body:  "",
      path: "/wildlife",
      status: nil
    }

    assert Servy.Handler.rewrite_path(conv).path == "/wildthings"
  end
end
