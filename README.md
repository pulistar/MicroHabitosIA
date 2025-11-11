# MicroHabits AI

Una aplicación móvil inteligente para construir y mantener microhábitos con el poder de la inteligencia artificial. Transforma tu vida un pequeño paso a la vez.

## ¿Qué es MicroHabits AI?

MicroHabits AI es una app que te ayuda a crear hábitos sostenibles a través de:
- **Coach IA personalizado** que te motiva y guía usando Google Gemini
- **Seguimiento visual** de tu progreso con gráficos interactivos
- **Sistema de ranking** para competir sanamente con otros usuarios
- **Notificaciones inteligentes** que se adaptan a tu rutina
- **Modo offline** para que nunca pierdas tu racha

## Características principales

### Gestión de Microhábitos
- Crea hábitos pequeños y alcanzables
- Marca completaciones diarias
- Visualiza tu progreso con gráficos de FL Chart
- Exporta reportes en PDF

### Coach IA Personalizado
- Análisis inteligente de tu progreso
- Sugerencias personalizadas de hábitos
- Mensajes motivacionales adaptativos
- Powered by Google Gemini AI

### Gamificación
- Sistema de puntos y rachas
- Ranking semanal con otros usuarios
- Compite de forma saludable
- Visualiza tu posición en tiempo real

### Notificaciones Inteligentes
- Recordatorios personalizables
- Mensajes motivacionales generados por IA
- Notificaciones diarias, semanales o personalizadas
- Funciona incluso después de reiniciar el dispositivo

### Sincronización y Offline
- Funciona sin conexión a internet
- Sincronización automática con Supabase
- Tus datos siempre seguros en la nube
- Almacenamiento local con Hive

## Arquitectura

El proyecto sigue **Clean Architecture** con el patrón **BLoC**:

```
lib/
├── core/                    # Funcionalidades compartidas
├── features/               # Características por módulo
│   ├── authentication/     # Login con Google
│   ├── microhabits/        # CRUD de hábitos
│   ├── ai_coach/           # Coach IA con Gemini
│   ├── ranking/            # Sistema de puntos
│   └── notifications/      # Notificaciones
└── injection/              # Inyección de dependencias
```

## Stack Tecnológico

### Frontend
- **Flutter** - Framework multiplataforma
- **flutter_bloc** - Gestión de estado
- **fl_chart** - Gráficos interactivos
- **flutter_local_notifications** - Notificaciones locales

### Backend & IA
- **Supabase** - Backend as a Service (Auth, Database, Storage)
- **Google Gemini AI** - Inteligencia artificial para el coach
- **Hive** - Base de datos local NoSQL

### Arquitectura & Utilidades
- **get_it** - Inyección de dependencias
- **dartz** - Programación funcional y manejo de errores
- **equatable** - Comparación de objetos
- **uuid** - Generación de IDs únicos

## Instalación

### Prerrequisitos
- Flutter SDK (3.9.2 o superior)
- Cuenta de Supabase
- API Key de Google Gemini

### Pasos

1. **Clona el repositorio**
```bash
git clone https://github.com/tu-usuario/microhabits_ai.git
cd microhabits_ai
```

2. **Instala las dependencias**
```bash
flutter pub get
```

3. **Configura las variables de entorno**

Crea un archivo `.env` basado en `.env.example` con tus credenciales:
```env
SUPABASE_URL=https://tu-proyecto.supabase.co
SUPABASE_ANON_KEY=tu-anon-key-aqui
GEMINI_API_KEY=tu-api-key-gemini
```

4. **Ejecuta la app**
```bash
flutter run
```

## Plataformas soportadas

- Android
- iOS
- Web (en desarrollo)
- Windows (en desarrollo)
- macOS (en desarrollo)
- Linux (en desarrollo)

## Comandos útiles

```bash
flutter pub get                    # Instalar dependencias
flutter run                        # Ejecutar app
flutter build apk --release        # Crear APK
flutter test                       # Ejecutar tests
```


## Autor

**Pulistar**

