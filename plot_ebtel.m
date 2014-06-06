%function [T_max,n_max,P_max,T_max_idl,n_max_idl,P_max_idl,t_Tmax,t_nmax,t_Pmax,t_Tmax_idl,t_nmax_idl,t_Pmax_idl] = plot_ebtel(time_step,Case)
%plot_ebtel.m

%Will Barnes
%4 April 2013

clear all
close all

%This file plots data generated by the Enthalpy Based Thermal Evolution of
%Loops (EBTEL) model. The model is written in C and data is output to a
%text file.

%Decide which case we are plotting first
eb_case = 8;
if eb_case==1
    loop_length = 75;
    total_time = 10000;
    h_nano = 1.5e-3;
    t_pulse_half = 250;
    t_start = 0;
    heating_shape = 1;
    T0 = 0.85e+6;
    n0 = 0.36e+8;
elseif eb_case==2
    loop_length = 25;
    total_time = 6000;
    h_nano = 1e-2;
    t_pulse_half = 100;
    t_start = 0;
    heating_shape = 1;
    T0 = 0.78e+6;
    n0 = 1.85e+8;
elseif eb_case==3
    loop_length = 25;
    total_time = 2000;
    h_nano = 2;
    t_pulse_half = 100;
    t_start = 0;
    heating_shape = 1;
    T0 = 2.1e+6;
    n0 = 18.5e+8;
elseif eb_case==4
    loop_length = 25;
    total_time = 6000;
    h_nano = 1e-2;
    t_pulse_half = 100;
    t_start = 0;
    heating_shape = 1;
    T0 = 1.6e+6;
    n0 = 9.2e+8;
elseif eb_case==5
    loop_length = 25;
    total_time = 4000;
    h_nano = 5e-3;
    t_pulse_half = 100;
    t_start = 100;
    heating_shape = 2;
    T0 = 9e+5;
    n0 = 1.4e+8;
elseif eb_case==6
    loop_length = 25;
    total_time = 4000;
    h_nano = 5e-3;
    t_pulse_half = 250;
    t_start = 100;
    heating_shape = 2;
    T0 = 9e+5;
    n0 = 1.4e+8;
elseif eb_case==7
    loop_length = 75;
    total_time = 8000;
    h_nano = 5e-3;
    t_pulse_half = 250;
    t_start = 100;
    heating_shape = 2;
    T0 = 9e+5;
    n0 = 1.4e+8;
elseif eb_case == 8
    loop_length = 25;
    total_time = 4000;
    h_nano = 1e-2;
    t_pulse_half = 100;
    t_start = 40;
    heating_shape = 3;
    T0 = 9e+5;
    n0 = 1.4e+8;
else 
    loop_length = 25;
    total_time = 6000;
    h_nano = 1e-2;
    t_pulse_half = 1000;
    t_start = 300;
    heating_shape = 3;
    T0 = 9e+5;
    n0 = 1.4e+8;
end

%Start our model with the appropriate inputs
%First set each parameter appropriately
%total_time = 6000;
param(1) = total_time;
tau = 1;
param(2) = tau;
%heating_shape = 1;
param(3) = heating_shape;
%loop_length = 75;
param(4) = loop_length;
usage=1;
param(5) = usage;
rtv=1;
param(6) = rtv;
dem_old = 0;
param(7) = dem_old;
dynamic = 0;
param(8) = dynamic;
solver=0;
param(9) = solver;
mode=1;
param(10) = mode;
%h_nano = 1e-2;
param(11) = h_nano;
%t_pulse_half = 100;
param(12) = t_pulse_half;
%t_start = 0;
param(13) = t_start;
index_dem = 451;
param(14) = index_dem;
%T0 = 1.3e+6;
param(15) = T0;
%n0 = 9.2e+8;
param(16) = n0;

%Print the param vector to a file
fileID = fopen('ebtel_parameters.txt','w');
fprintf(fileID,'%d\n',param);
fclose(fileID);

%Start the model now that we have set our inputs appropriately

%Utilize the EBTEL makefile
%To clean up the object files and executable, run make clean in the command
%line
unix('make')

