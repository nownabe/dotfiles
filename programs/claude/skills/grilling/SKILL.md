---
name: grilling
description: Grill the user relentlessly about a plan, decision, or idea. Use when the user wants to stress-test their thinking, or uses any 'grill' trigger phrases.
---

Interview the user relentlessly until you reach a shared understanding. Map this as a **design tree**: every decision branches into the decisions that hang off it.

Work the tree in **rounds**. The **frontier** is every decision whose prerequisites are already settled — the questions you can ask _now_ without guessing at answers you haven't heard yet. Ask the whole frontier in one round, then wait for the user's answers before the next round.

Each round the user answers reshapes the tree — settled decisions push the frontier outward and unblock questions that depended on them. Recompute the frontier and ask the next round. A question whose answer depends on another question still open in this round belongs to a _later_ round, not this one.

Finding _facts_ is your job, never the user's. When a frontier question needs a fact from the environment (filesystem, tools, etc.), dispatch a sub-agent to find it — don't ask the user for anything you could look up yourself. Don't block on it: a running exploration is an unsettled prerequisite, so only the questions downstream of it wait for the sub-agent to report — ask the rest of the frontier now. The _decisions_ are the user's — put each to them and wait.

## Ask with the AskUserQuestion tool

Use `AskUserQuestion` for every frontier question you can. Picking costs the user far less than composing prose, and a question you were able to write options for is a question you were forced to think through first.

Earn the options before you offer them. For each question:

1. **Find the real candidates.** Read the code, check the constraints, look at what the surrounding system already does. Options invented at the keyboard are filler and the user will feel it.
2. **Cut to the live ones.** Keep only answers that are genuinely on the table, mutually exclusive, and lead to materially different work. Two sharp options beat four padded ones. Never add a straw option to make your favourite look good — the user's real answer may well be the one you rank last.
3. **Commit to a recommendation.** Decide what you would actually ship and why. Put it first and end its label with `(Recommended)`.
4. **Spend the `description` on the trade-off.** What the option buys and what it costs — never a restatement of the label.

Tool mechanics worth using well:

- Up to 4 questions per call, 2–4 options each, `header` at most 12 characters.
- "Other" is always offered automatically. Never write your own escape-hatch option.
- `multiSelect: true` when the choices are not mutually exclusive.
- `preview` when the options are concrete artifacts worth comparing side by side — a layout, a schema, a snippet, a directory shape. Single-select only.

If the frontier is wider than four questions, ask it in back-to-back calls within the same round. Don't act between the calls, and don't quietly drop the remainder.

## Falling back to prose

A question earns prose only when you genuinely cannot name two real options — the answer is a number, a name, or a piece of context that lives only in the user's head. Don't reach for it just because enumerating is hard work; that is the work. Then ask like so:

```
❓ **Q1** - **<question title>**: <question body, might be multiple paragraphs>

➡️ <your recommended answer>
```

## Finishing

The session is done when the frontier is empty: every branch of the design tree visited, nothing left silently assumed. Do not act on it until the user confirms you have reached a shared understanding.
