function [] = plot_transition_matrix(subject,task,num_states_subject,hn_trained)

current_date_and_time = char(datetime(now,'ConvertFrom','datenum'));
current_date_and_time = erase(current_date_and_time,' ');
current_date_and_time = erase(current_date_and_time,':');
current_date_and_time = current_date_and_time(1:end-4);
mkdir(['\\prfs.cri.uchicago.edu\nicho-lab\caleb_sponheim\intermittent_control\figures\',subject,task,num2str(num_states_subject),'states',current_date_and_time])

figure; hold on;
imagesc(hn_trained.a)
colormap(gca,jet)
axis square
axis tight
colorbar
xlabel('next state number')
ylabel('previous state number')
if strcmp(task,'center_out')
    title([subject,' center out transition probabilities']);
else
    title([subject,' ',strrep(task,'_',' '),' transition probabilities']);
end
box off
set(gcf,'Color','White');
saveas(gcf,strcat('\\prfs.cri.uchicago.edu\nicho-lab\caleb_sponheim\intermittent_control\figures\',subject,task,num2str(num_states_subject),'states',current_date_and_time,'\'...
    ,subject,task,num2str(num_states_subject),'states_transition_matrix.png'));


end