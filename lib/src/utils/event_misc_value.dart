class EventMiscValue {
  String _miscellaneous = '';

  EventMiscValue addValue(List<String> key, List<dynamic> value) {
    int length = key.length;

    if (0 < length) {
      if (key[0].isEmpty || value[0] == null) {
        return this;
      }
    }
    if (1 < length) {
      if (key[1].isEmpty || value[1] == null) {
        return this;
      }
    }
    if (2 < length) {
      if (key[2].isEmpty || value[2] == null) {
        return this;
      }
    }

    if (0 < length) {
      if (_miscellaneous.isEmpty) {
        _miscellaneous += '${key[0]}:${value[0]}';
      } else {
        _miscellaneous += '::${key[0]}:${value[0]}';
      }
    }
    if (1 < length) {
      if (_miscellaneous.isEmpty) {
        _miscellaneous += '${key[1]}:${value[1]}';
      } else {
        _miscellaneous += '::${key[1]}:${value[1]}';
      }
    }
    if (2 < length) {
      if (_miscellaneous.isEmpty) {
        _miscellaneous += '${key[2]}:${value[2]}';
      } else {
        _miscellaneous += '::${key[2]}:${value[2]}';
      }
    }

    return this;
  }

  String build() {
    return _miscellaneous;
  }
}
