function [subjects__id,subjects__name] = sqlv2_getSubjectFromSession(sessions__name)

conn = establishConn;
qry = fileread('sqlv2_getSubjectFromSession.sql');
qry = sprintf(qry,sessions__name);
T = fetch2(conn,qry,'session name not found');

subjects__id = T.subjects__id(1);
subjects__name = T.subjects__name{1};

close(conn);