import { installSwiper } from "./swiper";
import { installWeui } from "./weui";
import { MPWebDialog } from "./web_dialog";
import { installLazyLoad } from "./lazy_load";
import { installNoneScaleFont } from "./none_scale_font";

const main = () => {
  installNoneScaleFont();
  installSwiper();
  installWeui();
  installLazyLoad();
  (window as any).MPWebDialog = MPWebDialog;
};

main();
