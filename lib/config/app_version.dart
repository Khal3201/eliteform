// ─── lib/config/app_version.dart ─────────────────────────────────────────────
// Control de versiones de EliteForm.
//
// CÓMO ACTUALIZAR:
//   1. Sube kVersionActual cuando publiques una nueva versión.
//   2. Sube kVersionMinima solo cuando la versión anterior sea incompatible
//      (cambios de estructura en Firestore, modelos, etc.).
//   3. El documento en Firestore "config/version" se actualiza desde el
//      panel admin o manualmente en Firebase Console con los campos:
//        version_minima: "1.1.0"
//        mensaje: "Texto que ve el usuario"
//        
// ─────────────────────────────────────────────────────────────────────────────

// ══════════════════════════════════════════════════════════════════════════════
// ▼▼▼  EDITA SOLO ESTOS VALORES CUANDO HAGAS UNA NUEVA VERSIÓN  ▼▼▼
// ══════════════════════════════════════════════════════════════════════════════

/// Versión actual de esta build. Formato: MAYOR.MENOR.PARCHE
const String kVersionActual = '1.17.0';

// ══════════════════════════════════════════════════════════════════════════════
// ▲▲▲  FIN DE LA ZONA EDITABLE  ▲▲▲
// ══════════════════════════════════════════════════════════════════════════════

/// Compara dos versiones semánticas. Devuelve true si [a] >= [b].
bool versionMayorOIgual(String a, String b) {
  final pa = a.split('.').map(int.tryParse).toList();
  final pb = b.split('.').map(int.tryParse).toList();
  for (int i = 0; i < 3; i++) {
    final va = (i < pa.length ? pa[i] : 0) ?? 0;
    final vb = (i < pb.length ? pb[i] : 0) ?? 0;
    if (va > vb) return true;
    if (va < vb) return false;
  }
  return true; // son iguales
}
