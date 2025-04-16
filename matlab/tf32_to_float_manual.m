function x = tf32_to_float_manual(S, E, F)
    F = double(F) - '0';  % Chuyển F từ chuỗi ký tự thành mảng số 0 và 1.

    % Kiểm tra exponent có phải là denormalized (00000000)?
    if E == '00000000'
        exp = -126;  % Exponent cho denormalized số là -126.
        % Mantissa không có bit ẩn (ẩn = 0), chỉ có các bit F
        mant = sum(F .* 2.^-(1:length(F)));  % Tính mantissa cho denormalized số
    else
        exp = bin2dec(E) - 127;  % Exponent chuẩn (normalized).
        % Mantissa có bit ẩn = 1
        mant = 1 + sum(F .* 2.^-(1:length(F)));
    end

    % Tính giá trị cuối cùng
    x = mant * 2^exp;

    % Áp dụng dấu
    if S == 1
        x = -x;
    end
end
