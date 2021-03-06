%% @author Marc Worrell <marc@worrell.nl>
%% @copyright 2016 Marc Worrell
%%
%% @doc Check if an identified file is acceptable as upload.

%% Copyright 2016 Marc Worrell
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

-module(z_media_sanitize).

-export([
    sanitize/2,
    is_file_acceptable/2
    ]).

-include("zotonic.hrl").


%% @doc Sanitize uploaded media (SVG) files.
sanitize(#media_upload_preprocess{mime = <<"image/svg+xml">>} = PP, _Context) ->
    sanitize_svg(PP);
sanitize(#media_upload_preprocess{ mime = <<"text/html">> } = PP, Context) ->
    sanitize_html(PP, Context);
sanitize(#media_upload_preprocess{ mime = <<"text/csv">> } = PP, Context) ->
    sanitize_csv(PP, Context);
sanitize(#media_upload_preprocess{ mime = <<"application/xml+html">> } = PP, Context) ->
    sanitize_html(PP, Context);
sanitize(#media_upload_preprocess{mime = Mime} = PP, _Context) when is_binary(Mime)  ->
    PP.

sanitize_svg(#media_upload_preprocess{file=File} = PP) ->
    {ok, Bin} = file:read_file(File),
    Svg = z_svg:sanitize(Bin),
    TmpFile = z_tempfile:new(".svg"),
    ok = file:write_file(TmpFile, Svg),
    PP#media_upload_preprocess{file=TmpFile}.

sanitize_html(#media_upload_preprocess{file=File} = PP, Context) ->
    {ok, Bin} = file:read_file(File),
    Html = z_sanitize:html(Bin, Context),
    TmpFile = z_tempfile:new(".html"),
    ok = file:write_file(TmpFile, Html),
    PP#media_upload_preprocess{ file = TmpFile, mime = <<"text/html">> }.

sanitize_csv(#media_upload_preprocess{file=File} = PP, _Context) ->
    TmpFile = z_tempfile:new(".csv"),
    ok = z_csv_writer:sanitize(File, TmpFile),
    PP#media_upload_preprocess{ file = TmpFile }.


%% @doc Check the contents of an identified file, to see if it is acceptable for further processing.
%%      Catches files that might be problematic for ImageMagick or other file processors.
-spec is_file_acceptable( file:filename_all(), list() ) -> boolean().
is_file_acceptable(File, MediaProps) when is_list(MediaProps) ->
    Mime = z_convert:to_binary(proplists:get_value(mime, MediaProps)),
    is_file_acceptable_1(Mime, File, MediaProps).

% is_file_acceptable_1(<<"image/svg+xml">>, File, _MediaProps) ->
%     {ok, Bin} = file:read_file(File),
%     is_acceptable_svg(Bin);
is_file_acceptable_1(<<"unacceptable-mime-type">>, _File, _MediaProps) ->
    false;
is_file_acceptable_1(_Mime, _File, _MediaProps) ->
    true.
