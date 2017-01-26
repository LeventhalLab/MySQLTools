function eib_electrodes = sqlv2_getEibElectrodes(subjects__id)

conn = establishConn;
qry = fileread('sqlv2_getEibElectrodes.sql');
qry = sprintf(qry,subjects__id);
T = fetch2(conn,qry,'subject not found');

eib_electrodes = table2array(T);

close(conn);