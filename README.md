# Indiana

Indiana is a plugin for Elixir and Phoenix apps that reports response times to New Relic since they haven't released an Elixir SDK yet.

## Installation

[Available in Hex](https://hex.pm/packages/indiana), the package can be installed as:

  1. Add `indiana` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:indiana, "~> 0.1.2"}]
    end
    ```

  2. Ensure `indiana` is started before your application:

    ```elixir
    def application do
      [applications: [:indiana]]
    end
    ```

## Usage

First make sure that you have the environment setup properly. Indiana needs several env vars to work.

```elixir
# config
config :indiana,
  new_relic_license_key: "some-key",
  app_name: "my-awesome-app"
  # by default, Indiana always sends to new relic so to turn it off in dev.exs or test.exs
  send_to_new_relic: "false"
```

Indiana is designed to work with Phoenix applications first and foremost so to get started add it to your endpoint.

```elixir
# lib/my_awesome_app/endpoint.ex
defmodule MyAwesomeApp.Endpoint do
  use Phoenix.Endpoint, otp_app: :my_awesome_app

  plug Indiana.Integrations.Phoenix
end
```

If you are using Ecto and want to add query time to your stats, add it to your Repo.

```elixir
# lib/my_awesome_app/repo.ex
defmodule MyAwesomeApp.Repo do
  use Ecto.Repo, otp_app: :my_awesome_app
  use Indiana.Integrations.Ecto
end
```

That's it! Stats will show up under the plugin tabs in your New Relic under indiana. You'll need to customize the data in a way that makes sense for you.


### Roadmap

Things that need to be added for this library to be most useful:

  1. Find a way to get response times for external calls
  2. stuff I haven't thought of yet

### Contributing

New Relic is a powerful and complex tool. I need help if we are going to make this work. I started this project in an effort to learn Elixir so I'm sure there are many improvements in the existing codebase that can be made. There are probably bugs and generally bad Elixir patterns. Feel free to submit issues, fork, or submit pull requests for anything you think can be improved.

### License

This software is licensed under [the MIT license](LICENSE.md).
