defmodule Servy.Handler do
  def handle(request) do
    request
    |> parse
    |> rewrite_path
    |> route
    |> track
    |> emojify
    |> format_response
  end

  def parse(request) do
    [method, path, _] =
      request
      |> String.split("\n")
      |> List.first()
      |> String.split(" ")

    %{method: method, status: nil, path: path, resp_body: ""}
  end

  def emojify(conv) do
    %{conv | resp_body: "😜 #{conv[:resp_body]} 😎"}
  end

  def rewrite_path(%{path: "/wildlife"} = conv) do
    %{conv | path: "/wildthings"}
  end

  def rewrite_path(%{path: "/bears?id=" <> bear_id} = conv) do
    %{conv | path: "/bears/#{bear_id}"}
  end

  def rewrite_path(conv), do: conv

  def track(%{status: 404} = conv) do
    IO.puts("404 for #{conv.path}")
    conv
  end

  def track(conv), do: conv

  def route(%{method: "DELETE", path: "/bears/" <> _id} = conv) do
    %{conv | status: 403, resp_body: "Deleting a bear is forbidden!"}
  end

  def route(conv) do
    route(conv, conv.method, conv.path)
  end

  def route(conv, "GET", "/bears" <> id) do
    %{conv | status: 200, resp_body: "bear #{id}"}
  end

  def route(conv, "GET", "/bears") do
    %{conv | status: 200, resp_body: "Teddy, Paddington"}
  end

  def route(conv, "GET", "/bigfoot") do
    %{conv | status: 200, resp_body: "roooarrr"}
  end

  def route(conv, "GET", "/wildthings") do
    %{conv | status: 200, resp_body: "Bears, Lions, Tigers"}
  end

  def route(conv, "GET", "/pages/" <> page_name) do
    {status, content} =
      Path.expand("../../pages/", __DIR__)
      |> Path.join("#{page_name}.html")
      |> File.read()
      |> handle_file_read

    %{conv | status: status, resp_body: content}
  end

  def route(conv, _method, path) do
    %{conv | status: 404, resp_body: "No #{path} here!"}
  end

  def handle_file_read({:ok, content}) do
    {200, content}
  end

  def handle_file_read({:error, :enoent}) do
    {404, "File not found"}
  end

  def handle_file_read({:error, reason}) do
    # how to test this?
    {500, "File error: #{reason}"}
  end

  def format_response(conv) do
    """
    HTTP/1.1 #{conv.status} #{status_msg(conv.status)}
    Content-Type: text/html
    Content-Length: #{byte_size(conv.resp_body)}

    #{conv.resp_body}
    """
  end

  defp status_msg(status_code) do
    %{
      200 => "OK",
      404 => "NOT FOUND"
    }[status_code]
  end
end
