import { installSwiper } from "./swiper";
import { installWeui } from "./weui";
import { MPWebDialog } from "./web_dialog";
import { installLazyLoad } from "./lazy_load";

const main = () => {
  installSwiper();
  installWeui();
  installLazyLoad();
  (window as any).MPWebDialog = MPWebDialog;
};

main();
