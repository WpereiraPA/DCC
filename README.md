# ============================================================================
# Conteúdo do README.md (para referência)
# ============================================================================
# 
## DCC

Pacote em R para análise de Delineamentos Composto Central (Central Composite Designs).

## Descrição

O pacote **DCC** foi desenvolvido para facilitar a análise estatística de experimentos planejados utilizando Delineamento Composto Central.

Permite:

- geração automática da matriz experimental DCC  
- exportação da matriz experimental  
- ajuste de modelos quadráticos  
- análise de variância (ANOVA)  
- estimação de efeitos  
- gráficos de Pareto  
- gráficos de superfície de resposta  
- gráficos de contorno  
- exportação completa para Excel  
- geração automática de relatório analítico  

Indicado para pesquisadores, estudantes e profissionais que trabalham com planejamento experimental e otimização de processos.

---

## Instalação

Instale diretamente do GitHub:

install.packages("remotes")
remotes::install_github("WpereiraPA/DCC")

---

## Fluxo completo de utilização

### Carregar o pacote

library(DCC)

### Importar dados copiados do Excel

dados <- read_clipboard_dcc()

### Ajustar o modelo

fit <- dcc_fit(
  dados,
  resposta = "Rugosidade"
)

---

## Geração da matriz experimental

# 2 fatores
matriz_dcc(k = 2)

# 3 fatores
matriz_dcc(k = 3)

# aleatorização
matriz_dcc(k = 3, aleatorizar = TRUE, seed = 12)

---

## Exportação da matriz

m <- matriz_dcc(k = 3)
exportar_matriz_dcc(m)

---

## Análise dos resultados

sumario_dcc(fit)

anova_dcc(fit)
coeficientes_dcc(fit)

efeitos_dcc(fit)

---

## Gráficos

pareto_dcc(fit)

superficie_dcc(fit, "A", "B")
contorno_dcc(fit, "A", "B")

---

## Exportar relatório

exportar_relatorio_dcc(
  fit,
  arquivo = "Relatorio_DCC"
)

O relatório contém:

- estatísticas do modelo  
- tabela ANOVA  
- coeficientes  
- efeitos  
- equação ajustada  
- interpretação básica  
- ponto ótimo previsto  

---

## Exportação completa para Excel

exportar_excel_dcc(fit)

O arquivo gerado contém:

- métricas do modelo  
- tabela ANOVA  
- coeficientes  
- efeitos com destaque de significância  
- gráfico de Pareto  
- superfícies de resposta (todas as combinações de fatores)  
- gráficos de contorno  

---

## Exemplo completo

library(DCC)

dados <- read_clipboard_dcc()

fit <- dcc_fit(
  dados,
  resposta = "Rugosidade"
)

sumario_dcc(fit)

anova_dcc(fit)
coeficientes_dcc(fit)

efeitos_dcc(fit)

pareto_dcc(fit)
superficie_dcc(fit, "A", "B")
contorno_dcc(fit, "A", "B")

exportar_relatorio_dcc(
  fit,
  arquivo = "Relatorio_DCC"
)

exportar_excel_dcc(fit)

---

## Aplicações

- otimização de processos industriais  
- engenharia química  
- engenharia de produção  
- estudos de superfície de resposta  
- planejamento experimental  
- experimentos laboratoriais  

---

## Autoria

Desenvolvido por Wanderley Xavier Pereira.

## Titularidade

Titularidade compartilhada entre:

- Wanderley Xavier Pereira  
- Centro Federal de Educação Tecnológica de Minas Gerais (CEFET-MG)

## Apoio institucional

O desenvolvimento deste pacote contou com apoio institucional do  
Centro Federal de Educação Tecnológica de Minas Gerais (CEFET-MG),  
no contexto de atividades acadêmicas, sem financiamento específico.

---

## Status

Pacote em desenvolvimento contínuo.
