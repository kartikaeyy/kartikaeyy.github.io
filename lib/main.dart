import 'package:flutter/material.dart';

import 'portfolio_app.dart';
import 'theme/edition.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Settle which edition to open on before the first frame, so the site never
  // paints one stock and fades to the other in front of the reader.
  runApp(PortfolioApp(initialMode: await EditionStore.read()));
}
