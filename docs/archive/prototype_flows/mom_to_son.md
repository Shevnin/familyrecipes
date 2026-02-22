# PoC: Mom → Son recipe handoff

Goal: prove E2E flow **create → share → accept → cook → feedback → improve**.

## Roles
- Mom = author (create/edit, receives feedback)
- Son = recipient (accept via link, cook, sends feedback)

## Minimal data
- Recipe {id, title, ingredients[], steps[]}
- Ingredient {name, amount?, unit?}
- Step {action, done_marker, timer_s?}
- InviteLink {token, recipe_id}
- CookAttempt {id, recipe_id, user_id, started_at, finished_at}
- Feedback {attempt_id, success, hard_step_idx?, comment?}

## Flow
1) Mom: create recipe (title + ingredients + steps; each step requires **action + done_marker**; timer optional) → Save
2) Mom: Share → Generate link → Copy
3) Son: Open link → Add recipe → Start cooking
4) Son: Cook mode (1 step/screen: action + done_marker + optional timer; Back/Next)
5) Son: Feedback (success Yes/No + hardest step + 1-line comment) → Send
6) Mom: View feedback → Edit highlighted step → Save

## PoC success
- Recipe saved (≥1 ingredient, ≥1 step with done_marker).
- Link opens; Son can add recipe.
- Son completes cook + sends feedback.
- Mom sees feedback and updates a step.

## Out of scope
- public catalog/search/feed
- co-editing
- complex permissions
- AI/autocomplete
- broad UGC moderation