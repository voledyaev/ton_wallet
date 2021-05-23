import 'package:auto_route/auto_route.dart';

import '../loading_page/loading_page.dart';
import '../phrase_input_page/phrase_input_page.dart';
import '../phrase_output_page/phrase_output_page.dart';
import '../wallet_address_scan_page/wallet_address_scan_page.dart';
import '../wallet_creation_page/wallet_creation_page.dart';
import '../wallet_info_page/wallet_info_page.dart';
import '../wallet_overview_page/wallet_overview_page.dart';
import '../wallet_receive_page/wallet_receive_page.dart';
import '../wallet_selection_page/wallet_selection_page.dart';
import '../wallet_send_page/wallet_send_page.dart';

@MaterialAutoRouter(
  replaceInRouteName: 'Page,Route',
  routes: <AutoRoute>[
    AutoRoute(
      page: LoadingPage,
      initial: true,
    ),
    AutoRoute(
      name: "WalletCreationRouter",
      page: WalletCreationPage,
      children: [
        AutoRoute(page: WalletSelectionPage, initial: true),
        AutoRoute(page: PhraseInputPage),
        AutoRoute(page: PhraseOutputPage),
      ],
    ),
    AutoRoute(
      name: "WalletInfoRouter",
      page: WalletInfoPage,
      children: [
        AutoRoute(page: WalletOverviewPage, initial: true),
        AutoRoute(page: WalletReceivePage),
        AutoRoute(page: WalletSendPage),
        AutoRoute<String>(page: WalletAddressScanPage),
      ],
    ),
  ],
)
class $AppRouter {}
