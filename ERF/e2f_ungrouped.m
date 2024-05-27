%% This code
%  This code is converting the data processed with EEGLAB to Fieldtrip
%  format for further processing.

clear; eeglab nogui;
addpath('C:\Users\eriksam1\Documents\MATLAB\fieldtrip-master');
ft_defaults;

%% init the dirs
indir = 'L:\eeg\lastekatse2021\Erik\data\working\preprocessing\relevantStimuli_update\splitByStimCond';
outdir = 'L:\eeg\lastekatse2021\Erik\data\working\preprocessing\ungrouped';

%% Read files to analyses

% KP -> clinical
% EK -> typically developing


%% Create output folders to save data
stimulus = ["sadam","sada", "vere", ];
condition = ["16"; "32"; "64"];
groupCode = ["EK"; "KP"];
groupName = ["typical"; "clinical"];




for stim = 1:3
    for cond = 1:height(condition)
        for group = 1:height(groupCode)
            
            indir_current = char(strcat(indir ,filesep,groupCode(group),filesep,stimulus(stim), filesep, condition(cond)));

            datafile_dev=dir(char(strcat(indir_current,filesep,'deviant')));
            datafile_dev=datafile_dev(~ismember({datafile_dev.name},{'.', '..', '.DS_Store'}));
            datafile_dev={datafile_dev.name};

            datafile_std=dir(char(strcat(indir_current,filesep,'standard')));
            datafile_std=datafile_std(~ismember({datafile_std.name},{'.', '..', '.DS_Store'}));
            datafile_std={datafile_std.name};

            counter = 1;
            for subject=1:length(datafile_dev)
            disp('subject')
                [filepath,name,ext] = fileparts(char(datafile_dev{subject}));
                if strcmp(ext,'.fdt') | contains(name,'no_usable_data_all_bad_epochs')
                    disp('no_usable_data_all_bad_epochs')
                    continue
                end

                if ~contains(name,groupCode(group))
                    disp('dev')
                    continue
                end
                disp([filepath,name,ext])

                [filepath,name,ext] = fileparts(char(datafile_std{subject}));
                if ~contains(name,groupCode(group))
                    disp('std')
                    continue
                end
                disp([filepath,name,ext])
                name = char(name)

                outdir_current = char(strcat(outdir,filesep,groupName(group),filesep,stimulus(stim), filesep, condition(cond),filesep,'subj',name(1:2)));

                if exist(outdir_current, 'dir') == 0
                    mkdir(outdir_current);
                end



                cfg = []; cfg.dataset = char(strcat(indir_current,filesep,'deviant',filesep,datafile_dev{subject}));
                ft_data_dev = ft_preprocessing(cfg);

                cfg                = [];

                ft_data_dev         = ft_timelockanalysis(cfg, ft_data_dev);
                % Save the data

                cfg = []; cfg.dataset = char(strcat(indir_current,filesep,'standard',filesep,datafile_std{subject}));
                ft_data_std = ft_preprocessing(cfg);

                cfg                = [];

                ft_data_std         = ft_timelockanalysis(cfg, ft_data_std);

                counter = counter + 1;

                save(char(strcat(outdir_current,filesep,'ft_data_std.mat')),'ft_data_std')
                save(char(strcat(outdir_current,filesep,'ft_data_dev.mat')),'ft_data_dev')
            end

        end
    end
end