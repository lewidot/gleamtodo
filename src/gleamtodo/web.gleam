/// Context type for sharing data across requests.
pub type Context {
  Context(static_directory: String, items: List(String))
}
