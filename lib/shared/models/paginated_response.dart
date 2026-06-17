class PaginatedResponse<T> {
  final List<T> data;
  final int total;
  final int page;
  final int limit;

  const PaginatedResponse({
    required this.data,
    required this.total,
    required this.page,
    required this.limit,
  });

  int get totalPages =>
      (total / limit).ceil();

  bool get hasNextPage =>
      page < totalPages;

  bool get hasPreviousPage =>
      page > 1;
}