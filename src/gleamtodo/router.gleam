import gleam/http
import gleamtodo/pages
import gleamtodo/pages/layout.{layout}
import gleamtodo/routes/item_routes.{items_middleware}
import gleamtodo/web.{type Context}
import lustre/element
import wisp.{type Request, type Response}

pub fn handle_request(req: Request, ctx: Context) -> Response {
  // Apply middleware.
  use _req <- web.middleware(req, ctx)
  use ctx <- items_middleware(req, ctx)

  // Handle routes.
  case wisp.path_segments(req) {
    // Homepage
    [] -> {
      [pages.home(ctx.items)]
      |> layout
      |> element.to_document_string_builder
      |> wisp.html_response(200)
    }
    ["items", "create"] -> {
      use <- wisp.require_method(req, http.Post)
      item_routes.post_create_item(req, ctx)
    }

    ["items", id] -> {
      use <- wisp.require_method(req, http.Delete)
      item_routes.delete_item(req, ctx, id)
    }

    // Empty responses
    ["internal-server-error"] -> wisp.internal_server_error()
    ["unprocessable-entity"] -> wisp.unprocessable_entity()
    ["method-not-allowed"] -> wisp.method_not_allowed([])
    ["entity-too-large"] -> wisp.entity_too_large()
    ["bad-request"] -> wisp.bad_request()
    _ -> wisp.not_found()
  }
}
