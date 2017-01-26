function conn = establishConn()

% modify by: 
% > t = load('/Users/mattgaidica/Documents/MATLAB/LeventhalLab/MySQLTools/mysql.mat');
% (modify t struct)
% > save('mysql-archive','-struct','t')

load('mysql.mat');
% if this script has been compiled, make sure to include the jar
% as a shared resource: http://www.mathworks.com/matlabcentral/answers/129715-how-do-i-connect-to-a-mysql-database-in-a-compiled-application
% ex. -a 'C:\...somewhere...\mysql-connector-java-5.1.34-bin.jar'
if ~isdeployed
    addJava(sqlJava_version);
end

% establishes a database connection
conn = database(dbName, user, password, jdbcDriver, jdbcString);
if isopen(conn)
    setdbprefs('DataReturnFormat','table');
else
    error('Cannot connect to sql database');
end