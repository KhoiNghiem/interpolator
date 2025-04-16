%% Tham số đầu vào
phi = 0;                   % Phi = 0 (mod(d,5)/5)
Ts = 1;                   % Lấy Ts = 1 cho đơn giản (không ảnh hưởng kết quả)
m = 0:40;                 % Vùng tín hiệu rộng
x = cos(2*pi*(m*Ts/(8*Ts) + phi)); % Tín hiệu x1[m] với f_sampling = 8*f_signal

mu_set = 0:1/9:8/9;       % Các giá trị mu
m_interp = 16:32;         % Vùng nội suy

%% Hàm mẫu thật (ground truth)
t_true = m_interp' + mu_set;  % Các thời điểm thực
x_true = cos(2*pi*(t_true/8) + phi); % Hàm gốc tại các điểm nội suy

%% Nội suy tuyến tính
x_linear = zeros(length(m_interp), length(mu_set));
for k = 1:length(m_interp)
    for i = 1:length(mu_set)
        mu = mu_set(i);
        n = m_interp(k)+1;
        x_linear(k,i) = mu*x(n+1) + (1-mu)*x(n);
    end
end

%% Tính lỗi
err_linear = (x_linear - x_true).^2;

MSE_linear = mean(err_linear(:));

fprintf('Mean Squared Errors:\n');
fprintf('- Linear      : %.6f\n', MSE_linear);

x_linear_row = reshape(x_linear.', [], 1);
x_true_row   = reshape(x_true.', [], 1);

% Trục thời gian của tín hiệu đã lấy mẫu (discrete)
t_sampled = m;

% Trục thời gian sau nội suy
t_interp = reshape(t_true.', [], 1);  % Flatten theo hàng

figure;
hold on;
grid on;

% Vẽ tín hiệu mẫu (gốc) dạng stem
stem(t_sampled, x, 'k', 'filled', 'DisplayName', 'Original Samples');

% Vẽ tín hiệu sau nội suy dạng đường liên tục
plot(t_interp, x_linear_row, 'r', 'LineWidth', 1.5, 'DisplayName', 'Linear Interpolation x1[m]');

% Vẽ giá trị thực (ground truth) nếu muốn so sánh
plot(t_interp, x_true_row, '--b', 'LineWidth', 1.5, 'DisplayName', 'Ground Truth');

% Cài đặt biểu đồ
xlabel('m');
ylabel('Amplitude');
legend;
title('Original Signal vs Linear Interpolation x1[m]');

figure;
stem(t_interp, abs(x_linear_row - x_true_row), 'black', 'LineWidth', 1.5);
xlabel('m');
ylabel('Absolute Error');
title('Absolute Error of Linear Interpolation x1[m]');
grid on;