%Compute the executables
tic
unix('./ebtel')
toc

%Change to the data directory to plot the file
cd('data')

%Load the data file
file_string = ['L' num2str(loop_length) 'u' num2str(usage) 'h' num2str(heating_shape) 's' num2str(solver)];
ebtel_array = load(['ebteldat' file_string '.txt']);

time = ebtel_array(:,1);
if solver==2
    index=find(time(2:end)==0);
    index=index(1);
else
    index = length(time);
end

time = time(1:index,1);

T = ebtel_array(1:index,2);

n = ebtel_array(1:index,3);

P = ebtel_array(1:index,4);

v = ebtel_array(1:index,5);

ta = ebtel_array(1:index,6);

na = ebtel_array(1:index,7);

cond = ebtel_array(1:index,9);

f_ratio = ebtel_array(1:index,end-3);

heat = ebtel_array(1:index,end-2);

r3 = ebtel_array(1:index,end-1);

rad = ebtel_array(1:index,end);

%Print necessary values to the screen
[maxval,index] = max(T);
fprintf('T_max = %g at t(Tmax) = %g\n',maxval/1e+6,time(index));
[maxval,index] = max(n);
fprintf('n_max = %g at t(nmax) = %g\n',maxval/1e+8,time(index));
[maxval,index] = max(P);
fprintf('p_max = %g at t(pmax) = %g\n',maxval,time(index));

current_dir = pwd;
cd('/Users/willbarnes/Documents/Rice/Research/EBTEL_IDL/data')

%Load the appropriate IDL data file for the right case
%idl_varname = ['IDL_case' num2str(eb_case) '.txt'];
idl_varname = 'ebtelIDLoutput.txt';
eb_idl = load(idl_varname);

cd(current_dir)
cd('..')

%Make all necessary variables from IDL data
timeidl = eb_idl(:,1);
heatidl = eb_idl(:,2);
Tidl = eb_idl(:,3);
nidl = eb_idl(:,4);
Pidl = eb_idl(:,5);
vidl = eb_idl(:,6);
taidl = eb_idl(:,7);
naidl = eb_idl(:,8);
paidl = eb_idl(:,9);
r3idl = eb_idl(:,10);
radidl = eb_idl(:,11);
condidl = eb_idl(:,end-1);
f_ratioidl = eb_idl(:,end);

[n_max,j_max] = max(n);
t_nmax = time(j_max);
[n_max_idl,j_max_idl] = max(nidl);
t_nmax_idl = timeidl(j_max_idl);
T_max_n = T(j_max);
T_max_nidl = Tidl(j_max_idl);

%Compute differences between idl and c models
dP = abs(max(P) - max(Pidl));
dn = abs(max(n) - max(nidl));
dT = abs(max(T) - max(Tidl));

%Calculate parameters listed in Table 2 from Paper 2
[T_max,j_max_T] = max(T);
t_Tmax = time(j_max_T);
[T_max_idl,j_max_Tidl] = max(Tidl);
t_Tmax_idl = timeidl(j_max_Tidl);
[P_max,j_max_P] = max(P);
t_Pmax = time(j_max_P);
[P_max_idl,j_max_Pidl] = max(Pidl);
t_Pmax_idl = timeidl(j_max_Pidl);

%Compute the differences between max parameter and time at which parameters
%are max
fprintf('Differences between max parameters and max times\n');
fprintf('Delta(T_max) = %g\n',abs(T_max - T_max_idl));
fprintf('Delta(t_Tmax) = %g\n',abs(t_Tmax - t_Tmax_idl));
fprintf('Delta(n_max) = %g\n',abs(n_max - n_max_idl));
fprintf('Delta(t_nmax) = %g\n',abs(t_nmax - t_nmax_idl));
fprintf('Delta(P_max) = %g\n',abs(P_max - P_max_idl));
fprintf('Delta(t_Pmax) = %g\n',abs(t_Pmax - t_Pmax_idl));


%% Plotting

%Set the size of the figures
height = 2.0; % width/golden ratio
width = 0.5;
scale = 1500; %scale the plots appropriately; adjust as needed

row = 3;
col = 2;

