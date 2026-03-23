# DCC

Pacote em R para análise de Delineamentos Composto Central (Central Composite Designs).

## Descrição

O pacote **DCC** foi desenvolvido para facilitar a análise estatística de experimentos planejados utilizando Delineamento Composto Central.

Permite:

- ajuste de modelos quadráticos
- análise de variância (ANOVA)
- estimação de efeitos
- gráficos de Pareto
- gráficos de superfície de resposta
- gráficos de contorno
- geração automática de relatório analítico

Indicado para pesquisadores, estudantes e profissionais que trabalham com planejamento experimental e otimização de processos.

---

## Instalação

Instale diretamente do GitHub:

```r
install.packages("remotes")
remotes::install_github("WpereiraPA/DCC")
```

---

## Fluxo completo de utilização

### Carregar o pacote

```r
library(DCC)
```

### Importar dados copiados do Excel

Copie a tabela experimental e execute:

```r
dados <- read_clipboard_dcc()
```

### Ajustar o modelo

```r
fit <- dcc_fit(
  dados,
  resposta = "Rugosidade"
)
```

---

## Análise dos resultados

### Estatísticas do modelo

```r
summary(fit$modelo)
```

### ANOVA

```r
anova(fit$modelo)
```

### Coeficientes

```r
coef(fit$modelo)
```

### Efeitos

```r
efeitos_dcc(fit)
```

---

## Gráficos

### Pareto

```r
pareto_dcc(fit)
```

### Superfície de resposta

```r
superficie_dcc(fit, "A", "B")
```

### Contorno

```r
contorno_dcc(fit, "A", "B")
```

---

## Exportar relatório

```r
export_relatorio_dcc(
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

## Exemplo completo

```r
library(DCC)

dados <- read_clipboard_dcc()

fit <- dcc_fit(
  dados,
  resposta = "Rugosidade"
)

summary(fit$modelo)
anova(fit$modelo)
coef(fit$modelo)

efeitos_dcc(fit)

pareto_dcc(fit)
superficie_dcc(fit, "A", "B")
contorno_dcc(fit, "A", "B")

export_relatorio_dcc(
  fit,
  arquivo = "Relatorio_DCC"
)
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

## Autor

Wanderley Xavier Pereira

---

## Licença

Licença MIT.

---

## Status

Pacote em desenvolvimento contínuo.
