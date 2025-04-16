function [S, E_str, F_str] = float_to_tf32_manual(x)
    
    if x == 0
        S = '0';
        E_str = '00000000';  % Exponent là tất cả 0s
        F_str = '0000000000'; % Mantissa là tất cả 0s
    else
        % Bước 1: Lấy dấu
        if x < 0
            S = '1';
            x = -x;
        else 
            S = '0';
        end

        % Bước 2: Chuẩn hóa số (dạng 1.xxx * 2^e)
        e = 0;
        while x >= 2
            x = x / 2;
            e = e + 1;
        end
        while x < 1 && x ~= 0
            x = x * 2;
            e = e - 1;
        end    
        % Bước 3: Mã hóa exponent
        E = e + 127;  % Bias = 127
        E_bin = dec2bin(E, 8);  % 8 bit exponent nhị phân
        E = arrayfun(@(c) str2double(c), E_bin);  % Chuyển thành mảng số
        E_str = strrep(num2str(E), ' ', '');
        % Bước 4: Mã hóa mantissa (chỉ lấy 10 bits đầu)
        frac = x - 1;  % bỏ số 1. phía trước
        F = zeros(1,10);
        for i = 1:10
            frac = frac * 2;
            if frac >= 1
                F(i) = 1;
                frac = frac - 1;
            end
        end
        F_str = strrep(num2str(F), ' ', '');
    end
end
