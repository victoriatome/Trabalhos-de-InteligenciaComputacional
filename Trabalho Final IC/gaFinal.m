%     UNIVERSIDADE FEDERAL DO CEARÁ
%            CAMPUS SOBRAL
%   CURSO DE ENGENHARIA DE COMPUTAÇÃO
%
% INTELIGENCIA COMPUTACIONAL - TRABALHO 03
%
% ARTHUR SOUSA DE SENA    MATRICULA: 345750
% VICTORIA TOME OLIVEIRA  MATRICULA: 366333
% VITORIA ALMEIDA BERTAIA MATRICULA: 356741

% PROBLEMA ================================================================
%   UTILIZANDO GA REAL, ENCONTRAR VALOR DE MÁXIMO DA FUNÇÃO
%   z = (1 + sqrt(x) + 0.5.*y ).^2
%==========================================================================

clear; clc;

% Função calcula distância entre dois pontos ------------------------------
dist = @(p1,p2) sqrt((p2(1)-p1(1))^2 + (p2(2)-p1(2))^2 + (p2(3)- p1(3))^2);
%--------------------------------------------------------------------------

% Variáveis de controle ---------------------------------------------------
  OPMode = 1; % Modo 1 -> Encontra ponto de máximo da função
              % Modo 2 -> Executa o algoritmo N vezes e exibe a média de erros e média dos tempos
              % Modo 3 -> Executa o algoritmo N vezes, variando linearmente o número de cromossomos da população
% -------------------------
  
% Modo 1-------------
  crossAndSel = 4;  % Especifica o tipo de cruzamento e seleção:
                        % 1 -> Seleção Roleta e cruzamento Simples
                        % 2 -> Seleção Roleta e cruzamento Flat
                        % 3 -> Seleção Torneio e cruzamento Simples
                        % 4 -> Seleção Torneio e cruzamento Flat
                    
  tempoReal = true; % Plota o gráfico em tempo real ou não
% -------------------

% Modo 2 e 3---------
  nRep = 20;        % Número de repetições
% -------------------

% Modo 3-------------
  startSizePop = 10;% Tamanho inicial da população
  pStep = 10;       % Taxa de aumento do tamanho da população
% -------------------
%--------------------------------------------------------------------------


% Definição de parâmetros do GA -------------------------------------------
numGenerations = 200; % Número de gerações
sizePop = 200; % Tamanho da população ( Número de cromossomos )
chromoLength = 2; % Tamanho do cromossomo (número de variáveis);
crossProb = .8; % Taxa de crossover
mutProb = .3; % Taxa de mutação
%--------------------------------------------------------------------------


% Inicialização de variáveis ----------------------------------------------
tipo=1;tipoTest=1;numTipos=1;numRepeticoes=1;
if OPMode ~= 1 % Se o modo selecionado for 2 ou 3, variáveis necessárias para esse modo são inicializadas.
    numRepeticoes = nRep; % Número de repetições
    numTipos = 4; % Número de combinações possíveis de seleção e cruzamento
    if OPMode == 3 % Se o modo selecionado for o 3, variáveis necessárias para esse modo são inicializadas.
        vtSizePop = zeros(numTipos,numRepeticoes); % Vetor armazena os tamanhos da população
        popStep = pStep; % Incremento do tamanho da população
        sizePop = startSizePop; % Valor inicial do tamanho da população
        vtSizePop(tipo,1) = sizePop; % Vetor armazena o primeiro tamanho da população
    end
end
tempPop = zeros(sizePop,chromoLength); % Variável utilizada para armazenar temporariamente a população
newPop = zeros(sizePop,chromoLength); % Variável utilizada para receber a nova população
zMax = zeros(1,numGenerations); % Vetor que armazena a melhor aptidão de cada geração
xMax = zeros(1,numGenerations); % Vetor que armazena o valor x do melhor cromossomo de cada geração
yMax = zeros(1,numGenerations); % Vetor que armazena o valor y do melhor cromossomo de cada geração
vtTempo = zeros(numRepeticoes,4); % Matriz utilizada para armazenar o tempo gasto em cada repetição
erro = zeros(numRepeticoes,1); % Vetor utilizado para armazenar os erros em cada repetição
%--------------------------------------------------------------------------

