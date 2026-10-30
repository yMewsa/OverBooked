# Overbooked

> **Acompanhe suas leituras. Organize sua estante.**

O Overbooked é um aplicativo em Flutter pronto para produção que transforma sua vida de leitor em uma experiência de estante virtual — inspirado no formato do Letterboxd para filmes, mas desenvolvido para livros. Pesquise milhões de títulos pela API do Google Books, organize-os em três estantes personalizadas e veja suas estatísticas de leitura serem atualizadas automaticamente.

[![Flutter](https://img.shields.io/badge/Flutter-3.3%2B-02569B?logo=flutter)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Auth%20%7C%20Firestore-FFCA28?logo=firebase)](https://firebase.google.com)
[![Provider](https://img.shields.io/badge/State-Provider-5C6BC0)](https://pub.dev/packages/provider)
[![Google Books](https://img.shields.io/badge/API-Google%20Books-4285F4?logo=google)](https://developers.google.com/books)

---

## Capturas de Tela

<!-- Adicione as capturas de tela aqui -->

---

## Funcionalidades

| Funcionalidade | Descrição |
|---|---|
| **Três Estantes** | Organize os livros entre *Lendo agora*, *Quero ler* ou *Lidos e resenhados* |
| **Busca de Livros** | Encontre qualquer livro utilizando a API do Google Books (por título ou autor) |
| **Autenticação** | Cadastro e login seguros por e-mail e senha via Firebase Auth |
| **Sincronização em Tempo Real** | Streams do Firestore mantêm sua estante atualizada em todos os dispositivos |
| **Estatísticas Automáticas** | Uma Cloud Function calcula automaticamente total de livros lidos, páginas lidas e páginas lidas no mês |
| **Editor de Páginas** | Insira ou corrija o número de páginas manualmente por um menu de contexto |
| **Tratamento Offline** | Interface preparada para falta de conexão, estados vazios e falhas na API |

---

## Visão Geral da Arquitetura

O projeto adota uma organização em camadas (layer-first), onde cada camada possui uma responsabilidade única.

overbooked/
├── lib/
│   ├── main.dart              # Ponto de entrada, MultiProvider, AuthGate
│   ├── firebase_options.dart  # Placeholder — gerar via FlutterFire CLI
│   ├── theme/
│   │   └── app_theme.dart     # Cores, tipografia e ThemeData
│   ├── models/
│   │   ├── book.dart          # Modelo de Livro + constantes de BookStatus
│   │   └── reading_stats.dart # Modelo de estatísticas de leitura
│   ├── services/
│   │   ├── auth_service.dart      # Abstração do FirebaseAuth
│   │   ├── firestore_service.dart # CRUD do Firestore + streams
│   │   └── books_api_service.dart # Cliente HTTP para a API do Google Books
│   ├── providers/
│   │   ├── auth_provider.dart       # Estado de autenticação (ChangeNotifier)
│   │   ├── bookshelf_provider.dart  # Estado dos livros e da busca
│   │   └── stats_provider.dart      # Estado das estatísticas de leitura
│   ├── views/
│   │   ├── auth/
│   │   │   ├── login_view.dart
│   │   │   └── signup_view.dart
│   │   ├── bookshelf/
│   │   │   └── bookshelf_view.dart  # Aba 1 — Estantes
│   │   ├── stats/
│   │   │   └── stats_view.dart      # Aba 2 — Dados
│   │   ├── discover/
│   │   │   └── discover_view.dart   # Aba 3 — Descoberta
│   │   ├── profile/
│   │   │   └── profile_view.dart    # Aba 4 — Perfil
│   │   └── main_shell.dart          # Estrutura com BottomNavigationBar
│   └── widgets/
│       ├── book_card.dart        # Cartão de capa do livro com menu de 3 pontos
│       ├── shelf_section.dart    # Linha de estante rotulada com divisória de madeira
│       ├── stat_card.dart        # Cartão de métrica individual
│       ├── add_book_sheet.dart   # Modal: adicionar resultado da busca à estante
│       └── edit_pages_sheet.dart # Modal: editar contagem de páginas
├── functions/
│   ├── index.js      # Cloud Function (onBookStatusChanged)
│   └── package.json
├── firestore.rules   # Regras de segurança
└── README.md

### Gerenciamento de Estado com Provider

Três provedores baseados em `ChangeNotifier` são registrados globalmente via `MultiProvider` no arquivo `main.dart`:

| Provedor | Responsabilidade |
|---|---|
| `AuthProvider` | Escuta as alterações de `FirebaseAuth.authStateChanges()`, expõe `user`, `isAuthenticated` e os métodos assíncronos `signIn`, `signUp` e `signOut` |
| `BookshelfProvider` | Inscreve-se na coleção de livros do usuário no Firestore por meio de uma stream. Expõe getters filtrados (`readingNow`, `wantToRead`, `read`) e os resultados da busca no Google Books |
| `StatsProvider` | Inscreve-se no documento `/users/{userId}/stats/summary` em tempo real. As estatísticas são gravadas exclusivamente pela Cloud Function |

O widget raiz `AuthGate` utiliza um `Consumer<AuthProvider>` para alternar o roteamento entre a `LoginView` e a `MainShell`. Após entrar na `MainShell`, o método `initState` dispara `BookshelfProvider.init(userId)` e `StatsProvider.init(userId)` para iniciar o fluxo de dados.

---

## Esquema do Banco de Dados Firebase

### `/users/{userId}/books/{bookId}`

| Campo | Tipo | Descrição |
|---|---|---|
| `id` | `String` | ID do volume no Google Books ou UUID |
| `title` | `String` | Título do livro |
| `authors` | `List<String>` | Lista com os nomes dos autores |
| `coverUrl` | `String?` | URL HTTPS para a imagem de capa |
| `pageCount` | `int?` | Número de páginas (nulo se desconhecido) |
| `status` | `String` | `'want_to_read'` \| `'reading'` \| `'read'` |
| `updatedAt` | `Timestamp` | Data e hora da última modificação |
| `completedAt` | `Timestamp?` | Data e hora em que o livro foi marcado como lido (usado para estatísticas mensais) |

### `/users/{userId}/stats/summary`

| Campo | Tipo | Descrição |
|---|---|---|
| `booksRead` | `int` | Total acumulado de livros concluídos |
| `pagesRead` | `int` | Total acumulado de páginas lidas em todos os livros |
| `pagesReadThisMonth` | `int` | Páginas lidas no mês corrente |
| `lastUpdated` | `Timestamp` | Data e hora em que a função atualizou o documento pela última vez |

---

## Lógica da Cloud Function

A função `onBookStatusChanged` (localizada em `functions/index.js`) é executada a **cada atualização** em um documento da coleção de livros e realiza o seguinte fluxo:

1. **Verifica** se o campo `status` foi alterado **para** `'read'` (ignorando qualquer outra modificação).
2. **Extrai** o valor de `pageCount` com validação — define o valor padrão como `0` caso o campo esteja ausente, nulo ou não seja um número positivo.
3. **Determina** se a data de conclusão pertence ao mês vigente (comparando ano e mês do campo `completedAt` com a data atual).
4. **Executa uma escrita atômica** no caminho `/users/{userId}/stats/summary` usando `FieldValue.increment` para evitar condições de corrida e perda de dados.
5. Utiliza a opção `{ merge: true }` para garantir que o documento de estatísticas seja **criado automaticamente** no primeiro uso.

Status alterado para 'read'
│
▼
Extrai pageCount (validação com padrão 0)
│
▼
A data completedAt pertence ao mês atual?
SIM ──► Incrementa booksRead, pagesRead e pagesReadThisMonth
NÃO ──► Incrementa apenas booksRead e pagesRead
│
▼
Escrita atômica em /users/{userId}/stats/summary

---

## Guia de Configuração

### Pré-requisitos

- SDK do Flutter a partir da versão 3.3.0
- Firebase CLI instalado
- FlutterFire CLI ativado
- Node.js a partir da versão 20 (necessário para Cloud Functions)
- Uma conta no Google com acesso ao Firebase Console

---

### 1. Clonar o Repositório e Instalar Dependências do Flutter

```bash
# Clonar o repositório
git clone <url-do-repositorio>
cd overbooked

# Instalar dependências do projeto
flutter pub get
