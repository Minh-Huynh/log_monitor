-module(log_monitor).
-behavior(gen_server).
-export([start/2, stop/0]).

%%API
start(FileName, Regex) ->
    read_data(FileName, Regex).

stop() ->.

read_data(FileName, Regex) ->
    {ok, LogFile} = file:open(FileName, read),
    io:format("successfully opened ~p~n", [FileName]),
    %Move pointer to end of file to read new lines
    file:position(LogFile, eof),
    read_line(FileName, LogFile, Regex).

read_line(FileName, FilePid, Regex) ->
    case io:get_line(FilePid, '') of
        eof ->
            io:format("Encountered EOF for ~p~n", [FileName]),
            timer:sleep(10000),
            read_line(FileName, FilePid, Regex);
        {error, Reason} ->
            io:format("Unable to read file: ~p~n", [Reason]),
            file:close(FilePid),
            read_data(FileName, Regex);
        Data ->
            find_text(Data, Regex),
            read_line(FileName, FilePid, Regex)
    end.

find_text(Line, Regex) ->
    case re:run(Line, Regex, [global, caseless]) of
        {match, _} -> 
            io:format("Found match: ~p~n", [Line]),
            file:write_file("errors.log", Line, [append]);
        nomatch ->  
            ok
    end.


