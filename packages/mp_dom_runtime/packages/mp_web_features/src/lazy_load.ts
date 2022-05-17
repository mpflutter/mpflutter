export const installLazyLoad = () => {
  const script = document.createElement("script");
  script.src = "https://lf26-cdn-tos.bytecdntp.com/cdn/expire-1-M/lazyload/2.0.3/lazyload-min.js";
  document.body.appendChild(script);
};
