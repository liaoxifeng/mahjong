%%%-------------------------------------------------------------------
%%% @author feng.liao
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 06. 三月 2019 下午4:49
%%%-------------------------------------------------------------------

-module(player_srv).
-author("feng.liao").

-include("common.hrl").
-include("player.hrl").

-behaviour(gen_server).

%% API
-export([start_link/1]).

%% gen_server callbacks
-export([init/1,
    handle_call/3,
    handle_cast/2,
    handle_info/2,
    terminate/2,
    code_change/3]).

%%%===================================================================
%%% API
%%%===================================================================

start_link(Args) ->
    gen_server:start_link(?MODULE, [Args], []).

%%%===================================================================
%%% gen_server callbacks
%%%===================================================================

init([{WebSocketPid}]) ->
    %% monitor the web socket process
    erlang:monitor(process, WebSocketPid),
    State = #{?map_name => ?player_state},
    {ok, State}.

handle_call(Request, From, State) ->
    try
        do_call(Request, From, State)
    catch
        Class: Reason ->
            ?ERR_ST("", [], {Class, Reason}),
            {noreply, State}
    end.

handle_cast(Msg, State) ->
    try
        do_cast(Msg, State)
    catch
        Class: Reason ->
            ?ERR_ST("~nstate=~w", [State], {Class, Reason}),
            {noreply, State}
    end.

handle_info(Info, State) ->
    try
        do_info(Info, State)
    catch
        Class: Reason ->
            ?ERR_ST("~nstate=~w", [State], {Class, Reason}),
            {noreply, State}
    end.

terminate(Reason, #{?map_name := ?player_state} = State) ->
    %% save player info
    player_hdl:on_terminate(Reason, State),
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

do_info(Msg, State) ->
    case Msg of
        %% 执行函数
        {info_apply, F, A} when is_function(F) andalso is_list(A) ->
            erlang:apply(F, [State| A]);

        %% 执行函数
        {info_apply, M, F, A} when is_atom(M) andalso is_atom(F) andalso is_list(A) ->
            erlang:apply(M, F, [State| A]);

        {'DOWN', _, process, Pid, _Reason} ->
            player_hdl:on_ws_terminate(State, Pid);

        Unknown ->
            ?WRN("unknown msg: ~p", [Unknown]),
            {noreply, State}
    end.

do_call(Request, From, State) ->
    case Request of
        %% 执行函数
        {call_apply, F, A} when is_function(F) andalso is_list(A) ->
            erlang:apply(F, [State, From| A]);

        %% 执行函数
        {call_apply, M, F, A} when is_atom(M) andalso is_atom(F) andalso is_list(A) ->
            erlang:apply(M, F, [State, From| A]);

        Unknown ->
            ?WRN("unknown request: ~p", [Unknown]),
            {noreply, State}
    end.

do_cast(Msg, State) ->
    case Msg of
        %% 执行处理协议
        {apply_proto, F, OtherArgs, ProtoMsg} when is_function(F) ->
            F(ProtoMsg, OtherArgs, State);

        %% 执行函数
        {cast_apply, F, A} when is_function(F) andalso is_list(A) ->
            erlang:apply(F, [State| A]);

        %% 执行函数
        {cast_apply, M, F, A} when is_atom(M) andalso is_atom(F) andalso is_list(A) ->
            erlang:apply(M, F, [State| A]);

        Unknown ->
            ?WRN("unknown msg: ~p", [Unknown]),
            {noreply, State}
    end.