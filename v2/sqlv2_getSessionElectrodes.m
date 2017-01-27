function T = sqlv2_getSessionElectrodes(sessions__name)

conn = establishConn;
qry = fileread('sqlv2_getSessionElectrodes.sql');
qry = sprintf(qry,sessions__name);
T = fetch2(conn,qry,'subject not found');
T = sortrows(T);

close(conn);