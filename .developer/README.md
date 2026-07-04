# プラトン『ソクラテスの弁明』ローカル読書環境

Perseus プロジェクトが公開しているデータを用いた、プラトン『ソクラテスの弁明』(*Apology*) のローカル読書環境です。

## 使い方（読者の方へ）

専門知識がなくても使えます。次の手順で読み始められます。

1. フォルダの中にある次のアプリを**ダブルクリック**します。

   ```text
   Open Plato Apology.app
   ```

2. 自動的にお使いのパソコンの中だけで小さな「サーバー」が起動し、続けてブラウザ（Safari や Chrome など）が開きます。インターネットにアップロードされるわけではなく、すべてあなたのパソコンの中で完結します。
3. ブラウザにギリシア語原文が表示されます。**ギリシア語の単語をクリック**すると、その単語の形態分析（品詞・格・活用形など）を示す「morph（形態）パネル」が開きます。これは辞書を都度引く手間を省くための補助機能です。
4. 読み終えたら、そのままブラウザやアプリを閉じてしまって構いません。裏で動いているサーバーは、8時間ほどアクセスがないと自動的に停止するので、後片付けを気にする必要はありません。

### 「開発元を確認できないため開けません」と表示されたら

このアプリは Apple の審査を通っていない個人配布のアプリなので、初回起動時に
macOS が安全確認のためにブロックすることがあります。その場合は次の手順で開いてください。

1. 表示されたブロック画面（または通知）はそのまま閉じます。
2. Apple メニュー →「システム設定」→ 左側の「プライバシーとセキュリティ」を開きます。
3. 画面を下にスクロールし、「セキュリティ」欄にある
   「"Open Plato Apology.app" がブロックされました」というメッセージの横の
   **「このまま開く」**ボタンをクリックします。
4. Mac のパスワード（または Touch ID）の入力を求められたら入力します。
5. もう一度 `Open Plato Apology.app` をダブルクリックすると起動します。

この確認は**最初の1回だけ**必要です。以降はダブルクリックだけで起動します。
`Update Plato Apology.app` を初めて使うときも、同様の手順が必要になる場合があります。

読書環境は `http://127.0.0.1:8000/` というアドレスで、あなたのパソコンの中だけで動作します。外部のサーバーには一切データを送信しません。

### アップデートのしかた

GitHub 上の最新版に更新したいときは、次のアプリをダブルクリックしてください。

```text
Update Plato Apology.app
```

これまでにキャッシュした形態分析データ（単語の解析結果）はそのまま保持されつつ、GitHub から最新のファイル一式を取得し、読書環境を再度開いてくれます。

## いま何がローカルにあるか

- ギリシア語本文は `.developer/app/data/apology.json` にローカル保存されています。
- 生成された読書画面 `app/index.html` は、インターネット接続なしで動く静的なローカルページです。
- ギリシア語の単語をクリックすると、ローカルの「morph（形態）パネル」が開きます。
- `scripts/fetch_morph.py` は、『ソクラテスの弁明』本文に実際に出てくる語形だけを対象に、Perseus Hopper の形態分析ページをキャッシュ（保存）できます。

morph パネルは、まず `.developer/app/data/morph.json` にキャッシュ済みの Perseus 解析があればそれを使います。なければ、正規化した語形や `hib_lemmas.sql` 由来のローカルな見出し語候補を代わりに表示します。

---

以下は開発者向けの技術的な説明です（英語）。

# Plato Apology Local Reader

Local reading environment for Plato's *Apology* using openly distributed Perseus data.

## For Readers

On macOS, double-click:

```text
Open Plato Apology.app
```

It starts the local reader and opens your browser. The reader stops itself
automatically after about 8 hours without access.

To update this folder from GitHub, double-click:

```text
Update Plato Apology.app
```

The updater preserves locally cached morphology data, pulls the latest files
from GitHub, and opens the reader again.

### If macOS says "cannot verify the developer" or blocks the app

This app is distributed personally and is not notarized through the App Store,
so macOS may block it the first time you open it. To allow it:

1. Dismiss the block dialog/notification.
2. Apple menu → System Settings → Privacy & Security.
3. Scroll down to the "Security" section and click **Open Anyway** next to the
   message saying `"Open Plato Apology.app" was blocked`.
4. Enter your Mac password (or use Touch ID) if prompted.
5. Double-click `Open Plato Apology.app` again to launch it.

