class GraphqlBody {
  final String? operationName;
  final String query;
  final Map<String, dynamic> variables;

  GraphqlBody({
    required this.operationName,
    required this.query,
    required this.variables,
  });

  Map<String, dynamic> toJson() => {
        'operationName': operationName,
        'query': query,
        'variables': variables,
      };
}
