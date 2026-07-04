# Perseus Local Reader

Perseus Local Reader は、Perseus Digital Library が公開しているデータを利用し、古典ギリシア語の原文と翻訳をMac上で読むための読書環境です。著者名や作品名からテキストを検索し、読みたい作品を手元に保存して閲覧できます。

ギリシア語原文と翻訳の切り替え、作品内検索、節や行による移動、単語をクリックして形態情報を確認する機能を備えています。一度取得した作品や形態解析データはローカルに保存されるため、保存済みの内容はオフラインでも利用できます。

利用者が開くアプリは、次の1つだけです。

```text
Perseus Local Reader.app
```

このアプリを開くと読書環境が起動し、自動的にブラウザで本文画面が開きます。読書を終えるときは、アプリの「終了」ボタンを押すか、アプリのウィンドウを閉じてください。起動中の読書環境も同時に終了します。

---

# 日本語ガイド

## 1. 動作環境

- macOS 13 Ventura 以降
- Apple Silicon または Intel Mac
- `/usr/bin/python3` として実行できる Python 3
- 初回ダウンロード、作品の追加取得、未取得単語の形態解析、更新確認・更新にはインターネット接続が必要

本文、取得済み作品、取得済み形態解析はローカルに保存されます。保存済みデータはオフラインでも利用できます。

## 2. ダウンロードと配置

GitHub のリポジトリ画面から **Code → Download ZIP** を選び、ZIPを解凍してください。

解凍後の一番外側のフォルダは、概ね次の構成です。

```text
perseus-local-reader-main/
├── Perseus Local Reader.app
├── README.md
├── VERSION
└── .developer/                 Finderでは通常非表示
```

このフォルダは**中身を分離せず、そのまま保管してください**。`Perseus Local Reader.app` だけを別の場所へ移すと、読書用のWebアプリやPythonサーバーを見つけられなくなります。

## 3. 初回起動

`Perseus Local Reader.app` をダブルクリックします。

### 「開発元を確認できないため開けません」と表示された場合

このアプリは現時点ではAppleのDeveloper IDによる公証を受けていないため、macOSのGatekeeperにより初回起動が拒否される場合があります。

1. 警告画面を閉じます。
2. Appleメニュー → **システム設定** → **プライバシーとセキュリティ** を開きます。
3. セキュリティ欄まで下へ移動します。
4. `Perseus Local Reader.app` に関する表示の横にある **このまま開く** を押します。
5. MacのパスワードまたはTouch IDで承認します。
6. もう一度 `Perseus Local Reader.app` を開きます。

通常、この確認は最初の一度だけです。

### 「読書環境フォルダを選択」と表示された場合

macOSのApp Translocation、アプリの移動、または保存場所の変更により、アプリが読書環境を自動検出できない場合があります。

その場合は、ZIPを解凍してできた**一番外側のフォルダ**を選択してください。通常は次の名前です。

```text
perseus-local-reader-main
```

選択するフォルダには、少なくとも次が含まれている必要があります。

```text
Perseus Local Reader.app
README.md
.developer/
```

次のものは選択しません。

- `Perseus Local Reader.app` 自体
- `.developer` フォルダ
- `.developer/app` や `.developer/scripts`
- ZIPファイル
- `Downloads` フォルダ全体

正しいフォルダは記憶され、通常は次回以降自動的に使用されます。

## 4. 起動中の動作

アプリを起動すると、次の処理が行われます。

1. 読書環境のルートフォルダを特定します。
2. ローカルのPythonサーバーを子プロセスとして起動します。
3. `127.0.0.1` の8000番から8010番までのうち、利用可能な最初のポートを選びます。
4. サーバーの応答を確認します。
5. 既定のブラウザで読書画面を開きます。
6. バックグラウンドでGitHub上の最新版を確認します。

表示されるURLは、例えば次のいずれかです。

```text
http://127.0.0.1:8000/
http://127.0.0.1:8001/
```

8000番が他のプロセスに使われている場合は、8001番以降が選択されます。

### コントローラ画面

