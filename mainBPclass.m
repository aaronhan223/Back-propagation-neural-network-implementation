
randn('seed', 2000);
%% BP clustering
load data.mat;%  datacell typecell typemat fs0;
load dataforBP.mat;% Fmat typemat;
Outputdata=typemat';%Sample type,
Inputdata=Fmat';%Sample characteristics, onecolumn correspond to one sample
Outputdata0=Outputdata;
long001=length(Outputdata0);

index1=randperm(long001);
% index1=1:length(Outputdata);
numberTest=10;%The number of sample used for testing
% Data conversion
typenumber=length(unique(Outputdata0));%the number of type
Outputdata=zeros(typenumber,long001);%output
for i=1:long001
    Outputdata(Outputdata0(i),i)=1;
end

indextrain=index1(1:end-numberTest);
indextest=index1(end-numberTest+1:end);
indextrain0=index1(1:end-numberTest);

% Define training set
P1=Inputdata(:,indextrain);
T1=Outputdata(:,indextrain);
% Define testing set
P2=Inputdata(:,indextest);
T2=Outputdata(:,indextest);

%% (2)Normalisation for data in training set
[input_train,inputps]=mapminmax(P1,0,1);
[output_train,outputps]=mapminmax(T1,0,1);
%Normalisation for data in testing set
input_test=mapminmax('apply',P2,inputps);

%% (3)The construction, training and simulation for BP network
% % Choose the optimum number of node in hidden layer
% hidnumberset=3:1:9;
% long1=length(hidnumberset);
% emat1=zeros(long1,1);
% for i=1:long1
%     net=newff(input_train,output_train,hidnumberset(i),{'tansig','purelin'});%transfer
%     function set as tansig and purelin
%     % Set training parameters of neural network
%     net.trainparam.epochs=200;%Network training epochs
%     net.trainparam.goal=0.000000001;%Network training goal
%     net.trainparam.lr=0.1;%Learning rate
%     net.trainParam.showWindow = false; % the training window is not
%     displayed
%     [net,tr]=train(net,input_train,output_train);%train the network
%     mse01=tr.perf;
%     emat1(i,1)=mse01(end);
% end
% [v1,index1]=min(emat1);
% hidnumber=hidnumberset(index1);
% figure;
% plot(hidnumberset,emat1);
% xlabel('Number of node in hidden layer','fontname','宋体');
% ylabel('Error rate','fontname','宋体');
% title('Relationship between number of node in hidden layer and error rate','fontname','宋体');
% 
% 
% % Choose the appropriate learning rate
% lrset=0.01:0.01:0.2;
% long1=length(lrset);
% emat1=zeros(long1,1);
% for i=1:long1
%     net=newff(input_train,output_train,hidnumber,{'tansig','purelin'});%transfer
%     function set as tansig and purelin
%     % Set training parameters of neural network
%     net.trainparam.epochs=200;%Neural network training epochs
%     net.trainparam.goal=0.000000001;%Network training goal
%     net.trainparam.lr=lrset(i);%Learning rate
%     net.trainParam.showWindow = false; %the training window is not
%     displayed
%     [net,tr]=train(net,input_train,output_train);%train the network
%     mse01=tr.perf;
%     emat1(i,1)=mse01(end);
% end
% [v1,index1]=min(emat1);
% lr=lrset(index1);
% figure;
% plot(lrset,emat1);
% xlabel('learning rate','fontname','宋体');
% ylabel('MSE','fontname','宋体');
% title('Relationship between learning rate and training error','fontname','宋体');


hidnumber=8;
lr=0.05;
tic;
net=newff(input_train,output_train,hidnumber);%Setup new BP network "net"
% Set BP network parameters
net.trainparam.epochs=1000;%Set training epochs
net.trainparam.goal=0.0000001;%Set training goal
% net.trainparam.lr=lr;%Set learning rate
% net.trainFcn='trainlm';
% net.trainFcn='traingd';
 net.trainFcn='traingdm';% choose the most appropriate training algorithm
% net.trainFcn='traingdx';
% net.trainFcn='trainrp';
net.divideFcn ='';


