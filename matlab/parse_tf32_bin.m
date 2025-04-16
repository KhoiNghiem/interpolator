function tf = parse_tf32_bin(bin_str)
    tf.sign = str2double(bin_str(1));
    tf.exp  = bin2dec(bin_str(2:9));
    tf.frac = bin2dec(bin_str(10:19)); % 10 bit fraction
end
