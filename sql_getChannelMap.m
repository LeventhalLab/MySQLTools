function chMap = sql_getChannelMap(ratID, varargin)
%
% usage: chMap = findNASpath(ratID, varargin)
%
% function that will query the sql database to find the mapping from
% tetrodes to channel numbers for ratID
%
% INPUTS:
%   ratID - string with unique rat identifier (e.g., 'R0023')
%
% OUTPUT:
%   chMap - structure with the following fields:
%           .tetNames - names of the "tetrodes" (e.g., 'T01', 'E01', etc.)
%           .chMap - m x n array, where the first element of each row is
%                    the tetrode ID, and the last n-1 elements are the
%                    channel numbers for that tetrode. If there are
%                    different numbers of channels for each "tetrode",
%                    extra spaces for individual tetrodes are filled with
%                    zeros
           
conn = establishConn;

if isconnection(conn)
    % first, get the ephys interface type from the subject table
    qry = sprintf('SELECT ephysInterface FROM subject WHERE subject.subjectName = "%s"',ratID);
    rs = fetch(exec(conn, qry));
    ephysInterfaceID = rs.data{1};
    if strcmpi(ephysInterfaceID, 'no data')
        error('sql_getChannelMap:invalidSubject',[ratID ' not found in subject table']);
    end
    
    % next, get the NAS IP address ID and name of the recordings folder from the nasLocation table
    qry = sprintf('SELECT tetrodeID, channelNumber FROM channelMap WHERE channelMap.interfaceID = %d',ephysInterfaceID);
    rs = fetch(exec(conn, qry));
    numChannels = size(rs.data, 1);
    tetrodeIDs = zeros(numChannels, 1);
    channelList = zeros(numChannels, 1);
    
    %loop through channels to input the tetrode IDs and channel list
    for iCh = 1 : numChannels
        tetrodeIDs(iCh) = rs.data{iCh, 1};
        channelList(iCh) = rs.data{iCh, 2};
    end
    
    %Get rid of any repeated tetrode IDs
    unique_tetIDs = unique(tetrodeIDs);
    % find the maximum number of channel numbers for each tetrode
    maxChannels = 0;
    for iTet = 1 : length(unique_tetIDs)
        temp = find(tetrodeIDs == unique_tetIDs(iTet));
        if length(temp) > maxChannels
            maxChannels = length(temp);
        end
    end
    
    chMap.chMap = zeros(length(unique_tetIDs), maxChannels + 1);
    chMap.chMap(:,1) = unique_tetIDs;
    chMap.tetNames = cell(length(unique_tetIDs), 1);
    
    for iTet = 1 : length(unique_tetIDs)
        temp = find(tetrodeIDs == unique_tetIDs(iTet));
        chMap.chMap(iTet, 2:(length(temp)+1)) = channelList(temp)';
        
        qry = sprintf('SELECT tetrodeName FROM tetrode WHERE tetrode.tetrodeID = %d',unique_tetIDs(iTet));
        rs = fetch(exec(conn, qry));
        chMap.tetNames{iTet} = rs.data{1};
    end
    
    close(conn);
    
else

	error('sql_getChannelMap:invalidConnection','Cannot connect to sql database');

end