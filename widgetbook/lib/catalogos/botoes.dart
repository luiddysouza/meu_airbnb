import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

final botoesFolder = WidgetbookFolder(
  name: 'Botões',
  children: [
    WidgetbookComponent(
      name: 'DsBotaoPrimario',
      useCases: [
        WidgetbookUseCase(
          name: 'Default',
          builder: (context) => Padding(
            padding: const EdgeInsets.all(16),
            child: DsBotaoPrimario(
              rotulo: context.knobs.string(
                label: 'Rótulo',
                initialValue: 'Salvar',
              ),
              aoTocar: () {},
            ),
          ),
        ),
        WidgetbookUseCase(
          name: 'Com ícone',
          builder: (context) => const Padding(
            padding: EdgeInsets.all(16),
            child: DsBotaoPrimario(
              rotulo: 'Adicionar',
              icone: Icons.add,
              aoTocar: null,
            ),
          ),
        ),
        WidgetbookUseCase(
          name: 'Carregando',
          builder: (context) => const Padding(
            padding: EdgeInsets.all(16),
            child: DsBotaoPrimario(rotulo: 'Salvar', carregando: true),
          ),
        ),
        WidgetbookUseCase(
          name: 'Desabilitado',
          builder: (context) => const Padding(
            padding: EdgeInsets.all(16),
            child: DsBotaoPrimario(rotulo: 'Salvar'),
          ),
        ),
      ],
    ),
    WidgetbookComponent(
      name: 'DsBotaoSecundario',
      useCases: [
        WidgetbookUseCase(
          name: 'Default',
          builder: (context) => Padding(
            padding: const EdgeInsets.all(16),
            child: DsBotaoSecundario(
              rotulo: context.knobs.string(
                label: 'Rótulo',
                initialValue: 'Cancelar',
              ),
              aoTocar: () {},
            ),
          ),
        ),
        WidgetbookUseCase(
          name: 'Com ícone',
          builder: (context) => const Padding(
            padding: EdgeInsets.all(16),
            child: DsBotaoSecundario(
              rotulo: 'Editar',
              icone: Icons.edit,
              aoTocar: null,
            ),
          ),
        ),
        WidgetbookUseCase(
          name: 'Carregando',
          builder: (context) => const Padding(
            padding: EdgeInsets.all(16),
            child: DsBotaoSecundario(rotulo: 'Cancelar', carregando: true),
          ),
        ),
      ],
    ),
    WidgetbookComponent(
      name: 'DsBotaoIcone',
      useCases: [
        WidgetbookUseCase(
          name: 'Default',
          builder: (context) =>
              const Center(child: DsBotaoIcone(icone: Icons.delete_outline)),
        ),
        WidgetbookUseCase(
          name: 'Com tooltip',
          builder: (context) => const Center(
            child: DsBotaoIcone(
              icone: Icons.delete_outline,
              tooltip: 'Excluir',
            ),
          ),
        ),
        WidgetbookUseCase(
          name: 'Carregando',
          builder: (context) => const Center(
            child: DsBotaoIcone(icone: Icons.delete_outline, carregando: true),
          ),
        ),
      ],
    ),
  ],
);
