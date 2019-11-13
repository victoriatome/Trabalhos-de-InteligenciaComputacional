%%  UNIVERSIDADE FEDERAL DO CEARÁ
%           CAMPUS SOBRAL
%   CURSO DE ENGENHARIA DE COMPUTAÇÃO
%
% INTELIGENCIA COMPUTACIONAL - TRABALHO 02
%
% ARTHUR SOUSA DE SENA    MATRICULA: 345750
% VICTORIA TOME OLIVEIRA  MATRICULA: 366333
% VITORIA ALMEIDA BERTAIA MATRICULA: 356741

%% PROBLEMA ===============================================================
%   CRIAR UMA REDE MLP PARA APROXIMAR A FUNCAO z=x^2+y^2
%==========================================================================

%% Inicialização da rede ==================================================

clc;

limI = -10; % Limite inferior do vetor de valores de treinamento
limS = 10; % Limite superior do vetor de valores de treinamento

% 200 valores aleatórios dentro do intervalo [-10,10] são gerados para treinar a rede
x = (limI + (limS-limI)*rand(200,1))'; % Vetor de treinamento x
y = (limI + (limS-limI)*rand(200,1))'; % Vetor de treinamento y
z = x.^2 + y.^2; % Funcao real

numNeuros = 15; % Número de neurôneos da camada interna da rede
zMLP = feedforwardnet(numNeuros); % Rede MLP para aproximacao de funcao é criada
zMLP.layers{1}.transferFcn = 'tansig'; % A função de ativação da primeira camada é definida como tangente hiperbólica sigmóide
zMLP.layers{2}.transferFcn = 'purelin'; % A função de ativação da camada de saída é definida como linear.
zMLP.trainParam.lr = 10e5; % Indice de aprendizagem

% Critérios de parada
zMLP.trainParam.epochs = 3000;  % Numero maximo de iteracoes.
zMLP.trainParam.goal = 1e-8; % Tolerancia de erro.
zMLP.trainParam.time = 15; % Tempo máximo de treinamento.
zMLP.trainParam.max_fail = 10; % Número máximo de erros de validação, utilizado para parada antecipada.

inputs = [x;y]; % Vetores x e y sao definidos como entrada da rede MLP
targets = z; % z é definida como a funcao alvo (desejada).

% Treinamento da rede
[zMLP,tr] = train(zMLP, inputs, targets);


%% Trecho responsável por plotar os gráficos ==============================

d=limI:0.1:limS; % Intervalo utilizado para plotar a função
[X, Y]=meshgrid(d,d); % Faz um meshgrid do intervalo

% Mesh da função real -----------------------------------------------------
f = figure('Name','Funções real e aproximada','NumberTitle','off','position',[0 0 1200 480]);
movegui(f,'center');
subplot(1,2,1);
Z = griddata(x,y,z,X,Y,'v4');
mesh(X,Y,Z)
xlabel('Eixo x');
ylabel('Eixo y');
zlabel('Eixo z');
title('Função real z = x^2 + y^2');
zlim([0 200]);

% Mesh da função aproximada -----------------------------------------------
subplot(1,2,2);
a= sim(zMLP,inputs);
A = griddata(x,y,a,X,Y,'v4');
mesh(X,Y,A)
xlabel('Eixo x');
ylabel('Eixo y');
zlabel('Eixo z');
title('Função aproximada zMLP');
zlim([0 200]);


% Mesh de erro ------------------------------------------------------------
f = figure('Name','Gráfico de Erro','NumberTitle','off','position',[0 0 800 480]);
movegui(f,'center');
AZ = griddata(x,y,z-a,X,Y,'v4');
mesh(X,Y,AZ)
colormap hsv
colorbar
xlabel('Eixo x');
ylabel('Eixo y');
zlabel('Erro');
title('Superfície de erro') 

% Evolução do erro quadrático médio durante o treinamento -----------------

figure, plotperform(tr);
ylabel('Erro Quadrático Médio');

% Gráfico de regressão linear ---------------------------------------------
figure, plotregression(targets,a);
title('Regressão');
xlabel('Alvo');

% Mostra o diagrama da rede -----------------------------------------------
view(zMLP);


%% Trecho mostra relatório com resultado dos pesos e teste da rede ========

display(sprintf('---------RESULTADOS---------\n\n'));

% Pesos e bias ------------------------------------------------------------
display(sprintf('Pesos da camada interna\n\n    w_k1       w_k2        b_k'));
display(sprintf('%10f %10f %10f\n',zMLP.IW{1}(:,1),zMLP.IW{1}(:,2),zMLP.b{1}));
display(sprintf('\nPesos do neurôneo de saída\n\n    w_k'));
display(sprintf('%10f\n',zMLP.LW{2,1}'));
display(sprintf('\n     b'));
display(sprintf('%10f\n',zMLP.b{2}));

% Teste da rede -----------------------------------------------------------
fprintf('\n\nTeste da rede para valores não treinados\n');
zr = @(a,b) a^2 + b^2; % Funcao real

% Dois vetores com 10 valores aleatórios são criados para testar 
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
