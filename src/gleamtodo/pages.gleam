import gleamtodo/models/item.{type Item}
import gleamtodo/pages/home

/// Render the Home page.
pub fn home(items: List(Item)) {
  home.root(items)
}
