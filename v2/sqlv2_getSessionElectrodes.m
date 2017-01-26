function session_electrodes = sqlv2_getSessionElectrodes(sessions__name)

conn = establishConn;
qry = fileread('sqlv2_getSessionElectrodes.sql');
qry = sprintf(qry,subjects__id);
T = fetch2(conn,qry,'subject not found');

session_electrodes = '';

close(conn);