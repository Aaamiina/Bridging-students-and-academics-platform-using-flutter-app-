// Mobile/desktop implementation using url_launcher
import 'package:url_launcher/url_launcher.dart';

Future<bool> openSubmissionUrl(String url) async {
  try {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
    return false;
  } catch (_) {
    return false;
  }
}
