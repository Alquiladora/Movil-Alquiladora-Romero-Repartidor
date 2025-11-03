// Base del backend (cámbiala cuando sea necesario)
const String baseUrl = 'https://alquiladora-romero-server.onrender.com';

// Helper mínimo para armar URLs
// Usa api('/api/usuarios/login-movil') por ejemplo.
Uri api(String path) => Uri.parse('$baseUrl$path');
