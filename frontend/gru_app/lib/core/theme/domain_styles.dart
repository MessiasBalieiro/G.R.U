import 'package:flutter/material.dart';

import '../../data/models/lixeira_model.dart';
import '../../data/models/residuo_model.dart';
import 'app_colors.dart';

/// Cor e ícone de cada tipo de resíduo.
extension TipoResiduoStyle on TipoResiduo {
  Color get cor {
    switch (this) {
      case TipoResiduo.plastico:
        return AppColors.orange;
      case TipoResiduo.vidro:
        return AppColors.green;
      case TipoResiduo.metal:
        return AppColors.darkLight;
      case TipoResiduo.papel:
        return AppColors.sky;
    }
  }

  IconData get icone {
    switch (this) {
      case TipoResiduo.plastico:
        return Icons.local_drink_rounded;
      case TipoResiduo.vidro:
        return Icons.wine_bar_rounded;
      case TipoResiduo.metal:
        return Icons.hardware_rounded;
      case TipoResiduo.papel:
        return Icons.description_rounded;
    }
  }
}

/// Cor de severidade da ocupação (verde → âmbar → laranja → vermelho).
Color corDoStatus(StatusLixeira s) {
  switch (s) {
    case StatusLixeira.vazia:
    case StatusLixeira.baixa:
      return AppColors.green;
    case StatusLixeira.media:
      return AppColors.amber;
    case StatusLixeira.alta:
      return AppColors.orange;
    case StatusLixeira.cheia:
      return AppColors.danger;
  }
}