figure(1)
box('on')
set(gcf,'Position',[0 0 scale*width scale*height])
set(gca,'FontSize',18,'FontName','Arial')
set(gcf,'PaperPositionMode','auto')
subplot(row,col,1)
hold on
plot(time,heat,'LineWidth',2)
plot(timeidl,heatidl,'--r','LineWidth',2)
%plot(time,abs(heat - heatidl))
xlabel('$t$~(s)','interpreter','latex')
ylabel('$h$ (erg~cm$^{-3}$~s$^{-1}$)','interpreter','latex')
%xlim([t_pulse_half - 2*t_start t_pulse_half+t_start*7])
%xlim([0 t_start+2*t_pulse_half+50])
xlim([0 400])
ylim([0 h_nano+0.1*h_nano])

% figure(2)
% box('on')
% set(gcf,'Position',[0 0 scale*width scale*height])
% set(gca,'FontSize',18,'FontName','Arial')
subplot(row,col,2)
hold on
plot(time,T/10^6,'LineWidth',2)
plot(timeidl,Tidl/10^6,'--r','LineWidth',2)
%plot(time,(T - Tidl)/10^6)
xlabel('$t$~(s)','interpreter','latex')
ylabel('$T$~(MK)','interpreter','latex')
%title(['Loop Parameters, Case ' num2str(eb_case) ])
hleg = legend('C','IDL');
set(hleg,'Location','Best','FontSize',10);
xlim([0 timeidl(end)])

% fn = ['temp_c_' num2str(eb_case) 's_' num2str(solver) 'h_' num2str(heating_shape)];
% print(gcf,'-depsc',fn)

% figure(3)
% box('on')
% set(gcf,'Position',[0 0 scale*width scale*height])
% set(gca,'FontSize',18,'FontName','Arial')
subplot(row,col,3)
hold on
plot(time,P,'LineWidth',2)
plot(timeidl,Pidl,'--r','LineWidth',2)
%plot(time,(P - Pidl))
xlabel('$t$~(s)','interpreter','latex')
ylabel('$P$~(dyne~cm$^{-2}$)','interpreter','latex')
ylim([min(P) max(P)+0.10*max(P)])
xlim([0 timeidl(end)])

% fn = ['press_c_' num2str(eb_case) 's_' num2str(solver) 'h_' num2str(heating_shape)];
% print(gcf,'-depsc',fn)

% figure(4)
% box('on')
% set(gcf,'Position',[0 0 scale*width scale*height])
% set(gca,'FontSize',18,'FontName','Arial')
subplot(row,col,4)
hold on
plot(time,n/10^8,'LineWidth',2)
plot(timeidl,nidl/10^8,'--r','LineWidth',2)
%plot(time,(n - nidl)/10^8)
xlabel('$t$~(s)','interpreter','latex')
ylabel('$n$~($10^8$~cm$^{-3}$)','interpreter','latex')
ylim([min(n)/10^8 (max(n)+0.10*max(n))/10^8])
xlim([0 timeidl(end)])

% fn = ['ndens_c_' num2str(eb_case) 's_' num2str(solver) 'h_' num2str(heating_shape)];
% print(gcf,'-depsc',fn)

% figure(5)
% box('on')
% set(gcf,'Position',[0 0 scale*width scale*height])
% set(gca,'FontSize',18,'FontName','Arial')
subplot(row,col,5)
hold on
plot(time,na/10^8,'LineWidth',2)
plot(timeidl,naidl/10^8,'--r','LineWidth',2)
xlabel('$t~(s)$','interpreter','latex')
ylabel('$n_{apex}~$($10^8$~(cm$^{-3}$)','interpreter','latex')
ylim([min(na)/10^8 max(na)/10^8])
xlim([0 timeidl(end)])

% fn = ['ndensa_c_' num2str(eb_case) 's_' num2str(solver) 'h_' num2str(heating_shape)];
% print(gcf,'-depsc',fn)

