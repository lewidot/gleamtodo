import dot_env
import dot_env/env
import gleam/erlang/process
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

  let assert Ok(secret_base_key) = env.get_string("SECRET_BASE_KEY")

  // Start web server
  let assert Ok(_) = {
    wisp.mist_handler(fn(_) { todo }, secret_base_key)
    |> mist.new
    |> mist.port(8000)
    |> mist.start_http
  }

  process.sleep_forever()
}
