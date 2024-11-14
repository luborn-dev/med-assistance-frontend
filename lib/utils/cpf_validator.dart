class CPFValidator {
  static bool validarCPF(String cpf) {
    cpf = cpf.replaceAll(RegExp(r'\D'), '');

    if (cpf.length != 11 || RegExp(r'^(\d)\1{10}$').hasMatch(cpf)) {
      return false;
    }

    int soma = 0;
    for (int i = 0; i < 9; i++) {
      soma += int.parse(cpf[i]) * (10 - i);
    }
    int primeiroDigitoVerificador = (soma * 10) % 11;
    if (primeiroDigitoVerificador == 10) primeiroDigitoVerificador = 0;

    if (primeiroDigitoVerificador != int.parse(cpf[9])) {
      return false;
    }

    soma = 0;
    for (int i = 0; i < 10; i++) {
      soma += int.parse(cpf[i]) * (11 - i);
    }
    int segundoDigitoVerificador = (soma * 10) % 11;
    if (segundoDigitoVerificador == 10) segundoDigitoVerificador = 0;

    if (segundoDigitoVerificador != int.parse(cpf[10])) {
      return false;
    }

    return true;
  }
}
