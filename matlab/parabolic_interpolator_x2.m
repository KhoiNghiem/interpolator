
%% Tham số đầu vào
phi = 0;                   % Phi = 0 (mod(d,5)/5)
Ts = 1;                   % Lấy Ts = 1 cho đơn giản (không ảnh hưởng kết quả)
m = 0:40;                 % Vùng tín hiệu rộng
x = 2^-15*cos(2*pi*(2*m*Ts/(5*Ts)) + phi); % Tín hiệu x1[m] với f_sampling = 8*f_signal

mu_set = 0:1/9:8/9;       % Các giá trị mu
m_interp = 5:10;         % Vùng nội suy

%% Hàm mẫu thật (ground truth)
t_true = m_interp' + mu_set;  % Các thời điểm thực
x_true = 2^-15*cos(2*pi*(2*t_true/5) + phi); % Hàm gốc tại các điểm nội suy

%% Nội suy piecewise parabolic
alpha = 0.5;
x_parabolic = zeros(length(m_interp), length(mu_set));
for k = 1:length(m_interp)
    for i = 1:length(mu_set)
        mu = mu_set(i);
        n = m_interp(k) + 1;

        C1   = -alpha*mu + alpha*mu^2;
        C0   = 1 + (alpha - 1)*mu - alpha*mu^2;
        Cm1  = (alpha + 1)*mu - alpha*mu^2;
        Cm2  = -alpha*mu + alpha*mu^2;

        x_parabolic(k,i) = C1*x(n-1) + C0*x(n) + Cm1*x(n+1) + Cm2*x(n+2);
    end
end

%% Tính lỗi
err_parabolic = (x_parabolic - x_true).^2;

MSE_parabolic = mean(err_parabolic(:));

fprintf('Mean Squared Errors:\n');
fprintf('- Parabolic   : %.6f\n', MSE_parabolic);

%% Plot kết quả nội suy
%% Plot kết quả nội suy
x_parabolic_row = reshape(x_parabolic.', [], 1);
x_true_row   = reshape(x_true.', [], 1);

t_sampled = m;

t_interp = reshape(t_true.', [], 1);  % Flatten theo hàng

figure;
hold on;
grid on;

% Vẽ tín hiệu mẫu (gốc) dạng stem
stem(t_sampled, x, 'k', 'filled', 'DisplayName', 'Original Samples');

% Vẽ tín hiệu sau nội suy dạng đường liên tục
plot(t_interp, x_parabolic_row, 'r', 'LineWidth', 1.5, 'DisplayName', 'Piecewise parabolic Interpolation x2[m]');

% Vẽ giá trị thực (ground truth) nếu muốn so sánh
plot(t_interp, x_true_row, '--b', 'LineWidth', 1.5, 'DisplayName', 'Ground Truth');

% Cài đặt biểu đồ
xlabel('m');
ylabel('Amplitude');
legend;
title('Original Signal vs Piecewise parabolic Interpolation x2[m]');

figure;
stem(t_interp, abs(x_parabolic_row - x_true_row), 'black', 'LineWidth', 1.5);
xlabel('m');
ylabel('Absolute Error');
title('Absolute Error of Piecewise parabolic Interpolation x2[m]');
grid on;

