# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

# This configuration is loaded before any dependency and is restricted
# to this project. If another project depends on this project, this
# file won't be loaded nor affect the parent project. For this reason,
# if you want to provide default values for your application for
# 3rd-party users, it should be done in your "mix.exs" file.

# You can configure for your application as:
#
#     config :indiana, key: :value
#
# And access this configuration in your application as:
#
#     Application.get_env(:indiana, :key)
#
# Or configure a 3rd-party app:
#
#     config :logger, level: :info
#

# It is also possible to import configuration files, relative to this
# directory. For example, you can emulate configuration per environment
# by uncommenting the line below and defining dev.exs, test.exs and such.
# Configuration from the imported file will override the ones defined
# here (which is why it is important to import them last).
#
#     import_config "#{Mix.env}.exs"

app_name         = :my_awesome_webapp
polling_interval = 1_000
histogram_stats  = ~w(min max mean 95 90)a
memory_stats     = ~w(atom binary ets processes total)a

config :exometer,
  predefined:
    [
      {
        ~w(erlang memory)a,
        {:function, :erlang, :memory, [], :proplist, memory_stats},
        []
      },
      {
        ~w(erlang statistics)a,
        {:function, :erlang, :statistics, [:'$dp'], :value, [:run_queue]},
        []
      },
      {
        [app_name, :ecto, :query_exec_time],
        :histogram,
        [truncate: :false]
      },
      {
        [app_name, :ecto, :query_queue_time],
        :histogram,
        [truncate: :false]
      },

      {
        [app_name, :ecto, :query_count],
        :spiral,
        []
      },
      {
        [app_name, :webapp, :resp_time],
        :histogram,
        [truncate: false]
      },
      {
        [app_name, :webapp, :resp_count],
        :spiral,
        []
      },
    ],

  reporters:
    [
      exometer_report_statsd:
      [
        hostname: 'localhost',
        port: 8125
      ],
    ],

  report: [
    subscribers:
      [
        {
          :exometer_report_statsd,
          [app_name, :webapp, :resp_time], histogram_stats, polling_interval, true
        },
        {
          :exometer_report_statsd,
          [app_name, :ecto, :query_exec_time], histogram_stats, polling_interval, true
        },
        {
          :exometer_report_statsd,
          [:erlang, :memory], memory_stats, polling_interval, true
        },
        {
          :exometer_report_statsd,
          [app_name, :webapp, :resp_count], :one, polling_interval, true
        },
        {
          :exometer_report_statsd,
          [app_name, :ecto, :query_count], :one, polling_interval, true
        },
        {
          :exometer_report_statsd,
          [:erlang, :statistics], :run_queue, polling_interval, true
        },
      ]
  ]
