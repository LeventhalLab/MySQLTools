function sql_addTetrodeSessions(ratID, varargin)
% [] Maybe this function can update values too?
%
% usage: sql_addTetrodeSessions(ratID, varargin)
%
% function to find all the sessions for a given rat ID that include ephys
% recordings, and all the available tetrodes for the implant type for that
% rat, and add entries to the tetrodeSessions chart that aren't already
% there
%
% INPUTS:
%   ratID - "RZZZZ" where ZZZZ is the 4 digit rat identifier
%   validMask - tetrodes x channels logical matrix of good/bad wires (ex.
%   16x4: validMask = ones(16,4); %all good channels
%   lfpWire - tetrodes x 1 integer matrix of the LFP wire for each tetrode
%   (ex. 16x1: lfpWire = ones(16,1); %use first wire
%
% OUTPUTS:
%   none


for iarg = 1 : 2 : nargin - 1
    switch varargin{iarg}
        case 'validMask'
            validMask = varargin{iarg + 1};
        case 'lfpWire'
            lfpWire = varargin{iarg + 1};
        case 'sessionName'
            sessionName = varargin{iarg + 1};
        case 'coordinates'
            coordinates = varargin{iarg + 1};
    end
end


conn = establishConn;

if isconnection(conn)
    %get the subject ID and ephysInterface from the subject table
    qry = sprintf('SELECT subjectID, ephysInterface FROM subject WHERE subject.SubjectName = "%s"',ratID);
    rs = fetch(exec(conn, qry));
    subjectID = rs.Data{1};
    if strcmpi(subjectID, 'no data')
        error('sql_addTetrodeSessions:invalidSubject',[ratID ' not found in subject table']);
    end
    ephysInterfaceID = rs.Data{2};
    if isnan(ephysInterfaceID)
        error('sql_addTetrodeSessions:ephys_interface_undefined',['No eletrophysiology interface entered in sql database for' ratID]);
    end
    
    % get the list of tetrodes associated with this rat
    qry = sprintf('SELECT tetrodeID FROM channelMap WHERE channelMap.interfaceID = "%d"',ephysInterfaceID);
    rs = fetch(exec(conn, qry));
    if strcmpi(rs.Data{1},'no data')
        error('sql_addTetrodeSessions:invalid_ephys_interface',['Electrophysiology interface ' num2str(ephysInterfaceID) ' undefined']);
    end
    tetrodeIDlist = zeros(length(rs.Data), 1);
    for iTet = 1 : length(tetrodeIDlist)
        tetrodeIDlist(iTet) = rs.Data{iTet};
    end
    tetrodeIDlist = unique(tetrodeIDlist);
    
    if exist('validMask','var')
        if ~(length(tetrodeIDlist)==size(validMask,1))
            error('sql_addTetrodeSessions:validMaskSize','Your valid mask size does not match the amount of tetrodes');
        end
    end
    
    % find all the sessions already entered in the sql database for that
    % rat that have ephys recordings
    if ~exist('sessionName','var')
        qry = sprintf('SELECT sessionID,sessionName FROM session WHERE session.subjectID = "%d" AND ephysSystemID > "0"',subjectID);
    else
        qry = sprintf('SELECT sessionID FROM session WHERE session.subjectID = "%d" AND ephysSystemID > "0" AND session.sessionName="%s"',...
            subjectID,sessionName);
    end
    rs = fetch(exec(conn, qry));
    if strcmpi(rs.Data{1}, 'no data')
        error('sql_addTetrodeSessions:noValidSessions',['No sessions for ' ratID ' found in session table']);
    end 
    sessionID = zeros(length(rs.Data),1);
    for iSession = 1 : length(sessionID)
        sessionID(iSession) = rs.Data{iSession,1}; %sessionIDs
    end
    
    % find the last tetrodeSession ID already in the table
    qry = sprintf('SELECT MAX(tetrodeSessionID) FROM tetrodeSession');
    rs = fetch(exec(conn, qry));
	lastTetSessionID = rs.Data{1};
    if isnan(lastTetSessionID); lastTetSessionID = 0; end
    
    % now loop through the sessions to see if all tetrode-sessions have
    % been set up in the table
    for iSession = 1 : length(sessionID)
        for iTet = 1 : length(tetrodeIDlist)
            if lastTetSessionID > 0
                qry = sprintf('SELECT tetrodeSessionID FROM tetrodeSession WHERE tetrodeSession.sessionID = "%d" AND tetrodeSession.tetrodeID = "%d"', sessionID(iSession), tetrodeIDlist(iTet));
                rs = fetch(exec(conn, qry));
                if ~iscell(rs.Data)
                    tetrodeSessionID = 0;
                else
                    tetrodeSessionID = rs.Data{1};
                end
                if isnumeric(tetrodeSessionID)   % not sure exactly what's going on here; rs.Data{1} = 0 when the current tetrodeSession is not in the table, not sure why but this seems to work
                    if tetrodeSessionID > 0
                        continue; 
                    end    
                end    % a valid tetrodeSession identifier already exists for this tetrode-session combination
            end
            
            lastTetSessionID = lastTetSessionID + 1;
            
            %Input the information into the tables in the MySQL database
            
            if exist('validMask','var') && exist('lfpWire','var')
                qry = sprintf('INSERT INTO tetrodeSession (tetrodeSessionID, tetrodeID, sessionID, ch1valid, ch2valid, ch3valid, ch4valid, lfpWire) VALUES ("%d", "%d", "%d", "%d", "%d", "%d", "%d", "%d")', ...
                          lastTetSessionID, ...
                          tetrodeIDlist(iTet), ...
                          sessionID(iSession), ...
                          validMask(iTet,1),validMask(iTet,2),validMask(iTet,3),validMask(iTet,4),lfpWire(iTet));
            elseif exist('validMask','var')
                qry = sprintf('INSERT INTO tetrodeSession (tetrodeSessionID, tetrodeID, sessionID, ch1valid, ch2valid, ch3valid, ch4valid) VALUES ("%d", "%d", "%d", "%d", "%d", "%d", "%d")', ...
                          lastTetSessionID, ...
                          tetrodeIDlist(iTet), ...
                          sessionID(iSession), ...
                          validMask(iTet,1),validMask(iTet,2),validMask(iTet,3),validMask(iTet,4));
            else
                qry = sprintf('INSERT INTO tetrodeSession (tetrodeSessionID, tetrodeID, sessionID) VALUES ("%d", "%d", "%d")', ...
                          lastTetSessionID, ...
                          tetrodeIDlist(iTet), ...
                          sessionID(iSession));
            end
            rs = fetch(exec(conn, qry));
        end
    end
    
    close(conn);
    
else
    
    error('sql_createSessionsFromRaw:invalidConnection','Cannot connect to sql database');
    
end