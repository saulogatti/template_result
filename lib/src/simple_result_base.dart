final class Failure<S, F> extends Result<S, F> {
  final F error;
  const Failure(this.error);
}

/// Uma implementação leve do padrão Result para Clean Architecture.
/// Usa sealed classes do Dart 3 para garantir tratamento exaustivo.
///
/// [S] é o tipo de sucesso [Success.value].
/// [F] é o tipo de falha [Failure.error].
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
  T fold<T extends Object?>({
    required T Function(S value) onSuccess,
    required T Function(F error) onFailure,
  }) {
    return switch (this) {
      Success<S, F>(value: final S v) => onSuccess(v),
      Failure<S, F>(error: final F e) => onFailure(e),
    };
  }

  /// Alias semântico para [fold], mantido por legibilidade e familiaridade
  /// com APIs de pattern matching (por exemplo, `when` em outras linguagens).
  /// Útil especialmente em Widgets/Blocs; em código novo, prefira usar [fold].
  T when<T extends Object>(
    T Function(S value) onSuccess,
    T Function(F error) onFailure,
  ) => fold<T>(onSuccess: onSuccess, onFailure: onFailure);

  /// Utilitário estático para envolver chamadas perigosas (try-catch)
  static Future<Result<T, Exception>> guard<T extends Object>(
    Future<T> Function() block,
  ) async {
    try {
      return Result<T, Exception>.success(await block());
    } on Exception catch (e) {
      return Result<T, Exception>.failure(e);
    } catch (e) {
      return Result<T, Exception>.failure(Exception(e.toString()));
    }
  }

  /// Utilitário assíncrono para criar um Result a partir de uma função assíncrona
  /// que pode lançar uma exceção do tipo F.
  /// O tipo F deve estender Object para garantir que não seja nulo.
  /// Exemplo de uso:
  /// ```dart
  /// final result = await Result.resultAsync<MyType, MyException>(() async {
  ///    // código que pode lançar MyException
  ///  return await fetchData();
  /// });
  /// ```
  static Future<Result<T, F>> resultAsync<T, F extends Object>(
    Future<T> Function() action,
  ) async {
    try {
      final T value = await action();
      return Result<T, F>.success(value);
    } on F catch (e) {
      return Result<T, F>.failure(e);
    }
  }
}

final class Success<S, F> extends Result<S, F> {
  final S value;
  const Success(this.value);
}

extension ResultExtension<S, F> on Result<S, F> {
  /// Flat maps a [Result] to a new [Result] with a different success type.
  Result<R, F> flatMap<R extends Object>(
    Result<R, F> Function(S value) mapper,
  ) {
    return fold<Result<R, F>>(
      onSuccess: mapper,
      onFailure: (F error) => Result<R, F>.failure(error),
    );
  }

  /// Flat maps a [Result] to a new [Result] with a different error type.
  Result<S, R> flatMapError<R>(Result<S, R> Function(F error) mapper) {
    return fold(
      onSuccess: (S value) => Result<S, R>.success(value),
      onFailure: (F error) => mapper(error),
    );
  }

  /// Maps a [Result] to a new [Result] with a different success type.
  Result<R, F> map<R extends Object>(R Function(S value) mapper) {
    return fold(
      onSuccess: (S value) => Result<R, F>.success(mapper(value)),
      onFailure: (F error) => Result<R, F>.failure(error),
    );
  }

  /// Maps a [Result] to a new [Result] with a different error type.
  Result<S, R> mapError<R>(R Function(F error) mapper) {
    return fold(
      onSuccess: (S value) => Result<S, R>.success(value),
      onFailure: (F error) => Result<S, R>.failure(mapper(error)),
    );
  }

  /// Executes a side effect function if the result is a failure.
  Result<S, F> onFailure(void Function(F error) effect) {
    if (this case Failure<S, F>(error: final Object? e)) {
      effect(e as F);
    }
    return this;
  }

  /// Executes a side effect function if the result is a success.
  Result<S, F> onSuccess(void Function(S value) effect) {
    if (this case Success<S, F>(value: final Object v)) {
      effect(v as S);
    }
    return this;
  }
}
