# Loading Despesas

Aplicativo mobile para controle de despesas cotidianas, com foco em usabilidade, design moderno e funcionamento offline. Desenvolvido como parte do Processo Seletivo 2026.2 da **Loading Desenvolvimento Jr.**

## Tecnologias Utilizadas
- **Flutter & Dart**: Framework e linguagem para o desenvolvimento mobile.
- **SQLite (sqflite)**: Banco de dados local para persistência dos dados offline.
- **Shared Preferences**: Para salvar o nome do usuário e preferências locais.
- **Google Fonts (Inter)**: Tipografia moderna.
- **Intl**: Formatação de datas e moedas (Real).
- **Git**: Versionamento de código.

## Funcionalidades Implementadas (Requisitos Obrigatórios)
- [x] **RF01 - Cadastro**: Registro de despesas com descrição, valor positivo, data e categoria.
- [x] **RF02 - Listagem**: Exibição das despesas com valor, data, categoria e ordem cronológica.
- [x] **RF03 - Resumo Mensal**: Cálculo e apresentação do total gasto no mês selecionado.
- [x] **RF04 - Filtros**: Navegação entre meses, com atualização da lista e do total.
- [x] **RF05 - Exclusão**: Remoção de despesas com atualização automática do resumo.
- [x] **RF06 - Persistência**: Dados mantidos após fechar e reabrir o app, sem internet.
- [x] **RF07 - Validação**: Impedimento de cadastro com dados inválidos e feedback ao usuário.

## Funcionalidades Extras (Diferenciais)
- **Modo Escuro (Dark Mode)**: Alternância entre tema claro e escuro com persistência de design.
- **Ocultar Valores**: Botão de "olho" para esconder o saldo (privacidade).
- **Ícones Dinâmicos**: Ícones coloridos baseados na categoria da despesa.
- **Animação de Saldo**: O valor total é animado ao carregar a tela.
- **Design System**: Paleta de cores baseada na identidade visual da Loading Jr.

## Uso de Inteligência Artificial
Durante o desenvolvimento deste projeto, utilizei ferramentas de IA (como o Claude e o DeepSeek) como assistentes de código para:
- Auxílio na configuração inicial do ambiente (Android SDK, Gradle, JDK).
- Estruturação de código e criação de widgets complexos.
- Revisão de lógica de SQLite e queries.
*A IA foi utilizada como ferramenta de apoio, e todo o código foi revisado, testado e validado por mim, garantindo a compreensão total da solução.*

## Como executar o projeto
1. Clone o repositório.
2. Certifique-se de ter o Flutter instalado e um emulador configurado.
3. Rode `flutter pub get` para baixar as dependências.
4. Rode `flutter run` para iniciar o app.

## Decisões de Arquitetura
- **Organização em pastas**: O projeto foi dividido em `models` (entidades), `screens` (telas) e `data` (banco de dados) para facilitar a manutenção.
- **Gerenciamento de Estado**: Utilizei `StatefulWidget` e `setState` nativo do Flutter, pois o escopo do projeto é focado e não exigia bibliotecas complexas como Provider ou Bloc.
- **Banco de Dados Local**: SQLite foi escolhido por ser robusto, relacional e ideal para queries de soma e filtro por data.
- **Temas (Light/Dark)**: Implementação do `ThemeMode` nativo do Flutter para alternar entre os temas de forma fluida.

## Roadmap (Melhorias Futuras)
- [ ] **Múltiplos Perfis**: Implementação de "Workspaces" para gerenciar as despesas de familiares (ex: idosos) sem misturar com as contas pessoais.
- [ ] **Sincronização em Nuvem**: Para permitir acesso em diferentes dispositivos.
- [ ] **Gráficos de Categoria**: Visualização de gastos por categoria com gráficos de pizza.
- [ ] **Tela de Relatórios**: Histórico anual e comparação entre meses.