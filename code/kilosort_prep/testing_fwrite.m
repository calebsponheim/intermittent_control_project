%Testing fwrite

file2save = 'binary_data_fwrite_test.dat';

data = rand(10);

for iStep = 1:10
    fidW = fopen(file2save, 'w');
    df = int16(data(iStep,:));
    fwrite(fidW, df, 'int16');
    fclose(fidW);
end

%%

fidW = fopen(file2save, 'a');
fscanf(fidW,'%i')