export const installSwiper = () => {
  const script = document.createElement("script");
  script.src = "https://lf6-cdn-tos.bytecdntp.com/cdn/expire-1-M/Swiper/6.8.1/swiper-bundle.min.js";
  document.body.appendChild(script);
  const cssStyle = document.createElement("link");
  cssStyle.rel = "stylesheet";
  cssStyle.href = "https://lf6-cdn-tos.bytecdntp.com/cdn/expire-1-M/Swiper/6.8.1/swiper-bundle.min.css";
  document.head.appendChild(cssStyle);
  const patchStyle = document.createElement("style");
  patchStyle.innerHTML = `
.swiper-container {
  z-index: unset;
}

.swiper-wrapper {
  z-index: unset;
}
  `;
  document.head.appendChild(patchStyle);
};
