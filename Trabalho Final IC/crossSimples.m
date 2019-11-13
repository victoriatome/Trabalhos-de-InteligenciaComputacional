function [parent1,parent2]=crossSimples(parent1,parent2,crossProb)
    if(crossProb>rand)
        chromoSize = length(parent1); % Tamanho do cromossomo
        cut = round((1 + (chromoSize-1)*rand)); % Ponto de corte é definido aleatoriamente

        % O crossover é realizado
        temp = parent1(cut); % Elemento do parent1 é armazenado temporariamente
        parent1(cut) = parent2(cut); % Parent1 recebe elemento de parent2
        parent2(cut) = temp; % Parent2 recebe elemento de parent1
    end
end