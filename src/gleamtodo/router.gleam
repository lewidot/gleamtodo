import gleam/string_builder
import gleamtodo/web.{type Context}
import wisp.{type Request, type Response}

pub fn handle_request(req: Request, ctx: Context) -> Response {
  // Apply middleware.
  use _req <- web.middleware(req, ctx)

  // Handle routes.
  case wisp.path_segments(req) {
    // Homepage
    [] -> wisp.html_response(string_builder.from_string("Home"), 200)

    // Empty responses
    ["internal-server-error"] -> wisp.internal_server_error()
    ["unprocessable-entity"] -> wisp.unprocessable_entity()
    ["method-not-allowed"] -> wisp.method_not_allowed([])
    ["entity-too-large"] -> wisp.entity_too_large()
    ["bad-request"] -> wisp.bad_request()
    _ -> wisp.not_found()
  }
}
