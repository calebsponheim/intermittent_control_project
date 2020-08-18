function params = init_paramsBreaux_CS() 

params.monkey = 'Bx';
params.monkeyLong = 'Breaux';
params.session = '180323';
params.array = 'M1l';
params.taskCondition = 'delay';
params.task = 'center-out';
params.codeDir = '\\prfs.cri.uchicago.edu\nicho-lab\caleb_sponheim\intermittent_control\code\';
params.dataDir = '';%'D:\vp hatlab\data\Breaux\';
params.dataDirServer = ['\\prfs.cri.uchicago.edu\nicho-lab\Data\all_raw_datafiles_7\Breaux\2018\' params.session(1:6) '\'];
% params.kinarmFileDir = '\\prfs.cri.uchicago.edu\nicho-lab\Data\all_raw_datafiles_7\Breaux\kinarmFiles\';
params.plotDir = '\\prfs.cri.uchicago.edu\nicho-lab\caleb_sponheim\intermittent_control\figures\';

end