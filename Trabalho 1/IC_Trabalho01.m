        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%                                             %%%
        %%% 	 UNIVERSIDADE FEDERAL DO CEAR�          %%%
        %%%	             CAMPUS SOBRAL                  %%%
        %%% 	CURSO DE ENGENHARIA DE COMPUTA��O       %%%
        %%%                                             %%%
        %%%	 INTELIGENCIA COMPUTACIONAL - TRABALHO 01   %%%
        %%%                                             %%%
        %%%   ARTHUR SOUSA DE SENA  MATRICULA: 345750   %%%
        %%%   VICTORIA TOME OLIVEIRA MATRICULA: 366333  %%%
        %%%                                             %%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%-------------------------------------------------------------------%
% PROBLEMA:                                                         %
%   CRIAR UMA REDE PERCEPTRON COM UM �NICO NEURONIO PARA APROXIMAR  %
%   A COMBINA��O LINEAR y=x1+x2/2.                                  %
%   OS SEGUINTES VALORES INICIAIS S�O UTILIZADOS:                   %
%   w1=0.1 w2=0.1   a=0.1                                           %
%-------------------------------------------------------------------%

clear, clc

fprintf('Rede perceptron para aproxima��o da fun��o y=x1+x2/2\n');
fprintf('-----------------------------------------------------\n\n');

func = @(x1,x2) (x1+x2/2); %Func�o real.
u = @(a,b) (a + b)*1.5; %Fun��o de ativa��o da rede perceptron.

w=[0 0]; %Valores iniciais dos pesos.
a=0.05; % Taxa de aprendizagem.

x1=0:0.04:3; % Vetores utilizados para treinamento da rede perceptron.
x2=0:0.04:3; %
N=length(x1); % Armazena o tamanho do vetor x1.

e=ones(1,N); % Vetor de erros.
erro=true; % Indicador de erro.
it=1; % Contador de itera��es.

E=0; % Vari�vel utilizada para armazenar a soma dos erros.

% Vetores do hist�rico dos pesos s�o utilizados para plotar o gr�fico.
histw1=ones(1,N); %Vetor para armazenar hist�rico dos pesos 1.
histw2=ones(1,N); %Vetor para armazenar hist�rico dos pesos 2.
histw1(1)=w(1); %Valor inicial de w(1) � armazenado em histw1.
histw2(1)=w(2); %Valor inicial de w(2) � armazenado em histw2.

c = colormap(jet(3000)); % Utilizado para plotar gr�fico em degrad�.
subplot(2,2,3);

% Loop respons�vel por atualizar o valor dos pesos.
% O loop � executado at� que um valor aceit�vel de erro seja atingido.
while(erro)
    
    % Loops respons�veis por percorrer os vetores de treinamento.
    for i=1:N % Primeiro loop percorre os elementos de x1.
        for j=1:N % Segundo loop percorre os elementos de x2.
            
            % O valor real da fun��o � calculado para as entradas
            % x1(i) e x2(j).        
            d = func(x1(i),x2(j));
            
            % Para os valores x1(i) e x2(j),os pesos w(1) e w(2) s�o
            % testados na rede perceptron.
            y = u( x1(i)*w(1) , x2(j)*w(2) );                                                                      
                                            
            % O erro � calculado.
            % d � o valor esperado e y � o resultado obtido na perceptron.
            e(it)=d-y;
            
            % A vari�vel E receber� a soma dos valores absolutos dos erros de N itera��es.
            % Onde N � o tamanho do vetor de treinamento.
            E=E+abs(e(it));
            
            % Os pesos s�o ent�o atualizados, dado o erro obtido.
            w(1)=w(1)+e(it)*a*x1(i);
            w(2)=w(2)+e(it)*a*x2(j);
            
            % Os novos valores de pesos s�o armazenados nos vetores de
            % historico.
            histw1(it+1)=w(1);
            histw2(it+1)=w(2);
            
            
            % Plota as retas de cada itera��o, mostrando a perceptron
            % convergir para a solu��o desejada.            
            plot(u(x1*w(1) , x2*w(2)),'Color',c(it,:));
            hold on
            
            
            it = it + 1; % O n�mero de itera��es � atualizado.
            
            
        end
        
        % A soma de erros E � utilizada como crit�rio de parada. 
        % Se o E for suficientemente pequeno,
        % a vari�vel 'erro' � setado para false,
        % fazendo com que seja encerrada as itere��es.
        if E<0.001
            erro=false;
            break;
        end
        E=0; % A cada N itera��es, a soma dos erros � zerada.
        
    end
    
end

% Trecho respons�vel por mostrar os resultados ----------------------------
fprintf('Fun��o de ativa��o utilizada:\nu=(w1*x1 + w2*x2)*1.5\n\n');
fprintf('Pesos calculados:\nw1 = %f   w2 = %f\n\n',w(1),w(2));
fprintf('N�mero de itera��es:\n%d\n\n',it);

fprintf('\n\nTeste da rede para valores n�o treinados:\n');


% Dois vetores de valores aleat�rios s�o criados para testar 
% a rede perceptron depois de treinada.
k= randi(100,10,1);
l=randi(100,10,1);
table(10,5)=ones();

%Imprime os resultados em formato de tabela
for i=1:10
    table(i,1)=k(i);
    table(i,2)=l(i);
    table(i,3)=func(k(i),l(i));
    table(i,4)=u(k(i)*w(1) , l(i)*w(2));
    table(i,5)=abs(table(i,3)-table(i,4))*100;
end

fprintf('\n x1    x2   F(x1,x2)  P(x1,x2)  Erro');
fprintf('\n --    --   --------  --------  -----');

for i=1:10
    fprintf('\n');
    for j=1:5
        if j>2&&j<5
            fprintf('%7.3f   ',table(i,j));
        else if j==5
                fprintf('%3.2f%%   ',table(i,j));
            else
                fprintf('%3.0d   ',table(i,j));
            end
            
        end
            
    end
end
fprintf('\n --    --   -------   -------   -----\n');

% Trecho respons�vel por plotar os gr�ficos ----------------------------
title('Hist�rico de aprendizagem');
str = strcat(int2str(it),' itera��es');
text(70,4.7,str);
text(70,0.5, '0 itera��es');

%Gr�fico de compara��o Perceptron/Fun��o real � plotado
subplot(2,2,1);
plot(func(x1,x2),'r');
title('Compara��o Perceptron e Fun��o real');
hold on
plot(u(x1*w(1) , x2*w(2)), 'g*');
legend('Fun��o real','Perceptron','Location','West');

%Gr�fico de pesos � plotado
subplot(2,2,2);
plot(histw1,'r');
title('Hist�rico dos pesos')
hold on
plot(histw2);
legend(' Peso w1',' Peso w2','Location','northwest');
str1 = strcat('w1=',num2str(w(1)));
text(1800,0.7,str1);
str2 = strcat('w2=',num2str(w(2)));
text(1800,0.3,str2);

%Gr�fico de erro � plotado
subplot(2,2,4);
plot(e);
title('Erro')

%--------------------------------------------------------------------------