% figure(6)
% box('on')
% set(gcf,'Position',[0 0 scale*width scale*height])
% set(gca,'FontSize',18,'FontName','Arial')
subplot(row,col,6)
hold on
loglog(T/T_max_n,n/n_max,'LineWidth',2)
loglog(Tidl/T_max_nidl,nidl/n_max_idl,'--r','LineWidth',2)
%set(gca,'XScale','Log','YScale','Log')
xlabel('$T/T_{max}$','interpreter','latex')
ylabel('$n/n_{max}$','interpreter','latex')
xlim([0.2 2.2])
ylim([0.2 1.4])

%Save the figure
% print(gcf,'-depsc',...
%     ['/Users/willbarnes/Documents/Rice/Research/EBTEL_figures/case_' num2str(eb_case) '_parameters']);

%Velocity and r3 coefficient
% subplot(2,4,7)
% hold on
% plot(time,v,'LineWidth',2)
% plot(timeidl,vidl,'--r','LineWidth',2)
% ylabel('$v$~(m/s)','interpreter','latex')
% xlabel('$t$~(s)','interpreter','latex')
% 
% figure(gcf+1)
% box('on')
% set(gcf,'Position',[0 0 scale*width scale*height])
% set(gca,'FontSize',18,'FontName','Arial')
% %subplot(2,4,8)
% hold on
% plot(time,(r3 - r3idl)./r3idl,'LineWidth',2)
% %plot(timeidl,r3idl,'--r','LineWidth',2)
% xlabel('$t$ (s)','interpreter','latex')
% ylabel('$c_1$','interpreter','latex')
% 
% figure(gcf+1)
% box('on')
% set(gcf,'Position',[0 0 scale*width scale*height])
% set(gca,'FontSize',18,'FontName','Arial')
% hold on
% plot(time,(rad - radidl)./radidl,'LineWidth',2)
% %plot(timeidl,radidl,'--r','LineWidth',2)
% %plot([2*t_pulse_half 2*t_pulse_half],[10^(-23) 10^(-21)],'--k')
% %plot(t_pulse_half,rad(t_pulse_half),'k*','MarkerSize',15)
% %set(gca,'YScale','Log')
% xlabel('$t$ (s)','interpreter','latex')
% ylabel('$\Lambda(T)$','interpreter','latex')
% 
% %Plot the enthalpy flux
% pv = P.*v;
% pvidl = Pidl.*vidl;
% figure(gcf+1)
% box('on')
% set(gcf,'Position',[0 0 scale*width scale*height])
% set(gca,'FontSize',18,'FontName','Arial')
% hold on
% plot(time,pv,'LineWidth',2)
% plot(timeidl,pvidl,'--r','LineWidth',2)
% set(gca,'YScale','Log')
% xlabel('$t$ (s)','interpreter','latex')
% ylabel('$Pv$','interpreter','latex')
% %xlim([3000 10000])
% 
% %Plot the f_ratio
% figure(gcf+1)
% box('on')
% set(gcf,'Position',[0 0 scale*width scale*height])
% set(gca,'FontSize',18,'FontName','Arial')
% hold on
% plot(time,(cond./f_ratio - condidl./f_ratioidl)./(condidl./f_ratioidl),'LineWidth',2)
% %plot(timeidl,condidl./f_ratioidl/10^5,'--r','LineWidth',2)
% %set(gca,'YScale','Log')
% xlabel('$t$~(s)','interpreter','latex')
% ylabel('$F_{eq}$','interpreter','latex')
% %xlim([3000 10000])

