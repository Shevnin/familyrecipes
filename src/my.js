import { RECIPES } from "../data/recipes.js";
import { getSavedIds, removeId } from "./lib.js";

const ids = getSavedIds();
const list = document.getElementById("list");
const empty = document.getElementById("empty");

if (!ids.length) {
  empty.textContent = "Пока ничего не сохранено. Открой рецепт и нажми “Сохранить”.";
} else {
  empty.textContent = "";
  ids.forEach(id => {
    const r = RECIPES[id];
    if (!r) return;
    const li = document.createElement("li");
    const a = document.createElement("a");
    a.href = `./recipe.html?id=${encodeURIComponent(id)}`;
    a.textContent = r.title;
    li.appendChild(a);

    const btn = document.createElement("button");
    btn.textContent = "Удалить";
    btn.style.marginLeft = "8px";
    btn.addEventListener("click", (e) => {
      e.preventDefault();
      removeId(id);
      location.reload();
    });
    li.appendChild(btn);

    list.appendChild(li);
  });
}
