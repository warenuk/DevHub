import 'package:equatable/equatable.dart';

class RepoLanguageStat extends Equatable {
  const RepoLanguageStat({
    required this.name,
    required this.size,
    required this.ratio,
    this.color,
  });

  final String name;
  final int size;
  final double ratio;
  final String? color;

  String get percentageLabel => '${(ratio * 100).toStringAsFixed(1)}%';

  @override
  List<Object?> get props => [name, size, ratio, color];
}
