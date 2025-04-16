
%% Tham số đầu vào
phi = 0;                   % Phi = 0 (mod(d,5)/5)
Ts = 1;                   % Lấy Ts = 1 cho đơn giản (không ảnh hưởng kết quả)
m = 0:40;                 % Vùng tín hiệu rộng
m_interp = 4:13;         % Vùng nội suy
x = (2^-15)*cos(2*pi*(2*m_interp*Ts/(5*Ts)) + phi); % Tín hiệu x1[m] với f_sampling = 8*f_signal

mu_set = 0:1/9:8/9;       % Các giá trị mu


result_all = [];

for k = 1:length(x)
        [S, E, F] = float_to_tf32_manual(x(k));
        result_all = [result_all; S, E, F];
end

% Khởi tạo chuỗi nhị phân rỗng để lưu kết quả
fileID = fopen('input_x2m.txt', 'w');   % Mở file để ghi

% Ghi từng dòng của result_all
for i = 1:size(result_all, 1)
    fprintf(fileID, '%s\n', result_all(i, :));
end
% Đóng file
fclose(fileID);
