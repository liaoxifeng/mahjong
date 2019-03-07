%%%-------------------------------------------------------------------
%%% @author feng.liao
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%% 本地持久化
%%% @end
%%% Created : 06. 三月 2019 下午3:49
%%%-------------------------------------------------------------------

-module(mnesia_mylib).

-include("common.hrl").

-author("feng.liao").

%% API
-export([init/0]).

init() ->
    mnesia:create_schema([node()]),
    mnesia:start(),

    %% 不支持版本升级
    mnesia:create_table(mn_id, [
        {attributes, record_info(fields, mn_id)}, {disc_copies, [node()]}]),

    TablesInfo = [
        {mn_player, record_info(fields, mn_player), mn_player, [{disc_copies, [node()]}]}
        ],

    lists:foreach(
        fun({Table, Attributes, RecordName, OtherCreateOpt}) ->
            mnesia:create_table(Table, [{attributes, Attributes}, {record_name, RecordName} | OtherCreateOpt])
        end,
        TablesInfo
    ),
    mnesia:wait_for_tables([mn_id, mn_player], infinity),
    init_order_id(),
    ok.

init_order_id() ->
    case mnesia:dirty_read(mn_id, order) of
        [] ->
            Fun =
                fun() ->
                    mnesia:write(#mn_id{key = order, value = 0})
                end,
            mnesia:sync_dirty(Fun),
            mnesia:dump_tables([mn_id]);
        _ ->
            ignore
    end.
