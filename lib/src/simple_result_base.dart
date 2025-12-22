final class Failure<S, F> extends Result<S, F> {
  final F error;
  const Failure(this.error);
}

/// Uma implementação leve do padrão Result para Clean Architecture.
/// Usa sealed classes do Dart 3 para garantir tratamento exaustivo.
sealed class Result<S, F> {
  const Result();

  /// Cria um resultado de Falha
  factory Result.failure(F failure) = Failure<S, F>;

  /// Cria um resultado de Sucesso
  factory Result.success(S value) = Success<S, F>;

  /// Retorna o erro ou null se for sucesso
  F? get failureOrNull => isFailure ? (this as Failure<S, F>).error : null;

  /// Retorna o valor de sucesso ou null se for falha
  S? get getOrNull => isSuccess ? (this as Success<S, F>).value : null;

  /// Verifica se é falha
  bool get isFailure => this is Failure<S, F>;

  /// Verifica se é sucesso
  bool get isSuccess => this is Success<S, F>;

  /// O método mágico: obriga a tratar os dois casos.
  /// Ideal para usar nos Widgets/Blocs.
  T fold<T>(T Function(S value) onSuccess, T Function(F error) onFailure) {
    return switch (this) {
      Success(value: final v) => onSuccess(v),
      Failure(error: final e) => onFailure(e),
    };
  }

  /// Utilitário estático para envolver chamadas perigosas (try-catch)
  static Future<Result<T, Exception>> guard<T>(
    Future<T> Function() block,
  ) async {
    try {
      return Result.success(await block());
    } on Exception catch (e) {
      return Result.failure(e);
    } catch (e) {
      return Result.failure(Exception(e.toString()));
    }
  }
}

final class Success<S, F> extends Result<S, F> {
  final S value;
  const Success(this.value);
}
