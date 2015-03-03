function validMask = sql_getValidTetChannels(sessionName, tetrodeID, varargin)
% DEPRECATED
% usage: sql_getValidTetChannels(sessionName, tetrodeID, varargin)
%
% function to read in valid tetrode channels for a given tetrode-session.
% If the tetrode-session is not found in the sql database, 
%
% INPUTS:
%   sessionName - name of the recording session in the format
%       "RZZZZ_YYYYMMDDX" where ZZZZ is the 4 digit rat identifier,
%       YYYYMMDD is the date, and X is a letter indicating the specific
%       session for that date (i.e., 'a', 'b', etc.)
%   tetrodeID - ID of the tetrode in the tetrode database for which to
%       extract which wires are good
%
% OUTPUTS:
%   validMask

conn = establishConn;

if isconnection(conn)

    % get the sessionID from the session table for the given session name
    qry = sprintf('SELECT sessionID FROM session WHERE session.sessionName= "%s"',sessionName);
    rs = fetch(exec(conn, qry));
    sessionID = rs.Data{1};
    if strcmpi(sessionID, 'no data')
        error('sql_getValidTetChannels:invalidSession',[sessionName ' not found in session table']);
    end
    
    % read the "channelvalid" fields from the sql database for this
    % tetrode-session pair
    qry = sprintf('SELECT ch1valid, ch2valid, ch3valid, ch4valid FROM tetrodeSession WHERE tetrodeSession.sessionID = "%d" AND tetrodeSession.tetrodeID = "%d"',...
                  sessionID, ...
                  tetrodeID);
    rs = fetch(exec(conn, qry));
    if strcmpi(rs.Data{1},'no data')
        error('sql_getValidTetChannels:invalidTetrodeSession',['tetrode-session combination not found in sql database']);
    end
    validMask = zeros(1, length(rs.Data));   % made this general in case we have different electrodes with more channels/"tetrode" in the future
    for i_isValid = 1 : length(rs.Data)
        validMask(i_isValid) = rs.Data{i_isValid};
    end
    
    close(conn);
    
else
    
    error('sql_createSessionsFromRaw:invalidConnection','Cannot connect to sql database');
    
end