Swiftアプリには次のボタンがあります。

- **ブラウザで開く**: 現在の読書URLを既定のブラウザで開きます。
- **更新を確認**: GitHub上の `main/VERSION` を取得し、現在のアプリ版と比較します。
- **終了**: Pythonサーバーを停止し、アプリを終了します。

赤い閉じるボタンでウィンドウを閉じた場合も、アプリ全体が終了し、サーバーが停止します。

## 5. 終了とポートの扱い

ローカルサーバーはSwiftアプリの子プロセスです。アプリの終了時には、Swift側からサーバーへ終了要求を送り、必要に応じて強制終了します。

さらにPythonサーバー自身もSwiftアプリのPIDを監視します。Swiftアプリが異常終了した場合でも、親プロセスが消えたことを検知するとサーバーを終了します。

したがって、通常は次が成立します。

> `Perseus Local Reader.app` が動作している間だけローカルポートが開く。

ブラウザのタブだけを閉じてもサーバーは終了しません。コントローラ画面の **終了** を押すか、Swiftアプリを閉じてください。

## 6. 作品を読む

起動後のライブラリ画面では、Perseus Digital Libraryの著者・作品・版を検索できます。

- 著者名・作品名で検索
- 取得済み作品の即時表示
- 未取得作品のダウンロード
- ギリシア語原文と翻訳の切り替え
- 巻・節・行単位の移動
- 作品内検索
- ギリシア語単語の形態解析
- 作品中の単語形態情報の一括取得

プラトン『ソクラテスの弁明』は初期データとして含まれています。

## 7. 形態解析

ギリシア語本文の単語をクリックすると、Perseus Hopper由来の形態解析候補を表示します。

形態解析は文脈に応じた一意の解析結果ではなく、対象語形に対して可能な解析候補を列挙するものです。見出し語、短い語義、品詞、格、数、性、人称、時制、法、態などが、取得できた範囲で表示されます。

取得済みの解析結果は次へ保存され、作品間で共有されます。

```text
.developer/app/data/morph.json
```

## 8. ローカルに保存されるデータ

### 作品カタログ

```text
.developer/app/data/catalog.json
```

### ダウンロード済み作品

```text
.developer/app/data/texts/
```

作品ごとにJSONファイルとして保存され、利用可能な原文・翻訳の版を含みます。

### 形態解析キャッシュ

```text
.developer/app/data/morph.json
```

### 実行ログ

```text
.developer/data/build/
```

主なログは次です。

```text
swift-app-server-8000.log
swift-app-server-8001.log
swift-update.log
```

これらの利用者データは現時点では `~/Library/Application Support` ではなく、解凍したリポジトリフォルダ内に保存されます。フォルダ全体を削除すると、ダウンロード済み作品と形態解析キャッシュも失われます。

## 9. 更新

### 自動確認

ローカルサーバーの起動後、アプリは次のファイルを短いタイムアウト付きで確認します。

```text
https://raw.githubusercontent.com/sohma-kbysh/perseus-local-reader/main/VERSION
```

リモート版が現在のアプリ版より新しい場合、更新するか確認するダイアログを表示します。

オフライン、タイムアウト、GitHubへの接続失敗などが起きても、読書機能は停止しません。既存のローカルデータでそのまま利用できます。

### 手動確認

コントローラ画面の **更新を確認** を押します。

- 最新の場合: `最新版です`
- 新版がある場合: 更新確認ダイアログ
- 接続できない場合: オフラインでも読書を継続できる旨の表示

### 更新処理

**更新する** を選ぶと、更新ヘルパーが起動されます。

1. アプリ終了を待ちます。
2. `morph.json` と `texts/` を一時退避します。
3. 最新の `main` を取得します。
4. プログラムとアプリ本体を更新します。
5. 利用者データを復元・統合します。
6. 新しい `Perseus Local Reader.app` を再起動します。

Git cloneした開発用チェックアウトでは `git pull --ff-only origin main` を使用します。通常のDownload ZIP版ではGitHubから `main.zip` を取得して展開します。

