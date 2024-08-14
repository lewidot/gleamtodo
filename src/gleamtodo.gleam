import dot_env
import dot_env/env
import gleam/erlang/process
import gleamtodo/router
import gleamtodo/web.{Context}
import mist
import wisp

pub fn main() {
  // Logging
  wisp.configure_logger()

  // Environment variables
  dot_env.new()
  |> dot_env.set_path(".env")
  |> dot_env.set_debug(True)
  |> dot_env.load

  let assert Ok(secret_key_base) = env.get_string("SECRET_KEY_BASE")

  // Context
  let ctx = Context(static_directory: static_directory(), items: [])

  // Router
  let handler = router.handle_request(_, ctx)

  // Start web server
  let assert Ok(_) = {
    wisp.mist_handler(handler, secret_key_base)
    |> mist.new
    |> mist.port(8000)
    |> mist.start_http
  }

  process.sleep_forever()
}

/// Secure path for the static file directory
fn static_directory() {
  let assert Ok(priv_directory) = wisp.priv_directory("gleamtodo")
  priv_directory <> "/static"
}
