function [parent1,parent2]=crossFlat(parent1,parent2,crossProb)
    if(crossProb>rand)
        chromoSize = length(parent1); % Tamanho do cromossomo
        for i = 1: chromoSize
            interval = [parent1(i),parent2(i)];
            raffle1 = (min(interval) + (max(interval)-min(interval))*rand); % Sorteio do elemento i do parent1
            raffle2 = (min(interval) + (max(interval)-min(interval))*rand); % Sorteio do elemento i do parent2

            % o crossover é realizado para cada elemento i;
            parent1(i) = raffle1;
            parent2(i) = raffle2;
        end
    end
end