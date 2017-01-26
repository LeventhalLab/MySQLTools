function nasPath = sqlv2_findNASpath(subjects__name)
%
% usage: nasPath = sql_findNASpath(subject_name)
%
% INPUTS:
%   subject_name - string with unique subject name (e.g., 'R0023')
%
% OUTPUT:
%   nasPath - string containing the path to the data directory for ratID

conn = establishConn;

qry = fileread('sqlv2_findNASpath.sql');
qry = sprintf(qry,subjects__name);
T = fetch2(conn,qry,'subject name not found');

if ispc
    host = sprintf('\\\\%s',T.nas_server__host{1});
elseif ismac
    host = '/Volumes';
elseif isunix
    host = '';
end

nasPath = fullfile(host,T.nas_folders__path{1},T.experiments__name{1});
close(conn);