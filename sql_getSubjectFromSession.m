function [subjectID, ratID] = sql_getSubjectFromSession(sessionName, varargin)
%
% usage: nasPath = sql_findNASpath(ratID, varargin)
%
% function that will query the sql database to get the path on the nas
% server to the data for ratID
%
% INPUTS:
%   sessionName - string with unique session identifier (e.g., 'R0035_20141203a')
%
% OUTPUT:
%   subjectID - the subject ID from the sql database (this is an integer)
%   ratID - the ratID (subjectName in the sql db), a string in the format
%       "RZZZZ"

conn = establishConn;

if isopen(conn)
    % first, get the subjectID given the session name
    qry = sprintf('SELECT subjectID FROM session WHERE session.sessionName= "%s"', sessionName);
    rs = fetch(exec(conn, qry));
    subjectID = rs.Data{1};
    if strcmpi(subjectID, 'no data')
        error('sql_getSubjectFromSession:invalidSession',['Cannot find session ' sessionName ' in sql database']);
    end
    % next, get the rat ID given the subjectID
    qry = sprintf('SELECT subjectName FROM subject WHERE subject.subjectID = %d', subjectID);
    rs = fetch(exec(conn, qry));
    ratID = rs.Data{1};
    close(conn);
else
	error('sql_getSubjectFromSession:invalidConnection','Cannot connect to sql database');

end