## The contents of this file are subject to the Mozilla Public License
## Version 1.1 (the "License"); you may not use this file except in
## compliance with the License. You may obtain a copy of the License
## at http://www.mozilla.org/MPL/
##
## Software distributed under the License is distributed on an "AS IS"
## basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See
## the License for the specific language governing rights and
## limitations under the License.
##
## The Original Code is RabbitMQ.
##
## The Initial Developer of the Original Code is GoPivotal, Inc.
## Copyright (c) 2007-2018 Pivotal Software, Inc.  All rights reserved.

defmodule RabbitMQ.CLI.Ctl.Commands.SetLogLevelCommand do
  alias RabbitMQ.CLI.Core.Helpers

  @behaviour RabbitMQ.CLI.CommandBehaviour
  @known_levels ["debug", "info", "notice", "warning", "error", "critical", "alert", "emergency", "none"]

  def merge_defaults(args, opts), do: {args, opts}

  def validate([], _), do: {:validation_failure, :not_enough_args}
  def validate([_|_] = args, _) when length(args) > 1, do: {:validation_failure, :too_many_args}
  def validate([level], _) do
    case Enum.member?(@known_levels, level) do
      true  -> :ok
      false -> {:error, "level #{level} is not supported. Try one of debug, info, warning, error, none"}
    end
  end

  use RabbitMQ.CLI.Core.RequiresRabbitAppRunning

  def run([log_level], %{node: node_name}) do
    arg = String.to_atom(log_level)
    :rabbit_misc.rpc_call(node_name, :rabbit_lager, :set_log_level, [arg])
  end

  def usage, do: "set_log_level <log_level>"

  def banner([log_level], _), do: "Setting log level to \"#{log_level}\" ..."

  def output({:error, {:invalid_log_level, level}}, _opts) do
    {:error, RabbitMQ.CLI.Core.ExitCodes.exit_software,
     "level #{level} is not supported. Try one of debug, info, warning, error, none"}
  end
  use RabbitMQ.CLI.DefaultOutput
end
