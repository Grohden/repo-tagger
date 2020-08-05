import 'dart:html' as html;

void replaceUrl(String url) {
  html.window.location.href = url;
}

void openUrlInNewTab(String url) {
  html.window.open(url, '_blank');
}