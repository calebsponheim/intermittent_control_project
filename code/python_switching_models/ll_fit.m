filepath_base = 'C:\Users\calebsponheim\Documents\git\intermittent_control_project\data\python_switching_models\';
% filepath = [filepath_base 'Bxcenter_out1902280.05_sBins_move_window_only\'];
% filepath = [filepath_base 'Bxcenter_out1902280.05sBins\'];
% filepath = [filepath_base 'Bxcenter_out_and_RTP1902280.05sBins\'];
% filepath = [filepath_base 'RSCO0.05sBins\'];
% filepath = [filepath_base 'RSCO_move_window0.05sBins\'];
% filepath = [filepath_base 'RSRTP0.05sBins\'];
filepath = [filepath_base 'RJRTP0.05sBins\'];

select_ll = readmatrix(...
    [filepath 'select_ll.csv']...
    );
select_ll = select_ll(2:end);

state_range = readmatrix(...
    [filepath 'num_states.csv']...
    );
state_range = state_range(2:end);


curve_exp = fit(state_range,select_ll,'exp2');
figure; hold on
plot(curve_exp,state_range,select_ll)
title(filepath);