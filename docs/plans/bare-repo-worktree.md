# Bare Repo + Worktree Migration Plan

Migrate `git-wt-helper` to use bare clones (`ghq get --bare`) with all branches managed as `wt-xxx` worktrees.

## Current State

- `ghq get` creates a normal (non-bare) clone
- The cloned repo root is the main worktree (default branch)
- Feature branches are worktrees under `<repo>/.worktrees/wt-001, wt-002, ...`
- `git wt -b` returns to the main worktree (repo root)

```
~/src/github.com/user/repo/              ← main worktree (main branch)
~/src/github.com/user/repo/.worktrees/
  wt-001/                                ← feature-a
  wt-002/                                ← feature-b
```

## Target State

- `ghq get --bare` creates a bare clone
- All branches (including default) are `wt-xxx` worktrees inside the bare repo root
- No branch gets special treatment; all are equal
- `.worktrees` directory is eliminated

```
~/src/github.com/user/repo/              ← bare repo (HEAD, objects/, refs/, ...)
  wt-001/                                ← main
  wt-002/                                ← feature-a
  wt-003/                                ← feature-b
```

## Design Decisions

| Topic | Decision |
|---|---|
| Worktree location | Directly under bare repo root as `wt-xxx` |
| Default branch | No special treatment; just another `wt-xxx` |
| `git wt -b` | Goes to bare repo root |
| Non-bare repo support | Keep backward compatibility |
| fzf display | `wt-xxx  branch-name` (already implemented in PR #60) |
| Code structure | **Top-level bare/non-bare 分岐。以降は完全に別パス。共有ユーティリティのみ共通。** |

---

## Architecture: Top-Level Branching

各関数内部で bare/non-bare を判定するのではなく、エントリポイントで一度だけ判定し、以降は完全に分岐する。コードの重複は許容する。

```bash
# Shared utilities (bare/non-bare 共通)
die()
get_default_branch()
is_worktree_dirty()
is_merged()

# Non-bare path (現行コードほぼそのまま)
nonbare_main()        # 現行の Main セクション
nonbare_list_worktrees()
nonbare_find_unused_worktree()
nonbare_create_new_worktree()
nonbare_prepare_worktree()
nonbare_find_worktree_for_branch()
nonbare_select_with_fzf()

# Bare path (新規)
bare_main()
bare_list_worktrees()
bare_find_unused_worktree()
bare_create_new_worktree()
bare_prepare_worktree()
bare_find_worktree_for_branch()
bare_select_with_fzf()
```

**エントリポイント:**

```bash
# Ensure we're in a git repository
if [[ $(git rev-parse --is-bare-repository 2>/dev/null) == true ]]; then
  bare_main "$@"
elif git rev-parse --is-inside-work-tree &>/dev/null; then
  nonbare_main "$@"
else
  die "Not in a git repository"
fi
```

---

## Phase 1: git-wt-helper に bare パスを追加

### 1-1. Shared utilities

現行の以下の関数はそのまま共通で使う（bare/non-bare に依存しない）:

- `die()`
- `get_default_branch()`
- `is_worktree_dirty()`
- `is_merged()`
- `show_help()` — bare 向けの説明を追記

### 1-2. Bare path の関数群

**`bare_list_worktrees()`**

`git worktree list --porcelain` の出力から bare エントリ（`bare` 行を持つ）を除外し、worktree のみ列挙する。

```bash
# Output format: <path>:<branch>
bare_list_worktrees() {
  git worktree list --porcelain | awk '
    /^worktree / { path = substr($0, 10) }
    /^branch /   { branch = substr($0, 8); sub("refs/heads/", "", branch) }
    /^bare$/     { is_bare = 1 }
    /^$/ {
      if (!is_bare && path != "" && branch != "") {
        print path ":" branch
      }
      path = ""; branch = ""; is_bare = 0
    }
    END {
      if (!is_bare && path != "" && branch != "") {
        print path ":" branch
      }
    }
  '
}
```

**`bare_find_unused_worktree()`**

`nonbare_find_unused_worktree` と同じロジック。`bare_list_worktrees` を使う。

**`bare_create_new_worktree()`**

bare repo root 直下に `wt-xxx` を作成する（`.worktrees` なし）。

```bash
bare_create_new_worktree() {
  local repo_root=$1
  local branch=$2
  local default_branch=$3
  local num=1 new_path

  while [[ -d "$repo_root/wt-$(printf '%03d' $num)" ]]; do
    ((num++))
  done

  new_path="$repo_root/wt-$(printf '%03d' $num)"
  git worktree add -b "$branch" "$new_path" "$default_branch" >&2
  echo "$new_path"
}
```

**`bare_prepare_worktree()`**

新しいブランチ用の worktree を用意する（再利用 or 新規作成）。

```bash
bare_prepare_worktree() {
  local branch=$1
  local default_branch repo_root unused_worktree

  default_branch=$(get_default_branch)
  repo_root=$(git rev-parse --git-dir)

  if [[ $FORCE_NEW == false ]] && unused_worktree=$(bare_find_unused_worktree "$default_branch"); then
    (
      cd "$unused_worktree"
      git fetch -q origin "$default_branch" 2>/dev/null || true
      git checkout -q -B "$branch" "origin/$default_branch"
    ) >&2
    echo "$unused_worktree"
  else
    bare_create_new_worktree "$repo_root" "$branch" "$default_branch"
  fi
}
```

**`bare_find_worktree_for_branch()`**

`nonbare_find_worktree_for_branch` と同じロジック。`bare_list_worktrees` を使う。

**`bare_select_with_fzf()`**

bare repo には "main worktree" エントリがないので、全て `bare_list_worktrees` から列挙。

```bash
bare_select_with_fzf() {
  local fzf_out query selected

  fzf_out=$(
    bare_list_worktrees | while IFS=: read -r path branch; do
      printf '%s\t%s  %s\n' "$path" "$(basename "$path")" "$branch"
    done | fzf --prompt='worktree> ' \
        --with-nth=2 \
        --delimiter=$'\t' \
        --preview='cd {1} && git log --oneline -10' \
        --print-query
  ) || true

  query=$(echo "$fzf_out" | sed -n '1p')
  selected=$(echo "$fzf_out" | sed -n '2p')

  if [[ -n $selected ]]; then
    echo "$selected" | cut -d$'\t' -f1
  elif [[ -n $query ]]; then
    exec "$0" "$query"
  fi
}
```

**`bare_main()`**

```bash
bare_main() {
  if (($#)); then
    local branch=$1

    # Check if branch already has a worktree
    if worktree_path=$(bare_find_worktree_for_branch "$branch"); then
      echo "$worktree_path"
      exit 0
    fi

    # Check if it's an existing branch (local or remote)
    if branch_exists "$branch"; then
      local default_branch repo_root
      default_branch=$(get_default_branch)
      repo_root=$(git rev-parse --git-dir)

      if [[ $FORCE_NEW == false ]] && unused_worktree=$(bare_find_unused_worktree "$default_branch"); then
        (
          cd "$unused_worktree"
          if git show-ref --verify --quiet "refs/heads/$branch"; then
            git checkout -q "$branch"
          else
            git checkout -q -b "$branch" "origin/$branch"
          fi
        ) >&2
        echo "$unused_worktree"
      else
        local num=1 new_path
        while [[ -d "$repo_root/wt-$(printf '%03d' $num)" ]]; do
          ((num++))
        done
        new_path="$repo_root/wt-$(printf '%03d' $num)"
        git worktree add "$new_path" "$branch" >&2
        echo "$new_path"
      fi
    else
      # New branch
      bare_prepare_worktree "$branch"
    fi
  else
    bare_select_with_fzf
  fi
}
```

### 1-3. Non-bare path

現行コードをそのまま `nonbare_main()` と `nonbare_*` 関数群にリネームするだけ。ロジック変更なし。

### Files Modified

- `programs/git/scripts/git-wt-helper`

---

## Phase 2: Shell Wrapper (`git wt -b`)

`programs/zsh/config/git.zsh` の `gitwt` 関数を更新。

### 変更内容

`git wt -b` で bare repo root に戻れるようにする。

```bash
if [[ $1 == "-b" ]]; then
  shift
  local git_common_dir
  if git_common_dir=$(git rev-parse --git-common-dir 2>/dev/null); then
    if [[ $(git rev-parse --is-bare-repository 2>/dev/null) == true ]]; then
      cd "$git_common_dir"
    else
      cd "$git_common_dir/.."
    fi
  else
    echo "Not in a git repository" >&2
    return 1
  fi
  return
fi
```

### Files Modified

- `programs/zsh/config/git.zsh`

---

## Phase 3: ghq Workflow

`ghq get --bare` 後に初回 worktree を自動作成する仕組み。

### 案: `git wt` を引数なしで bare repo（worktree 0 個）で実行したとき、default branch の worktree を自動作成

`bare_select_with_fzf` または `bare_main` の先頭で worktree が 0 個なら default branch で worktree を作る。

```bash
bare_main() {
  # If no worktrees exist, create one for the default branch
  if [[ -z $(bare_list_worktrees) ]]; then
    local default_branch repo_root
    default_branch=$(get_default_branch)
    repo_root=$(git rev-parse --git-dir)
    bare_create_new_worktree "$repo_root" "$default_branch" "$default_branch"
    # If no branch argument was given, just output the new worktree
    if (($# == 0)); then
      return
    fi
  fi

  # ... rest of bare_main
}
```

これにより、ワークフローは:

```bash
ghq get --bare user/repo
cd $(ghq list -p user/repo)
git wt   # → worktree 0 個なので default branch で wt-001 を自動作成、cd される
```

### Files Modified

- `programs/git/scripts/git-wt-helper`

---

## Execution Order

```
Phase 1 (git-wt-helper bare パス追加)
  └──> Phase 2 (Shell wrapper)
         └──> Phase 3 (ghq workflow / 初回 worktree 自動作成)
```

---

## Progress

- [ ] **Phase 1**: git-wt-helper に bare パスを追加（top-level 分岐）
- [ ] **Phase 2**: Shell wrapper `git wt -b` の bare 対応
- [ ] **Phase 3**: ghq bare clone + 初回 worktree 自動作成
