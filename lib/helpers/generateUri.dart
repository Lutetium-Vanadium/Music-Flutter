Uri generateUri(String base, Map<String, String> params) {
  if (params.isNotEmpty) base += "?";

  List<String> paramList = [];
  params.forEach((key, value) {
    paramList.add("$key=$value");
  });

  base += paramList.join("&");

  return Uri.parse(base);
}
