import gleam/option.{type Option}
import wisp

/// Union type for the status of the item.
pub type ItemStatus {
  Completed
  Uncompleted
}

/// Data model for the Item.
pub type Item {
  Item(id: String, title: String, status: ItemStatus)
}

/// Create a new Item.
pub fn create_item(id: Option(String), title: String, completed: Bool) -> Item {
  // Get the id or set a random id as a fallback
  let id = option.unwrap(id, wisp.random_string(64))

  case completed {
    True -> Item(id, title, status: Completed)
    False -> Item(id, title, status: Uncompleted)
  }
}

/// State machine for the Item status.
pub fn toggle_todo(item: Item) -> Item {
  let new_status = case item.status {
    Completed -> Uncompleted
    Uncompleted -> Completed
  }

  // Return a new Item with all original data and the new status
  Item(..item, status: new_status)
}

/// Cast ItemStatus to a Bool
pub fn item_status_to_bool(status: ItemStatus) -> Bool {
  case status {
    Completed -> True
    Uncompleted -> False
  }
}
