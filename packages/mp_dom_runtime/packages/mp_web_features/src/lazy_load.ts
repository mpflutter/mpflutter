export const installLazyLoad = () => {
  const script = document.createElement("script");
  script.src = "https://cdn.jsdelivr.net/npm/lazyload@2.0.0-rc.2/lazyload.js";
  document.body.appendChild(script);
};
