function data = dataCol(data,cols,col)

idx = ismember(cols,col);
data = data{idx};