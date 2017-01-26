function data = dataLabel(data,labels,label)

idx = ismember(labels,label);
data = data{idx};