figure;hold on
plot(dc(5).prob')
title('trial 5 probabilities')
xlabel('timebin count (50ms)')
ylabel('state probability')
box off
set(gcf,'color','white','Position', [100 100 1200 400])
legend('state 1','state 2','state 3','state 4','state 5')
saveas(gcf,'\\prfs.cri.uchicago.edu\nicho-lab\caleb_sponheim\intermittent_control\figures\trial_5_probabilities_5states_Bx_190228_M1l.png')