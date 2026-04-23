abstract final class DsEspacamentos {
  // Escala base (múltiplos de 4)
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
  static const double xxxl = 64;

  // Breakpoints responsivos
  static const double breakpointMobile = 600;
  static const double breakpointTablet = 900;
  static const double breakpointDesktop = 1200;

  // Largura máxima do conteúdo em desktop
  static const double maxWidthConteudo = 1440;

  // Sidebar em desktop
  static const double larguraSidebar = 320;

  // Border radius
  static const double radiusXs = 4;
  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusXl = 24;
  static const double radiusCircular = 999;
}

abstract final class DsAlturas {
  /// Altura mínima padrão dos botões — 48px
  static const double botaoPadrao = 48;

  /// Dimensão do SizedBox do CircularProgressIndicator em botões — 20px
  static const double spinnerBotao = 20;
}
