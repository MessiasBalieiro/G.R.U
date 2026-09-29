# G.R.U — App Android

App Android do **Gerenciador de Resíduos Urbanos**, baseado na versão web
(`frontend/gru`)

## Como rodar

```bash
# dentro da pasta gru_app (ao lado de frontend/gru)
flutter pub get
flutter run            # com um celular/emulador Android conectado
flutter test           # testes de unidade dos modelos
flutter build apk      # gera o APK
```

## Contas de teste 

| Tipo          | E-mail            | Senha    |
|---------------|-------------------|----------|
| Administrador | `admin@gru.com`   | `gru123` |
| Coletor       | `coletor@gru.com` | `gru123` |

## Integrando com o backend

Tudo passa por `MockDataService` e `UsuarioRepository`. Para ligar na API,
troque essas implementações por chamadas HTTP. O backend atual precisa ganhar:
login/cadastro, tipo de usuário, instituições e vínculos, `ocupacao` e
composição por material nas lixeiras, endereço estruturado (CEP, logradouro, número, bairro, cidade, UF), e um
endpoint de visitas (coletas).
