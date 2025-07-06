module interpolator_tb();
    reg clk;
    reg rst_n;
    reg [18:0] Intplt;
    reg [18:0] mu;
    wire [18:0] IntpOut;

    localparam NUM_DATA = 21;
    localparam NUM_MU = 9;

    reg [18:0] input_data [0:NUM_DATA-1]; 
    reg [18:0] input_mu [0:NUM_MU-1]; 

    integer i_x;
    integer i_mu;
    integer fd_x;
    integer fd_mu;

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
        fd_x = $fopen("input_xm.txt", "r");
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
        #100;

        for (i_x = 0; i_x < NUM_DATA; i_x = i_x + 1) begin
            Intplt = input_data[i_x];
            for (i_mu = 0; i_mu < NUM_MU; i_mu = i_mu + 1) begin
                mu = input_mu[i_mu];
                #10;
            end
        end
    end

endmodule
