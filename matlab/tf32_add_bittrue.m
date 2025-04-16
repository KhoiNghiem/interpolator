function [result, x_float, exception] = tf32_add_bittrue(a, b, issub)
    
    if bin2dec(a(2:19)) < bin2dec(b(2:19))
        comp_enable = '1';
        operand_a = b;
        operand_b = a;
    else
        comp_enable = '0';
        operand_a = a;
        operand_b = b;
    end
    exception_a = all(operand_a(2:9) == '1');
    exception_b = all(operand_b(2:9) == '1');

    % Kết quả exception là true nếu bất kỳ exponent nào có tất cả bit là 1
    exception = exception_a | exception_b;
    
    if issub == 1
        if comp_enable == '1'
            output_sign = dec2bin(~bin2dec(operand_a(1)), 1);  % Đảo ngược bit thứ 18 của operand_a
        else
            output_sign = operand_a(1);
        end
    else
        output_sign = operand_a(1);
    end
    
    if issub == 1
        operation_sub_add = bitxor(bin2dec(operand_a(1)), bin2dec(operand_b(1)));  % Phép XOR giữa bit thứ 18 của operand_a và operand_b
    else
        operation_sub_add = ~(bitxor(bin2dec(operand_a(1)), bin2dec(operand_b(1))));  % Phủ định kết quả XOR
    end
    
    if any(operand_a(2:9) == '1')  % Kiểm tra nếu có bất kỳ bit nào trong exponent là 1
        mantissa_a = ['1', operand_a(10:end)];  % Đặt bit ẩn là 1
    else
        mantissa_a = ['0', operand_a(10:end)];  % Đặt bit ẩn là 0
    end
    
    if any(operand_b(2:9) == '1')  % Kiểm tra nếu có bất kỳ bit nào trong exponent là 1
        mantissa_b = ['1', operand_b(10:end)];  % Đặt bit ẩn là 1
    else
        mantissa_b = ['0', operand_b(10:end)];  % Đặt bit ẩn là 0
    end

    exponent_diff = bin2dec(operand_a(2:9)) - bin2dec(operand_b(2:9));
    
    mantissa_b_add_sub = bitshift(bin2dec(mantissa_b), -exponent_diff);   % Dùng dịch phải thôi, dịch trái ngu vl
    
    exp_b_add_sub = bin2dec(operand_b(2:9)) + exponent_diff;
    
    if bin2dec(operand_a(2:9)) == exp_b_add_sub
        exp_equal = 1;
    else
        exp_equal = 0;
    end
    
    if exp_equal && operation_sub_add
    % Nếu cả hai điều kiện đều đúng, thực hiện phép cộng
        mantissa_add = dec2bin(bin2dec(mantissa_a) + mantissa_b_add_sub, 12);
    else
        % Nếu không, gán giá trị 0
        mantissa_add = '000000000000';  % Tạo mảng 12 bit, tất cả các phần tử là 0
    end
    
    if mantissa_add(1) == '1'  % Vì MATLAB tính chỉ số từ 1, bit 1 tương đương với bit 11 trong Verilog
        % Nếu bit 11 là 1, lấy các bit từ 10 đến 1
        add_sum_9_0 = mantissa_add(2:11);    % add_sum 10 bit
    else
        % Nếu bit 11 là 0, lấy các bit từ 9 đến 0
        add_sum_9_0 = mantissa_add(3:12);
    end
    
    if mantissa_add(1) == '1'  % Vì MATLAB tính chỉ số từ 1, bit 1 tương đương với bit 11 trong Verilog
        % Nếu bit 11 là 1, lấy các bit từ 10 đến 1
        add_sum_17_10 = dec2bin(bin2dec(operand_a(2:9)) + 1, 8);   % exponent 8 bit
    else
        % Nếu bit 11 là 0, lấy các bit từ 9 đến 0
        add_sum_17_10 = operand_a(2:9);
    end
    
    add_sum = strcat(add_sum_17_10, add_sum_9_0);
    
    if exp_equal && ~operation_sub_add
        % Lấy bit phủ định của significand_b_add_sub và cộng 1 (phép 2's complement)
        inverted_bin = strrep(dec2bin(mantissa_b_add_sub, 11), '1', 'X');  % Tạm thay '1' bằng 'X'
        inverted_bin = strrep(inverted_bin, '0', '1');  % Thay '0' bằng '1'
        inverted_bin = strrep(inverted_bin, 'X', '0');  % Thay 'X' bằng '0'
        if inverted_bin == '11111111111'
            mantissa_sub_compl = '00000000000';  % 11 bit 0
        else
            mantissa_sub_compl = dec2bin(bin2dec(inverted_bin) + 1, 11);  % 2's complement ???
        end
    else
        % Nếu không thì gán 11 bit 0
        mantissa_sub_compl = '00000000000';  % 11 bit 0
    end
    
    if exp_equal
        % Lấy bit phủ định của significand_b_add_sub và cộng 1 (phép 2's complement)
        mantissa_sub = dec2bin(bin2dec(mantissa_a) + bin2dec(mantissa_sub_compl), 12);  % 2's complement
    else
        % Nếu không thì gán 11 bit 0
        mantissa_sub = '000000000000';  % 11 bit 0
    end
    
    exp_a = operand_a(2:9);
    
    significand = bin2dec(mantissa_sub);
    
    if exception
        result = '0000000000000000000';
        x_float = 0;
    else
        if ~operation_sub_add
            [subtraction_diff, exp_sub] = priority_encoder(significand, exp_a);
    
            sub_diff_17_10 = dec2bin(exp_sub, 8);
            subtraction_diff_bin = dec2bin(subtraction_diff, 12);
            sub_diff_9_0 = subtraction_diff_bin(3:12);

            sub_diff = strcat(sub_diff_17_10, sub_diff_9_0);
            % Nếu operation_sub_addBar là false, nối output_sign và sub_diff
            result = strcat(output_sign, sub_diff);  % Nối output_sign và sub_diff
            x_float = tf32_to_float_manual(bin2dec(output_sign), sub_diff_17_10, sub_diff_9_0);
        else
            % Nếu operation_sub_addBar là true, nối output_sign và add_sum
            result = strcat(output_sign, add_sum);  % Nối output_sign và add_sum
            x_float = tf32_to_float_manual(bin2dec(output_sign), add_sum_17_10, add_sum_9_0);
        end
    end
end

