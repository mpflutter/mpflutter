export const installSwiper = () => {
  const script = document.createElement("script");
  script.src = "https://cdn.jsdelivr.net/npm/swiper@6.8.1/swiper-bundle.min.js";
  document.body.appendChild(script);
  const cssStyle = document.createElement("link");
  cssStyle.rel = "stylesheet";
  cssStyle.href =
    "https://cdn.jsdelivr.net/npm/swiper@6.8.1/swiper-bundle.min.css";
  document.head.appendChild(cssStyle);
};
