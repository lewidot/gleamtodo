import gleam/bool
import gleam/string_builder
import gleamtodo/models/item.{type Item}
import wisp

/// Context type for sharing data across requests.
pub type Context {
  Context(static_directory: String, items: List(Item))
}

/// Global middleware handler.
pub fn middleware(
  req: wisp.Request,
  ctx: Context,
  handle_request: fn(wisp.Request) -> wisp.Response,
) -> wisp.Response {
  let req = wisp.method_override(req)
  use <- wisp.serve_static(req, under: "/static", from: ctx.static_directory)
  use <- wisp.log_request(req)
  use <- wisp.rescue_crashes
  use req <- wisp.handle_head(req)

  use <- default_responses

  handle_request(req)
}

/// Default response middleware.
pub fn default_responses(handle_request: fn() -> wisp.Response) -> wisp.Response {
  let response = handle_request()

  // If the response body is not empty, return early
  use <- bool.guard(when: response.body != wisp.Empty, return: response)

  case response.status {
    404 | 405 ->
      "<h1>Not Found</h1>"
      |> string_builder.from_string
      |> wisp.html_body(response, _)

    400 | 422 ->
      "<h1>Bad Request</h1>"
      |> string_builder.from_string
      |> wisp.html_body(response, _)
    413 ->
      "<h1>Request entity too large</h1>"
      |> string_builder.from_string
      |> wisp.html_body(response, _)
    500 ->
      "<h1>Internal Server Error</h1>"
      |> string_builder.from_string
      |> wisp.html_body(response, _)

    _ -> response
  }
}