[net,tr]=train(net,input_train,output_train);%Train the netowrk
timeBP=toc;
% Use the network to predict
ybptrain=sim(net,input_train(:,1:long001-numberTest));
ybptrain=mapminmax('reverse',ybptrain,outputps);%Anti-normalize predicting data
ybptrain0=ybptrain;

ybptest=sim(net,input_test);
ybptest=mapminmax('reverse',ybptest,outputps);%Anti-normalize predicting data
ybptest0=ybptest;
[v1,ybptest]=max(ybptest);
[v1,T2]=max(T2);


%% (4)Output results
disp('Optimum number of node in hidden layer');
hidnumber
disp('Optimum learning rate');
lr

mse01=tr.perf;
epochs=tr.epoch;
disp('Mean Square Error for BP network training');
MSE1=mse01(end)

figure;
semilogy(epochs,mse01);
xlabel('Training epochs','fontname','宋体'); 
ylabel('MSE','fontname','宋体'); 
title('BP neural network training error curve','fontname','宋体'); 

typemat=T2;
typemat2=ybptest;
[premat]=fntnfun(typemat,typemat2);
premat

% Figure plotting for output results

typeset=typecell;
figure;
stem(T2,'bo');
hold on;
stem(ybptest,'r*');
legend({'Actual value','Predicting value'},'fontname','宋体');
xlabel('Testing sample','fontname','宋体');
ylabel('Music type','fontname','宋体');
set(gca,'XLim',[0 length(T2)+1]);% Data display range for x-axis
set(gca,'YLim',[-1 max(max(T2),max(ybptest))+1]);% Data display range for y-axis
set(gca,'ytick',1:length(typeset),'yticklabel',typeset,'fontname','宋体');
title('Predicting result for BP network','fontname','宋体');


timeBP %time used for getting the result

% Accuracy
disp('Predicting accuracy(%)=')
BPa=sum((ybptest-T2)==0)/length(T2)*100

%% Output data
[data01_in,v1]=mapminmax(Inputdata,0,1);
[data01_out,v2]=mapminmax(Outputdata,0,1);

T001=Outputdata(:,indextrain0);
T002=Outputdata(:,indextest);
[data02_in,v3]=mapminmax(Inputdata(:,indextrain0),0,1);
[data02_out,v4]=mapminmax(Outputdata(:,indextrain0),0,1);
data03_in=mapminmax('apply',Inputdata(:,indextest),v3);%Normalise data in testing set
data03_out=mapminmax('apply',Outputdata(:,indextest),v4);%Normalise data in testing set



% 1.Normalised data
outcell=num2cell([data01_in']);
xlswrite('Normalised_data.xls',outcell,'All data');

outcell=num2cell([data02_in']);
xlswrite('Normalised_data.xls',outcell,'Training set data');
outcell=num2cell([data03_in']);
xlswrite('Normalised_data.xls',outcell,'Testing set data');

% 2.Output data
L1=size(data02_out,2);
outcell={'Expected output','Actual output','Judging result'};
outcell2=cell(L1,3);
for i=1:L1
    str1=num2str(T001(:,i)');
    outcell2{i,1}=str1;
    str2=num2str(ybptrain0(:,i)');
    outcell2{i,2}=str2;
    [v01,index091]=max(T001(:,i));
     [v02,index092]=max(ybptrain0(:,i));
    if index091==index092
        outcell2{i,3}='Y';
    else
        outcell2{i,3}='N';
    end
end
outcell=[outcell;outcell2];
xlswrite('Output data summary.xls',outcell,'Predicting data in training set');

L2=size(data03_out,2);
outcell={'Expected output','Actual output','Judging result'};
outcell2=cell(L2,3);
for i=1:L2
    str1=num2str(T002(:,i)');
    outcell2{i,1}=str1;
    str2=num2str(ybptest0(:,i)');
    outcell2{i,2}=str2;
    [v01,index081]=max(T002(:,i));
     [v02,index082]=max(ybptest0(:,i));
    if index081==index082
        outcell2{i,3}='Y';
    else
        outcell2{i,3}='N';
    end
end
outcell=[outcell;outcell2];
xlswrite('Output data summary.xls',outcell,'Predicting data in testing set');



