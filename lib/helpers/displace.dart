List<T> displace<T>(List<T> arr, int index) => [
      ...arr.sublist(index),
      ...arr.sublist(0, index),
    ];

List<T> displaceWithoutIndex<T>(List<T> arr, int index) => [
      ...arr.sublist(index + 1),
      ...arr.sublist(0, index),
    ];
