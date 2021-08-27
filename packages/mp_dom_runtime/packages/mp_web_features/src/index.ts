import { installSwiper } from "./swiper";
import { installWeui } from "./weui";
import { MPWebDialog } from "./web_dialog";

const main = () => {
  installSwiper();
  installWeui();
  (window as any).MPWebDialog = MPWebDialog;
};

main();
