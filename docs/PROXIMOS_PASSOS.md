# Próximos Passos — meu_airbnb

Roadmap pós-MVP, priorizado por impacto técnico e valor de portfólio.

---

## Prioridade Alta

### 1. Backend real com Supabase ou Firebase

Substituir `HospedagemLocalDataSource` por um datasource remoto.  
A arquitetura já está preparada: basta criar `HospedagemRemoteDataSource` implementando a mesma interface, registrar no `get_it` e trocar. Domain e Presentation não precisam mudar.

- Autenticação por e-mail/senha
- Banco de dados em tempo real (Realtime do Supabase ou Firestore)
- `ServerFailure` já reservado na hierarquia de erros
- Substituir `Future.delayed` por chamadas HTTP reais

### 2. Página de detalhes da hospedagem

Nova rota `/hospedagens/:id` com `go_router`.  
- Exibe todos os campos da `HospedagemEntity` (incluindo `telefone` e `notas`)
- Botões de editar e excluir inline
- Adicionar tipo SDUI `detalhes_hospedagem` ao `WidgetFactory`
- Documentar em `docs/SDUI.md`

### 3. Relatórios e métricas

Nova aba ou tela de resumo:
- Total de hospedagens por status
- Receita por imóvel e por período
- Taxa de ocupação
- Tipos SDUI novos: `grafico_barras`, `card_metrica`, `tabela`

---

## Prioridade Média

### 4. Gerenciamento de imóveis (CRUD)

Atualmente os imóveis são read-only (carregados do mock).  
Adicionar feature `imoveis/` com:
- `ImovelEntity` já existe — criar use cases `AdicionarImovel`, `AtualizarImovel`, `DeletarImovel`
- `ImovelStore` com Optimistic State Pattern
- Tela de listagem e formulário de imóveis

### 5. Notificações de check-in/check-out

- Listar hospedagens com check-in ou check-out nos próximos 3 dias
- Badge no ícone do app (mobile)
- Widget de alerta na tela principal via SDUI (`tipo: "alerta_proximidade"`)

### 6. Exportação de dados

- Exportar lista de hospedagens filtrada como CSV ou PDF
- Compartilhamento via `share_plus`

---

## Prioridade Baixa

### 7. Tema escuro (Dark Mode)

O `ThemeData` já usa `ColorScheme.fromSeed` — adicionar `darkTheme` com tokens de cor ajustados.  
Persistir preferência em `shared_preferences`.

### 8. Internacionalização (i18n)

- `flutter_localizations` + `intl`
- Suporte a pt-BR e en-US
- Formatação de datas e moeda por locale

### 9. Testes de integração (integration_test)

- Fluxo completo: abrir app → criar hospedagem → verificar na lista → editar → deletar
- Executar no emulador via GitHub Actions (`flutter drive`)

### 10. Deploy web (GitHub Pages ou Vercel)

- `flutter build web --release`
- Deploy automático via GitHub Actions após merge em `main`
- URL pública no README para demo ao vivo

---

## Melhorias Técnicas

| Item | Descrição |
|---|---|
| **Cobertura de testes** | Aumentar de ~80 % para ≥ 90 %, especialmente widgets responsivos |
| **Golden tests** | Capturar screenshots dos componentes do DS para regressão visual |
| **Performance** | Usar `const` constructors em todos os widgets SDUI; perfilar com DevTools |
| **Acessibilidade** | `Semantics` nos componentes do DS; testar com leitores de tela |
| **Error boundaries** | Widget de fallback global para erros não tratados |
| **Logging** | Integrar `logger` package para debug em produção |
