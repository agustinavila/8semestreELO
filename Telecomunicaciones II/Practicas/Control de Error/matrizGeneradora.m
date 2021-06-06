tb=0.06;
n=14; k=3; 
G=[1 0 1 1 1 0 0 1 0 1 1 1];
P=zeros(3,14);
for i=0:2
    X=[1 zeros(1,(n-k+i))]
    [q,r]=deconv(X,G);
    r=abs(r);
    P(3-i,:)=[zeros(1, 2-i) r+X];
end
P=P(:,4:size(P,2)) %matriz generadora

H=[P' eye(n-k)] %Matriz chequeadora

%% polinomio chequeador
X=[1 zeros(1,13) 1];
[q,r]=deconv(X,G);
h=abs(q)    %polinomio chequeador

%% asd
bitsInfo=[0 0 1]
pe=[1 zeros(1,13)];
sim("emi.slx")
bitserror=(xor(salidabien(1:14,:),salidaerr)')




% %% Chequeando:
% %Para dos errores:
% Htran=H';
% for i=1:(size(Htran,1)-1)
%     for j=i+1:size(Htran,1)
%         PE=zeros(1,14);
%         disp("Para error en "+(i)+" y "+(j))
%         PE(i)=1;PE(j)=1;
%         disp(mod(PE*Htran,2))
%     end
% end