自動更新で保持される主なデータ:

```text
.developer/app/data/morph.json
.developer/app/data/texts/
.developer/data/vendor/
```

Gitチェックアウトに、利用者データ以外の未コミット変更がある場合、自動更新は安全のため中止されます。

## 10. ネットワークとプライバシー

ローカルHTTPサーバーは次のアドレスにのみbindします。

```text
127.0.0.1
```

これはMac自身からだけアクセスできるループバックアドレスです。通常、同じLAN上の別端末には公開されません。

外部通信が発生する主な場面は次です。

- GitHubから作品・メタデータ・更新情報を取得する場合
- Perseusから未取得の形態解析を取得する場合
- GitHubからアプリ更新を取得する場合

取得済み本文や解析結果を読むだけの場合、外部通信は不要です。

## 11. トラブルシューティング

### ブラウザが開かない

コントローラ画面に表示されたURLをブラウザのアドレス欄へ直接入力します。

```text
http://127.0.0.1:8000/
```

実際のポートが8001以降の場合は、画面に表示された番号を使用します。

### サーバーを起動できない

次を確認します。

```bash
lsof -nP -iTCP:8000-8010 -sTCP:LISTEN
```

サーバーログも確認します。

```bash
tail -n 100 .developer/data/build/swift-app-server-*.log
```

### 更新に失敗する

```bash
tail -n 200 .developer/data/build/swift-update.log
```

Gitチェックアウトでは、未コミット変更が原因で更新が拒否されることがあります。

```bash
git status
```

### Python 3が見つからない

現在のSwiftアプリは次を直接起動します。

```text
/usr/bin/python3
```

この実行ファイルが使用できない環境では、ローカルサーバーを起動できません。

---

# English Guide

## 1. Overview

Perseus Local Reader is a macOS application for reading classical Greek texts and their translations locally. It uses openly distributed data from the Perseus Digital Library and provides a searchable library, downloadable works, translation switching, citation-aware navigation, in-work search, and on-demand morphological analysis.

The public user-facing entry point is a single application:

```text
Perseus Local Reader.app
```

The previous separate Open, Close, and Update applications are no longer required. The Swift application starts and supervises the local Python server, opens the reader in the default browser, checks GitHub for updates, and shuts the server down when the application exits.

The application preserves downloaded works and cached morphology data across normal launches and supported updates. Already downloaded content remains available for offline reading.

## 2. System requirements

- macOS 13 Ventura or later;
- Apple Silicon or Intel Mac;
- a working Python 3 executable at `/usr/bin/python3`;
- network access when downloading works, fetching uncached morphology, checking for updates, or applying updates.

The controller is built with Swift Package Manager using Swift tools version 5.9. End users do not need to build the application when using a repository ZIP that already contains the prebuilt `.app` bundle.

## 3. Installation

Download the repository ZIP from GitHub and extract it without separating its contents.

Expected top-level layout:

```text
perseus-local-reader-main/
├── Perseus Local Reader.app
├── README.md
├── VERSION
└── .developer/
```

The `.app` bundle is not currently a fully self-contained distribution. It expects the adjacent `.developer` runtime directory to remain available. Moving only the `.app` bundle elsewhere will prevent runtime discovery unless the user subsequently selects the correct repository root.

## 4. First launch and Gatekeeper

The distributed application is currently ad-hoc signed rather than signed and notarized with an Apple Developer ID. Gatekeeper may therefore block the first launch.

To authorize it:

1. dismiss the initial warning;
2. open System Settings;
3. open Privacy & Security;
4. locate the blocked-app notice;
5. choose Open Anyway;
6. authenticate;
7. launch `Perseus Local Reader.app` again.

The exact wording varies by macOS version.

## 5. Reader-root discovery

At startup, the Swift controller searches for a valid reader root in this order:

1. the directory containing the running `.app` bundle;
2. the path previously stored in `UserDefaults`.

A directory is considered valid when it contains both:

```text
.developer/scripts/server.py
.developer/app/data/catalog.json
```

