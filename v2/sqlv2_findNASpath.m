function nasPath = sql_findNASpath(subject_name)
%
% usage: nasPath = sql_findNASpath(subject_name)
%
% INPUTS:
%   subject_name - string with unique subject name (e.g., 'R0023')
%
% OUTPUT:
%   nasPath - string containing the path to the data directory for ratID

conn = establishConn;

if isopen(conn)
    qry = fileread('findNASpath.sql');
    [data,cols] = fetchCols(conn,qry,'subject name not found');
    
    nasPath = fullfile(dataCol(data,cols,'name'), dataCol(data,cols,'host'), dataCol(data,cols,'name'));
    close(conn);
else
	error('Cannot connect to sql database');
end