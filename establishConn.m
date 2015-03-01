function conn = establishConn()

load('mysql.mat');
addJava(sqlJava_version);
conn = database(dbName, user, password, jdbcDriver, jdbcString);
