# Conceitos do G.R.U

O G.R.U (Gerenciador de Resíduos Urbanos) monitora lixeiras inteligentes
espalhadas por instituições (prefeituras, universidades, terminais). Cada
lixeira tem sensores que estimam a **ocupação** (percentual da capacidade em
uso) e a **composição** do lixo por tipo de material.

## Status de ocupação

- **Vazia** (0% a 9%): acabou de ser coletada ou tem uso muito baixo.
- **Ocupação baixa** (10% a 39%): tranquila, sem urgência de coleta.
- **Ocupação média** (40% a 69%): merece acompanhamento, mas ainda não é prioridade.
- **Ocupação alta** (70% a 89%): entra na fila de coleta em breve.
- **Cheia** (90% a 100%): prioridade máxima, risco de transbordar.

Lixeiras com status "alta" ou "cheia" são consideradas **prioritárias** e é
isso que o KPI "Para coletar" do dashboard soma.

## Tipos de resíduo

O G.R.U rastreia quatro categorias: **Plástico**, **Vidro**, **Metal** e
**Papel**. O "material predominante" de uma lixeira é o tipo com maior
percentual na composição lida pelos sensores.

## Coletores e instituições

Um **Coletor** é o usuário que esvazia as lixeiras fisicamente. Ele só
enxerga (e só pode coletar) as lixeiras das instituições às quais o
Administrador o vinculou. Cada coleta registrada vira uma **visita** no
histórico: guarda quando, em qual lixeira, com qual ocupação e qual material
predominante no momento da coleta.
