function nasPath = sql_findNASpath(ratID, varargin)
%
% usage: nasPath = sql_findNASpath(ratID, varargin)
%
% function that will query the sql database to get the path on the nas
% server to the data for ratID
%
% INPUTS:
%   ratID - string with unique rat identifier (e.g., 'R0023')
%
% OUTPUT:
%   nasPath - string containing the path to the data directory for ratID

conn = establishConn;

if isconnection(conn)

    % first, get the NAS location ID and experiment ID from the subject table
    qry = sprintf('SELECT nasLocation,experimentID FROM subject WHERE subject.subjectName = "%s"',ratID);
    rs = fetch(exec(conn, qry));
    nasLocationID = rs.data{1};
    
    %print an error if the rat ID is not found in the tables
    if strcmpi(nasLocationID, 'no data')
        error('sql_findNASpath:invalidSubject',[ratID ' not found in subject table']);
    end
    experimentID = rs.data{2};

    % next, get the NAS IP address ID and name of the recordings folder from the nasLocation table
    qry = sprintf('SELECT nasIPaddress,recordingsFolder FROM nasLocation WHERE nasLocation.id = %d',nasLocationID);
    rs = fetch(exec(conn, qry));
    nasIPaddressID = rs.data{1};
    recordingsFolder = rs.data{2};

    % next, get the name of the experiment from the experiment table
    qry = sprintf('SELECT experimentName FROM experiment WHERE experiment.ExperimentID = %d',experimentID);
    rs = fetch(exec(conn, qry));
    experimentName = rs.data{1};

    % now, get the IP address from the nasIPaddress table
    qry = sprintf('SELECT IPaddress FROM nasIPaddress WHERE nasIPaddress.id = %d',nasIPaddressID);
    rs = fetch(exec(conn, qry));
    nasIPaddress = rs.data{1};

    %check what type of computer the program is running on
    if ispc
     IPpath = sprintf('\\\\%s',nasIPaddress);
    elseif ismac
     IPpath = '/Volumes';
    elseif isunix
     IPpath = '';
    end

    nasPath = fullfile(IPpath, recordingsFolder, experimentName);
    
    close(conn);

else

	error('findNASpath:invalidConnection','Cannot connect to sql database');

end