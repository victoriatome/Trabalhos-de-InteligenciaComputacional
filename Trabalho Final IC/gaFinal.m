%     UNIVERSIDADE FEDERAL DO CEAR�
%            CAMPUS SOBRAL
%   CURSO DE ENGENHARIA DE COMPUTA��O
%
% INTELIGENCIA COMPUTACIONAL - TRABALHO 03
%
% ARTHUR SOUSA DE SENA    MATRICULA: 345750
% VICTORIA TOME OLIVEIRA  MATRICULA: 366333
% VITORIA ALMEIDA BERTAIA MATRICULA: 356741

% PROBLEMA ================================================================
%   UTILIZANDO GA REAL, ENCONTRAR VALOR DE M�XIMO DA FUN��O
%   z = (1 + sqrt(x) + 0.5.*y ).^2
%==========================================================================

clear; clc;

% Fun��o calcula dist�ncia entre dois pontos ------------------------------
dist = @(p1,p2) sqrt((p2(1)-p1(1))^2 + (p2(2)-p1(2))^2 + (p2(3)- p1(3))^2);
%--------------------------------------------------------------------------

% Vari�veis de controle ---------------------------------------------------
  OPMode = 1; % Modo 1 -> Encontra ponto de m�ximo da fun��o
              % Modo 2 -> Executa o algoritmo N vezes e exibe a m�dia de erros e m�dia dos tempos
              % Modo 3 -> Executa o algoritmo N vezes, variando linearmente o n�mero de cromossomos da popula��o
% -------------------------
  
% Modo 1-------------
  crossAndSel = 4;  % Especifica o tipo de cruzamento e sele��o:
                        % 1 -> Sele��o Roleta e cruzamento Simples
                        % 2 -> Sele��o Roleta e cruzamento Flat
                        % 3 -> Sele��o Torneio e cruzamento Simples
                        % 4 -> Sele��o Torneio e cruzamento Flat
                    
  tempoReal = true; % Plota o gr�fico em tempo real ou n�o
% -------------------

% Modo 2 e 3---------
  nRep = 20;        % N�mero de repeti��es
% -------------------

% Modo 3-------------
  startSizePop = 10;% Tamanho inicial da popula��o
  pStep = 10;       % Taxa de aumento do tamanho da popula��o
% -------------------
%--------------------------------------------------------------------------


% Defini��o de par�metros do GA -------------------------------------------
numGenerations = 200; % N�mero de gera��es
sizePop = 200; % Tamanho da popula��o ( N�mero de cromossomos )
chromoLength = 2; % Tamanho do cromossomo (n�mero de vari�veis);
crossProb = .8; % Taxa de crossover
mutProb = .3; % Taxa de muta��o
%--------------------------------------------------------------------------


% Inicializa��o de vari�veis ----------------------------------------------
tipo=1;tipoTest=1;numTipos=1;numRepeticoes=1;
if OPMode ~= 1 % Se o modo selecionado for 2 ou 3, vari�veis necess�rias para esse modo s�o inicializadas.
    numRepeticoes = nRep; % N�mero de repeti��es
    numTipos = 4; % N�mero de combina��es poss�veis de sele��o e cruzamento
    if OPMode == 3 % Se o modo selecionado for o 3, vari�veis necess�rias para esse modo s�o inicializadas.
        vtSizePop = zeros(numTipos,numRepeticoes); % Vetor armazena os tamanhos da popula��o
        popStep = pStep; % Incremento do tamanho da popula��o
        sizePop = startSizePop; % Valor inicial do tamanho da popula��o
        vtSizePop(tipo,1) = sizePop; % Vetor armazena o primeiro tamanho da popula��o
    end
end
tempPop = zeros(sizePop,chromoLength); % Vari�vel utilizada para armazenar temporariamente a popula��o
newPop = zeros(sizePop,chromoLength); % Vari�vel utilizada para receber a nova popula��o
zMax = zeros(1,numGenerations); % Vetor que armazena a melhor aptid�o de cada gera��o
xMax = zeros(1,numGenerations); % Vetor que armazena o valor x do melhor cromossomo de cada gera��o
yMax = zeros(1,numGenerations); % Vetor que armazena o valor y do melhor cromossomo de cada gera��o
vtTempo = zeros(numRepeticoes,4); % Matriz utilizada para armazenar o tempo gasto em cada repeti��o
erro = zeros(numRepeticoes,1); % Vetor utilizado para armazenar os erros em cada repeti��o
%--------------------------------------------------------------------------

