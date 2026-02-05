// Web implementation: open URL in new tab (avoids url_launcher MissingPluginException on web)
import 'dart:html' as html;

Future<bool> openSubmissionUrl(String url) async {
  try {
    html.window.open(url, '_blank');
    return true;
  } catch (_) {
    return false;
  }
}
