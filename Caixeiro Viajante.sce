/* Maria Gabriele Bezerra da Silva - 403736 */
/* AVALIAÇÃO FINAL (AF) - ALGORITMO GENÉTICO - CAIXEIRO VIAJANTE */

clear;  // Limpa as variáveis armazenadas
clc;    // Limpa a tela

base = fscanfMat ('caixeiro.dat'); // Base de dados fornecida na questão - Matriz adjacente
// Coloquei a matriz em um arquivo separado para não ficar um código muito grande  

// PASSO 01: Precisamos criar a geração inicial de cromossosmos 

geracoes = 100; // Número de gerações que serão usadas
num_populacao = input("Digite o numero de indivíduos por geração (recomendado: 100): "); // Recomenda-se que seja um valor de 100 
// Número de cromossomos gerados aleatoriamente em cada geração - dei a opção para que o usuário pudesse escolher
// num_populacao = 100; - Também pode ser setado 
tam_cromossomo = 14; // Tamanho do cromossomo que iremos criar 
probabilidade = 0.2 // Defini a probabilidade de mutação em 20% dentro do intervalo (0 a 100%)

for i = 1:num_populacao
    populacao(i,:) = grand(1, "prm", (1:tam_cromossomo)')'; 
    /* Cria um vetor de tamanho tam_cromosso (14 - número de cidades a ser percorrido) com números aleatórios 
    e sem repetição (visto que esse é um dos requisitos do problema do caixeiro viajante) entre 1 e tam_cromomossos */
end

populacao_inicial = populacao; // A variavel populacao_inicial guardará a população inicial para fazer comparativo no final

// PASSO 02: Avaliação dos cromossos gerados no PASSO 01

for aux = 1:geracoes, // Laço para criação de novas gerações 
    avaliacao = zeros(num_populacao, 1);
    /* Variável "avaliacao" recebe o cálculo das distâncias percorridas em cada cromossomo. 
    Quanto menor esse valor melhor o fitness do cromossomo.*/
    for i = 1:num_populacao
        for j = 1:tam_cromossomo-1
            avaliacao(i) = avaliacao(i) + base(populacao(i,j), populacao(i,j+1));
            // Preenche o vetor de avaliação com as notas respectivas para cada cromossomo gerado
        end
    end
    
// PASSO 03: Com o vetor de avaliação preenchido no PASSO 02 podemos fazer a seleção dos pais (Roleta Viciada Invertida)

/* Fazendo uso da roleta viciada buscamos fazer com que a roleta desse maior probabilidade aos menores valores. 
Para isso foi subtraído o valor máximo do vetor avaliação, somado a 1 (para que o maior valor ainda tenha
possibilidade, ainda que mínima, de ser escolhido) menos os valores de cada avaliação. Fazendo isso temos como
resultado uma “inversão” dos valores de avaliação. Os menores valores passaram a ter maior fitness e os
maiores, menor fitness. */

    function [pais] = roleta()
        inversao = (max(avaliacao) + 1 ) - avaliacao;
        soma_inversao = sum(inversao);
        num = grand(1, 1, "unf", 1, soma_inversao); // Seleciona um número entre 0 e soma_inversao 
        pais = 1;
        aux2 = inversao(1);
        while aux2 < num,
            pais = pais +1;
            aux2 = aux2 + inversao(i);
        end
    endfunction
    
/* OBSERVAÇÃO: Ao fazer alguns testes foi percebido que o código da roleta viciada às vezes sorteia um número acima do tamanho da população, gerando um erro. 
Para garantir que o número sorteado nunca fique acima do valor indicado, criei uma função de tratamento que toda vez que o número sorteado ficar acima do 
informado a roleta  gira de novo até que um número abaixo do que foi informado seja encontrado e usado, por isso recomendei que o tamanho de num_população 
seja 100 */
    
    function [tratamento] = GR();
        tratamento = roleta();
        if tratamento > num_populacao,
            while tratamento > num_populacao,
                tratamento = roleta();
            end
        end
    endfunction
    
// PASSO 04: Neste passo acontece a geração dos filhos - Crossover baseado em ordem
// Para isso precisamos fazer nova geração com a quantidade que foi informada em num_populacao
    for F = 1:num_populacao,
        // Aqui iremos selecionar dois pais da geração anterior
        P(1,:) = populacao(GR(), :); // Selecionando pai 1
        P(2,:) = populacao(GR(), :); // Selecionando pai 2
        
        filho = zeros(1, 14);
        selecao = grand(1, 14, "uin", 0, 1); // String de seleção
        
        for i = 1:14,
            if selecao(1,i) == 1
                filho(1,i) = P(1,i);
            end
        end
        
        for k = 1:14,
            if selecao(1,k) == 0
                for z = 1:14
                    busca_filho = find(filho == P(2, z));
                    if busca_filho == [],
                        filho(1,k) = P(2, z);
                        break;
                    end
                end
            end
        end
        
// Mutação em Ordem   
/* Antes de serem lançados na matriz populacao, cada filho gerado é submetido a um algoritmo de 
mutação baseado em ordem que dada uma probabilidade (estabelecida em 20% aqui) pode ou não alterar a
posição de dois genes de cada filho gerado escolhidos aleatoriamente*/

        num_aleatorio = rand(); // Sorteia um número aleatório qualquer entre 0 e 1
        
        if num_aleatorio < probabilidade then
            G1 = grand(1, 1, "uin", 1, 14);  // Seleciona primeiro gene aleatório para troca
            G2 = grand(1, 1, "uin", 1, 14);  // Seleciona segundo gene aleatório para troca
            aux_filho = filho;
            filho(1, G1) = aux_filho(1, G2);
            filho(1, G2) = aux_filho(1, G1);
        end
        
        populacao(F, :) = filho; // Cria nova geração de filhos, por issso foi criado a variavel populacao no ínicio do código
    end
end

/* Como podemos ver, todo o processo anterior é iterado 100 vezes e o cromossomo de avaliação mais baixa é
exibido no console (mostrando melhor percurso) junto de sua distância. */

// PARTE 05: Mostrar os resultados da melhor rota para o caixeiro viajante

[melhor_valor, melhor_cromosso] = min(avaliacao);

melhor_percurso = populacao(melhor_cromosso, :);
melhor_avaliacao = avaliacao(melhor_cromosso);

disp("----------------- ALGORITMO GENÉTICO - CAIXEIRO VIAJANTE ----------------- ")
disp("Número de gerações: " + string(geracoes));
disp("Número de indivíduos por geração: " + string(num_populacao));
disp("Probabilidade de mutação: " + string(probabilidade * 100) + "%");
disp("---------------------- MELHOR PERCURSO ENCONTRADO -------------------------");
disp(melhor_percurso);
disp("Distância do percurso: " + string(melhor_avaliacao) + " unidades de distância.");






