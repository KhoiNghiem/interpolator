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

% Chuyển mu_set sang TF32 dạng string nhị phân
tf32_str_mu = cell(1, length(mu_set));  % Mỗi phần tử là char array

for i = 1:length(mu_set)
    [S, E, F] = float_to_tf32_manual(mu_set(i));
    tf32_str_mu{i} = [S, E, F];  % Gán char array vào cell
end

% Chuyển x sang TF32 dạng string nhị phân
tf32_str_x = cell(1, length(x));

for i = 1:length(x)
    [S, E, F] = float_to_tf32_manual(x(i));
    tf32_str_x{i} = [S, E, F];  % Chuỗi nhị phân TF32
end


%% Nội suy piecewise parabolic
alpha_1 = 1;

[S_alpha_1, E_str_alpha_1, F_str_E_str_alpha_1] = float_to_tf32_manual(alpha_1);
alpha_1_tf32 = [S_alpha_1, E_str_alpha_1, F_str_E_str_alpha_1];

alpha = 0.5;

[S_alpha, E_str_alpha, F_str_E_str_alpha] = float_to_tf32_manual(alpha);
alpha_tf32 = [S_alpha, E_str_alpha, F_str_E_str_alpha];

alpha_m_1_5 = 1.5;

[S_alpha_1_5, E_str_alpha_1_5, F_str_E_str_alpha_1_5] = float_to_tf32_manual(alpha_m_1_5);
alpha_1_5_tf32 = [S_alpha_1_5, E_str_alpha_1_5, F_str_E_str_alpha_1_5];

x_parabolic_tf32 = cell(length(m_interp), length(mu_set));
x_parabolic_float = zeros(size(x_parabolic_tf32));

for k = 1:length(m_interp)
    for i = 1:length(mu_set)
        
        n = m_interp(k) + 1;
        
        mu_str = tf32_str_mu{i};
        
        [mu_squared, ~, ~, ~, ~] = tf32_mul_bittrue(mu_str, mu_str);
        [neg_alpha_mu, ~, ~, ~, ~] = tf32_mul_bittrue(alpha_tf32, mu_str);
        [alpha_mu2, ~, ~, ~, ~] = tf32_mul_bittrue(alpha_tf32, mu_squared);
        [C1, ~, ~] = tf32_add_bittrue(alpha_mu2, neg_alpha_mu, 1);
        
        [alpha_sub1_mu, ~, ~, ~, ~] = tf32_mul_bittrue(alpha_tf32, mu_str);
        [tmp_C0, ~, ~] = tf32_add_bittrue(alpha_1_tf32, alpha_sub1_mu, 1); % 1-0.5*mu
        [C0, ~, ~]     = tf32_add_bittrue(tmp_C0, alpha_mu2, 1);  % trừ alpha*mu^2
        
        [alpha_plus1_mu, ~, ~, ~, ~] = tf32_mul_bittrue(alpha_1_5_tf32, mu_str);  % 1.5 * mu
        
        % Cm1 = (alpha + 1)*mu - alpha*mu^2
        [Cm1, ~, ~] = tf32_add_bittrue(alpha_plus1_mu, alpha_mu2, 1);
       
        
        x_n_1 = tf32_str_x{n - 1};
        x_n   = tf32_str_x{n};
        x_n1  = tf32_str_x{n + 1};
        x_n2  = tf32_str_x{n + 2};
        
        % Nhân từng hệ số với x tương ứng
        [term1, ~, ~, ~, ~] = tf32_mul_bittrue(C1, x_n_1);
        [term2, ~, ~, ~, ~] = tf32_mul_bittrue(C0, x_n);
        [term3, ~, ~, ~, ~] = tf32_mul_bittrue(Cm1, x_n1);
        [term4, ~, ~, ~, ~] = tf32_mul_bittrue(C1, x_n2);  % Cm2 = C1

        % Tổng 4 term lại
        [sum1, ~, ~] = tf32_add_bittrue(term1, term2, 0);
        [sum2, ~, ~] = tf32_add_bittrue(sum1, term3, 0);
        [final_result, ~, ~] = tf32_add_bittrue(sum2, term4, 0);

        % Lưu kết quả TF32 dạng string
        x_parabolic_tf32{k,i} = final_result;
    end
end

for k = 1:size(x_parabolic_tf32,1)
    for i = 1:size(x_parabolic_tf32,2)
        tf32_bin = x_parabolic_tf32{k,i};  % Lấy chuỗi nhị phân dạng TF32

        % Tách S, E, F từ chuỗi TF32
        S = bin2dec(tf32_bin(1));           % Bit dấu
        E = tf32_bin(2:9);         % 8-bit exponent
        F = tf32_bin(10:end);      % 10-bit fraction (TF32 mantissa)

        % Gọi hàm chuyển sang float
        x_parabolic_float(k,i) = tf32_to_float_manual(S, E, F);
    end
end


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


%% Plot kết quả nội suy
x_parabolic_row_tf32 = reshape(x_parabolic_float.', [], 1);  % TF32 kết quả
x_parabolic_row_double = reshape(x_parabolic.', [], 1);      % Kết quả nội suy double (Matlab)
x_true_row = reshape(x_true.', [], 1);                       % Ground truth theo công thức lý thuyết

t_interp = reshape(t_true.', [], 1);  % Thời gian tương ứng các điểm nội suy

t_sampled = m;

figure;
hold on;
grid on;

% Vẽ tín hiệu mẫu (gốc)
stem(t_sampled, x, 'k', 'filled', 'DisplayName', 'Original Samples');

% Vẽ tín hiệu TF32
plot(t_interp, x_parabolic_row_tf32, 'r', 'LineWidth', 1.5, 'DisplayName', 'TF32 Bittrue Interpolation');

% Vẽ tín hiệu nội suy Matlab double
plot(t_interp, x_parabolic_row_double, '--g', 'LineWidth', 1.5, 'DisplayName', 'Matlab Double Interpolation');

% Vẽ ground truth
plot(t_interp, x_true_row, '--b', 'LineWidth', 1.5, 'DisplayName', 'Ground Truth (Cosine)');

% Cài đặt biểu đồ
xlabel('m');
ylabel('Amplitude');
legend('Location', 'best');
title('Piecewise Parabolic Interpolation Comparison: TF32 vs Double vs Ground Truth x2[m]');


figure;
stem(t_interp, abs(x_parabolic_row_tf32 - x_parabolic_row_double), 'black', 'LineWidth', 1.5);
xlabel('m');
ylabel('Absolute Error');
title('Absolute Error of Piecewise parabolic Interpolation x2[m] Bitrue Model');
grid on;

%% MSE
mse_double = mean((x_parabolic_row_double - x_parabolic_row_tf32).^2);
fprintf('MSE (TF32 vs Matlab Double): %.6e\n', mse_double);