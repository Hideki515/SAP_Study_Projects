# Exercícios MiniSAP

1. Consultas Simples: Faça um programa que exibe as informações de voos.

   Crie uma consulta para listar as seguintes informações de voos na tabela `SFLIGHT`:

   - ID do voo (`CARRID` e `CONNID`)
   - Data do voo (`FLDATE`)
   - Assentos Disponíveis ( `SEATSMAX, SEATSOCC` ).

2. For all entries: Faça um programa que relacione os dados das tabelas `SFLIGHTS` e `SCARR` utilizando For All Entries.

   Escreva um programa para exibir o nome da companhia aérea (da tabela `SCARR`) e o número total de assentos ocupados de cada VOO (`SEATSOCC` da tabela `SFLIGHTS`).

3. Filtro com Parâmetros Dinâmicos: Permite que o usuário filtre informações.

   Escreva um programa ABAP que receba do usuário:

   - Código da companhia Aérea(`CARRID`)
   - Número do voo (`CONNID`)
   - Exiba todas as reservas feitas(`SBOOKS`) para o voo especificado

4. Contagem de Reservas por Clientes: Relacione as tabelas de reservas e Clientes:

   Crie um programa para contar e exibir o número total de reservas (SBOOKS) feitas por cada cliente (SCUSTOM).

5. Relatório de Agências de Viagem: Relacione as tabelas de agências e voos:

   Escreva um relatório para exibir o nome das agência de viagem (`STRAVELAG`) e o número de voos que elas organizaram (`SFLIGHTS`).

6. Resumo por País: Integre informações sobre clientes e reservas.

   Crie um programa para exibir o número total de reservas (`SBOOK`) feitas por país (com base no campo `COUNTRY` da tabela `SCUSTOM`).
