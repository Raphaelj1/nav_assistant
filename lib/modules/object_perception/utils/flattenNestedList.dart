import 'dart:typed_data';

Float32List flattenNestedList(dynamic nested) {
  final List<double> flatDoubles = [];
  _flattenRecursive(nested, flatDoubles);
  return Float32List.fromList(flatDoubles);
}

void _flattenRecursive(dynamic node, List<double> result) {
  if (node is List) {
    for (final item in node) {
      _flattenRecursive(item, result);
    }
  } else if (node is num) {
    result.add(node.toDouble());
  } else {
    // Skip non-numeric (shouldn't happen for your tensors)
    throw ArgumentError('Non-numeric node in tensor: $node');
  }
}