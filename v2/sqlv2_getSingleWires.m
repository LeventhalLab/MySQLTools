function singleWireChs = sql_getSingleWires(sessionName, varargin)
%
% usage: sql_getSingleWires(sessionName, tetrodeID, varargin)
%
% function to read in valid single wire channels for a given tetrode-session.
% 
%
% INPUTS:
%   sessionName - name of the recording session in the format
%       "RZZZZ_YYYYMMDDX" where ZZZZ is the 4 digit rat identifier,
%       YYYYMMDD is the date, and X is a letter indicating the specific
%       session for that date (i.e., 'a', 'b', etc.)
%
% OUTPUTS:
%   singleWireChs

conn = establishConn;

if isopen(conn)
    % get the sessionID from the session table for the given session name
    qry = sprintf('SELECT sessionID FROM session WHERE session.sessionName= "%s"',sessionName);
    rs = fetch(exec(conn, qry));
    sessionID = rs.Data{1};
    if strcmpi(sessionID, 'no data')
        error('sql_getLFPChannels:invalidSession',[sessionName ' not found in session table']);
    end
    
    % read the "channelvalid" fields from the sql database for this
    % tetrode-session pair
    qry = sprintf('SELECT singleWires FROM tetrodeSession WHERE tetrodeSession.sessionID = "%d"',...
                  sessionID);
    rs = fetch(exec(conn, qry));
    if strcmpi(rs.Data{1},'no data')
        error('sql_getAllTetChannels:invalidTetrodeSession',['tetrode-session combination not found in sql database']);
    end
    singleWireChs = cell2mat(rs.Data);
    
    %set any non-number values to zero
    singleWireChs(isnan(singleWireChs)) = 0;
    
    close(conn);
else
    error('sql_createSessionsFromRaw:invalidConnection','Cannot connect to sql database');
end