If automatic discovery fails, the application presents an `NSOpenPanel`. The user must select the outermost extracted repository folder, not the `.app` bundle or `.developer` itself.

The selected path is persisted under the `readerRoot` user-defaults key.

## 6. Process and server lifecycle

The Swift controller starts the Python server with `Foundation.Process`:

```text
/usr/bin/python3 .developer/scripts/server.py <port> --parent-pid <swift-pid>
```

It attempts ports 8000 through 8010 in ascending order. Standard output and standard error are redirected to:

```text
.developer/data/build/swift-app-server-<port>.log
```

After spawning the process, the controller polls the selected loopback URL until it receives HTTP 200. It then:

1. marks the controller status as running;
2. enables the Open in Browser button;
3. opens the URL through `NSWorkspace`;
4. starts a background update check.

The Python server binds to:

```text
127.0.0.1:<selected-port>
```

It is not intentionally exposed on all interfaces.

### Normal shutdown

When the application terminates, the controller sends a termination signal to the child process. It waits briefly and sends `SIGKILL` if the process fails to exit.

### Abnormal parent termination

The Python server receives the Swift process identifier through `--parent-pid`. A daemon watcher periodically checks whether that PID still exists. When the parent disappears, the server calls `shutdown()`.

This parent-watch mode replaces the historical eight-hour idle shutdown when the server is launched by the Swift application. The idle timeout remains available when `server.py` is launched without `--parent-pid`.

## 7. Controller interface

The controller exposes three primary actions:

- **Open in Browser**: opens the active loopback URL;
- **Check for Updates**: performs an explicit version check;
- **Quit**: terminates the server and exits the application.

The application is configured to terminate after its final window is closed. Closing the red window button therefore also terminates the server.

Closing only the browser tab does not terminate the controller or the Python process.

## 8. Reader functionality

The browser interface provides:

- offline catalog search;
- browsing by author and work;
- on-demand download of all available versions of a work;
- switching between Greek editions and available translations;
- citation-aware navigation for prose, epic, and drama;
- in-work text search;
- clickable Greek tokens;
- on-demand morphology retrieval;
- bulk morphology retrieval for the currently open work.

Plato's *Apology* is included as an initially downloaded work.

## 9. Data model and persistence

### Catalog

```text
.developer/app/data/catalog.json
```

Generated from CTS metadata and searched locally by the library interface.

### Downloaded works

```text
.developer/app/data/texts/<work-id>.json
```

Each work file contains the converted content for the downloaded editions and translations associated with that work.

### Morphology cache

```text
.developer/app/data/morph.json
```

Morphology entries are keyed by encountered word form and shared across works.

### Runtime and update logs

```text
.developer/data/build/
```

The current implementation stores user data inside the extracted repository directory rather than under `~/Library/Application Support`. Deleting or replacing the entire repository folder without preserving these files will delete the local library cache.

## 10. Morphology semantics

Morphology is obtained from Perseus Hopper. Results represent possible analyses for the submitted form; they are not contextually disambiguated parses of the sentence.

Depending on the returned data, an entry may include:

- lemma;
- short lexical gloss;
- part of speech;
- case;
- number;
- gender;
- person;
- tense;
- mood;
- voice;
- degree;
- dialect or other annotations.

A short definition belongs to the lemma entry and should not be interpreted as a sentence-level translation of the selected token.

## 11. Version checking

The app bundle embeds its local version in `CFBundleShortVersionString`, generated from the repository-root `VERSION` file during the build.

The controller requests:

```text
https://raw.githubusercontent.com/sohma-kbysh/perseus-local-reader/main/VERSION
```

The request:

- ignores the local URL cache;
- has a short timeout;
- runs after the reader server has started;
- does not block local reading on failure.

Versions are compared component-wise as numeric dotted versions. If the remote version is newer, the user is prompted to update. If the check fails, manual status reports that offline reading remains available.

## 12. Update architecture

The Swift controller does not overwrite itself while running. Instead it:

1. copies `.developer/scripts/apply_swift_update.sh` to a temporary location;
2. starts that temporary helper as an independent process;
3. passes the current application PID, repository root, and app path;
4. terminates the Swift application.

