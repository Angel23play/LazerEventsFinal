class Validators {
  static String? requiredField(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Este campo es obligatorio";
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return "Correo requerido";
    }
    final regex = RegExp(r"^[\w\.-]+@[\w\.-]+\.\w+$");
    if (!regex.hasMatch(value)) {
      return "Correo inválido";
    }
    return null;
  }

  static String? number(String? value) {
    if (value == null || value.isEmpty) {
      return "Este valor es obligatorio";
    }
    if (int.tryParse(value) == null) {
      return "Debe ser un número";
    }
    return null;
  }

  static String? minLength(String? value, int min) {
    if (value == null || value.isEmpty) {
      return "Campo obligatorio";
    }
    if (value.length < min) {
      return "Debe tener al menos $min caracteres";
    }
    return null;
  }
}
