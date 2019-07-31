
function[] = reset_text(fighandle)
%Helper function for extractPSDamps, this function resets the position of
%the text boxes in the figure so that every textblock is the same distance
%away from a line, in the hope that everything stays readable. This
%function can not be used independently.
%--------------------------------------------------------------------------
%SYNTAX
% reset_text(fighandle)
%--------------------------------------------------------------------------
%OUTPUT
% - none
%--------------------------------------------------------------------------
%INPUT
% - fighandle-------------------[figure handle object]
%                               - The figure handle object of the current
%                                 figure, this can be found using the
%                                 command 'gca'. (call this function with
%                                 'reset_text(gca)'
%--------------------------------------------------------------------------
%DEPENDENCIES
% - none
%--------------------------------------------------------------------------
%Rick Winters, 2018-01-03
h = findobj(fighandle,'Type','Text');

inds = [];
means = [];
diffmaginds = [];
for i = 1:length(h)
    try
        if h(i).Visible == 'on'
            mean = str2num(h(i).String{1}(8:end-3));
            if isempty(mean)
                diffmaginds = [diffmaginds, i];
            else
                means = [means, mean];
                inds = [inds, i];
            end
        end
    catch
        
    end
end

ymax = 0;
for i = 1:length(inds)
    Y = means(i)+(h(inds(i)).Extent(4)/2);
    h(inds(i)).Position(2) = Y;
    if Y+h(inds(i)).Extent(4) > ymax, ymax = Y+h(inds(i)).Extent(4); end
end

for i = 1:length(diffmaginds)
    Y = means(inds == diffmaginds(i)+1) + h(diffmaginds(i)).Extent(4)*1.5;
    h(diffmaginds(i)).Position(2) = Y;
    if Y+h(diffmaginds(i)).Extent(4) > ymax, ymax = Y+h(diffmaginds(i)).Extent(4); end
end

ylim = get(fighandle,'Ylim');
if ylim(2) < ymax, fighandle.YLim(2) = ymax; end
end

