import gleam/dynamic
import gleam/json
import gleam/list
import gleam/option.{Some}
import gleamtodo/models/item.{type Item, create_item}
import gleamtodo/web.{type Context, Context}
import wisp.{type Request, type Response}

/// Intermediate type for parsing JSON to an Item.
type ItemsJson {
  ItemsJson(id: String, title: String, completed: Bool)
}

/// Middleware to update context with the fetched todo items from cookies.
pub fn items_middleware(
  req: Request,
  ctx: Context,
  handle_request: fn(Context) -> Response,
) {
  let parsed_items = {
    case wisp.get_cookie(req, "items", wisp.PlainText) {
      Ok(json_string) -> {
        let decoder =
          dynamic.decode3(
            ItemsJson,
            dynamic.field("id", dynamic.string),
            dynamic.field("title", dynamic.string),
            dynamic.field("completed", dynamic.bool),
          )
          |> dynamic.list

        let result = json.decode(json_string, decoder)
        case result {
          Ok(items) -> items
          Error(_) -> []
        }
      }
      Error(_) -> []
    }
  }

  let items = create_items_from_json(parsed_items)

  let ctx = Context(..ctx, items: items)

  handle_request(ctx)
}

/// Cast ItemsJson to Item.
fn create_items_from_json(items: List(ItemsJson)) -> List(Item) {
  items
  |> list.map(fn(item) {
    let ItemsJson(id, title, completed) = item
    create_item(Some(id), title, completed)
  })
}
