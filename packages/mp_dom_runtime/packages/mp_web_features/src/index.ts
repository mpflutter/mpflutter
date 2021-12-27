import { installSwiper } from "./swiper";
import { installWeui } from "./weui";
import { MPWebDialog } from "./web_dialog";
import { installLazyLoad } from "./lazy_load";
import { installNoneScaleFont } from "./none_scale_font";
import * as preactCompat from "preact/compat";

const main = () => {
  installNoneScaleFont();
  installSwiper();
  installWeui();
  installLazyLoad();
  (window as any).MPWebDialog = MPWebDialog;
  (window as any).React = preactCompat;
  (window as any).ReactDOM = preactCompat;
};

main();