% Loop utilizado nas repeti��es, para executar o algor�timo para cada
% combina��o de sele��o e cruzamento
for tipo=1:numTipos
    % Loop utilizado para repetir a execu��o do algor�timo
    for it=1:numRepeticoes
        
        % Se o algoritmo estiver sendo executado em modo 1, as propriedades
        % dos gr�ficos para esse modo s�o inicializadas.
        if OPMode==1
            tipo=crossAndSel;
            % Propriedades do gr�fico da fun��o � setado ------------------------------
            movegui(figure('Name','Algoritmo Gen�tico','NumberTitle','off','position',[0 0 950 700]),'center');
            grafTempoReal = tempoReal; % Booleana utilizada para plotar ou n�o o gr�fico em tempo real
            %--------------------------------------------------------------------------
        end
        
        
        % Especifica��o dos tipos de sele��o e cruzamento -------------------------
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
        
        % Se o Modo 3 estiver sendo executado, as vari�veis tempor�rias de
        % popula��o, s�o inicializadas a cada repeti��o
        if OPMode==3
            tempPop = zeros(sizePop,chromoLength);
            newPop = zeros(sizePop,chromoLength);
        end
        
        % Inicializa��o da popula��o ----------------------------------------------
        limInf= 1; limSup = 6; % Limites do intervalo da popula��o
        pop = limInf +(limSup-limInf)*rand(sizePop,chromoLength); % Popula��o inicial � gerada aleatoriamente
        %--------------------------------------------------------------------------
        
       
        t0=tic; % Tempo come�a a ser contado
        
        % Loop de gera��es, e executado at� que o n�mero m�ximo de gera��es seja atingido
        for gen=1:numGenerations
            
            F = funcApt(pop(:,1),pop(:,2)); % Aptid�o � calculada para todos os valores da atual polula��o
            
            [~, maxFi] = max(F);        % Melhor cromossomo � guardado
            currentMax = pop(maxFi,:);  % para garantir o elitismo
            
            % Sele��o Roleta ------------------------------------------------------
            if (strcmp(tipoSelecao,'Roleta'))
                prob = zeros(length(F),3); % Vetor de probabilidades
                for i=1:length(pop');
                    % Cada probabilidade � calculada
                    prob(i,:) = [funcApt(pop(i,1),pop(i,2)) ./ sum(F),pop(i,1),pop(i,2)]; 
                end
                
                % O vetor de probabilidades � ordenado para ser utilizado na roleta
                prob = sortrows(prob,1); 
                
                % Vetor utilizado para guardar as posi��es da roleta e
                % utilizado pra evitar que tal posi��o seja selecionada novamente
                positions = zeros(sizePop/2,1); 
                
                i=1;
                while i<=sizePop/2
                    % Uma posi��o � gerada aleatoriamente, simulando a roleta
                    roulette =round(1 + (sizePop-1)*rand); 
                    if ~any(positions==roulette) % Verifica se a posi��o j� foi retirada
                        positions(i)=roulette; % Salva a posi��o gerada
                        % O cromossomo � guardado na nova popula��o
                        newPop(i,:)=[prob(positions(i),2),prob(positions(i),3)]; 
                        i = i+1;
                    end
                end
                newPop((sizePop/2+1:end),:) = flipud(newPop((1:sizePop/2),:));
                
            end
            %----------------------------------------------------------------------
            
            
            % Sele��o Torneio -----------------------------------------------------
            if (strcmp(tipoSelecao,'Torneio'))
                numTour = 5; % N�mero de cromossomos sorteados
                positions = zeros(numTour,1); % Vetor utilizado para evitar repeti��o de torneio
                
                for i=1:sizePop/2
                    t = 1;
                    while t<numTour+1
                        tournament = round(1 + (sizePop - 1)*rand); % Torneio � realizado
                        
                        if ~any(positions==tournament) % Verifica se o cromossomo j� foi sorteado
                            positions(t)=tournament; 
                            tempPop(t,:)=[pop(positions(t),1),pop(positions(t),2)]; % Cromossomos sorteados � armazenado em vetor tempor�rio
                            t = t+1;
                        end
                    end
                    
                    F = funcApt(tempPop(:,1),tempPop(:,2));
                    [~,maxTourI] = max(F); % O melhor cromossomo � selecionado dentre daqueles sorteados
                    newPop(i,:) = [tempPop(maxTourI,1),tempPop(maxTourI,2)]; % Cromossomo � salvo na nova popula��o
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
            
            
            % Muta��o aleat�ria ---------------------------------------------------
            for i=1:sizePop
                newPop(i,:)=mutRand(newPop(i,:),[limInf limSup],mutProb);
            end
            %----------------------------------------------------------------------
            
            
            % Elitismo ------------------------------------------------------------
            pop = newPop;
            pop(maxFi,:) = currentMax; % O melhor cromossomo � passado para a gera��o seguinte.
            % ---------------------------------------------------------------------
            
            
            % Os gr�ficos s�o plotados ------------------------------------
            
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
                    
                    title(sprintf('M�todo de sele��o: %s, M�todo de cruzamento: %s, Gera��o = %d', tipoSelecao, tipoCrossover, gen));
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
                
                title(sprintf('M�todo de sele��o: %s, M�todo de cruzamento: %s, Gera��o = %d', tipoSelecao, tipoCrossover, gen));
            end
            
            movegui(figure('Name','Evolu��o de aptid�o','NumberTitle','off','position',[0 0 1200 800]),'center');
            
            subplot(2,1,1);
            plot(zMax,'g');
            title('Aptid�o M�xima ao Longo das Gera��es');
            xlabel('N�mero de gera��es');
            ylabel('Aptid�o');
            legend(sprintf('Aptid�o m�xima = %f',zMax(gen)),'Location','best');
            
            
            subplot(2,1,2);
            plotX = plot(xMax,'b');
            
            hold on
            
            plotY = plot(yMax,'r');
            title('Melhores Cromossomos ao Longo das Gera��es');
            xlabel('N�mero de gera��es');
            ylabel('Valores de X e Y');
            legend([plotX plotY], sprintf('X_{max} = %f',xMax(gen)),sprintf('Y_{max} = %f',yMax(gen)));
            
            
            % Resultados --------------------------------------------------------------
            display(sprintf('=========================================================='));
            display(sprintf('       Algor�tmo Gen�tico com Representa��o Real'));
            display(sprintf('          para obten��o do ponto de m�ximo da'));
            display(sprintf('          fun��o Z = (1 + sqrt(x) + 0.5*y )^2\n'));
            display(sprintf('==================== Par�metros do GA ===================='));
            display(sprintf('N�mero de cromossomos: %d',sizePop));
            display(sprintf('N�mero de gera��es: %d',numGenerations));
            display(sprintf('M�todo de sele��o utilizado: %s',tipoSelecao));
            display(sprintf('M�todo de cruzamento utilizado: %s ',tipoCrossover));
            display(sprintf('\n\n------------------- Resultados -------------------'));
            display(sprintf('\nTempo gasto: %.2f s\n',tempo));
            display(sprintf('Valores obtidos\nX = %f     Y = %f    Z = %f\n',xMax(gen),yMax(gen),zMax(gen)));
            display(sprintf('Ponto de m�ximo real\nX = 6            Y = 6           Z = %f\n',funcApt(6,6)));
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
    movegui(figure('Name','Tempo gasto para diferentes par�metros','NumberTitle','off','position',[0 0 1200 800]),'center');
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
    
    legend([p1 p2 p3 p4],sprintf('Sele��o Roleta e Crossover Simples - Tempo m�dio = %.2f s', sum(vtTempo(:,1)/length(vtTempo(:,1)))), sprintf('Sele��o Roleta e Crossover Flat - Tempo m�dio = %.2f s',sum(vtTempo(:,2)/length(vtTempo(:,2)))), sprintf('Sele��o Torneio e Crossover Simples - Tempo m�dio = %.2f s',sum(vtTempo(:,3)/length(vtTempo(:,3)))), sprintf('Sele��o Torneio e Crossover Flat - Tempo m�dio = %.2f s',sum(vtTempo(:,4)/length(vtTempo(:,4)))) );
    xlabel('N�mero de repeti��es do experimento');
    ylabel('Tempo gasto (s)');
    title('Tempo gasto para diferentes combina��es de par�metros');
    
    movegui(figure('Name','Erro para diferentes par�metros','NumberTitle','off','position',[0 0 1200 800]),'center');
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
    legend([p1 p2 p3 p4],sprintf('Sele��o Roleta e Crossover Simples - Erro m�dio = %.4f', sum(erro(:,1)/length(erro(:,1)))), sprintf('Sele��o Roleta e Crossover Flat - Erro m�dio = %.4f',sum(erro(:,2)/length(erro(:,2)))), sprintf('Sele��o Torneio e Crossover Simples - Erro m�dio = %.4f',sum(erro(:,3)/length(erro(:,3)))), sprintf('Sele��o Torneio e Crossover Flat - Erro m�dio = %.4f',sum(erro(:,4)/length(erro(:,4)))) );
    xlabel('N�mero de repeti��es do experimento');
    ylabel('Erro');
    title('Erros para para diferentes combina��es de par�metros');
    

    %Resultados ---------------------------------------------------------------
    display(sprintf('=========================================================='));
    display(sprintf('       Algor�tmo Gen�tico com Representa��o Real'));
    display(sprintf('          para obten��o do ponto de m�ximo da'));
    display(sprintf('          fun��o Z = (1 + sqrt(x) + 0.5*y )^2\n'));
    display(sprintf('=========================================================='));
    display(sprintf('Teste de efici�ncia dos m�todos'));
    display(sprintf('implementados de sele��o e cruzamento'));
    display(sprintf('--------------------------------------------------------\n'));
    display(sprintf('N�mero de cromossomos: %d',sizePop));
    display(sprintf('N�mero de gera��es: %d',numGenerations));
    display(sprintf('\nN�mero de repeti��es para cada configura��o: %d',numRepeticoes));
    display(sprintf('Tempo total gasto: %.2f s\n',sum(vtTempo(:))));
    
    t=sum(vtTempo);
    display(sprintf('\n======================= Resultados dos testes ======================='));
    display(sprintf('\n----- M�todo de sele��o: ROLETA   M�todo de cruzamento: SIMPLES -----'));
    display(sprintf('Tempo total gasto nessa configura��o: %.2f s',t(1)));
    display(sprintf('Tempo m�dio de cada repeti��o: %.2f s',sum(vtTempo(:,1)/length(vtTempo(:,1)))));
    display(sprintf('Erro m�dio: %.4f',sum(erro(:,1)/length(erro(:,1)))));
    display(sprintf('---------------------------------------------------------------------\n'));
    
    display(sprintf('\n------ M�todo de sele��o: ROLETA   M�todo de cruzamento: FLAT -------'));
    display(sprintf('Tempo total gasto nessa configura��o: %.2f s',t(2)));
    display(sprintf('Tempo m�dio de cada repeti��o: %.2f s',sum(vtTempo(:,2)/length(vtTempo(:,2)))));
    display(sprintf('Erro m�dio: %.4f',sum(erro(:,2)/length(erro(:,2)))));
    display(sprintf('---------------------------------------------------------------------\n'));
    
    display(sprintf('\n---- M�todo de sele��o: TORNEIO   M�todo de cruzamento: SIMPLES -----'));
    display(sprintf('Tempo total gasto nessa configura��o: %.2f s',t(3)));
    display(sprintf('Tempo m�dio de cada repeti��o: %.2f s',sum(vtTempo(:,3)/length(vtTempo(:,3)))));
    display(sprintf('Erro m�dio: %.4f',sum(erro(:,3)/length(erro(:,3)))));
    display(sprintf('---------------------------------------------------------------------\n'));
    
    display(sprintf('\n------ M�todo de sele��o: TORNEIO   M�todo de cruzamento: FLAT ------'));
    display(sprintf('Tempo total gasto nessa configura��o: %.2f s',t(4)));
    display(sprintf('Tempo m�dio de cada repeti��o: %.2f s',sum(vtTempo(:,4)/length(vtTempo(:,4)))));
    display(sprintf('Erro m�dio: %.4f',sum(erro(:,4)/length(erro(:,4)))));
    display(sprintf('---------------------------------------------------------------------\n'));
    
end



% Resultados do modo 3 ------------------------------------------------------
if OPMode==3
    configs = {'M�todo de sele��o: ROLETA, M�todo de cruzamento: SIMPLES', 'M�todo de sele��o: ROLETA, M�todo de cruzamento: FLAT', 'M�todo de sele��o: TORNEIO, M�todo de cruzamento: SIMPLES', 'M�todo de sele��o: TORNEIO, M�todo de cruzamento: FLAT'};
    movegui(figure('Name','Influ�ncia do n�mero de cromossomos no tempo de execu��o do algoritmo','NumberTitle','off','position',[0 0 1200 800]),'center');
    for i=1:4
        subplot(2,2,i);
        plot(vtSizePop(i,2:end),vtTempo(2:end,i),'ko:', 10:sizePop,polyval(polyfit(vtSizePop(i,2:end)',vtTempo(2:end,i),1),10:sizePop), '--');
        xlabel('N�mero de cromossomos');
        ylabel('Tempo (s)');
        title(configs(i));
    end
    
    
    movegui(figure('Name','Influ�ncia do n�mero de cromossomos na efici�ncia do algoritmo','NumberTitle','off','position',[0 0 1200 800]),'center');
    for i=1:4
        subplot(2,2,i);
        plot(vtSizePop(i,2:end),erro(2:end,i),'ko:', 10:sizePop,polyval(polyfit(vtSizePop(i,2:end)',erro(2:end,i),3),10:sizePop), '--');
        xlabel('N�mero de cromossomos');
        ylabel('Erro');
        title(configs(i));
    end
    
    
    %Resultados ---------------------------------------------------------------
    display(sprintf('=========================================================='));
    display(sprintf('       Algor�tmo Gen�tico com Representa��o Real'));
    display(sprintf('          para obten��o do ponto de m�ximo da'));
    display(sprintf('          fun��o Z = (1 + sqrt(x) + 0.5*y )^2\n'));
    display(sprintf('=========================================================='));
    display(sprintf('Teste de influ�ncia do n�mero de cromossomos'));
    display(sprintf('no desempenho do algor�timo para cada'));
    display(sprintf('m�todo de sele��o e cruzamento'));
    display(sprintf('--------------------------------------------------------\n'));
    display(sprintf('N�mero inicial de cromossomos: %d     Passo: %d',startSizePop,popStep));
    display(sprintf('N�mero final de cromossomos: %d',sizePop));
    display(sprintf('N�mero de gera��es: %d',numGenerations));
    display(sprintf('\nN�mero de repeti��es para cada configura��o: %d',numRepeticoes));
    display(sprintf('Tempo total gasto: %.2f s\n',sum(vtTempo(:))));
    
   
    display(sprintf('\n======================= Resultados do teste ======================='));
    display(sprintf('\n----- M�todo de sele��o: ROLETA   M�todo de cruzamento: SIMPLES -----'));
    for i=1:numRepeticoes
        display(sprintf('N�mero de neur�nios: %4d      Tempo gasto: %.2f s      Erro: %f',vtSizePop(1,i),vtTempo(i,1),erro(i,1)));
    end
    display(sprintf('---------------------------------------------------------------------\n'));
    
    display(sprintf('\n------ M�todo de sele��o: ROLETA   M�todo de cruzamento: FLAT -------'));
    for i=1:numRepeticoes
        display(sprintf('N�mero de neur�nios: %4d      Tempo gasto: %.2f s      Erro: %f',vtSizePop(2,i),vtTempo(i,2),erro(i,2)));
    end
    display(sprintf('---------------------------------------------------------------------\n'));
    
    display(sprintf('\n---- M�todo de sele��o: TORNEIO   M�todo de cruzamento: SIMPLES -----'));
    for i=1:numRepeticoes
        display(sprintf('N�mero de neur�nios: %4d      Tempo gasto: %.2f s      Erro: %f',vtSizePop(3,i),vtTempo(i,3),erro(i,3)));
    end
    display(sprintf('---------------------------------------------------------------------\n'));
    
    display(sprintf('\n------ M�todo de sele��o: TORNEIO   M�todo de cruzamento: FLAT ------'));
    for i=1:numRepeticoes
        display(sprintf('N�mero de neur�nios: %4d      Tempo gasto: %.2f s      Erro: %f',vtSizePop(4,i),vtTempo(i,4),erro(i,4)));
    end
   display(sprintf('---------------------------------------------------------------------\n'));
    
end