%Plot differences between C and IDL solutions normalized to their
%respective maximum values
if length(time) == length(timeidl)

    % figure(gcf+1)
    % box('on')
    % set(gcf,'Position',[0 0 scale*width scale*height])
    % set(gca,'FontSize',18,'FontName','Arial')
    % hold on
    maxdiffT = max(abs(T - Tidl));
    Tdiff = (T-Tidl)/maxdiffT;
    % plot(time,Tdiff,'k','LineWidth',2)
    maxdiffn = max(abs(n - nidl));
    ndiff = (n - nidl)/maxdiffn;
    % plot(time,ndiff,'r','LineWidth',2)
    maxdiffna = max(abs(na - naidl));
    nadiff = (na - naidl)/maxdiffna;
    % plot(time,nadiff,'b','LineWidth',2)
    maxdiffP = max(abs(P - Pidl));
    Pdiff = (P - Pidl)/maxdiffP;
    % plot(time,Pdiff,'c','LineWidth',2)
    % xlabel('$t$ (s)','interpreter','latex')
    % ylabel('$\Delta$(C-IDL)','interpreter','latex')
    % %Print max differences
    % text(0.4*time(end),0.95,['$\Delta(T)_{max}$ = ' num2str(maxdiffT)],...
    %     'interpreter','latex','FontSize',15)
    % text(0.4*time(end),0.91,['$\Delta(n)_{max}$ = ' num2str(maxdiffn)],...
    %     'interpreter','latex','FontSize',15)
    % text(0.4*time(end),0.87,['$\Delta(n_a)_{max}$ = ' num2str(maxdiffna)],...
    %     'interpreter','latex','FontSize',15)
    % text(0.4*time(end),0.83,['$\Delta(P)_{max}$ = ' num2str(maxdiffP)],...
    %     'interpreter','latex','FontSize',15);
    % %Print average differences
    % text(0.6*time(end),0.95,['$\langle\Delta(T)\rangle$ = ' num2str(mean(abs(T-Tidl)))],...
    %     'interpreter','latex','FontSize',15);
    % text(0.6*time(end),0.91,['$\langle\Delta(n)\rangle$ = ' num2str(mean(abs(n-nidl)))],...
    %     'interpreter','latex','FontSize',15);
    % text(0.6*time(end),0.87,['$\langle\Delta(n_a)\rangle$ = ' num2str(mean(abs(na-naidl)))],...
    %     'interpreter','latex','FontSize',15);
    % text(0.6*time(end),0.83,['$\langle\Delta(P)\rangle$ = ' num2str(mean(abs(P-Pidl)))],...
    %     'interpreter','latex','FontSize',15);
    % %Legend
    % hleg = legend('$\Delta(T)$','$\Delta(n)$','$\Delta(n_a)$','$\Delta(P)$');
    % set(hleg,'FontSize',18,'Location','NorthWest','interpreter','latex')
    
    %Print these parameters to the screen
    fprintf('Max difference and average difference\n');
    fprintf('Delta(T)_max = %g\n',maxdiffT);
    fprintf('Delta(n)_max = %g\n',maxdiffn);
    fprintf('Delta(na)_max = %g\n',maxdiffna);
    fprintf('Delta(P)_max = %g\n',maxdiffP);
    fprintf('<Delta(T)> = %g\n',mean(abs(T-Tidl)));
    fprintf('<Delta(n)> = %g\n',mean(abs(n-nidl)));
    fprintf('<Delta(na)> = %g\n',mean(abs(na-naidl)));
    fprintf('<Delta(P)> = %g\n',mean(abs(P-Pidl)));
    
    %Plot differences between temperature and density for average and apex
    %values
    deltaToverT = (T - Tidl)./Tidl;
    deltanovern = (n - nidl)./nidl;
    deltaPoverP = (P - Pidl)./Pidl;
    deltaTaoverTa = (ta - taidl)./taidl;
    deltanaoverna = (na - naidl)./naidl;
    
    figure(gcf+1)
    box('on')
    set(gcf,'Position',[0 0 scale*height scale*width])
    set(gca,'FontSize',18,'FontName','Arial')
    set(gcf,'PaperPositionMode','auto')
    hold on
    plot(time,deltaPoverP,'g','LineWidth',2)
    plot(time,deltaToverT,'LineWidth',2)
    plot(time,deltanovern,'r','LineWidth',2)
    plot(time,deltaTaoverTa,'--')
    plot(time,deltanaoverna,'--r')
    plot([0 total_time],[0 0],'k--')
    xlabel('$t$~(s)','interpreter','latex')
    ylabel('$\Delta T/T,~\Delta n/n$','interpreter','latex')
    hleg = legend('$P$','$T$','$n$','$T_a$','$n_a$');
    set(hleg,'FontSize',14,'interpreter','latex','Location','Best')
    
