import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

final _checkIn = DateTime(2026, 4, 20);
final _checkOut = DateTime(2026, 4, 25);

final exibicaoFolder = WidgetbookFolder(
  name: 'Exibição',
  children: [
    WidgetbookComponent(
      name: 'DsCardHospedagem',
      useCases: [
        WidgetbookUseCase(
          name: 'Confirmada',
          builder: (context) => Padding(
            padding: const EdgeInsets.all(16),
            child: DsCardHospedagem(
              nomeHospede: context.knobs.string(
                label: 'Nome hóspede',
                initialValue: 'Ana Paula Ferreira',
              ),
              checkIn: _checkIn,
              checkOut: _checkOut,
              status: StatusHospedagemDs.confirmada,
              valorTotal: 1850.00,
              nomeImovel: 'Apto Centro SP',
            ),
          ),
        ),
        WidgetbookUseCase(
          name: 'Pendente',
          builder: (context) => Padding(
            padding: const EdgeInsets.all(16),
            child: DsCardHospedagem(
              nomeHospede: 'Carlos Eduardo Santos',
              checkIn: _checkIn,
              checkOut: _checkOut,
              status: StatusHospedagemDs.pendente,
              valorTotal: 620.00,
            ),
          ),
        ),
        WidgetbookUseCase(
          name: 'Cancelada',
          builder: (context) => Padding(
            padding: const EdgeInsets.all(16),
            child: DsCardHospedagem(
              nomeHospede: 'Fernanda Oliveira',
              checkIn: _checkIn,
              checkOut: _checkOut,
              status: StatusHospedagemDs.cancelada,
              valorTotal: 450.00,
            ),
          ),
        ),
        WidgetbookUseCase(
          name: 'Concluída',
          builder: (context) => Padding(
            padding: const EdgeInsets.all(16),
            child: DsCardHospedagem(
              nomeHospede: 'Roberto Alves Nunes',
              checkIn: _checkIn,
              checkOut: _checkOut,
              status: StatusHospedagemDs.concluida,
              valorTotal: 980.00,
            ),
          ),
        ),
        WidgetbookUseCase(
          name: 'Com ações',
          builder: (context) => Padding(
            padding: const EdgeInsets.all(16),
            child: DsCardHospedagem(
              nomeHospede: 'Mariana Costa Lima',
              checkIn: DateTime(2026, 4, 26),
              checkOut: DateTime(2026, 5, 3),
              status: StatusHospedagemDs.confirmada,
              valorTotal: 4200.00,
              nomeImovel: 'Casa Praia Ubatuba',
              aoEditar: () {},
              aoDeletar: () {},
            ),
          ),
        ),
      ],
    ),
    WidgetbookComponent(
      name: 'DsListTile',
      useCases: [
        WidgetbookUseCase(
          name: 'Default',
          builder: (context) => const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: DsListTile(titulo: 'Apto Centro SP'),
          ),
        ),
        WidgetbookUseCase(
          name: 'Com subtítulo',
          builder: (context) => const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: DsListTile(
              titulo: 'Apto Centro SP',
              subtitulo: 'Rua das Flores, 123 — São Paulo, SP',
            ),
          ),
        ),
        WidgetbookUseCase(
          name: 'Com leading e trailing',
          builder: (context) => const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: DsListTile(
              titulo: 'Apto Centro SP',
              subtitulo: 'São Paulo, SP',
              leading: Icon(Icons.home_outlined),
              trailing: Icon(Icons.chevron_right),
            ),
          ),
        ),
        WidgetbookUseCase(
          name: 'Selecionado',
          builder: (context) => const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: DsListTile(titulo: 'Apto Centro SP', selecionado: true),
          ),
        ),
        WidgetbookUseCase(
          name: 'Desabilitado',
          builder: (context) => const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: DsListTile(titulo: 'Apto Centro SP', habilitado: false),
          ),
        ),
      ],
    ),
    WidgetbookComponent(
      name: 'DsEstadoVazio',
      useCases: [
        WidgetbookUseCase(
          name: 'Default',
          builder: (context) =>
              const DsEstadoVazio(mensagem: 'Nenhuma hospedagem encontrada'),
        ),
        WidgetbookUseCase(
          name: 'Com ação',
          builder: (context) => DsEstadoVazio(
            mensagem: 'Nenhuma hospedagem encontrada',
            rotuloAcao: 'Adicionar hospedagem',
            aoAcionar: () {},
          ),
        ),
        WidgetbookUseCase(
          name: 'Ícone customizado',
          builder: (context) => const DsEstadoVazio(
            mensagem: 'Nenhum filtro aplicado',
            icone: Icons.filter_list_off,
          ),
        ),
      ],
    ),
    WidgetbookComponent(
      name: 'DsCarregando',
      useCases: [
        WidgetbookUseCase(
          name: 'Default',
          builder: (context) => const DsCarregando(),
        ),
        WidgetbookUseCase(
          name: 'Com mensagem',
          builder: (context) =>
              const DsCarregando(mensagem: 'Carregando hospedagens...'),
        ),
      ],
    ),
    WidgetbookComponent(
      name: 'DsSnackbar',
      useCases: [
        WidgetbookUseCase(
          name: 'Sucesso',
          builder: (context) => Center(
            child: DsBotaoPrimario(
              rotulo: 'Mostrar Sucesso',
              aoTocar: () => DsSnackbar.sucesso(
                context,
                mensagem: 'Hospedagem salva com sucesso!',
              ),
            ),
          ),
        ),
        WidgetbookUseCase(
          name: 'Erro',
          builder: (context) => Center(
            child: DsBotaoPrimario(
              rotulo: 'Mostrar Erro',
              aoTocar: () => DsSnackbar.erro(
                context,
                mensagem: 'Erro ao salvar hospedagem.',
              ),
            ),
          ),
        ),
        WidgetbookUseCase(
          name: 'Info',
          builder: (context) => Center(
            child: DsBotaoPrimario(
              rotulo: 'Mostrar Info',
              aoTocar: () => DsSnackbar.info(
                context,
                mensagem: 'Operação em andamento...',
              ),
            ),
          ),
        ),
      ],
    ),
    WidgetbookComponent(
      name: 'DsDialogConfirmacao',
      useCases: [
        WidgetbookUseCase(
          name: 'Padrão',
          builder: (context) => Center(
            child: DsBotaoPrimario(
              rotulo: 'Abrir confirmação',
              aoTocar: () => DsDialogConfirmacao.mostrar(
                context,
                titulo: 'Confirmar ação',
                mensagem: 'Tem certeza que deseja continuar?',
              ),
            ),
          ),
        ),
        WidgetbookUseCase(
          name: 'Destrutivo',
          builder: (context) => Center(
            child: DsBotaoPrimario(
              rotulo: 'Excluir hospedagem',
              aoTocar: () => DsDialogConfirmacao.mostrar(
                context,
                titulo: 'Excluir hospedagem',
                mensagem:
                    'Deseja excluir a hospedagem de João Silva? '
                    'Essa ação não pode ser desfeita.',
                rotuloConfirmar: 'Excluir',
                destrutivo: true,
              ),
            ),
          ),
        ),
      ],
    ),
  ],
);
