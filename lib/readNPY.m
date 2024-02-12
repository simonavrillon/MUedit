function data = readNPY(filename)

    % Function to read NPY files into matlab.
    % *** Only reads a subset of all possible NPY files, specifically N-D arrays of certain data types.
    % See https://github.com/kwikteam/npy-matlab/blob/master/tests/npy.ipynb for
    % more.
    %
    
    [shape, dataType, fortranOrder, littleEndian, totalHeaderLength, ~] = readNPYheader(filename);
    
    if littleEndian
        fid = fopen(filename, 'r', 'l');
    else
        fid = fopen(filename, 'r', 'b');
    end
    
    try
    
        [~] = fread(fid, totalHeaderLength, 'uint8');

        % read the data
        if strcmp(dataType, 'string') %Assume 513 bytes 
            % add support for different message lengths as needed 
            stringLength = 513; 

            rawData = fread(fid, 'int8');

            data = strings(length(rawData) / stringLength,1);

            for n = 1:length(data)
                text = char(nonzeros(rawData(((n-1)*stringLength+1):n*stringLength)));
                data(n) = string(text(:)');
            end
            
        else
            data = fread(fid, prod(shape), [dataType '=>' dataType]);
        end
    
        if length(shape)>1 && ~fortranOrder
            data = reshape(data, shape(end:-1:1));
            data = permute(data, [length(shape):-1:1]);
        elseif length(shape)>1
            data = reshape(data, shape);
        end
    
        fclose(fid);
    
    catch me
        fclose(fid);
        rethrow(me);
    end

end