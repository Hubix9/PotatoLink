# This code basically starts all the dependencies of the app without starting the app itself
# source: https://virviil.github.io/2016/10/26/elixir-testing-without-starting-supervision-tree/

Application.load(:potatolink)

for app <- Application.spec(:potatolink,:applications) do
  Application.ensure_all_started(app)
end

ExUnit.start()
