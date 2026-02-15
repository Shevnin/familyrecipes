const KEY = "fr_saved_recipe_ids";

export function getSavedIds() {
  try { return JSON.parse(localStorage.getItem(KEY) || "[]"); }
  catch { return []; }
}

export function saveId(id) {
  const ids = new Set(getSavedIds());
  ids.add(id);
  localStorage.setItem(KEY, JSON.stringify([...ids]));
}

export function removeId(id) {
  const ids = new Set(getSavedIds());
  ids.delete(id);
  localStorage.setItem(KEY, JSON.stringify([...ids]));
}

export function toast(text) {
  const el = document.getElementById("toast");
  if (!el) return;
  el.textContent = text;
  el.classList.remove("hidden");
  clearTimeout(window.__toastTimer);
  window.__toastTimer = setTimeout(() => el.classList.add("hidden"), 1400);
}
