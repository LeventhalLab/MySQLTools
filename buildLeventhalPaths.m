function leventhalPaths = buildLeventhalPaths(nasPath,sessionName,varargin)

leventhalPaths = {};
ratID = sessionName(1:5);
leventhalPaths.rawdata = fullfile(nasPath,ratID,[ratID,'-rawdata']);
leventhalPaths.processed = fullfile(nasPath,ratID,[ratID,'-processed'],sessionName);
leventhalPaths.session = fullfile(leventhalPaths.rawdata,sessionName,sessionName);

% pass in makeFolders (ie. {'rawData'})
if nargin == 3
    makeFolders = varargin{1};
    allFields = fieldnames(leventhalPaths);
    for ii=1:length(makeFolders)
        if ismember(makeFolders{ii},allFields)
            if ~exist(leventhalPaths.(makeFolders{ii}),'dir')
                mkdir(leventhalPaths.(makeFolders{ii}));
            end
        end
    end
end