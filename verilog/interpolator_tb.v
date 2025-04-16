module interpolator_tb();
    reg clk;
    reg rst_n;
    reg [18:0] Intplt;
    reg [18:0] mu;
    wire [18:0] IntpOut;

    localparam NUM_DATA = 9;
    localparam NUM_MU = 9;

    reg [18:0] input_data [0:NUM_DATA-1]; 
    reg [18:0] input_mu [0:NUM_MU-1]; 

    integer i_x;
    integer i_mu;
    integer fd_x;
    integer fd_mu;
    integer fd_out;

    interpolator uut(
        .clk(clk),
        .rst_n(rst_n),
        .Intplt(Intplt),
        .mu(mu),
        .IntpOut(IntpOut)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;  // Toggle clock every 5 time units
    end

    // Reset logic
    initial begin
        rst_n = 0;
        #10 rst_n = 1;
    end

    initial begin
        fd_x = $fopen("input_x2m.txt", "r");
        if (fd_x == 0) begin
            $display("Error: Could not open input file.");
            $finish;
        end

        // Đọc dữ liệu từ file vào mảng
        for (i_x = 0; i_x < NUM_DATA; i_x = i_x + 1) begin
            $fscanf(fd_x, "%b\n", input_data[i_x]);  // Đọc giá trị dưới dạng số thực
        end

        $fclose(fd_x);
    end

    initial begin
        fd_mu = $fopen("input_mu.txt", "r");
        if (fd_mu == 0) begin
            $display("Error: Could not open input file.");
            $finish;
        end

        // Đọc dữ liệu từ file vào mảng
        for (i_mu = 0; i_mu < NUM_MU; i_mu = i_mu + 1) begin
            $fscanf(fd_mu, "%b\n", input_mu[i_mu]);  // Đọc giá trị dưới dạng số thực
        end

        $fclose(fd_mu);
    end

    

    initial begin
        // Reset filter
        #10;

        for (i_x = 0; i_x < NUM_DATA; i_x = i_x + 1) begin
            Intplt = input_data[i_x];
            for (i_mu = 0; i_mu < NUM_MU; i_mu = i_mu + 1) begin
                mu = input_mu[i_mu];
                #10;
            end
        end
    end

    initial begin
        fd_out = $fopen("output_x2.txt", "w");
        if (fd_out == 0) begin
            $display("Error: Could not open output file.");
            $finish;
        end
    end

    reg[15:0] count_output;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            count_output <= 0;
        end else begin
            count_output <= count_output + 1;
        end
    end

    always @(posedge clk) begin
        // if (count_output > 8'd27 && count_output < 8'd181) begin
        if (count_output > 27 && count_output < 82) begin
            // Ghi giá trị data_out vào file dưới dạng nhị phân
            $fdisplay(fd_out, "%b", IntpOut);  // Lưu dữ liệu dưới dạng nhị phân
        end
    end

    // Đóng file output sau khi kết thúc mô phỏng
    initial begin
        #5000;  // Đợi thời gian đủ để ghi dữ liệu
        $fclose(fd_out);
    end

endmodule
