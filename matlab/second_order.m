%% Tham số đầu vào
phi = 0;                   % Phi = 0 (mod(d,5)/5)
Ts = 1;                   % Lấy Ts = 1 cho đơn giản (không ảnh hưởng kết quả)
m = 0:40;                 % Vùng tín hiệu rộng
x = cos(2*pi*(m*Ts)/(8*Ts) + phi); % Tín hiệu x1[m] với f_sampling = 8*f_signal

mu_set = 0:1/9:8/9;       % Các giá trị mu
m_interp = 16:32;         % Vùng nội suy

%% Hàm mẫu thật (ground truth)
t_true = m_interp' + mu_set;  % Các thời điểm thực
x_true = cos(2*pi*(t_true/8 + phi)); % Hàm gốc tại các điểm nội suy

%% Nội suy đa thức bậc 2 (Farrow - quadratic)
x_poly2 = zeros(length(m_interp), length(mu_set));
for k = 1:length(m_interp)
    for i = 1:length(mu_set)
        mu = mu_set(i);
        n = m_interp(k) + 1;
        x_poly2(k,i) = 0.5*(1-mu)*(2-mu)*x(n) + mu*(2-mu)*x(n+1) - 0.5*mu*(1-mu)*x(n+2);
    end
end

%% Tính lỗi
err_poly2 = (x_poly2 - x_true).^2;

MSE_poly2 = mean(err_poly2(:));

fprintf('Mean Squared Errors:\n');
fprintf('- Polynomial 2: %.6f\n', MSE_poly2);

%% Plot kết quả nội suy
x_poly2_row = reshape(x_poly2.', [], 1);
x_true_row   = reshape(x_true.', [], 1);

t_sampled = m;

t_interp = reshape(t_true.', [], 1);  % Flatten theo hàng

figure;
hold on;
grid on;

% Vẽ tín hiệu mẫu (gốc) dạng stem
stem(t_sampled, x, 'k', 'filled', 'DisplayName', 'Original Samples');

% Vẽ tín hiệu sau nội suy dạng đường liên tục
plot(t_interp, x_poly2_row, 'r', 'LineWidth', 1.5, 'DisplayName', 'Second-order polynomial Interpolation x1[m]');

% Vẽ giá trị thực (ground truth) nếu muốn so sánh
plot(t_interp, x_true_row, '--b', 'LineWidth', 1.5, 'DisplayName', 'Ground Truth');

% Cài đặt biểu đồ
xlabel('m');
ylabel('Amplitude');
legend;
title('Original Signal vs Second-order polynomial Interpolation x1[m]');

figure;
stem(t_interp, abs(x_poly2_row - x_true_row), 'black', 'LineWidth', 1.5);
xlabel('m');
ylabel('Absolute Error');
title('Absolute Error of Second-order polynomial Interpolation x1[m]');
grid on;
