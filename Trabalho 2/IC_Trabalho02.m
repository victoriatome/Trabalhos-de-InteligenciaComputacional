%%  UNIVERSIDADE FEDERAL DO CEAR�
%           CAMPUS SOBRAL
%   CURSO DE ENGENHARIA DE COMPUTA��O
%
% INTELIGENCIA COMPUTACIONAL - TRABALHO 02
%
% ARTHUR SOUSA DE SENA    MATRICULA: 345750
% VICTORIA TOME OLIVEIRA  MATRICULA: 366333
% VITORIA ALMEIDA BERTAIA MATRICULA: 356741

%% PROBLEMA ===============================================================
%   CRIAR UMA REDE MLP PARA APROXIMAR A FUNCAO z=x^2+y^2
%==========================================================================

%% Inicializa��o da rede ==================================================

clc;

limI = -10; % Limite inferior do vetor de valores de treinamento
limS = 10; % Limite superior do vetor de valores de treinamento

% 200 valores aleat�rios dentro do intervalo [-10,10] s�o gerados para treinar a rede
x = (limI + (limS-limI)*rand(200,1))'; % Vetor de treinamento x
y = (limI + (limS-limI)*rand(200,1))'; % Vetor de treinamento y
z = x.^2 + y.^2; % Funcao real

numNeuros = 15; % N�mero de neur�neos da camada interna da rede
zMLP = feedforwardnet(numNeuros); % Rede MLP para aproximacao de funcao � criada
zMLP.layers{1}.transferFcn = 'tansig'; % A fun��o de ativa��o da primeira camada � definida como tangente hiperb�lica sigm�ide
zMLP.layers{2}.transferFcn = 'purelin'; % A fun��o de ativa��o da camada de sa�da � definida como linear.
zMLP.trainParam.lr = 10e5; % Indice de aprendizagem

% Crit�rios de parada
zMLP.trainParam.epochs = 3000;  % Numero maximo de iteracoes.
zMLP.trainParam.goal = 1e-8; % Tolerancia de erro.
zMLP.trainParam.time = 15; % Tempo m�ximo de treinamento.
zMLP.trainParam.max_fail = 10; % N�mero m�ximo de erros de valida��o, utilizado para parada antecipada.

inputs = [x;y]; % Vetores x e y sao definidos como entrada da rede MLP
targets = z; % z � definida como a funcao alvo (desejada).

% Treinamento da rede
[zMLP,tr] = train(zMLP, inputs, targets);


%% Trecho respons�vel por plotar os gr�ficos ==============================

d=limI:0.1:limS; % Intervalo utilizado para plotar a fun��o
[X, Y]=meshgrid(d,d); % Faz um meshgrid do intervalo

% Mesh da fun��o real -----------------------------------------------------
f = figure('Name','Fun��es real e aproximada','NumberTitle','off','position',[0 0 1200 480]);
movegui(f,'center');
subplot(1,2,1);
Z = griddata(x,y,z,X,Y,'v4');
mesh(X,Y,Z)
xlabel('Eixo x');
ylabel('Eixo y');
zlabel('Eixo z');
title('Fun��o real z = x^2 + y^2');
zlim([0 200]);

% Mesh da fun��o aproximada -----------------------------------------------
subplot(1,2,2);
a= sim(zMLP,inputs);
A = griddata(x,y,a,X,Y,'v4');
mesh(X,Y,A)
xlabel('Eixo x');
ylabel('Eixo y');
zlabel('Eixo z');
title('Fun��o aproximada zMLP');
zlim([0 200]);


% Mesh de erro ------------------------------------------------------------
f = figure('Name','Gr�fico de Erro','NumberTitle','off','position',[0 0 800 480]);
movegui(f,'center');
AZ = griddata(x,y,z-a,X,Y,'v4');
mesh(X,Y,AZ)
colormap hsv
colorbar
xlabel('Eixo x');
ylabel('Eixo y');
zlabel('Erro');
title('Superf�cie de erro') 

% Evolu��o do erro quadr�tico m�dio durante o treinamento -----------------

figure, plotperform(tr);
ylabel('Erro Quadr�tico M�dio');

% Gr�fico de regress�o linear ---------------------------------------------
figure, plotregression(targets,a);
title('Regress�o');
xlabel('Alvo');

% Mostra o diagrama da rede -----------------------------------------------
view(zMLP);


%% Trecho mostra relat�rio com resultado dos pesos e teste da rede ========

display(sprintf('---------RESULTADOS---------\n\n'));

% Pesos e bias ------------------------------------------------------------
display(sprintf('Pesos da camada interna\n\n    w_k1       w_k2        b_k'));
display(sprintf('%10f %10f %10f\n',zMLP.IW{1}(:,1),zMLP.IW{1}(:,2),zMLP.b{1}));
display(sprintf('\nPesos do neur�neo de sa�da\n\n    w_k'));
display(sprintf('%10f\n',zMLP.LW{2,1}'));
display(sprintf('\n     b'));
display(sprintf('%10f\n',zMLP.b{2}));

% Teste da rede -----------------------------------------------------------
fprintf('\n\nTeste da rede para valores n�o treinados\n');
zr = @(a,b) a^2 + b^2; % Funcao real

% Dois vetores com 10 valores aleat�rios s�o criados para testar 
% a rede depois de treinada.
x1 = (limI + (limS-limI)*rand(20,1))'; % Vetor de teste x1
x2 = (limI + (limS-limI)*rand(20,1))'; % Vetor de teste x2

table(20,5)=ones();

%Imprime os resultados em formato de tabela
for i=1:20
    table(i,1)=x1(i);
    table(i,2)=x2(i);
    table(i,3)=zr(x1(i),x2(i));
    table(i,4)=zMLP([x1(i);x2(i)]);
    table(i,5)=abs(table(i,3)-table(i,4))*100;
end

fprintf('\n   x        y       z(x,y)    zMLP(x,y)  Erro');
fprintf('\n -----    -----    --------  ----------  -----');

for i=1:20
    fprintf('\n');
    for j=1:5
        if j>2&&j<5
            fprintf('%8.3f   ',table(i,j));
        else if j==5
                fprintf('%5.3f%%   ',table(i,j));
            else
                fprintf('%6.3f   ',table(i,j));
            end
            
        end
            
    end
end
fprintf('\n -----    -----    --------  ----------  -----\n\n');
