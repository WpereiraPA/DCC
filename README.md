# ============================================================================
# Conteúdo do README.md (para referência)
# ============================================================================
# 
# # DCC
# 
# Pacote em R para análise de Delineamentos Composto Central (Central Composite Designs).
# 
# ## Descrição
# 
# O pacote **DCC** foi desenvolvido para facilitar a análise estatística de experimentos planejados utilizando Delineamento Composto Central.
# 
# Permite:
# 
# - geração automática da matriz experimental DCC
# - exportação da matriz experimental
# - ajuste de modelos quadráticos
# - análise de variância (ANOVA)
# - estimação de efeitos
# - gráficos de Pareto
# - gráficos de superfície de resposta
# - gráficos de contorno
# - geração automática de relatório analítico
# 
# Indicado para pesquisadores, estudantes e profissionais que trabalham com planejamento experimental e otimização de processos.
# 
# ---
# 
# ## Instalação
# 
# Instale diretamente do GitHub:
# 
# ```r
# install.packages("remotes")
# remotes::install_github("WpereiraPA/DCC")
# ```
# 
# ---
# 
# ## Fluxo completo de utilização
# 
# ### Carregar o pacote
# 
# ```r
# library(DCC)
# ```
# 
# ### Importar dados copiados do Excel
# 
# Copie a tabela experimental e execute:
# 
# ```r
# dados <- read_clipboard_dcc()
# ```
# 
# ### Ajustar o modelo
# 
# ```r
# fit <- dcc_fit(
#   dados,
#   resposta = "Rugosidade"
# )
# ```
# 
# ### Gerar a Matriz Experimental DCC
# 
# A função `matriz_dcc` permite criar o planejamento experimental completo (pontos fatoriais, axiais e centrais) para diferentes números de fatores. Você pode optar pela ordem padrão ou aleatorizada.
# 
# #### Exemplos para 2, 3, 4 e 5 Fatores:
# 
# ```r
# # --- 2 FATORES ---
# matriz_dcc(k = 2)                                      # Ordem padrão
# matriz_dcc(k = 2, aleatorizar = TRUE, seed = 12)       # Aleatorizada
# 
# # --- 3 FATORES ---
# matriz_dcc(k = 3)                                      # Ordem padrão
# matriz_dcc(k = 3, aleatorizar = TRUE, seed = 12)       # Aleatorizada
# 
# # --- 4 FATORES ---
# matriz_dcc(k = 4)                                      # Ordem padrão
# matriz_dcc(k = 4, aleatorizar = TRUE, seed = 12)       # Aleatorizada
# 
# # --- 5 FATORES ---
# matriz_dcc(k = 5)                                      # Ordem padrão
# matriz_dcc(k = 5, aleatorizar = TRUE, seed = 12)       # Aleatorizada
# ```
# 
# ### Exportar a Matriz Experimental
# 
# ```r
# m <- matriz_dcc(k = 3)
# export_matriz_dcc(m)
# ```
# 
# ---
# 
# ## Análise dos resultados
# 
# ### Estatísticas do modelo
# 
# ```r
# summary_dcc(fit)
# ```
# 
# ### ANOVA
# 
# ```r
# anova_dcc(fit)
# ```
# 
# ### Coeficientes
# 
# ```r
# coeficientes_dcc(fit)
# ```
# 
# ### Efeitos
# 
# ```r
# efeitos_dcc(fit)
# ```
# 
# ---
# 
# ## Gráficos
# 
# ### Pareto
# 
# ```r
# pareto_dcc(fit)
# ```
# 
# ### Superfície de resposta
# 
# ```r
# superficie_dcc(fit, "A", "B")
# ```
# 
# ### Contorno
# 
# ```r
# contorno_dcc(fit, "A", "B")
# ```
# 
# ---
# 
# ## Exportar relatório
# 
# ```r
# export_relatorio_dcc(
#   fit,
#   arquivo = "Relatorio_DCC"
# )
# ```
# 
# O relatório contém:
# 
# - estatísticas do modelo  
# - tabela ANOVA  
# - coeficientes  
# - efeitos  
# - equação ajustada  
# - interpretação básica  
# - ponto ótimo previsto  
# 
# ---
# 
# ## Exemplo completo
# 
# ```r
# library(DCC)
# 
# dados <- read_clipboard_dcc()
# 
# fit <- dcc_fit(
#   dados,
#   resposta = "Rugosidade"
# )
# 
# sumario_dcc(fit)
# 
# anova_dcc(fit)
# coeficientes_dcc(fit)
# 
# efeitos_dcc(fit)
# 
# pareto_dcc(fit)
# superficie_dcc(fit, "A", "B")
# contorno_dcc(fit, "A", "B")
# 
# export_relatorio_dcc(
#   fit,
#   arquivo = "Relatorio_DCC"
# )
# ```
# 
# ---
# 
# ## Aplicações
# 
# - otimização de processos industriais  
# - engenharia química  
# - engenharia de produção  
# - estudos de superfície de resposta  
# - planejamento experimental  
# - experimentos laboratoriais  
# 
# ---
# 
# ## Autor
# 
# Wanderley Xavier Pereira
# 
# ---
# 
# ## Licença
# 
# Licença MIT.
# 
# ---
# 
# ## Status
# 
# Pacote em desenvolvimento contínuo.
