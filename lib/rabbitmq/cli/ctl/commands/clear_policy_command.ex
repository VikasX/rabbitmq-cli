## The contents of this file are subject to the Mozilla Public License
## Version 1.1 (the "License"); you may not use this file except in
## compliance with the License. You may obtain a copy of the License
## at https://www.mozilla.org/MPL/
##
## Software distributed under the License is distributed on an "AS IS"
## basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See
## the License for the specific language governing rights and
## limitations under the License.
##
## The Original Code is RabbitMQ.
##
## The Initial Developer of the Original Code is GoPivotal, Inc.
## Copyright (c) 2007-2020 Pivotal Software, Inc.  All rights reserved.

defmodule RabbitMQ.CLI.Ctl.Commands.ClearPolicyCommand do
  alias RabbitMQ.CLI.Core.{Helpers, DocGuide}

  @behaviour RabbitMQ.CLI.CommandBehaviour
  use RabbitMQ.CLI.DefaultOutput

  def merge_defaults(args, opts) do
    {args, Map.merge(%{vhost: "/"}, opts)}
  end

  use RabbitMQ.CLI.Core.AcceptsOnePositionalArgument
  use RabbitMQ.CLI.Core.RequiresRabbitAppRunning

  def run([key], %{node: node_name, vhost: vhost}) do
    :rabbit_misc.rpc_call(node_name, :rabbit_policy, :delete, [
      vhost,
      key,
      Helpers.cli_acting_user()
    ])
  end

  def usage, do: "clear_policy [--vhost <vhost>] <name>"

  def usage_additional() do
    [
      ["<name>", "Name of policy to clear (remove)"]
    ]
  end

  def usage_doc_guides() do
    [
      DocGuide.parameters()
    ]
  end

  def help_section(), do: :policies

  def description(), do: "Clears (removes) a policy"

  def banner([key], %{vhost: vhost}) do
    "Clearing policy \"#{key}\" on vhost \"#{vhost}\" ..."
  end
end