The helper waits until the application process exits before modifying files.

### Git-checkout update path

When `.git` exists:

1. back up morphology and downloaded works;
2. reject the update if non-user-data changes are uncommitted;
3. restore the tracked `morph.json` before pulling when necessary;
4. execute `git fetch origin main`;
5. execute `git pull --ff-only origin main`;
6. merge the saved morphology cache;
7. restore downloaded works;
8. reopen the updated application.

### ZIP-installation update path

When `.git` does not exist:

1. download the `main` branch ZIP;
2. extract it to a temporary directory;
3. synchronize the new distribution into the current root;
4. exclude local morphology, downloaded works, runtime logs, vendor caches, and `.git`;
5. restore and merge user data;
6. reopen the updated application.

Update logs are written to:

```text
.developer/data/build/swift-update.log
```

## 13. Network boundary

The local HTTP service listens only on the loopback address. External network requests may be made for:

- GitHub-hosted version and update files;
- Perseus text or metadata resources;
- Perseus Hopper morphology pages.

The reader does not require an external application server for already cached content.

## 14. Repository architecture

```text
Perseus Local Reader.app/              prebuilt user-facing controller
VERSION                                distribution/application version
README.md
.developer/
  app/
    index.html                         library interface
    library.js
    reader.html                        reading interface
    reader.js
    morph.html
    morph.js
    styles.css
    data/
      catalog.json
      texts/
      morph.json
  scripts/
    server.py                          local HTTP/API server
    text_store.py                      work download and conversion orchestration
    tei_convert.py                     TEI/EpiDoc to reader JSON conversion
    fetch_morph.py                     morphology retrieval and cache update
    merge_morph_cache.py               cache merge used during update
    apply_swift_update.sh              detached self-update helper
    start_reader.sh                    optional command-line launcher
    stop_reader.sh                     optional command-line stop helper
  swift-app/
    Package.swift
    Sources/
      PerseusLocalReader/
        main.swift                     AppKit controller and update UI
    Resources/
      AppIcon.icns
    build_app.sh                       release build and app-bundle assembly
  data/
    build/                              runtime logs and transient state
    vendor/                             development/runtime source caches
```

## 15. Developer build

Requirements:

- macOS;
- Xcode Command Line Tools or Xcode;
- Swift 5.9-compatible toolchain.

Build the release application from the repository root:

```bash
.developer/swift-app/build_app.sh
```

The script:

1. reads `VERSION`;
2. runs `swift build -c release`;
3. assembles `Perseus Local Reader.app`;
4. writes `Info.plist`;
5. embeds the version;
6. copies the application icon when available;
7. applies an ad-hoc code signature.

Launch the result:

```bash
open "Perseus Local Reader.app"
```

## 16. Release procedure

For a new release:

1. update the root `VERSION` file;
2. ensure `updateBranch` in `main.swift` is `main`;
3. rebuild `Perseus Local Reader.app`;
4. test startup, browser opening, shutdown, port release, manual version checking, and self-update;
5. commit the Swift source, Python changes, update helper, `VERSION`, README, icon resource, and rebuilt `.app` bundle together;
6. push to `main`.

Example:

```bash
echo "0.2.0" > VERSION
.developer/swift-app/build_app.sh
git add -A
git commit -m "Release Perseus Local Reader 0.2.0"
git push origin main
```

The prebuilt app bundle and `VERSION` must be updated in the same commit. Otherwise users may receive a distribution whose executable version does not match the remote update version.

## 17. Manual server execution

For debugging without the Swift controller:

```bash
python3 .developer/scripts/server.py 8000
```

In this mode no parent PID is supplied, so the historical idle-shutdown watcher is used.

Then open:

```text
http://127.0.0.1:8000/
```

## 18. Data sources

- Texts and CTS metadata: `PerseusDL/canonical-greekLit`
- Morphology: Perseus Hopper morphology service
- Lemma short definitions: Perseus Hopper `hib_lemmas.sql` data where available
