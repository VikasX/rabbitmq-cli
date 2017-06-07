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
## Copyright (c) 2007-2017 Pivotal Software, Inc.  All rights reserved.


defmodule ListVhostLimitsCommandTest do
  use ExUnit.Case, async: false
  import TestHelper

  @command RabbitMQ.CLI.Ctl.Commands.ListVhostLimitsCommand

  @vhost "test_vhost"
  @vhost1 "test_vhost1"
  @definition "{\"max-connections\":100}"
  @definition1 "{\"max-queues\":1000}"

  setup_all do
    RabbitMQ.CLI.Core.Distribution.start()


    add_vhost @vhost

    on_exit([], fn ->
      delete_vhost @vhost

    end)

    :ok
  end

  setup context do

    vhost = context[:vhost] || @vhost

    clear_vhost_limits(vhost)

    on_exit(context, fn ->
      clear_vhost_limits(vhost)
    end)

    {
      :ok,
      opts: %{
        node: get_rabbit_hostname()
      },
      vhost: vhost
    }
  end

  test "merge_defaults: does not change defined vhost" do
    assert match?({[], %{vhost: "test_vhost"}}, @command.merge_defaults([], %{vhost: "test_vhost"}))
  end

  test "validate: providing arguments fails validation" do
    assert @command.validate(["many"], %{}) == {:validation_failure, :too_many_args}
    assert @command.validate(["too", "many"], %{}) == {:validation_failure, :too_many_args}
    assert @command.validate(["is", "too", "many"], %{}) == {:validation_failure, :too_many_args}
    assert @command.validate(["this", "is", "too", "many"], %{}) == {:validation_failure, :too_many_args}
  end

  test "run: a well-formed command returns an empty list if there are no limits", context do
    assert @command.run([], context[:opts]) == []
  end

  test "run: a well-formed vhost specific command returns an empty list if there are no limits", context do
    vhost_opts = Map.put(context[:opts], :vhost, @vhost)
    assert @command.run([], vhost_opts) == []
  end

  test "run: list limits for all vhosts", context do
    add_vhost(@vhost1)
    on_exit(fn() ->
      delete_vhost(@vhost1)
    end)
    set_vhost_limits(@vhost, @definition)
    set_vhost_limits(@vhost1, @definition1)

    {:ok, defs} = JSON.decode(@definition)
    {:ok, defs1} = JSON.decode(@definition1)
    assert Enum.sort(@command.run([], context[:opts])) ==
           Enum.sort([{@vhost, Map.to_list(defs)}, {@vhost1, Map.to_list(defs1)}])
  end

  test "run: list limits for a single vhost", context do
    vhost_opts = Map.put(context[:opts], :vhost, @vhost)
    set_vhost_limits(@vhost, @definition)
    {:ok, defs} = JSON.decode(@definition)
    assert @command.run([], vhost_opts) == Map.to_list(defs)
  end

  test "run: an unreachable node throws a badrpc" do
    target = :jake@thedog

    opts = %{node: target, vhost: "/"}

    assert @command.run([], opts) == {:badrpc, :nodedown}
  end

  @tag vhost: "bad-vhost"
  test "run: providing a non-existent vhost reports an error", context do
    vhost_opts = Map.merge(context[:opts], %{vhost: context[:vhost]})

    assert @command.run([],vhost_opts) == {:error, {:no_such_vhost, context[:vhost]}}
  end

  test "banner", context do
    vhost_opts = Map.merge(context[:opts], %{vhost: context[:vhost]})

    assert @command.banner([], vhost_opts)
      == "Listing limits for vhost \"#{context[:vhost]}\" ..."
    assert @command.banner([], context[:opts])
      == "Listing limits for all vhosts ..."
  end

end
