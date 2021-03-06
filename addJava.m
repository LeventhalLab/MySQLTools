function sql_java_path = addJava(sqlJava_version)
% This was just stripped from the SQL files since it was always
% repeated.

versionString   = ['R' version('-release')];
if ispc
    matlabParentDir = fullfile('C:\Program Files', ...
                               'MATLAB', ...
                               versionString);
elseif ismac
    matlabParentDir = fullfile('/Applications', ...
                               ['MATLAB_' versionString '.app']);
elseif isunix
end

sql_java_main_path = fullfile(matlabParentDir, ...
                              'java', ...
                              'jarext');
                          
if isempty(sqlJava_version)
    java_connector_folder = dir(fullfile(sql_java_main_path,...
        'mysql-connector-java-*'));

    if length(java_connector_folder) > 1
        java_connector_folder = java_connector_folder(1);
    end

    sql_java_path = fullfile(matlabParentDir, ...
                             'java', ...
                             'jarext', ...
                             java_connector_folder.name, ...
                             [java_connector_folder.name '-bin.jar']);
else             
    sql_java_path = fullfile(matlabParentDir, ...
                             'java', ...
                             'jarext', ...
                             ['mysql-connector-java-' sqlJava_version], ...
                             ['mysql-connector-java-' sqlJava_version '-bin.jar']);
end

if ~any(strcmp(javaclasspath('-static'),sql_java_path)) && ...
   ~any(strcmp(javaclasspath('-dynamic'),sql_java_path))
    javaaddpath(sql_java_path);
% elseif ~strcmp(sql_java_path, javaclasspath)
%     javaaddpath(sql_java_path);
end