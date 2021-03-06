%% @author Maas-Maarten Zeeman <mmzeeman@xs4all.nl>
%% @copyright 2019 Maas-Maarten Zeeman 
%% @doc Zotonic: admin status model

%% Copyright 2019 Maas-Maarten Zeeman
%%
%% Licensed under the Apache License, Version 2.0 (the "License");
%% you may not use this file except in compliance with the License.
%% You may obtain a copy of the License at
%%
%%     http://www.apache.org/licenses/LICENSE-2.0
%%
%% Unless required by applicable law or agreed to in writing, software
%% distributed under the License is distributed on an "AS IS" BASIS,
%% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
%% See the License for the specific language governing permissions and
%% limitations under the License.

-module(m_admin_status).
-author("Maas-Maarten Zeeman <mmzeeman@xs4all.nl>").

-behaviour(zotonic_model).

-include_lib("zotonic_core/include/zotonic.hrl").


%% interface functions
-export([
    m_get/3,

    session_count/1,
    page_count/1,
    tcp_connection_count/0,
    group_sockets/0,
    close_sockets/2
]).

m_get([ session_count | Rest ], _Msg, Context) ->
    {ok, {session_count(Context), Rest}};
m_get([ page_count | Rest ], _Msg, Context) ->
    {ok, {page_count(Context), Rest}};
m_get([ tcp_connection_count | Rest ], _Msg, _Context) ->
    {ok, {tcp_connection_count(), Rest}};

m_get([ group_sockets | Rest ], _Msg, _Context) ->
    {ok, {group_sockets(), Rest}};

m_get([ memory, used | Rest ], _Msg, _Context) ->
    {ok, {recon_alloc:memory(used), Rest}};
m_get([ memory, allocated | Rest ], _Msg, _Context) ->
    {ok, {recon_alloc:memory(used), Rest}};
m_get([ memory, unused | Rest ], _Msg, _Context) ->
    {ok, {recon_alloc:memory(unused), Rest}};
m_get([ memory, usage | Rest ], _Msg, _Context) ->
    {ok, {recon_alloc:memory(usage), Rest}}.


%%
%% Helpers
%%

% Return the total number of open tcp connections in the system.
% This includes local sockets.
tcp_connection_count() ->
    length(recon:tcp()).

% Return the number of sessions of this site. 
session_count(Context) ->
    undefined.
    % z_session_manager:count(Context).

% Return the number of page processes which are open.
page_count(Context) ->
    undefined.
    % z_session_manager:fold(
    %   fun(S, Acc) ->
    %           case z_session:get_pages(S) of
    %               Pages when is_list(Pages) ->
    %                   length(Pages) + Acc;
    %               _ -> Acc
    %           end
    %   end,
    %   0,
    %   Context).

% Group open sockets per ip-address, returns a list of proplists.
group_sockets() ->
    Dict = group_sockets(recon:tcp(), dict:new()),
    [[{count, length(Ports)}, {ip, inet:ntoa(IP)}, {ports, Ports}] || {IP, Ports} <- dict:to_list(Dict)].

% Return a dict with as key the ip-address. 
group_sockets([], Dict) ->
    Dict;
group_sockets([Port|Rest], Dict) ->
    case inet:peername(Port) of
        {ok, {Addr, _}} ->
            group_sockets(Rest, dict:append_list(Addr, [Port], Dict));
        _ ->
            group_sockets(Rest, Dict)
    end.

% Close sockets
close_sockets(Max, _Context) ->
    socket_reaper(Max).

% Close sockets of ip-addresses which have 
socket_reaper(Max) ->
    Dict = group_sockets(recon:tcp(), dict:new()),
    socket_reaper(dict:to_list(Dict), Max, 0).

socket_reaper([], _Max, Acc) ->
    Acc;
socket_reaper([{_Ip, Ports}|Rest], Max, Acc) when length(Ports) >= Max ->
    [inet:close(Port) || Port <- Ports],
    socket_reaper(Rest, Max, length(Ports) + Acc);
socket_reaper([_|Rest], Max, Acc) ->
    socket_reaper(Rest, Max, Acc).

