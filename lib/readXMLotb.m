%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% To read the xml file saved with OTBiolab

% Input:
% filename: filename

% Output: 
% structOTB: attributes of the xml file with info on the acquisition

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function structOTB = readXMLotb(filename)
% XML2STRUCT Convert an XML file into a MATLAB structure.
%   Copyright 2003-2007 The MathWorks, Inc.
%   Based on an idea by Douglas M. Schwarz, Eastman Kodak Company

tree = xmlread(filename);
structOTB = parseChildNodes(tree);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function nodeStruct = makeStructFromNode(theNode)

nodeStruct = struct('Name',char(theNode.getNodeName),...
    'Attributes',parseAttributes(theNode),'Data','',...
    'Children',parseChildNodes(theNode));

if any(strcmp(methods(theNode),'getData'))
   nodeStruct.Data = char(theNode.getData); 
else
    nodeStruct.Data = '';
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function attributes = parseAttributes(theNode)
% Create attributes struct
attributes = [];
if theNode.hasAttributes
    theAttributes = theNode.getAttributes;
    numAttributes = theAttributes.getLength;
    allocCell = cell(1,numAttributes);
    attributes = struct('Name',allocCell,'Value',allocCell);
    for count = 1:numAttributes
        attrib = theAttributes.item(count-1);
        attributes(count).Name = char(attrib.getName);
        attributes(count).Value = char(attrib.getValue);
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function children = parseChildNodes(theNode)
% Recurse over node children
children = [];
if theNode.hasChildNodes
    childNodes = theNode.getChildNodes;
    numChildNodes = childNodes.getLength;
    allocCell = cell(1,numChildNodes);
    children = struct('Name',allocCell,'Attributes',allocCell,...
                                 'Data',allocCell,'Children',allocCell);
    for count = 1:numChildNodes
        theChild = childNodes.item(count-1);
        children(count) = makeStructFromNode(theChild);
    end
end