%     %Print the figure
%     print(gcf,'-depsc',...
%     ['/Users/willbarnes/Documents/Rice/Research/EBTEL_figures/case_' num2str(eb_case) '_diff']);

end


% figure(3)
% box('on')
% set(gcf,'Position',[0 0 scale*width scale*height])
% set(gca,'FontSize',18,'FontName','Arial')
% subplot(2,2,1)
% hist(abs(deltaToverT),linspace(0,max(deltaToverT),1000))
% title('$\Delta T$','interpreter','latex')
% xlim([0 1])
% subplot(2,2,2)
% hist(abs(deltaPoverP),linspace(0,max(deltaPoverP),1000))
% title('$\Delta P$','interpreter','latex')
% xlim([0 1])
% subplot(2,2,3)
% hist(abs(deltanovern),linspace(0,max(deltanovern),1000))
% title('$\Delta n$','interpreter','latex')
% xlim([0 1])
% subplot(2,2,4)
% hist(abs(deltanaoverna),linspace(0,max(deltanaoverna),1000))
% title('$\Delta n_a$','interpreter','latex')
% xlim([0 1])


%cd(c_dir)

%Plot DEM if option 1 or 4 is turned on
if usage == 1 || usage == 4
    
    %Load the DEM data file
    cd('data')
    ebteldem_array = load(['ebteldemdat' file_string '.txt']);
    cd('..')
    
    %Make the necessary vectors
    logtdem = ebteldem_array(:,1);
    log10meandem_tr = ebteldem_array(:,2);
    log10meandem_cor = ebteldem_array(:,3);
    log10meandem_tot = ebteldem_array(:,4);
    
    current_dir = pwd;
    cd('/Users/willbarnes/Documents/Rice/Research/EBTEL_IDL/data')
    
    %Load the IDL data 
    %idl_dem_varname = ['IDL_DEM_case' num2str(eb_case) '.txt'];
    idl_dem_varname = 'ebtelIDLoutput_DEM.txt';
    
    eb_idl_dem = load(idl_dem_varname);
    
    cd(current_dir)
    
    %Make the vectors
    dem_tr_idl = log10(eb_idl_dem(:,1));
    dem_cor_idl = log10(eb_idl_dem(:,2));
    logtdem_idl = eb_idl_dem(:,3);
    tot_idl = log10(eb_idl_dem(:,1) + eb_idl_dem(:,2));
    
    %Make the difference vectors
    dem_tr_diff = abs(dem_tr_idl - log10meandem_tr)./dem_tr_idl;
    
    figure(gcf+1)
    box('on')
    set(gcf,'Position',[0 0 scale*width scale*height])
    set(gca,'FontSize',18,'FontName','Arial')
    set(gcf,'PaperPositionMode','auto')
    hold on
    plot(logtdem,log10meandem_tr,'b')
    plot(logtdem,log10meandem_cor,'r')
    plot(logtdem_idl,dem_tr_idl,'--b')
    plot(logtdem_idl,dem_cor_idl,'--r')
    plot(logtdem,log10meandem_tot,'g')
    plot(logtdem_idl,tot_idl,'--g')
    %plot([log10(T(t_pulse_half)) log10(T(t_pulse_half))],[18 22],'--k')
    %plot([log10(T(1)) log10(T(1))],[18 22],'--k')
    hold off
    %axis([5.5 7.5 18 22])
    xlim([5.5 7.5])
    title(['DEM, Case ' num2str(eb_case)])
    xlabel('log($T$) (K)','interpreter','latex')
    ylabel('log(DEM) (cm$^{-5}$~K$^{-1}$)','interpreter','latex')
    hleg=legend('TR','Corona','TR, IDL','Corona, IDL','Total','Total, IDL');
    set(hleg,'Location','Best','FontSize',14)
    
%     %Print the figure
%     print(gcf,'-depsc',...
%     ['/Users/willbarnes/Documents/Rice/Research/EBTEL_figures/case_' num2str(eb_case) '_dem']);
    
%     figure(gcf+1)
%     plot(logtdem,dem_tr_diff)
%     xlabel('log10(T_{DEM})')
%     ylabel('DEM_{TR} diff')
    
end