This confirmation is only needed the first time; after that, double-clicking
is enough. `Update Plato Apology.app` may require the same steps the first
time it is used.

The reader runs only on your own computer at `http://127.0.0.1:8000/` and
never sends data anywhere else.

## What is local now

- The Greek text is stored locally in `.developer/app/data/apology.json`.
- The generated reader in `app/index.html` works as a static local page.
- Clicking a Greek word opens a local "morph" panel.
- `scripts/fetch_morph.py` can cache Perseus Hopper morph pages for only the
  word forms that appear in the Apology.

The morph panel first uses `.developer/app/data/morph.json` when a cached Perseus analysis
is available. Otherwise it falls back to normalized forms and local lemma
candidates from `hib_lemmas.sql`.

## Project Layout

```text
.developer/
  app/            generated static reader (served as-is, no build step at runtime)
    index.html    reader page (produced by scripts/build.py)
    morph.js/html/styles.css
    data/
      apology.json  Greek text + line/word metadata (produced by build.py)
      morph.json    cached Perseus morphology, keyed by word form
  scripts/
    build.py              generates app/index.html and app/data/apology.json
                           from data/vendor/ source files (TEI XML + lemma dump)
    server.py             dev/production server, serves app/ and the /api/morph
                           endpoint used for on-demand lookups
    fetch_morph.py         batch-fetches and caches Perseus Hopper morph pages
    merge_morph_cache.py   merges two morph.json caches (base + local) into one
    start_reader.sh / stop_reader.sh   background the server, track its pid/log
                           under data/build/, and enforce the 8h idle shutdown
    update_reader.sh       git pull wrapper used by the updater app
    open_reader_app.jxa / update_reader_app.jxa
                           JXA source compiled into the two .app launchers below
  data/
    vendor/    (gitignored) raw TEI XML + lemma SQL dump that build.py consumes
    build/     (gitignored) runtime pid/log files written by start_reader.sh
Open Plato Apology.app/     end-user launcher at repo root, wraps open_reader_app.jxa
Update Plato Apology.app/   end-user updater at repo root, wraps update_reader_app.jxa
```

The two `.app` bundles are thin AppleScript/JXA wrappers built in Script
Editor from the `.jxa` sources above; they locate this checkout (handling the
Gatekeeper quarantine/translocation case) and shell out to
`start_reader.sh`/`update_reader.sh`. Rebuild them in Script Editor after
editing the `.jxa` files — editing the compiled `.app` bundles directly is not
supported.

## Running the Server

Preferred, matches what the `.app` launcher does (backgrounds the process,
writes a pid file, and self-terminates after 8h idle):

```sh
.developer/scripts/start_reader.sh 8000
.developer/scripts/stop_reader.sh
```

Or run it in the foreground for debugging:

```sh
python3 .developer/scripts/server.py 8000
```

Then open:

```text
http://localhost:8000/
```

## Rebuilding the Reader from Source

`build.py` regenerates `app/index.html` and `app/data/apology.json` from the
TEI XML and lemma dump under `data/vendor/` (not checked in — see Data
Sources below for where to obtain them):

```sh
python3 .developer/scripts/build.py
```

To merge a morph cache built elsewhere (e.g. on another machine) back into
the tracked cache:

```sh
python3 .developer/scripts/merge_morph_cache.py .developer/app/data/morph.json path/to/local-morph.json
```

## Fetch Perseus Morph Data

The official `hib_parses.tar.gz` download repeatedly terminated early from this
network, so this project uses a resumable, Apology-only cache of Hopper's morph
pages instead.

Fetch the first 20 word forms in reading order:

```sh
python3 .developer/scripts/fetch_morph.py --limit 20 --delay 2.0
```

Continue toward all Apology word forms:

```sh
python3 .developer/scripts/fetch_morph.py --delay 2.0
```

When the reader is served with `.developer/scripts/server.py`, clicking an uncached word
fetches just that word form on demand and writes it to `.developer/app/data/morph.json`.

Perseus may return `429 Too Many Requests`; the batch script waits and retries.
The ad hoc click handler reports the 429 and lets you retry later. Both paths
write `.developer/app/data/morph.json`, so it is safe to stop and resume.

## Data Sources

- Apology TEI XML: `PerseusDL/canonical-greekLit`
- Lemma dump: Perseus Hopper official open-source download page