% Loop utilizado nas repetições, para executar o algorítimo para cada
% combinação de seleção e cruzamento
for tipo=1:numTipos
    % Loop utilizado para repetir a execução do algorítimo
    for it=1:numRepeticoes
        
        % Se o algoritmo estiver sendo executado em modo 1, as propriedades
        % dos gráficos para esse modo são inicializadas.
        if OPMode==1
            tipo=crossAndSel;
            % Propriedades do gráfico da função é setado ------------------------------
            movegui(figure('Name','Algoritmo Genético','NumberTitle','off','position',[0 0 950 700]),'center');
            grafTempoReal = tempoReal; % Booleana utilizada para plotar ou não o gráfico em tempo real
            %--------------------------------------------------------------------------
        end
        
        
        % Especificação dos tipos de seleção e cruzamento -------------------------
        if(tipo==1)
            tipoSelecao = 'Roleta'; 
            tipoCrossover = 'Simples'; 
        end
        if(tipo==2)
            tipoSelecao = 'Roleta';
            tipoCrossover = 'Flat';
        end
        if(tipo==3)
            tipoSelecao = 'Torneio';
            tipoCrossover = 'Simples';
        end
        if(tipo==4)
            tipoSelecao = 'Torneio';
            tipoCrossover = 'Flat';
        end
        %--------------------------------------------------------------------------
        
        % Se o Modo 3 estiver sendo executado, as variáveis temporárias de
        % população, são inicializadas a cada repetição
        if OPMode==3
            tempPop = zeros(sizePop,chromoLength);
            newPop = zeros(sizePop,chromoLength);
        end
        
        % Inicialização da população ----------------------------------------------
        limInf= 1; limSup = 6; % Limites do intervalo da população
        pop = limInf +(limSup-limInf)*rand(sizePop,chromoLength); % População inicial é gerada aleatoriamente
        %--------------------------------------------------------------------------
        
       
        t0=tic; % Tempo começa a ser contado
        
        % Loop de gerações, e executado até que o número máximo de gerações seja atingido
        for gen=1:numGenerations
            
            F = funcApt(pop(:,1),pop(:,2)); % Aptidão é calculada para todos os valores da atual polulação
            
            [~, maxFi] = max(F);        % Melhor cromossomo é guardado
            currentMax = pop(maxFi,:);  % para garantir o elitismo
            
            % Seleção Roleta ------------------------------------------------------
            if (strcmp(tipoSelecao,'Roleta'))
                prob = zeros(length(F),3); % Vetor de probabilidades
                for i=1:length(pop');
                    % Cada probabilidade é calculada
                    prob(i,:) = [funcApt(pop(i,1),pop(i,2)) ./ sum(F),pop(i,1),pop(i,2)]; 
                end
                
                % O vetor de probabilidades é ordenado para ser utilizado na roleta
                prob = sortrows(prob,1); 
                
                % Vetor utilizado para guardar as posições da roleta e
                % utilizado pra evitar que tal posição seja selecionada novamente
                positions = zeros(sizePop/2,1); 
                
                i=1;
                while i<=sizePop/2
                    % Uma posição é gerada aleatoriamente, simulando a roleta
                    roulette =round(1 + (sizePop-1)*rand); 
                    if ~any(positions==roulette) % Verifica se a posição já foi retirada
                        positions(i)=roulette; % Salva a posição gerada
                        % O cromossomo é guardado na nova população
                        newPop(i,:)=[prob(positions(i),2),prob(positions(i),3)]; 
                        i = i+1;
                    end
                end
                newPop((sizePop/2+1:end),:) = flipud(newPop((1:sizePop/2),:));
                
            end
            %----------------------------------------------------------------------
            
            
            % Seleção Torneio -----------------------------------------------------
            if (strcmp(tipoSelecao,'Torneio'))
                numTour = 5; % Número de cromossomos sorteados
                positions = zeros(numTour,1); % Vetor utilizado para evitar repetição de torneio
                
                for i=1:sizePop/2
                    t = 1;
                    while t<numTour+1
                        tournament = round(1 + (sizePop - 1)*rand); % Torneio é realizado
                        
                        if ~any(positions==tournament) % Verifica se o cromossomo já foi sorteado
                            positions(t)=tournament; 
                            tempPop(t,:)=[pop(positions(t),1),pop(positions(t),2)]; % Cromossomos sorteados é armazenado em vetor temporário
                            t = t+1;
                        end
                    end
                    
                    F = funcApt(tempPop(:,1),tempPop(:,2));
                    [~,maxTourI] = max(F); % O melhor cromossomo é selecionado dentre daqueles sorteados
                    newPop(i,:) = [tempPop(maxTourI,1),tempPop(maxTourI,2)]; % Cromossomo é salvo na nova população
                end
                newPop((sizePop/2+1:end),:) = flipud(newPop((1:sizePop/2),:));
            end
            
            
            %----------------------------------------------------------------------
            
            
            % Crossover simples ---------------------------------------------------
            if(strcmp(tipoCrossover,'Simples'))
                for i=1:2:sizePop
                    [newPop(i,:), newPop(i+1,:)]=crossSimples(newPop(i,:), newPop(i+1,:),crossProb);
                end
            end
            %----------------------------------------------------------------------
            
            % Crossover flat ------------------------------------------------------
            if(strcmp(tipoCrossover,'Flat'))
                for i=1:2:sizePop
                    [newPop(i,:), newPop(i+1,:)]=crossFlat(newPop(i,:), newPop(i+1,:),crossProb);
                end
            end
            %----------------------------------------------------------------------
            
            
            % Mutação aleatória ---------------------------------------------------
            for i=1:sizePop
                newPop(i,:)=mutRand(newPop(i,:),[limInf limSup],mutProb);
            end
            %----------------------------------------------------------------------
            
            
            % Elitismo ------------------------------------------------------------
            pop = newPop;
            pop(maxFi,:) = currentMax; % O melhor cromossomo é passado para a geração seguinte.
            % ---------------------------------------------------------------------
            
            
            % Os gráficos são plotados ------------------------------------
            
            F = funcApt(pop(:,1),pop(:,2));
            [zMax(gen), iMax] = max(F);
            xMax(gen) = pop(iMax,1);
            yMax(gen) = pop(iMax,2);
            if OPMode==1
                if grafTempoReal
                    passo = 0.03;
                    x = limInf:passo:limSup;
                    y = limInf:passo:limSup;
                    [x,y]=meshgrid(x,y);
                    z = funcApt(x,y);
                    mesh(x,y,z);
                    hold on;
                    plot3(pop(:,1),pop(:,2),F,'b+');
                    plot3(xMax(gen),yMax(gen),zMax(gen),'r*');
                    xlabel(sprintf('X_{max} = %f',xMax(gen)));
                    ylabel(sprintf('Y_{max} = %f',yMax(gen)));
                    zlabel(sprintf('Z_{max} = %f',zMax(gen)));
                    hold off;
                    
                    title(sprintf('Método de seleção: %s, Método de cruzamento: %s, Geração = %d', tipoSelecao, tipoCrossover, gen));
                    pause(0);
                end
            end
        end
        tempo = toc(t0);
        
        if OPMode==1
                        
            if ~grafTempoReal
                
                passo = 0.03;
                x = limInf:passo:limSup;
                y = limInf:passo:limSup;
                [x,y]=meshgrid(x,y);
                z = funcApt(x,y);
                mesh(x,y,z);
                hold on;
                plot3(pop(:,1),pop(:,2),F,'b+');
                plot3(xMax(gen),yMax(gen),zMax(gen),'r*');
                xlabel(sprintf('X_{max} = %f',xMax(gen)));
                ylabel(sprintf('Y_{max} = %f',yMax(gen)));
                zlabel(sprintf('Z_{max} = %f',zMax(gen)));
                hold off;
                
                title(sprintf('Método de seleção: %s, Método de cruzamento: %s, Geração = %d', tipoSelecao, tipoCrossover, gen));
            end
            
            movegui(figure('Name','Evolução de aptidão','NumberTitle','off','position',[0 0 1200 800]),'center');
            
            subplot(2,1,1);
            plot(zMax,'g');
            title('Aptidão Máxima ao Longo das Gerações');
            xlabel('Número de gerações');
            ylabel('Aptidão');
            legend(sprintf('Aptidão máxima = %f',zMax(gen)),'Location','best');
            
            
            subplot(2,1,2);
            plotX = plot(xMax,'b');
            
            hold on
            
            plotY = plot(yMax,'r');
            title('Melhores Cromossomos ao Longo das Gerações');
            xlabel('Número de gerações');
            ylabel('Valores de X e Y');
            legend([plotX plotY], sprintf('X_{max} = %f',xMax(gen)),sprintf('Y_{max} = %f',yMax(gen)));
            
            
            % Resultados --------------------------------------------------------------
            display(sprintf('=========================================================='));
            display(sprintf('       Algorítmo Genético com Representação Real'));
            display(sprintf('          para obtenção do ponto de máximo da'));
            display(sprintf('          função Z = (1 + sqrt(x) + 0.5*y )^2\n'));
            display(sprintf('==================== Parâmetros do GA ===================='));
            display(sprintf('Número de cromossomos: %d',sizePop));
            display(sprintf('Número de gerações: %d',numGenerations));
            display(sprintf('Método de seleção utilizado: %s',tipoSelecao));
            display(sprintf('Método de cruzamento utilizado: %s ',tipoCrossover));
            display(sprintf('\n\n------------------- Resultados -------------------'));
            display(sprintf('\nTempo gasto: %.2f s\n',tempo));
            display(sprintf('Valores obtidos\nX = %f     Y = %f    Z = %f\n',xMax(gen),yMax(gen),zMax(gen)));
            display(sprintf('Ponto de máximo real\nX = 6            Y = 6           Z = %f\n',funcApt(6,6)));
            display(sprintf('Erros\ne_x = %.3f%%     e_y = %.3f%%    e_z = %.3f%%\n',(6-xMax(gen))*100/6,(6-yMax(gen))*100/6,(funcApt(6,6)-zMax(gen))*100/funcApt(6,6)));
            display(sprintf('Erro absoluto: %.4f\n',abs(dist([xMax(gen) yMax(gen) zMax(gen)],[6 6 funcApt(6,6)]))));
            display(sprintf('=========================================================='));
            
        else
            erro(it,tipo) = abs(dist([xMax(gen) yMax(gen) zMax(gen)],[6 6 funcApt(6,6)]));
            vtTempo(it,tipo) = tempo;
            
            if OPMode == 3 && ~(it==1&&tipo==1)
                sizePop = sizePop+popStep;
                if tipo ~= tipoTest
                    sizePop=startSizePop;
                end
                vtSizePop(tipo,it) = sizePop;
                tipoTest = tipo;
            end
            
        end
        
    end
end

% Resultados do modo 2 ------------------------------------------------------
if OPMode==2
    movegui(figure('Name','Tempo gasto para diferentes parâmetros','NumberTitle','off','position',[0 0 1200 800]),'center');
    for i=1:4
        switch i
            case 1
                p1=plot(vtTempo(:,i),'s:');
                r1=lsline;
            case 2
                p2=plot(vtTempo(:,i),'o:');
                r2=lsline;
            case 3
                p3=plot(vtTempo(:,i),'v:');
                r3=lsline;
            case 4
                p4=plot(vtTempo(:,i),'h:');
                r4=lsline;
        end
        hold on
    end
    
    legend([p1 p2 p3 p4],sprintf('Seleção Roleta e Crossover Simples - Tempo médio = %.2f s', sum(vtTempo(:,1)/length(vtTempo(:,1)))), sprintf('Seleção Roleta e Crossover Flat - Tempo médio = %.2f s',sum(vtTempo(:,2)/length(vtTempo(:,2)))), sprintf('Seleção Torneio e Crossover Simples - Tempo médio = %.2f s',sum(vtTempo(:,3)/length(vtTempo(:,3)))), sprintf('Seleção Torneio e Crossover Flat - Tempo médio = %.2f s',sum(vtTempo(:,4)/length(vtTempo(:,4)))) );
    xlabel('Número de repetições do experimento');
    ylabel('Tempo gasto (s)');
    title('Tempo gasto para diferentes combinações de parâmetros');
    
    movegui(figure('Name','Erro para diferentes parâmetros','NumberTitle','off','position',[0 0 1200 800]),'center');
    for i=1:4
        switch i
            case 1
                p1=plot(erro(:,i),'s:');
                r1=lsline;
            case 2
                p2=plot(erro(:,i),'o:');
                r2=lsline;
            case 3
                p3=plot(erro(:,i),'v:');
                r3=lsline;
            case 4
                p4=plot(erro(:,i),'h:');
                r4=lsline;
        end
        hold on
    end
    legend([p1 p2 p3 p4],sprintf('Seleção Roleta e Crossover Simples - Erro médio = %.4f', sum(erro(:,1)/length(erro(:,1)))), sprintf('Seleção Roleta e Crossover Flat - Erro médio = %.4f',sum(erro(:,2)/length(erro(:,2)))), sprintf('Seleção Torneio e Crossover Simples - Erro médio = %.4f',sum(erro(:,3)/length(erro(:,3)))), sprintf('Seleção Torneio e Crossover Flat - Erro médio = %.4f',sum(erro(:,4)/length(erro(:,4)))) );
    xlabel('Número de repetições do experimento');
    ylabel('Erro');
    title('Erros para para diferentes combinações de parâmetros');
    

    %Resultados ---------------------------------------------------------------
    display(sprintf('=========================================================='));
    display(sprintf('       Algorítmo Genético com Representação Real'));
    display(sprintf('          para obtenção do ponto de máximo da'));
    display(sprintf('          função Z = (1 + sqrt(x) + 0.5*y )^2\n'));
    display(sprintf('=========================================================='));
    display(sprintf('Teste de eficiência dos métodos'));
    display(sprintf('implementados de seleção e cruzamento'));
    display(sprintf('--------------------------------------------------------\n'));
    display(sprintf('Número de cromossomos: %d',sizePop));
    display(sprintf('Número de gerações: %d',numGenerations));
    display(sprintf('\nNúmero de repetições para cada configuração: %d',numRepeticoes));
    display(sprintf('Tempo total gasto: %.2f s\n',sum(vtTempo(:))));
    
    t=sum(vtTempo);
    display(sprintf('\n======================= Resultados dos testes ======================='));
    display(sprintf('\n----- Método de seleção: ROLETA   Método de cruzamento: SIMPLES -----'));
    display(sprintf('Tempo total gasto nessa configuração: %.2f s',t(1)));
    display(sprintf('Tempo médio de cada repetição: %.2f s',sum(vtTempo(:,1)/length(vtTempo(:,1)))));
    display(sprintf('Erro médio: %.4f',sum(erro(:,1)/length(erro(:,1)))));
    display(sprintf('---------------------------------------------------------------------\n'));
    
    display(sprintf('\n------ Método de seleção: ROLETA   Método de cruzamento: FLAT -------'));
    display(sprintf('Tempo total gasto nessa configuração: %.2f s',t(2)));
    display(sprintf('Tempo médio de cada repetição: %.2f s',sum(vtTempo(:,2)/length(vtTempo(:,2)))));
    display(sprintf('Erro médio: %.4f',sum(erro(:,2)/length(erro(:,2)))));
    display(sprintf('---------------------------------------------------------------------\n'));
    
    display(sprintf('\n---- Método de seleção: TORNEIO   Método de cruzamento: SIMPLES -----'));
    display(sprintf('Tempo total gasto nessa configuração: %.2f s',t(3)));
    display(sprintf('Tempo médio de cada repetição: %.2f s',sum(vtTempo(:,3)/length(vtTempo(:,3)))));
    display(sprintf('Erro médio: %.4f',sum(erro(:,3)/length(erro(:,3)))));
    display(sprintf('---------------------------------------------------------------------\n'));
    
    display(sprintf('\n------ Método de seleção: TORNEIO   Método de cruzamento: FLAT ------'));
    display(sprintf('Tempo total gasto nessa configuração: %.2f s',t(4)));
    display(sprintf('Tempo médio de cada repetição: %.2f s',sum(vtTempo(:,4)/length(vtTempo(:,4)))));
    display(sprintf('Erro médio: %.4f',sum(erro(:,4)/length(erro(:,4)))));
    display(sprintf('---------------------------------------------------------------------\n'));
    
end



% Resultados do modo 3 ------------------------------------------------------
if OPMode==3
    configs = {'Método de seleção: ROLETA, Método de cruzamento: SIMPLES', 'Método de seleção: ROLETA, Método de cruzamento: FLAT', 'Método de seleção: TORNEIO, Método de cruzamento: SIMPLES', 'Método de seleção: TORNEIO, Método de cruzamento: FLAT'};
    movegui(figure('Name','Influência do número de cromossomos no tempo de execução do algoritmo','NumberTitle','off','position',[0 0 1200 800]),'center');
    for i=1:4
        subplot(2,2,i);
        plot(vtSizePop(i,2:end),vtTempo(2:end,i),'ko:', 10:sizePop,polyval(polyfit(vtSizePop(i,2:end)',vtTempo(2:end,i),1),10:sizePop), '--');
        xlabel('Número de cromossomos');
        ylabel('Tempo (s)');
        title(configs(i));
    end
    
    
    movegui(figure('Name','Influência do número de cromossomos na eficiência do algoritmo','NumberTitle','off','position',[0 0 1200 800]),'center');
    for i=1:4
        subplot(2,2,i);
        plot(vtSizePop(i,2:end),erro(2:end,i),'ko:', 10:sizePop,polyval(polyfit(vtSizePop(i,2:end)',erro(2:end,i),3),10:sizePop), '--');
        xlabel('Número de cromossomos');
        ylabel('Erro');
        title(configs(i));
    end
    
    
    %Resultados ---------------------------------------------------------------
    display(sprintf('=========================================================='));
    display(sprintf('       Algorítmo Genético com Representação Real'));
    display(sprintf('          para obtenção do ponto de máximo da'));
    display(sprintf('          função Z = (1 + sqrt(x) + 0.5*y )^2\n'));
    display(sprintf('=========================================================='));
    display(sprintf('Teste de influência do número de cromossomos'));
    display(sprintf('no desempenho do algorítimo para cada'));
    display(sprintf('método de seleção e cruzamento'));
    display(sprintf('--------------------------------------------------------\n'));
    display(sprintf('Número inicial de cromossomos: %d     Passo: %d',startSizePop,popStep));
    display(sprintf('Número final de cromossomos: %d',sizePop));
    display(sprintf('Número de gerações: %d',numGenerations));
    display(sprintf('\nNúmero de repetições para cada configuração: %d',numRepeticoes));
    display(sprintf('Tempo total gasto: %.2f s\n',sum(vtTempo(:))));
    
   
    display(sprintf('\n======================= Resultados do teste ======================='));
    display(sprintf('\n----- Método de seleção: ROLETA   Método de cruzamento: SIMPLES -----'));
    for i=1:numRepeticoes
        display(sprintf('Número de neurônios: %4d      Tempo gasto: %.2f s      Erro: %f',vtSizePop(1,i),vtTempo(i,1),erro(i,1)));
    end
    display(sprintf('---------------------------------------------------------------------\n'));
    
    display(sprintf('\n------ Método de seleção: ROLETA   Método de cruzamento: FLAT -------'));
    for i=1:numRepeticoes
        display(sprintf('Número de neurônios: %4d      Tempo gasto: %.2f s      Erro: %f',vtSizePop(2,i),vtTempo(i,2),erro(i,2)));
    end
    display(sprintf('---------------------------------------------------------------------\n'));
    
    display(sprintf('\n---- Método de seleção: TORNEIO   Método de cruzamento: SIMPLES -----'));
    for i=1:numRepeticoes
        display(sprintf('Número de neurônios: %4d      Tempo gasto: %.2f s      Erro: %f',vtSizePop(3,i),vtTempo(i,3),erro(i,3)));
    end
    display(sprintf('---------------------------------------------------------------------\n'));
    
    display(sprintf('\n------ Método de seleção: TORNEIO   Método de cruzamento: FLAT ------'));
    for i=1:numRepeticoes
        display(sprintf('Número de neurônios: %4d      Tempo gasto: %.2f s      Erro: %f',vtSizePop(4,i),vtTempo(i,4),erro(i,4)));
    end
   display(sprintf('---------------------------------------------------------------------\n'));
    
end



