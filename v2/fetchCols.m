function [data,columnlist] = fetchCols(conn,qry,err)
curs = fetch(exec(conn, qry));
data = curs.Data;
% handle empty return
if ~isempty(err)
    if isempty(data)
        error(err);
    end
end

columnlist = columnnames(curs,true);