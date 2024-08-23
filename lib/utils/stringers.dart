String newlineJoin(List<Object> items, {String padding = ''}) {
  return items.map((item) => '$padding$item').join('\n');
}
