function T = fetch2(conn,qry,err)
curs = fetch(exec(conn,qry));
T = curs.Data;
% handle empty return
if ~isempty(err)
    if isempty(T)
        error(err);
    end
end

T.Properties.VariableNames = columnlabels(curs);
close(curs);