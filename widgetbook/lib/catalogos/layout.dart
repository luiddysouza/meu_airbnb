import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

final layoutFolder = WidgetbookFolder(
  name: 'Layout',
  children: [
    WidgetbookComponent(
      name: 'DsAppBarAdaptativa',
      useCases: [
        WidgetbookUseCase(
          name: 'Default',
          builder: (context) => Scaffold(
            appBar: DsAppBarAdaptativa(
              titulo: context.knobs.string(
                label: 'Título',
                initialValue: 'Hospedagens',
              ),
            ),
            body: const Center(child: Text('Conteúdo da página')),
          ),
        ),
        WidgetbookUseCase(
          name: 'Com ações',
          builder: (context) => Scaffold(
            appBar: DsAppBarAdaptativa(
              titulo: 'Hospedagens',
              acoes: [
                IconButton(onPressed: () {}, icon: const Icon(Icons.add)),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.filter_list),
                ),
              ],
            ),
            body: const Center(child: Text('Conteúdo da página')),
          ),
        ),
      ],
    ),
    WidgetbookComponent(
      name: 'DsScaffoldResponsivo',
      useCases: [
        WidgetbookUseCase(
          name: 'Com sidebar',
          builder: (context) => DsScaffoldResponsivo(
            titulo: 'Hospedagens',
            conteudoSidebar: const Padding(
              padding: EdgeInsets.all(DsEspacamentos.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Filtros', style: DsTipografia.titleMedium),
                  SizedBox(height: DsEspacamentos.md),
                  Text('Período: 20/04 – 25/04'),
                  SizedBox(height: DsEspacamentos.xs),
                  Text('Imóvel: Todos'),
                ],
              ),
            ),
            conteudoPrincipal: ListView.builder(
              padding: const EdgeInsets.all(DsEspacamentos.md),
              itemCount: 3,
              itemBuilder: (_, i) => Padding(
                padding: const EdgeInsets.only(bottom: DsEspacamentos.sm),
                child: DsCardHospedagem(
                  nomeHospede: 'Hóspede ${i + 1}',
                  checkIn: DateTime(2026, 4, 20 + i),
                  checkOut: DateTime(2026, 4, 25 + i),
                  status: StatusHospedagemDs.confirmada,
                  valorTotal: 1000.0 * (i + 1),
                ),
              ),
            ),
          ),
        ),
        WidgetbookUseCase(
          name: 'Sem sidebar',
          builder: (context) => const DsScaffoldResponsivo(
            titulo: 'Hospedagens',
            conteudoPrincipal: Center(child: Text('Conteúdo principal')),
          ),
        ),
        WidgetbookUseCase(
          name: 'Com estado vazio',
          builder: (context) => const DsScaffoldResponsivo(
            titulo: 'Hospedagens',
            conteudoPrincipal: DsEstadoVazio(
              mensagem: 'Nenhuma hospedagem encontrada',
            ),
          ),
        ),
      ],
    ),
  ],
);
