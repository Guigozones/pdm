import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_theme.dart';
import '../widgets/index.dart';
import '../models/route_model.dart';
import '../models/vehicle_model.dart';
import '../services/route_service.dart';
import '../services/vehicle_service.dart';

class RoutesScreen extends StatefulWidget {
  const RoutesScreen({Key? key}) : super(key: key);

  @override
  State<RoutesScreen> createState() => _RoutesScreenState();
}

class _RoutesScreenState extends State<RoutesScreen> {
  final RouteService _routeService = RouteService();
  final VehicleService _vehicleService = VehicleService();
  final _user = FirebaseAuth.instance.currentUser;

  final originController = TextEditingController();
  final destinationController = TextEditingController();
  final valueController = TextEditingController();
  final capacityController = TextEditingController();
  final availableSeatsController = TextEditingController();
  final durationController = TextEditingController();
  final timeslotsController = TextEditingController();
  final tripsPerWeekController = TextEditingController();
  String selectedStatus = 'Ativa';
  List<String> selectedWeekDays = [];
  VehicleModel? selectedVehicle;

  static const List<String> allWeekDays = [
    'Seg',
    'Ter',
    'Qua',
    'Qui',
    'Sex',
    'Sab',
    'Dom',
  ];

  @override
  void dispose() {
    originController.dispose();
    destinationController.dispose();
    valueController.dispose();
    capacityController.dispose();
    availableSeatsController.dispose();
    durationController.dispose();
    timeslotsController.dispose();
    tripsPerWeekController.dispose();
    super.dispose();
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Ativa':
        return const Color(0xFF10B981);
      case 'Pausada':
        return const Color(0xFFFB923C);
      case 'Inativa':
        return const Color(0xFFEF4444);
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null) {
      return const Center(child: Text('Usuário não autenticado'));
    }

