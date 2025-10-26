/// Servicio centralizado de validación
class Validators {
  // Regex para email
  static final _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  // Regex para contraseña fuerte
  static final _strongPasswordRegex = RegExp(
    r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$',
  );

  /// Validar email
  /// Retorna null si es válido, mensaje de error si no
  static String? validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return 'El email es requerido';
    }

    email = email.trim();

    if (email.length < 5) {
      return 'El email es muy corto';
    }

    if (email.length > 254) {
      return 'El email es muy largo';
    }

    if (!_emailRegex.hasMatch(email)) {
      return 'Ingresa un email válido (ej: usuario@ejemplo.com)';
    }

    return null;
  }

  /// Validar contraseña básica (mínimo 8 caracteres)
  static String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'La contraseña es requerida';
    }

    if (password.length < 8) {
      return 'La contraseña debe tener al menos 8 caracteres';
    }

    if (password.length > 128) {
      return 'La contraseña es muy larga';
    }

    return null;
  }

  /// Validar contraseña fuerte
  /// Requiere: mayúscula, minúscula, número y símbolo
  static String? validateStrongPassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'La contraseña es requerida';
    }

    if (password.length < 8) {
      return 'La contraseña debe tener al menos 8 caracteres';
    }

    if (password.length > 128) {
      return 'La contraseña es muy larga';
    }

    if (!_strongPasswordRegex.hasMatch(password)) {
      return 'La contraseña debe contener mayúscula, minúscula, número y símbolo (@\$!%*?&)';
    }

    return null;
  }

  /// Validar que dos contraseñas coincidan
  static String? validatePasswordMatch(String? password1, String? password2) {
    if (password1 != password2) {
      return 'Las contraseñas no coinciden';
    }
    return null;
  }

  /// Validar nombre
  static String? validateName(String? name) {
    if (name == null || name.isEmpty) {
      return 'El nombre es requerido';
    }

    name = name.trim();

    if (name.length < 2) {
      return 'El nombre debe tener al menos 2 caracteres';
    }

    if (name.length > 100) {
      return 'El nombre es muy largo';
    }

    // Verificar que no contenga números
    if (RegExp(r'\d').hasMatch(name)) {
      return 'El nombre no puede contener números';
    }

    return null;
  }

  /// Validar que no esté vacío
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName es requerido';
    }
    return null;
  }

  /// Validar longitud mínima
  static String? validateMinLength(String? value, int minLength, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName es requerido';
    }

    if (value.length < minLength) {
      return '$fieldName debe tener al menos $minLength caracteres';
    }

    return null;
  }

  /// Validar longitud máxima
  static String? validateMaxLength(String? value, int maxLength, String fieldName) {
    if (value != null && value.length > maxLength) {
      return '$fieldName no puede exceder $maxLength caracteres';
    }
    return null;
  }

  /// Obtener fortaleza de contraseña (0-4)
  static int getPasswordStrength(String password) {
    int strength = 0;

    if (password.length >= 8) strength++;
    if (password.length >= 12) strength++;
    if (RegExp(r'[a-z]').hasMatch(password) && RegExp(r'[A-Z]').hasMatch(password)) strength++;
    if (RegExp(r'\d').hasMatch(password)) strength++;
    if (RegExp(r'[@$!%*?&]').hasMatch(password)) strength++;

    return strength > 4 ? 4 : strength;
  }

  /// Obtener descripción de fortaleza
  static String getPasswordStrengthDescription(int strength) {
    switch (strength) {
      case 0:
      case 1:
        return 'Muy débil';
      case 2:
        return 'Débil';
      case 3:
        return 'Media';
      case 4:
        return 'Fuerte';
      default:
        return 'Desconocida';
    }
  }
}
