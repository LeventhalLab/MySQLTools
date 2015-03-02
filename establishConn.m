function conn = establishConn()

load('mysql.mat');
% if this script has been compiled, make sure to include the jar
% as a shared resource: http://www.mathworks.com/matlabcentral/answers/129715-how-do-i-connect-to-a-mysql-database-in-a-compiled-application
% ex. -a 'C:\jdbcDriver\mysql-connector-java-5.1.21-bin.jar'
if ~isdeployed
    addJava(sqlJava_version);
end
conn = database(dbName, user, password, jdbcDriver, jdbcString);
