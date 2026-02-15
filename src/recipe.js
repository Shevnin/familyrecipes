import { RECIPES } from "../data/recipes.js";
import { saveId, toast } from "./lib.js";

const params = new URLSearchParams(location.search);
const id = params.get("id") || "1";
const recipe = RECIPES[id];

if (!recipe) {
  document.getElementById("title").textContent = "Рецепт не найден";
} else {
  document.getElementById("title").textContent = recipe.title;
  document.getElementById("meta").textContent = `${recipe.minutes} мин · ${recipe.servings} порц`;

  const ing = document.getElementById("ingredients");
  recipe.ingredients.forEach(x => {
    const li = document.createElement("li");
    li.textContent = x;
    ing.appendChild(li);
  });

  const steps = document.getElementById("steps");
  recipe.steps.forEach(x => {
    const li = document.createElement("li");
    li.textContent = x;
    steps.appendChild(li);
  });
}

document.getElementById("saveBtn").addEventListener("click", () => {
  if (!recipe) return;
  saveId(recipe.id);
  toast("Сохранено");
});

document.getElementById("shareBtn").addEventListener("click", async () => {
  try {
    await navigator.clipboard.writeText(location.href);
    toast("Ссылка скопирована");
  } catch {
    toast("Не удалось скопировать");
  }
});
