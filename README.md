# ============================================================================
# Conteúdo do README.md (para referência)
# ============================================================================
# 
## DCC

Pacote em R para análise de Delineamentos Composto Central (Central Composite Designs).

O pacote permite o ajuste de modelos quadráticos para DCC com 2 a 5 fatores, com visualização gráfica realizada por pares de fatores.
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
  resposta = "Rugosidade",
  fatores = c("A", "B", "C")
)
O argumento `fatores` deve receber os nomes das colunas correspondentes aos fatores experimentais. Para gráficos de superfície 
e contorno, os fatores são analisados em pares, mantendo os demais fixados no nível central.
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

# Ponto estacionário
ponto_estacionario_dcc(fit)

# Avaliação em relação ao objetivo
valiar_ponto_estacionario_dcc(fit, objetivo = "max")   ou
avaliar_ponto_estacionario_dcc(fit, objetivo = "min")

O ponto estacionário é classificado automaticamente como máximo local, mínimo 
local ou ponto de sela, a partir dos autovalores da matriz B.
```

---
## Otimização

# Minimizar resposta
otimo_dcc(fit, objetivo = "min")

# Maximizar resposta
otimo_dcc(fit, objetivo = "max")
```
---
# Exemplo de maximização
fit <- dcc_fit(dados, resposta = "Rendimento", fatores = c("A","B","C"))
otimo_dcc(fit, objetivo = "max")
```
---

## Gráficos

```r
pareto_dcc(fit)

superficie_dcc(fit, "A", "B")
superficie_dcc(fit, "A", "C")
superficie_dcc(fit, "B", "C")

contorno_dcc(fit, "A", "B") ou
contorno_dcc(fit, "A", "B", objetivo = "max")
contorno_dcc(fit, "A", "C", objetivo = "max")
contorno_dcc(fit, "B", "C", objetivo = "max")

# Versão com interpretação completa
contorno_dcc(
  fit,
  "A", "B",
  mostrar_otimo = TRUE,
  mostrar_estacionario = TRUE,
  objetivo = "min"
)

Quando o ponto ótimo e o ponto estacionário coincidirem ou estiverem muito próximos, recomenda-se exibir apenas o ponto ótimo no gráfico, evitando sobreposição visual:

```r
contorno_dcc(
  fit, "A", "B",
  mostrar_otimo = TRUE,
  mostrar_estacionario = FALSE,
  objetivo = "max"
)
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

## Exportação para Excel

O pacote permite duas formas de exportação:

---

###  Exportação rápida

```r
exportar_excel_dcc(fit)
```

Inclui:

- Dados  
- Métricas  
- ANOVA  
- Coeficientes  
- Efeitos  
- Ponto ótimo  
- Ponto estacionário  

✔ Ideal para análise e documentação rápida

---

###  Exportação completa

```r
exportar_excel_completo_dcc(fit)
ponto_estacionario_dcc(fit)
```
---
## Ponto estacionário vs ponto ótimo

O ponto estacionário é obtido analiticamente a partir do modelo quadrático e representa o ponto crítico da superfície de resposta.

Dependendo dos autovalores da matriz B, ele pode ser classificado como:

- máximo local  
- mínimo local  
- ponto de sela  

O ponto ótimo, por sua vez, é obtido por otimização numérica e pode não coincidir com o ponto estacionário, especialmente quando este é um ponto de sela.

---
Inclui tudo da versão anterior, além de:

- Gráfico de Pareto  
- Superfícies de resposta  
- Gráficos de contorno  

✔ Ideal para interpretação visual e apresentação

---

 Observação:

- os arquivos são gerados automaticamente com data e hora  
- evita sobrescrita  
- facilita rastreabilidade dos resultados  
- A versão atual amplia o uso do pacote para modelos DCC com 2 a 5 fatores, mantendo
  a visualização gráfica por pares e a otimização numérica para múltiplos fatores.

---

## Exemplo completo

```r
library(DCC)

dados <- read_clipboard_dcc()

fit <- dcc_fit(
  dados,
  resposta = "Rugosidade",
  fatores = c("A", "B", "C")
)

sumario_dcc(fit)

anova_dcc(fit)
coeficientes_dcc(fit)
efeitos_dcc(fit)

pareto_dcc(fit)

otimo_dcc(fit, objetivo = "max")
ponto_estacionario_dcc(fit)
avaliar_ponto_estacionario_dcc(fit, objetivo = "max")

superficie_dcc(fit, "A", "B")
superficie_dcc(fit, "A", "C")
superficie_dcc(fit, "B", "C")

contorno_dcc(
  fit, "A", "B",
  mostrar_otimo = TRUE,
  mostrar_estacionario = FALSE,
  objetivo = "max"
)

exportar_relatorio_dcc(
  fit,
  arquivo = "Relatorio_DCC"
)

# Exportação (maximizar)

exportar_excel_dcc(fit, objetivo = "max")
exportar_excel_completo_dcc(fit, objetivo = "max")

# Para minimizar a resposta

exportar_excel_dcc(fit, objetivo = "min")
exportar_excel_completo_dcc(fit, objetivo = "min")
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
