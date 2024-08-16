import gleam/dynamic
import gleam/json
import gleam/list
import gleam/option.{None, Some}
import gleam/result
import gleam/string
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

/// Handler function for creating todo items.
///
/// /items/create
pub fn post_create_item(req: Request, ctx: Context) {
  use form <- wisp.require_form(req)

  let current_items = ctx.items

  let result = {
    use item_title <- result.try(list.key_find(form.values, "todo_title"))
    let new_item = create_item(None, item_title, False)
    list.append(current_items, [new_item])
    |> todos_to_json
    |> Ok
  }

  case result {
    Ok(todos) ->
      wisp.redirect("/")
      |> wisp.set_cookie(req, "items", todos, wisp.PlainText, 60 * 60 * 24)

    Error(_) -> {
      wisp.bad_request()
    }
  }
}

/// Cast list of todo Item to a Json string.
fn todos_to_json(items: List(Item)) -> String {
  "["
  <> items
  |> list.map(item_to_json)
  |> string.join(",")
  <> "]"
}

/// Cast a todo Item to a Json string.
fn item_to_json(item: Item) -> String {
  json.object([
    #("id", json.string(item.id)),
    #("title", json.string(item.title)),
    #("completed", json.bool(item.item_status_to_bool(item.status))),
  ])
  |> json.to_string
}
