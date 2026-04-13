# ============================================================================
# Conteúdo do README.md (para referência)
# ============================================================================
# 
## DCC

Pacote em R para análise de Delineamentos Composto Central (Central Composite Designs).

---

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

```r
install.packages("remotes")
remotes::install_github("WpereiraPA/DCC")
library(DCC)
```

---

## Fluxo completo de utilização

### Carregar o pacote

```r
library(DCC)
```

### Importar dados copiados do Excel

```r
dados <- read_clipboard_dcc()
```

### Ajustar o modelo

"Rugosidade" é utilizada aqui apenas como exemplo de variável resposta. O usuário pode substituir esse nome conforme sua aplicação.

```r
fit <- dcc_fit(
  dados,
  resposta = "Rugosidade"
)
```

---

## Geração da matriz experimental

```r
# 2 fatores
matriz_dcc(k = 2)

# 3 fatores
matriz_dcc(k = 3)

# aleatorização
matriz_dcc(k = 3, aleatorizar = TRUE, seed = 12)
```

---

## Exportação da matriz

```r
m <- matriz_dcc(k = 3)
exportar_matriz_dcc(m)
```

---

## Análise dos resultados

```r
sumario_dcc(fit)

anova_dcc(fit)
coeficientes_dcc(fit)

efeitos_dcc(fit)
```

---

## Gráficos

```r
pareto_dcc(fit)

superficie_dcc(fit, "A", "B")
contorno_dcc(fit, "A", "B")
```

---

## Exportar relatório

```r
exportar_relatorio_dcc(
  fit,
  arquivo = "Relatorio_DCC"
)
```

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

```r
exportar_excel_dcc(fit)
```

O arquivo gerado contém:

- aba "Dados" com a matriz experimental utilizada  
- métricas do modelo  
- tabela ANOVA  
- coeficientes  
- efeitos com destaque de significância  
- gráfico de Pareto  
- superfícies de resposta (todas as combinações de fatores)  
- gráficos de contorno  

---

## Exemplo completo

```r
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
```

---

## Aplicações

- otimização de processos industriais  
- engenharia química  
- engenharia de produção  
- estudos de superfície de resposta  
- planejamento experimental  
- experimentos laboratoriais  

---

## Authors

- Wanderley Xavier Pereira (wander.wx@gmail.com)
- Augusto Henrique de Sousa Xavier (augustohpa12@gmail.com)

---

## Copyright and institutional context

Copyright is shared by:

- Wanderley Xavier Pereira  
- Augusto Henrique de Sousa Xavier  
- Centro Federal de Educacao Tecnologica de Minas Gerais (CEFET-MG)  

---

## Development notes

This package was developed by the authors with support from artificial intelligence tools for code structuring, review and refinement. All methodological definitions, statistical logic and final implementation decisions are the responsibility of the authors.

---

## Citation and authorship

If you use this package in academic, technical or derived work, please cite the original authorship of the DCC package.

Citation of the original package is strongly encouraged in cases of use, modification, adaptation or extension.

---

## Institutional support

The development of this package was carried out in an academic context with institutional support from the Centro Federal de Educacao Tecnologica de Minas Gerais (CEFET-MG).

---

## Status

Pacote em desenvolvimento contínuo com foco em aplicação prática e uso didático.
