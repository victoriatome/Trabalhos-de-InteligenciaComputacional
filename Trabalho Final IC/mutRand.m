function child=mutRand(child,interval,mutProb)
    if(mutProb>rand)
        chromoSize = length(child); % Tamanho do cromossomo
        mutPosition = round((1 + (chromoSize-1)*rand)); % A posi��o da muta��o � definida aleatoriamente
        
        mutation = interval(1) +(interval(2)-interval(1))*rand;

        % A muta��o � realizada
        child(mutPosition) = mutation;
    end
end