    return StreamBuilder<QuerySnapshot>(
      stream: _routeService.watchRoutesByOwner(_user.uid),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Erro ao carregar rotas: ${snapshot.error}'),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final routes = snapshot.data?.docs ?? [];

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Botão de cadastro de nova rota
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryStart,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () => _showAddRouteModal(context),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Cadastrar Nova Rota',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Lista de rotas ou mensagem de lista vazia
              if (routes.isEmpty)
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.route_outlined,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Nenhuma rota cadastrada',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Clique no botão acima para cadastrar sua primeira rota.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                )
              else
                ...routes.map((doc) {
                  final route = RouteModel.fromFirestore(doc);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: RouteManagementCard(
                      title: route.title,
                      origin: route.origin,
                      destination: route.destination,
                      passengers: route.tripsText,
                      valor: route.formattedPrice,
                      availableSeats: route.seatsText,
                      duration: route.duration.isNotEmpty
                          ? route.duration
                          : 'N/A',
                      vehicleName: route.vehicleName,
                      timeSlots: route.timeSlots,
                      weekDays: route.weekDays,
                      status: route.status,
                      statusColor: _getStatusColor(route.status),
                      onEdit: () => _showEditRouteModal(context, route),
                      onDelete: () => _showDeleteConfirmation(context, route),
                    ),
                  );
                }).toList(),

              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  void _showAddRouteModal(BuildContext context) {
    originController.clear();
    destinationController.clear();
    valueController.clear();
    capacityController.clear();
    availableSeatsController.clear();
    durationController.clear();
    timeslotsController.clear();
    tripsPerWeekController.clear();
    selectedStatus = 'Ativa';
    selectedWeekDays = [];
    selectedVehicle = null;

    bool isLoading = false;
    List<VehicleModel> vehicles = [];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            // Carrega os veículos do usuário
            if (vehicles.isEmpty && _user != null) {
              _vehicleService.getVehiclesByOwner(_user.uid).then((v) {
                setModalState(() {
                  vehicles = v.where((veh) => veh.status == 'Ativo').toList();
                });
              });
            }

            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Nova Rota',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textDark,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: const Icon(Icons.close, size: 24),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Origem e Destino em linha (Nova Rota)
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              'Origem:',
                              originController,
                              'Caxias',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildTextField(
                              'Destino:',
                              destinationController,
                              'Teresina',
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Valor e Duração em linha
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              'Valor (R\$):',
                              valueController,
                              '100',
                              isNumber: true,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildTextField(
                              'Duração:',
                              durationController,
                              '1h 30min',
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Seleção de Veículo (substitui Capacidade)
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Veículo:',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textDark,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                DropdownButtonFormField<VehicleModel>(
                                  value: selectedVehicle,
                                  isExpanded: true,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 10,
                                    ),
                                    hintText: vehicles.isEmpty
                                        ? 'Nenhum veículo'
                                        : 'Selecione',
                                  ),
                                  items: vehicles.map((vehicle) {
                                    return DropdownMenuItem(
                                      value: vehicle,
                                      child: Text(
                                        '${vehicle.fullName} (${vehicle.seats})',
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontSize: 13),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (vehicle) {
                                    setModalState(() {
                                      selectedVehicle = vehicle;
                                      if (vehicle != null) {
                                        capacityController.text = vehicle.seats
                                            .toString();
                                        availableSeatsController.text = vehicle
                                            .seats
                                            .toString();
                                      }
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Vagas:',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textDark,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                TextFormField(
                                  controller: availableSeatsController,
                                  readOnly: true,
                                  decoration: InputDecoration(
                                    hintText: '-',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 10,
                                    ),
                                    filled: true,
                                    fillColor: Colors.grey[100],
                                  ),
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Horários
                      _buildTextField(
                        'Horários (separados por vírgula):',
                        timeslotsController,
                        '08:00, 14:30, 20:00',
                      ),

                      const SizedBox(height: 16),

                      // Dias da Semana
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Dias da Semana:',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textDark,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: allWeekDays.map((day) {
                              final isSelected = selectedWeekDays.contains(day);
                              return GestureDetector(
                                onTap: () {
                                  setModalState(() {
                                    if (isSelected) {
                                      selectedWeekDays.remove(day);
                                    } else {
                                      selectedWeekDays.add(day);
                                    }
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppTheme.primaryStart
                                        : Colors.grey[200],
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: isSelected
                                          ? AppTheme.primaryStart
                                          : Colors.grey[300]!,
                                    ),
                                  ),
                                  child: Text(
                                    day,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.grey[700],
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Viagens por semana e Status
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              'Viagens/semana:',
                              tripsPerWeekController,
                              '21',
                              isNumber: true,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Status:',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textDark,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                DropdownButtonFormField<String>(
                                  value: selectedStatus,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 10,
                                    ),
                                  ),
                                  items: ['Ativa', 'Pausada', 'Inativa']
                                      .map(
                                        (status) => DropdownMenuItem(
                                          value: status,
                                          child: Text(status),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (value) {
                                    setModalState(() {
                                      selectedStatus = value ?? 'Ativa';
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Botões de ação
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryStart,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              onPressed: isLoading
                                  ? null
                                  : () async {
                                      if (originController.text.isEmpty ||
                                          destinationController.text.isEmpty) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Preencha origem e destino',
                                            ),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                        return;
                                      }

                                      if (selectedVehicle == null) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Selecione um veículo',
                                            ),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                        return;
                                      }

                                      setModalState(() => isLoading = true);

                                      try {
                                        final timeSlots = timeslotsController
                                            .text
                                            .split(',')
                                            .map((t) => t.trim())
                                            .where((t) => t.isNotEmpty)
                                            .toList();

                                        final route = RouteModel(
                                          ownerId: _user!.uid,
                                          vehicleId: selectedVehicle!.id,
                                          vehicleName:
                                              selectedVehicle!.fullName,
                                          origin: originController.text.trim(),
                                          destination: destinationController
                                              .text
                                              .trim(),
                                          price:
                                              double.tryParse(
                                                valueController.text,
                                              ) ??
                                              0,
                                          capacity: selectedVehicle!.seats,
                                          availableSeats:
                                              selectedVehicle!.seats,
                                          duration: durationController.text
                                              .trim(),
                                          timeSlots: timeSlots,
                                          weekDays: selectedWeekDays,
                                          tripsPerWeek:
                                              int.tryParse(
                                                tripsPerWeekController.text,
                                              ) ??
                                              0,
                                          status: selectedStatus,
                                        );

                                        await _routeService.addRoute(route);
                                        Navigator.pop(context);
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Rota cadastrada com sucesso!',
                                            ),
                                            backgroundColor: Colors.green,
                                          ),
                                        );
                                      } catch (e) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Erro ao cadastrar: $e',
                                            ),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      } finally {
                                        setModalState(() => isLoading = false);
                                      }
                                    },
                              child: isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text(
                                      'Salvar Rota',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              onPressed: () => Navigator.pop(context),
                              child: const Text(
                                'Cancelar',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showEditRouteModal(BuildContext context, RouteModel route) {
    originController.text = route.origin;
    destinationController.text = route.destination;
    valueController.text = route.price.toStringAsFixed(0);
    capacityController.text = route.capacity.toString();
    availableSeatsController.text = route.availableSeats.toString();
    durationController.text = route.duration;
    timeslotsController.text = route.timeSlots.join(', ');
    tripsPerWeekController.text = route.tripsPerWeek.toString();
    selectedStatus = route.status;
    selectedWeekDays = List<String>.from(route.weekDays);
    selectedVehicle = null;

    bool isLoading = false;
    List<VehicleModel> vehicles = [];
    String? currentVehicleId = route.vehicleId;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            // Carrega os veículos do usuário
            if (vehicles.isEmpty && _user != null) {
              _vehicleService.getVehiclesByOwner(_user.uid).then((v) {
                setModalState(() {
                  vehicles = v.where((veh) => veh.status == 'Ativo').toList();
                  // Seleciona o veículo atual da rota
                  if (currentVehicleId != null) {
                    try {
                      selectedVehicle = vehicles.firstWhere(
                        (veh) => veh.id == currentVehicleId,
                      );
                    } catch (e) {
                      selectedVehicle = null;
                    }
                  }
                });
              });
            }

            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Editar Rota',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textDark,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: const Icon(Icons.close, size: 24),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Origem e Destino em linha (Editar Rota)
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              'Origem:',
                              originController,
                              'Caxias',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildTextField(
                              'Destino:',
                              destinationController,
                              'Teresina',
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Valor e Duração em linha
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              'Valor (R\$):',
                              valueController,
                              '100',
                              isNumber: true,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildTextField(
                              'Duração:',
                              durationController,
                              '1h 30min',
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Seleção de Veículo e Vagas disponíveis
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Veículo:',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textDark,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                DropdownButtonFormField<VehicleModel>(
                                  value: selectedVehicle,
                                  isExpanded: true,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 10,
                                    ),
                                    hintText: route.vehicleName ?? 'Selecione',
                                  ),
                                  items: vehicles.map((vehicle) {
                                    return DropdownMenuItem(
                                      value: vehicle,
                                      child: Text(
                                        '${vehicle.fullName} (${vehicle.seats})',
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontSize: 13),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (vehicle) {
                                    setModalState(() {
                                      selectedVehicle = vehicle;
                                      if (vehicle != null) {
                                        capacityController.text = vehicle.seats
                                            .toString();
                                        availableSeatsController.text = vehicle
                                            .seats
                                            .toString();
                                      }
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Vagas:',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textDark,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                TextFormField(
                                  controller: availableSeatsController,
                                  readOnly: true,
                                  decoration: InputDecoration(
                                    hintText: route.availableSeats.toString(),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 10,
                                    ),
                                    filled: true,
                                    fillColor: Colors.grey[100],
                                  ),
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Horários
                      _buildTextField(
                        'Horários (separados por vírgula):',
                        timeslotsController,
                        '08:00, 14:30, 20:00',
                      ),

                      const SizedBox(height: 16),

                      // Dias da Semana (Editar Rota)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Dias da Semana:',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textDark,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: allWeekDays.map((day) {
                              final isSelected = selectedWeekDays.contains(day);
                              return GestureDetector(
                                onTap: () {
                                  setModalState(() {
                                    if (isSelected) {
                                      selectedWeekDays.remove(day);
                                    } else {
                                      selectedWeekDays.add(day);
                                    }
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppTheme.primaryStart
                                        : Colors.grey[200],
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: isSelected
                                          ? AppTheme.primaryStart
                                          : Colors.grey[300]!,
                                    ),
                                  ),
                                  child: Text(
                                    day,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.grey[700],
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Viagens por semana e Status (Editar Rota)
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              'Viagens/semana:',
                              tripsPerWeekController,
                              '21',
                              isNumber: true,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Status:',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textDark,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                DropdownButtonFormField<String>(
                                  value: selectedStatus,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 10,
                                    ),
                                  ),
                                  items: ['Ativa', 'Pausada', 'Inativa']
                                      .map(
                                        (status) => DropdownMenuItem(
                                          value: status,
                                          child: Text(status),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (value) {
                                    setModalState(() {
                                      selectedStatus = value ?? 'Ativa';
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Botões de ação (Editar Rota)
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryStart,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              onPressed: isLoading
                                  ? null
                                  : () async {
                                      if (originController.text.isEmpty ||
                                          destinationController.text.isEmpty) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Preencha origem e destino',
                                            ),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                        return;
                                      }

                                      setModalState(() => isLoading = true);

                                      try {
                                        final timeSlots = timeslotsController
                                            .text
                                            .split(',')
                                            .map((t) => t.trim())
                                            .where((t) => t.isNotEmpty)
                                            .toList();

                                        // Usa o veículo selecionado ou mantém o atual
                                        final vehicleId =
                                            selectedVehicle?.id ??
                                            route.vehicleId;
                                        final vehicleName =
                                            selectedVehicle?.fullName ??
                                            route.vehicleName;
                                        final capacity =
                                            selectedVehicle?.seats ??
                                            int.tryParse(
                                              capacityController.text,
                                            ) ??
                                            route.capacity;

                                        final updatedRoute = RouteModel(
                                          id: route.id,
                                          ownerId: route.ownerId,
                                          vehicleId: vehicleId,
                                          vehicleName: vehicleName,
                                          origin: originController.text.trim(),
                                          destination: destinationController
                                              .text
                                              .trim(),
                                          price:
                                              double.tryParse(
                                                valueController.text,
                                              ) ??
                                              0,
                                          capacity: capacity,
                                          availableSeats:
                                              int.tryParse(
                                                availableSeatsController.text,
                                              ) ??
                                              0,
                                          duration: durationController.text
                                              .trim(),
                                          timeSlots: timeSlots,
                                          weekDays: selectedWeekDays,
                                          tripsPerWeek:
                                              int.tryParse(
                                                tripsPerWeekController.text,
                                              ) ??
                                              0,
                                          status: selectedStatus,
                                          createdAt: route.createdAt,
                                        );

                                        await _routeService.updateRoute(
                                          route.id!,
                                          updatedRoute,
                                        );
                                        Navigator.pop(context);
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Rota atualizada com sucesso!',
                                            ),
                                            backgroundColor: Colors.green,
                                          ),
                                        );
                                      } catch (e) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Erro ao atualizar: $e',
                                            ),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      } finally {
                                        setModalState(() => isLoading = false);
                                      }
                                    },
                              child: isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text(
                                      'Salvar Alterações',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              onPressed: () => Navigator.pop(context),
                              child: const Text(
                                'Cancelar',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context, RouteModel route) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: Text('Deseja realmente excluir a rota "${route.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              try {
                await _routeService.deleteRoute(route.id!);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Rota excluída com sucesso!'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Erro ao excluir: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    String hint, {
    bool isNumber = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppTheme.textDark,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
          ),
        ),
      ],
    );
  }
}
