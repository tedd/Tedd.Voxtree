const reducedMotion = window.matchMedia(
  "(prefers-reduced-motion: reduce)",
).matches;

if (reducedMotion || !("IntersectionObserver" in window)) {
  document
    .querySelectorAll(".reveal")
    .forEach((element) => element.classList.add("visible"));
} else {
  const observer = new IntersectionObserver(
    (entries) => {
      for (const entry of entries) {
        if (!entry.isIntersecting) continue;
        entry.target.classList.add("visible");
        observer.unobserve(entry.target);
      }
    },
    { threshold: 0.12 },
  );

  document
    .querySelectorAll(".reveal")
    .forEach((element) => observer.observe(element));
}

document.querySelectorAll("[data-copy]").forEach((button) => {
  button.addEventListener("click", async () => {
    const originalLabel = button.textContent;

    try {
      await navigator.clipboard.writeText(button.dataset.copy);
      button.textContent = "Copied";
      button.classList.add("copied");
    } catch {
      button.textContent = "Select";
      window.getSelection()?.selectAllChildren(button.previousElementSibling);
    }

    window.setTimeout(() => {
      button.textContent = originalLabel;
      button.classList.remove("copied");
    }, 1800);
  });
});
