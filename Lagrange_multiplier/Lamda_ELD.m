clear all;
fprintf("Select the ELD problem:\n1. Without losse\n2. With losses\n\n");
n = 3; %generating units
D = LoadDemand; 
B = LossData;
dP = D;
data = BusData;
a=data(:,4);b=data(:,3);c=data(:,2);
Plow=data(:,5);Phigh=data(:,6);

Lmin = b+2.*c.*Plow; %incremental fuel costs
Lmax = b+2.*c.*Phigh;
L = mean([Lmin;Lmax]);

P = zeros(n,1);
dPL = zeros(n,1);

itr = 0;
disp(D);

s = input('Enter choice of study: ');


switch s
    case 1
        fprintf('\nEconomic Load Dispatch without LOSSES\n');
        fprintf('------------------------------------\n')
        fprintf('Initially assumed lambda      : %d $/MW\n', L);
        while abs(dP)>0.00001
            P = (L-b)./(2*c);
            P = min(P,Phigh);
            P = max(P,Plow);
            dP = D - sum(P);
            dL = dP*2/(sum(1./c));
            L = L + dL;
            itr = itr+1;
        end
        fprintf('lambda stabilized at          : %d $/MW\n', L);
        fprintf('Total power generated by plant: %d MW', sum(P));
    case 2
        fprintf('\nEconomic Load Dispatch with losses\n');
        fprintf('------------------------------------\n');
        fprintf('Initially assumed lambda      : %d $/MW\n', L);
        while abs(dP)>0.00001
            for i = 1:n
                P(i) = (L-b(i))./(2*(c(i) + L*B(i,i)));
            end
            P = min(P,Phigh);
            P = max(P,Plow);
            PL = P'*B*P;
            dP = D + PL - sum(P);
            for j = 1:n
                dPL(j) = (c(j) + B(j,j)*b(j))/(2*(c(j) + L*B(j,j))^2);
            end
            dL = dP/sum(dPL);
            L = L + dL;
            itr = itr+1;
        end
        fprintf('lambda stabilized at          : %d $/MW\n', L);
        fprintf('Total power generated by plant: %d MW\n', sum(P));
        fprintf('Power Loss                    : %d MW', PL);
    otherwise
        disp('Please select proper value and try again');
end
C=a+b.*P+c.*P.*P; % Costs
totalCost=sum(C);
fprintf('\nTotal number of iterations    : %d \n', itr);
fprintf('Total cost                    : %3f $\n\n', totalCost);
ELD = table(data(:,1),P,C,'V',{'Unit' 'Power' 'Cost'});
disp(ELD);
