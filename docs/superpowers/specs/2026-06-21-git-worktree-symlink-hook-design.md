# git worktree symlink hook 設計

## 目的

`git worktree` で新しい worktree を作成したとき、リポジトリごとに `git config` で
指定したファイル（`.env` などの git 未管理ローカル設定）を、新 worktree 内へ自動で
symlink する。これにより各 worktree でローカル設定ファイルを共有できる。

## 要件

- グローバルな git hook として設定する。
- symlink が既に存在する場合は、何も表示せず何もしない。
- symlink がまだ無い場合は symlink を作成し、作成成功を表示する。
- 設定したファイル（source）が存在しない場合は警告を表示する。
- エラーが発生したらエラーを表示する。

## 決定事項（ブレインストーミング結果）

| 項目               | 決定                                                                         |
| ------------------ | ---------------------------------------------------------------------------- |
| symlink 元（実体） | メイン worktree 内の同じ相対パス                                             |
| config スキーマ    | 多値 config キー `nownabe.worktreeSymlink`（git 予約セクションとの衝突回避） |
| ローカル hooks     | グローバル hook 内でリポジトリの `.git/hooks/post-checkout` へチェーンする   |
| bare repo          | 非対応（symlink 処理はスキップ）                                             |
| 発火範囲           | worktree 作成時のみ（`$1` が null OID のときだけ）                           |
| symlink パス形式   | 相対パス                                                                     |

## アプローチ

git には worktree-add 専用フックが無いが、`git worktree add` 時に新 worktree 内で
**post-checkout** フックが発火する。これを利用し、`core.hooksPath` でグローバルな
post-checkout フックを設置する。

> 注: `core.hooksPath` が設定されると git はそのパスのフックのみ実行し、リポジトリの
> `.git/hooks/` を無視する。これを補うため、グローバル hook がローカル hook へ明示的に
> チェーンする。

## 構成

```
programs/git/
├── default.nix              # core.hooksPath 設定 + hook ファイル配置を追加
└── hooks/
    └── post-checkout        # 新規: グローバル post-checkout フック（bash）
```

### Nix 統合（`programs/git/default.nix`）

- `home.file.".config/git/hooks/post-checkout"` を `./hooks/post-checkout` から配置し
  `executable = true`。
- `programs.git.settings.core.hooksPath = "${config.home.homeDirectory}/.config/git/hooks"`
  を追加。

## post-checkout フックの動作

post-checkout は `$1=移行前HEAD $2=移行後HEAD $3=flag` で呼ばれる。

### 1. ローカル hooks へチェーン（最初に実行）

- `local_hook="$(git rev-parse --git-common-dir)/hooks/post-checkout"`
- `local_hook` が存在し実行可能で、かつ自分自身でない場合、同じ引数で実行する。

### 2. 対象判定（symlink 処理に進むかのガード）

以下のいずれかに該当したら symlink 処理をスキップして正常終了（チェーンは実行済み）:

- bare repo: `basename "$(git rev-parse --git-common-dir)" != ".git"`
- worktree 作成時でない: `$1` が null OID（`0000000000000000000000000000000000000000`）でない
- 現在の toplevel がメイン worktree 自身（source==target で循環するため）

メイン worktree = `dirname "$(git rev-parse --git-common-dir)"`（non-bare では
common-dir が `<main>/.git` のため）。
現在の toplevel = `git rev-parse --show-toplevel`。

### 3. symlink 処理

`git config --get-all nownabe.worktreeSymlink` の各値（相対パス）について:

- `source = <メインworktree>/<相対パス>`
- `target = <現worktree>/<相対パス>`
- symlink は相対パスで張る（`realpath -m --relative-to="$(dirname target)" source`）。

| 状態                                                       | 動作                                                  |
| ---------------------------------------------------------- | ----------------------------------------------------- |
| target が既に symlink                                      | 何も表示せず何もしない                                |
| target が既存の通常ファイル/ディレクトリ（symlink でない） | 上書きせず警告（クロバー防止）                        |
| target が無く source が存在しない                          | 警告表示                                              |
| target が無く source が存在                                | 親 dir を `mkdir -p` し symlink 作成 → 成功メッセージ |
| 作成コマンド失敗など                                       | エラー表示                                            |

判定順序: ①target が symlink → 無音終了 → ②target が非 symlink で存在 → 警告 →
③source 無し → 警告 → ④symlink 作成（失敗時エラー）。

### 出力

- メッセージは stderr に出力する（post-checkout の慣習）。
- 成功例: `worktree-symlink: created .env -> ../../.env`
- 警告例: `worktree-symlink: warning: source not found: .env`
- エラー例: `worktree-symlink: error: failed to create symlink for .env`

## 使い方（リポジトリごと）

```bash
git config --add nownabe.worktreeSymlink .env
git config --add nownabe.worktreeSymlink .claude/settings.local.json
```

その後 `git wt <branch>` 等で worktree を作成すると、上記ファイルが新 worktree に
symlink される。

## テスト計画

- [ ] `hms` 実行後、`git config --global core.hooksPath` が設定され、
      `~/.config/git/hooks/post-checkout` が配置・実行可能になっている。
- [ ] 非 bare のテストリポジトリで `git config --add nownabe.worktreeSymlink .env` し、
      `.env` を作成 → `git wt test` で symlink 作成 + 成功メッセージ。
- [ ] 同じ worktree で再度 checkout しても発火しない（worktree 作成時のみ）。
- [ ] source（`.env`）を消した状態で新 worktree 作成 → 警告表示。
- [ ] target に既存の通常ファイルがある状態 → 上書きせず警告。
- [ ] リポジトリに既存のローカル `.git/hooks/post-checkout` を置き、worktree 作成時に
      それも実行される（チェーン）。
- [ ] bare repo の worktree 作成では symlink 処理がスキップされる。
