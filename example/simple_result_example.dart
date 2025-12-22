import 'package:simple_result/simple_result.dart';

void main() async {
  print('=== Simple Result Examples ===\n');

  // Exemplo 1: Básico
  basicExample();

  // Exemplo 2: Usando fold
  foldExample();

  // Exemplo 3: Pattern matching
  patternMatchingExample();

  // Exemplo 4: Guard
  await guardExample();

  // Exemplo 5: Caso de uso real
  await realWorldExample();
}

void basicExample() {
  print('1. Exemplo Básico:');

  final success = Result<int, String>.success(42);
  final failure = Result<int, String>.failure('Erro de exemplo');

  print('Success isSuccess: ${success.isSuccess}');
  print('Success value: ${success.getOrNull}');

  print('Failure isFailure: ${failure.isFailure}');
  print('Failure error: ${failure.failureOrNull}\n');
}

// Simulação de um repositório
Future<Result<User, String>> fetchUser(int id) async {
  await Future.delayed(Duration(milliseconds: 200));

  if (id > 0) {
    return Result.success(
      User(id: id, name: 'João Silva', email: 'joao@example.com'),
    );
  } else {
    return Result.failure('ID inválido: $id');
  }
}

void foldExample() {
  print('2. Usando fold():');

  final result = Result<int, String>.success(10);

  final message = result.fold(
    (value) => 'Operação retornou: $value',
    (error) => 'Erro: $error',
  );

  print(message);

  // Transformação de tipos
  final doubled = result.fold((value) => value * 2, (error) => 0);

  print('Valor dobrado: $doubled\n');
}

Future<void> guardExample() async {
  print('4. Usando Result.guard():');

  // Operação que pode falhar
  final result1 = await Result.guard(() async {
    await Future.delayed(Duration(milliseconds: 100));
    return 'Operação bem-sucedida';
  });

  print('Guard success: ${result1.getOrNull}');

  // Operação que lança exceção
  final result2 = await Result.guard(() async {
    throw Exception('Algo deu errado');
  });

  print('Guard failure: ${result2.failureOrNull}\n');
}

void patternMatchingExample() {
  print('3. Pattern Matching:');

  final results = [
    Result<String, int>.success('Sucesso!'),
    Result<String, int>.failure(404),
  ];

  for (final result in results) {
    final message = switch (result) {
      Success(value: final v) => 'Recebido: $v',
      Failure(error: final e) => 'Código de erro: $e',
    };
    print(message);
  }
  print('');
}

Future<void> realWorldExample() async {
  print('5. Exemplo de Caso de Uso Real:');

  // Simulação de busca de usuário
  final userId = 123;
  final result = await fetchUser(userId);

  result.fold(
    (user) {
      print('✓ Usuário encontrado:');
      print('  Nome: ${user.name}');
      print('  Email: ${user.email}');
    },
    (error) {
      print('✗ Falha ao buscar usuário: $error');
    },
  );
}

// Model de exemplo
class User {
  final int id;
  final String name;
  final String email;

  User({required this.id, required this.name, required this.email});
}
