function [resulst, x_float, exception, overflow, underflow] = tf32_mul_bittrue(a, b)
    tfa = parse_tf32_bin(a);
    tfb = parse_tf32_bin(b);

    % Sign
    s = num2str(xor(tfa.sign, tfb.sign));

    % Add implicit 1
    
    check_a = all(dec2bin(tfa.exp, 8) == '1');  % Kiểm tra các bit từ 17 đến 10 của tfa.exp (vị trí 2 đến 8 trong chuỗi nhị phân)
    check_b = all(dec2bin(tfb.exp, 8) == '1');  % Kiểm tra các bit từ 17 đến 10 của tfb.exp (vị trí 2 đến 8 trong chuỗi nhị phân)
    
    exception = check_a|check_b;
    
    if any(dec2bin(tfa.exp, 8) == '1')
        operand_a = ['1', dec2bin(tfa.frac, 10)];
    else
        operand_a = ['0', dec2bin(tfa.frac, 10)];
    end
    
    if any(dec2bin(tfb.exp, 8) == '1')
        operand_b = ['1', dec2bin(tfb.frac, 10)];
    else
        operand_b = ['0', dec2bin(tfb.frac, 10)];
    end

    % Chuyển chuỗi nhị phân thành số nguyên (decimal)
    decimal_a = bin2dec(operand_a);
    decimal_b = bin2dec(operand_b);

    % Nhân hai số nguyên
    result_decimal = decimal_a * decimal_b;
    
    product = dec2bin(result_decimal, 22);
    
    if product(1) == '1'
        normalised = 1;
        % Dịch chuỗi nhị phân sang trái theo số lượng bit 0 đã đếm được
        product_normalised = product;
        
    else  
        normalised = 0;
        product_normalised = circshift(product, -(normalised + 1));  % Dịch chuỗi sang trái
    end
    
    last_10_bits = product_normalised(end-9:end);
    
    isround = any(last_10_bits == '1');
    
    mantissa_bits = product_normalised(2:11);
    
    bit_12 = product_normalised(12);
    
    if isround == 1 && bit_12 == '1'
        % Nếu cần làm tròn, ta thực hiện phép cộng 1 vào bit cuối của mantissa
        carry = 1;  % Khởi tạo giá trị carry bằng 1 (cộng thêm 1)

        % Lặp qua các bit của mantissa từ cuối đến đầu để cộng carry
        for i = length(mantissa_bits):-1:1
            if mantissa_bits(i) == '1' && carry == 1
                mantissa_bits(i) = '0';  % Nếu bit hiện tại là 1 và có carry, ta đổi thành 0
                carry = 1;  % Carry vẫn mang 1 sang bit tiếp theo
            elseif mantissa_bits(i) == '0' && carry == 1
                mantissa_bits(i) = '1';  % Nếu bit hiện tại là 0 và có carry, ta đổi thành 1
                carry = 0;  % Carry hết (không mang theo nữa)
            end
        end
    end
    
    product_mantissa = mantissa_bits;
    sum_exponent = tfa.exp + tfb.exp;
    
        % Kiểm tra giá trị zero
    if exception == 1
        zero = 0;  % Nếu có ngoại lệ, zero = 0
    elseif (all(product_mantissa == '0')) && (sum_exponent == 127)
        zero = 1;  % Nếu product_mantissa = 0, zero = 1
    else
        zero = 0;  % Nếu không có ngoại lệ và product_mantissa khác 0, zero = 0
    end
    
    if sum_exponent==127
        sum_exponent = sum_exponent + 1;
    end
    
    %sum_exponent_bin = dec2bin(sum_exponent, 9);
    
    exponent = sum_exponent - 127 + normalised;   
    
    exponent_bin = dec2bin(exponent, 9);
 
    overflow = (str2double(exponent_bin(1)) & ~str2double(exponent_bin(2))) & ~zero;
    
    underflow_flag = (str2double(exponent_bin(1)) & str2double(exponent_bin(2))) & ~zero;
    % Kiểm tra underflow
    if underflow_flag
        underflow = 1;
    else
        underflow = 0;
    end
    
    if exception == 1
        resulst = '0000000000000000000';  % exception -> res = 0
        x_float = 0;
    elseif zero == 1 || overflow == 1 || underflow == 1
        % Nếu zero, overflow hoặc underflow, res = {sign, 18'd0}
        resulst = '0000000000000000000';  % Tạo mảng kết hợp sign và 18 bit 0
        x_float = 0;
    else
        % Nếu không có exception, zero, overflow, underflow, res = {sign, exponent[7:0], product_mantissa}
        resulst = [s, exponent_bin(2:9), product_mantissa];
        x_float = tf32_to_float_manual(bin2dec(s), exponent_bin(2:9), product_mantissa);
    end
    
end
