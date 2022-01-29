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

  test "Handles requests" do
    request = """
    GET /bears HTTP/1.1
    Host: example.com
    User-Agent: ExampleBrowser/1.0
    Accept: */*

    """

    expected = """
    HTTP/1.1 200 OK
    Content-Type: text/html
    Content-Length: 15

    😜 bear  😎
    """

    assert Servy.Handler.handle(request) == expected
  end

  test "Handles requests for individual bears" do
    request = """
    GET /bears/2 HTTP/1.1
    Host: example.com
    User-Agent: ExampleBrowser/1.0
    Accept: */*

    """
    response = Servy.Handler.handle(request)
    assert String.contains?(response, "bear /2")
  end
end
