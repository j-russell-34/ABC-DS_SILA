%script to estimate years from disease onset in the ABCDS cohort

%% add filepath to SILA
path = '/Users/jasonrussell/Documents/code/SILA-AD-Biomarker';
addpath(fullfile(path));

%% import data in long form
t = readtable('/Users/jasonrussell/Documents/OUTPUTS/sila_A001/ABC_DS_sila_tall.csv');

%% train the SILA model
disp('Training the SILA model using SILA.m')
[tsila,tdrs] = SILA(t.age,t.centiloid_value,t.fsid_base,0.25,18,200,0.6);

%% Estimate time to threshold and age at threshold for each subject
disp('Generating subject-level estimates with SILA_estimate.m')
test = SILA_estimate(tsila,t.age,t.centiloid_value,t.fsid_base);

%% These plots show the simulated data and some of the SILA outputs
disp('Generating plots of the data')

% spaghetti plot of value vs. age for simulated data
figure('Units','centimeters','Position',[2,2,12,8])
spaghetti_plot(t.age,t.centiloid_value,t.fsid_base)
hold on, plot(xlim,21*[1,1],'--k')
title('Simulated Input Data')
xlabel('Age (years)'),ylabel('Centiloid')

% plots showing the output from descrete rate sampling (i.e., rate vs. value) 
% and modeled value vs. time data.
figure('Units','centimeters','Position',[2,2,12,12])
subplot(2,1,1)
plot(tdrs.val,tdrs.rate,'-'),hold on
plot(tdrs.val,tdrs.rate + tdrs.ci,'--r')
plot(tdrs.val,tdrs.rate - tdrs.ci,'--r')
title('Discrete Rate Sampling Curve')
xlabel('Centiloid'),ylabel('\DeltaCentiloid per Year')

subplot(2,1,2)
plot(tsila.adtime,tsila.val,'-'),hold on
plot(xlim,21*[1,1],'--k')
title('SILA Modeled{\it Value vs. Time} Curve')
xlabel('Time from Threshold'),ylabel('Centiloid')
legend({'Modeled curve','threshold'},'Location','northwest')

% value vs. time for all subjects
figure('Units','centimeters','Position',[2,2,12,8])
spaghetti_plot(test.estdtt0,test.val,test.subid)
plot(tsila.adtime,tsila.val,'-k'),hold on
hold on, plot(xlim,20*[1,1],'--k')
title('Data Aligned by Estimated Time to Threshold')
xlabel('Estimated time to threshold (years)'),ylabel('Centiloid')

% value vs. time for an indivdual case
sub = find(test.estdtt0>1 & test.estdtt0<10,1);
ids = test.subid==test.subid(sub);

figure('Units','centimeters','Position',[2,2,9,12])
subplot(2,1,1)
spaghetti_plot(test.age(ids),test.val(ids),test.subid(ids))
hold on, plot([min(t.age),max(t.age)],20*[1,1],'--k')
title('Observations by Age')
xlabel('Age (years)'),ylabel('Centiloid')
legend({'Individual Case Observations'},'Location','northwest')
ylim([min(tsila.val),max(tsila.val)])
xlim([min(t.age),max(t.age)])

subplot(2,1,2)
spaghetti_plot(test.estdtt0(ids),test.val(ids),test.subid(ids))
plot(tsila.adtime,tsila.val,'-k'),hold on
hold on, plot(xlim,20*[1,1],'--k')
xlim([min(tsila.adtime),max(tsila.adtime)])
title('Observations by Estimated Time to Threshold')
xlabel('Estimated time to threshold (years)'),ylabel('Centiloid')
legend({'Individual Case Observations','SILA Modeled Values'},'Location','northwest')

%% Write estimated years to dz to csv
writetable(test, '/Users/jasonrussell/Documents/OUTPUTS/sila_A001/est_AB+_chron.csv')