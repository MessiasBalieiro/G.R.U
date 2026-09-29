# G.R.U — App Android

App Android do **Gerenciador de Resíduos Urbanos**, baseado na versão web
(`frontend/gru`) e no design do Figma. Tem dois tipos de usuário:
**Administrador** e **Coletor**.

## Como rodar

```bash
# dentro da pasta gru_app (ao lado de frontend/gru)
flutter pub get
flutter run            # com um celular/emulador Android conectado
flutter test           # testes de unidade dos modelos
flutter build apk      # gera o APK
```

O `android/` foi copiado do projeto web (sem o `local.properties`, que o
Flutter recria sozinho). O `applicationId` continua `com.example.gru`:
troque por um id próprio antes de publicar na Play Store.

## Contas de teste (dados fake em memória)

| Tipo          | E-mail            | Senha    |
|---------------|-------------------|----------|
| Administrador | `admin@gru.com`   | `gru123` |
| Coletor       | `coletor@gru.com` | `gru123` |

Também dá para se cadastrar. Um coletor recém-cadastrado não tem
instituição: entre como admin, abra **Coletores → Aguardando vínculo** e
toque em **Vincular** para ele passar a ver as lixeiras.

## Telas

```
Loading → Bem-vindo → Login ─┬─► Admin:   Home → Lixeiras · Dashboard · Coletores
                  └ Cadastro ┘            (Cadastro tem botão "Coletores" → Cadastro do coletor)
                             └─► Coletor: Home → Lixeiras · Histórico · Instituições
Lixeira (detalhe): compartilhada; o Coletor também vê "Suas visitas" e "Registrar coleta"
```

### Coletor
- **Lixeiras**: capacidade (% ocupada), material mais concentrado, endereço e
  atalho para abrir no mapa; busca e filtros (Prioridade / Atenção / Tranquilas).
- **Histórico**: quando o coletor esteve em cada lixeira, agrupado por dia.
  Uma visita é criada ao tocar em **Registrar coleta** no detalhe da lixeira.
- **Instituições**: instituições vinculadas, com as lixeiras de cada uma.

### Administrador
- **Lixeiras**: lista + cadastro de nova lixeira **pelo CEP** (o endereço é
  preenchido sozinho pela API ViaCEP; precisa de internet, e dá para preencher
  à mão se a consulta falhar). O mapa abre pelo endereço montado a partir do CEP.
  **Dashboard**: KPIs, ocupação
  por lixeira, tipos de resíduo, ranking e atividades. **Coletores**: vincular /
  desvincular.

## Ciclo (chatbot do Dashboard)

No Dashboard do Administrador, o botão **Pergunte ao Ciclo** abre o chat, e
cada gráfico tem um botão ✨ para perguntar sobre ele. O Ciclo roda no
backend (`POST /ciclo/chat`), então o backend precisa estar ligado:

```bash
flutter run --dart-define=GRU_API_URL=http://IP_DO_PC:3000
```

Sem o parâmetro, o app usa `http://10.0.2.2:3000` (o PC visto pelo emulador).
Detalhes em `ciclo/README.md` na raiz do repositório.

## Animações

- **Formas do rodapé** (onda laranja, forma verde do cadastro e forma escura do
  login): `AnimatedBottomShape` — sempre coladas na base da tela, com deslize
  lateral e balanço suaves. O teclado não as empurra para cima.
- **Transição entre telas**: `GruPageRoute` (desliza + esmaece + escala, com a
  tela anterior recuando). Vale para todas as rotas via `AppRoutes.onGenerateRoute`.

## Estrutura

```
lib/
  core/        tema, cores, formatadores, abrir mapa
  data/        models, MockDataService, repositório de login
  routes/      rotas
  presentation/
    widgets/   GruScaffold, LiquidCard, BottomWave, LixeiraCard, capacity…
    screens/   splash · auth · admin · coletor · shared
```

## Integrando com o backend

Tudo passa por `MockDataService` e `UsuarioRepository`. Para ligar na API,
troque essas implementações por chamadas HTTP. O backend atual precisa ganhar:
login/cadastro, tipo de usuário, instituições e vínculos, `ocupacao` e
composição por material nas lixeiras, endereço estruturado (CEP, logradouro, número, bairro, cidade, UF), e um
endpoint de visitas (coletas).
