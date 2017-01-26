function labels = columnlabels(curs)

% Matlab is a nuisance and returns original column names instead of
% intentional aliases. This goes into the Java and gets the column
% labels we want.

num_cols = cols(curs);
labels = cell(num_cols,1);
for i=1:num_cols
    labels{i} = char(curs.ResultSet.getMetaData().getColumnLabel(i));
end