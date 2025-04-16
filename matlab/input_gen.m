%% Tham số đầu vào
phi = 0;                   % Phi = 0 (mod(d,5)/5)
Ts = 1;                   % Lấy Ts = 1 cho đơn giản (không ảnh hưởng kết quả)
m = 0:40;                 % Vùng tín hiệu rộng
m_interp = 15:35;         % Vùng nội suy
x = cos(2*pi*(m_interp*Ts/(8*Ts) + phi)); % Tín hiệu x1[m] với f_sampling = 8*f_signal

mu_set = 0:1/9:8/9;       % Các giá trị mu

result_all = [];

for k = 1:length(x)
        [S, E, F] = float_to_tf32_manual(x(k));
        result_all = [result_all; S, E, F];
end

% Khởi tạo chuỗi nhị phân rỗng để lưu kết quả
fileID = fopen('input_xm.txt', 'w');   % Mở file để ghi

% Duyệt qua từng dòng trong result_all
for i = 1:size(result_all, 1)  % Duyệt qua các dòng
    binary_string = '';  % Mảng nhị phân rỗng cho mỗi dòng
    
    % Duyệt qua từng cột trong dòng i
    for j = 1:size(result_all, 2)  % Duyệt qua các cột
        % Chuyển phần tử result_all(i,j) thành chuỗi nhị phân (1 bit cho mỗi phần tử)
        binary_string = [binary_string, dec2bin(result_all(i,j), 1)];  % 1 bit cho mỗi phần tử
    end
    
    % Ghi chuỗi nhị phân của dòng vào file và thêm dấu xuống dòng
    fprintf(fileID, '%s\n', binary_string);   % Ghi chuỗi nhị phân và xuống dòng
end

% Đóng file
fclose(fileID);
