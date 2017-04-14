function T = fetch2(conn,qry,err)
curs = fetch(exec(conn,qry));
T = curs.Data;
% handle empty return
if ~isempty(err)
    if isempty(T)
        error(err);
    elseif ~istable(T)
        T = {};
    else
        T.Properties.VariableNames = columnlabels(curs);
    end
end

close(curs);