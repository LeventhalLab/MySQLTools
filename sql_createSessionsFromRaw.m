function sql_createSessionsFromRaw(ratID, varargin)
%
% usage: sql_createSessionsFromRaw(ratID, varargin)
%
% function to sift through raw data folders for a rat and automatically
% populate the sql database sessions table. Assumes that all folders that
% start "RZZZZ" inside the raw data directory contain a separate session,
% AND tha the name of the folder corresponds to the name of the session
% (should be "RZZZZ_YYYYMMDDX", where ZZZZ is the 4-digit rat identifier,
% YYYYMMDD is the date, and X is a letter indicating the session number for
% the day (e.g., a, b, c, etc.)
%
% INPUTS:
%   ratID - "RZZZZ" where ZZZZ is the 4 digit rat identifier
%
% OUTPUTS:
%   none

conn = establishConn;

if isconnection(conn)

    qry = sprintf('SELECT subjectID FROM subject WHERE subject.SubjectName = "%s"',ratID);
    rs = fetch(exec(conn, qry));
    subjectID = rs.Data{1};
    if strcmpi(subjectID,'no data')
        error('sql_createSessionsFromRaw:invalidSubject',[ratID ' not found in subject table']);
    end
    
    % find the last session ID already in the table
    qry = sprintf('SELECT MAX(sessionID) FROM session');
    rs = fetch(exec(conn, qry));
	lastSessionID = rs.Data{1};
    
    % find all the data directories
    cd(rawDataPath);    
    tempDirList = dir;
    for iDir = 1 : length(tempDirList)
        if length(tempDirList(iDir).name) ~= 15 && ...
           length(tempDirList(iDir).name) ~= 16
            continue
        end    % should be exactly fifteen characters in the folder name (RZZZZ_YYYYMMDDX)
        if isdir(tempDirList(iDir).name) && strcmpi(ratID, tempDirList(iDir).name(1:5))
           
            sessionName = tempDirList(iDir).name;
            
            qry = sprintf('SELECT sessionID FROM session WHERE session.sessionName = "%s"', sessionName);
            rs = fetch(exec(conn, qry));
            sessionID = rs.Data{1};
            if isnumeric(sessionID)    % a valid session identifier already exists for this session name
                continue;
            end
            sessionDateVec = datevec(sessionName(7:14), 'yyyymmdd');
            sessionDate = datestr(sessionDateVec, 'yyyy/mm/dd');
            
            cd(tempDirList(iDir).name);
            
            logInfo = dir('*.log');
            if ~isempty(logInfo)
                for iLog = 1 : length(logInfo)
                    logData = readLogData(logInfo(iLog).name);
                    if ~isempty(logData); break; end
                end
                if isempty(logData);continue;end
            end
            if ~isempty(logInfo)    % there is a .log file for this session
%                 error('sql_createSessionsFromRaw:noLogFile',['No log file for session ' sessionName]);
                sessionComment = logData.comment;
                behaviorID = 3; %choice task, !!!MUST FIX!!! -MG
                apparatusID = 1; %moved up here, needs a better check
                if isfield(logData, 'behaviorID')
                    behaviorID = logData.behaviorID;
                    if isfield(logData, 'box_number')
                        % CODE HERE TO FIGURE OUT THE APPARATUSID FROM THE SQL
                        % DATABASE BASED ON THE BEHAVIORID AND BOX_NUMBER
                        qry = sprintf('SELECT id FROM experiment_apparatus WHERE experiment_apparatus.experimentID = "%d" AND experiment_apparatus.box_number = "%d"',...
                                      logData.behaviorID,logData.box_number);
                        rs = fetch(exec(conn, qry));
                        apparatusID = rs.Data{1};
                        if strcmpi(apparatusID,'no data')
                            error('sql_createSessionsFromRaw:no_apparatus_id',['No apparatus found for experiment ' ', box number ' num2str(logData.box_number)]);
                        end
                    end
                end
                if isfield(logData, 'ephys_system')
                    ephysSystemID = logData.ephys_system;
                else
                    ephysSystemID = 1;      % indicates that the ephys system wasn't recorded in the .log file
                end
                logName = logInfo(iLog).name;

                sessionTimeVec = datevec(logName(16:23), 'HH-MM-SS');
                sessionTime = datestr(sessionTimeVec, 'HH:MM:SS');
            else
                behaviorID  = 1;    % indicates that the behavior wasn't recorded in the .log file
                apparatusID = 1;    % indicates that the apparatus couldn't be figured out because the experiment wasn't recorded in the .log file
                ephysSystemID = 1;
                sessionTime = '00:00:00';
                sessionComment = '';
            end

            cd ..
            
            lastSessionID = lastSessionID + 1;
            qry = sprintf('INSERT INTO session (sessionID, sessionName, subjectID, sessionDate, sessionTime, behaviorID, ephysSystemID, apparatusID, comment) VALUES ("%d", "%s", "%d", "%s", "%s", "%d", "%d", "%d", "%s")', ...
                          lastSessionID, ...
                          sessionName, ...
                          subjectID, ...
                          sessionDate, ...
                          sessionTime, ...
                          behaviorID, ...
                          ephysSystemID, ...
                          apparatusID, ...
                          sessionComment);
            rs = fetch(exec(conn, qry));

        end
    end
    
    close(conn);
    
else
    
    error('sql_createSessionsFromRaw:invalidConnection','Cannot connect to sql database');
    
end