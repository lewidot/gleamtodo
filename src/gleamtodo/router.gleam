import gleam/string_builder
import gleamtodo/web.{type Context}
import wisp.{type Request, type Response}

pub fn handle_request(req: Request, ctx: Context) -> Response {
  // Apply middleware.
  use _req <- web.middleware(req, ctx)

  wisp.html_response(string_builder.from_string("Hello World!"), 200)
}
