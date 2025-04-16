function [mantissa_shift, exp_sub] = priority_encoder(mantissa, exp_a)

    matissa_bin = dec2bin(mantissa, 12);
    shift = 0;
    if matissa_bin(1) == '1'
        if strcmp(matissa_bin(2), '1')
            shift = 0;
            shifted_part = matissa_bin(shift + 1:end);   
            Significand_bin = [shifted_part repmat('0', 1, shift)];
			mantissa_shift = bin2dec(Significand_bin);
        elseif strcmp(matissa_bin(2:3), '01')
            shift = 1;
            shifted_part = matissa_bin(shift + 1:end);   
            Significand_bin = [shifted_part repmat('0', 1, shift)];
            mantissa_shift = bin2dec(Significand_bin);
        elseif strcmp(matissa_bin(2:4), '001')
            shift = 2;
            shifted_part = matissa_bin(shift + 1:end);   % từ vị trí 6 đến 10
            Significand_bin = [shifted_part repmat('0', 1, shift)];
            mantissa_shift = bin2dec(Significand_bin);
        elseif strcmp(matissa_bin(2:5), '0001')
            shift = 3;
            shifted_part = matissa_bin(shift + 1:end);   % từ vị trí 6 đến 10
            Significand_bin = [shifted_part repmat('0', 1, shift)];
            mantissa_shift = bin2dec(Significand_bin);
        elseif strcmp(matissa_bin(2:6), '00001')
            shift = 4;
            shifted_part = matissa_bin(shift + 1:end);   % từ vị trí 6 đến 10
            Significand_bin = [shifted_part repmat('0', 1, shift)];
            mantissa_shift = bin2dec(Significand_bin);
        elseif strcmp(matissa_bin(2:7), '000001')
            shift = 5;
            shifted_part = matissa_bin(shift + 1:end);   % từ vị trí 6 đến 10
            Significand_bin = [shifted_part repmat('0', 1, shift)];
            mantissa_shift = bin2dec(Significand_bin);
        elseif strcmp(matissa_bin(2:8), '0000001')
            shift = 6;    
            shifted_part = matissa_bin(shift + 1:end);   % từ vị trí 6 đến 10
            Significand_bin = [shifted_part repmat('0', 1, shift)];
            mantissa_shift = bin2dec(Significand_bin);
        elseif strcmp(matissa_bin(2:9), '00000001')
            shift = 7;
            shifted_part = matissa_bin(shift + 1:end);   % từ vị trí 6 đến 10
            Significand_bin = [shifted_part repmat('0', 1, shift)];
            mantissa_shift = bin2dec(Significand_bin);
        elseif strcmp(matissa_bin(2:10), '000000001')
            shift = 8;
            shifted_part = matissa_bin(shift + 1:end);   % từ vị trí 6 đến 10
            Significand_bin = [shifted_part repmat('0', 1, shift)];
            mantissa_shift = bin2dec(Significand_bin);
        elseif strcmp(matissa_bin(2:11), '0000000001')
            shift = 9;
            shifted_part = matissa_bin(shift + 1:end);   % từ vị trí 6 đến 10
            Significand_bin = [shifted_part repmat('0', 1, shift)];
            mantissa_shift = bin2dec(Significand_bin);
        elseif strcmp(matissa_bin(2:12), '00000000001')
            shift = 10;
            shifted_part = matissa_bin(shift + 1:end);  
            Significand_bin = [shifted_part repmat('0', 1, shift)];
            mantissa_shift = bin2dec(Significand_bin);
        else
            shift = 11;
            shifted_part = matissa_bin(shift + 1:end);  
            Significand_bin = [shifted_part repmat('0', 1, shift)];
            mantissa_shift = bin2dec(Significand_bin);     
        end
    else
            mantissa_shift = mantissa + 1;
			shift = 0;
    end
    % Calculate exp_sub
    exp_sub = bin2dec(exp_a) - shift;
end