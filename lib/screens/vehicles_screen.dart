import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/app_theme.dart';
import '../widgets/index.dart';
import '../services/auth_service.dart';
import '../services/vehicle_service.dart';
import '../models/vehicle_model.dart';

class VehiclesScreen extends StatefulWidget {
  const VehiclesScreen({Key? key}) : super(key: key);

  @override
  State<VehiclesScreen> createState() => _VehiclesScreenState();
}

class _VehiclesScreenState extends State<VehiclesScreen> {
  final AuthService _authService = AuthService();
  final VehicleService _vehicleService = VehicleService();

  /// Retorna a cor do status
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'ativo':
        return Color(0xFF10B981);
      case 'manutenção':
        return Color(0xFFFB923C);
      case 'inativo':
        return Color(0xFFEF4444);
      default:
        return Color(0xFF10B981);
    }
  }

  /// Formata a data para exibição
  String _formatDate(DateTime? date) {
    if (date == null) return 'Não informado';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = _authService.currentUser;

    if (currentUser == null) {
      return Center(child: Text('Usuário não logado'));
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('vehicles')
          .where('ownerId', isEqualTo: currentUser.uid)
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Erro ao carregar veículos'));
        }

        final vehicles = snapshot.data?.docs
                .map((doc) => VehicleModel.fromFirestore(doc))
                .toList() ??
            [];

        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Botão de cadastro
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
                  onPressed: () => _showAddVehicleModal(context),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Cadastrar Novo Veículo',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 16),

              // Lista de veículos ou mensagem de vazio
              if (vehicles.isEmpty)
                Container(
                  padding: EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.directions_car_outlined,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Nenhum veículo cadastrado',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Clique no botão acima para adicionar seu primeiro veículo',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                )
              else
                ...vehicles.map((vehicle) => Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: VehicleManagementCard(
                        brand: vehicle.fullName,
                        plate: vehicle.plate,
                        type: vehicle.type,
                        seats: vehicle.seats.toString(),
                        year: vehicle.year.toString(),
                        mileage: vehicle.mileage.toStringAsFixed(0),
                        status: vehicle.status,
                        statusColor: _getStatusColor(vehicle.status),
                        lastReview: _formatDate(vehicle.lastReview),
                        amenities: vehicle.amenities,
                        onEdit: () => _showEditVehicleModal(context, vehicle),
                        onDelete: () => _showDeleteConfirmation(context, vehicle),
                      ),
                    )),

              SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  /// Modal de adicionar veículo
  void _showAddVehicleModal(BuildContext context) {
    final brandController = TextEditingController();
    final modelController = TextEditingController();
    final capacityController = TextEditingController();
    final plateController = TextEditingController();
    final yearController = TextEditingController();
    String selectedType = 'Van';
    String selectedStatus = 'Ativo';
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Novo Veículo',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textDark,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Icon(Icons.close, size: 24),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),

                      // Tipo do Veículo (Van ou Lotação)
                      Text(
                        'Tipo de Veículo',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textDark,
                        ),
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setDialogState(() => selectedType = 'Van');
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: selectedType == 'Van'
                                      ? AppTheme.primaryStart
                                      : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: selectedType == 'Van'
                                        ? AppTheme.primaryStart
                                        : Colors.grey.shade300,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.airport_shuttle,
                                      size: 20,
                                      color: selectedType == 'Van'
                                          ? Colors.white
                                          : Colors.grey.shade600,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Van',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: selectedType == 'Van'
                                            ? Colors.white
                                            : Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setDialogState(() => selectedType = 'Lotação');
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: selectedType == 'Lotação'
                                      ? AppTheme.primaryStart
                                      : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: selectedType == 'Lotação'
                                        ? AppTheme.primaryStart
                                        : Colors.grey.shade300,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.directions_car,
                                      size: 20,
                                      color: selectedType == 'Lotação'
                                          ? Colors.white
                                          : Colors.grey.shade600,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Lotação',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: selectedType == 'Lotação'
                                            ? Colors.white
                                            : Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),

                      // Marca
                      _buildTextField(
                        controller: brandController,
                        label: 'Marca',
                        hintText: 'Mercedes-Benz',
                      ),
                      SizedBox(height: 12),

                      // Modelo
                      _buildTextField(
                        controller: modelController,
                        label: 'Modelo',
                        hintText: 'Sprinter',
                      ),
                      SizedBox(height: 12),

                      // Capacidade e Ano em linha
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: capacityController,
                              label: 'Capacidade',
                              hintText: '10',
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: _buildTextField(
                              controller: yearController,
                              label: 'Ano',
                              hintText: '2022',
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),

                      // Placa e Status
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: plateController,
                              label: 'Placa',
                              hintText: 'ABC-1234',
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Status',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textDark,
                                  ),
                                ),
                                SizedBox(height: 6),
                                DropdownButtonFormField<String>(
                                  value: selectedStatus,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 10),
                                  ),
                                  items: ['Ativo', 'Inativo', 'Manutenção']
                                      .map((status) => DropdownMenuItem(
                                            value: status,
                                            child: Text(status),
                                          ))
                                      .toList(),
                                  onChanged: (value) {
                                    setDialogState(() {
                                      selectedStatus = value ?? 'Ativo';
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),

                      // Botões
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryStart,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              onPressed: isLoading
                                  ? null
                                  : () async {
                                      // Validações
                                      if (brandController.text.isEmpty ||
                                          modelController.text.isEmpty ||
                                          plateController.text.isEmpty) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                                'Preencha os campos obrigatórios'),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                        return;
                                      }

                                      setDialogState(() => isLoading = true);

                                      try {
                                        final uid =
                                            _authService.currentUser?.uid;
                                        if (uid != null) {
                                          await _vehicleService.addVehicle(
                                            ownerId: uid,
                                            type: selectedType,
                                            brand: brandController.text.trim(),
                                            model: modelController.text.trim(),
                                            plate: plateController.text.trim(),
                                            seats: int.tryParse(
                                                    capacityController.text) ??
                                                0,
                                            year: int.tryParse(
                                                    yearController.text) ??
                                                DateTime.now().year,
                                            status: selectedStatus,
                                          );

                                          if (mounted) {
                                            Navigator.pop(context);
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                    'Veículo cadastrado com sucesso!'),
                                                backgroundColor:
                                                    Color(0xFF10B981),
                                              ),
                                            );
                                          }
                                        }
                                      } catch (e) {
                                        setDialogState(() => isLoading = false);
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content:
                                                Text('Erro ao cadastrar: $e'),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    },
                              child: isLoading
                                  ? SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.white),
                                      ),
                                    )
                                  : Text(
                                      'Salvar Veículo',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                padding: EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              onPressed: () => Navigator.pop(context),
                              child: Text(
                                'Cancelar',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
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

  /// Modal de editar veículo
  void _showEditVehicleModal(BuildContext context, VehicleModel vehicle) {
    final brandController = TextEditingController(text: vehicle.brand);
    final modelController = TextEditingController(text: vehicle.model);
    final capacityController =
        TextEditingController(text: vehicle.seats.toString());
    final plateController = TextEditingController(text: vehicle.plate);
    final yearController = TextEditingController(text: vehicle.year.toString());
    final mileageController =
        TextEditingController(text: vehicle.mileage.toStringAsFixed(0));
    String selectedType = vehicle.type;
    String selectedStatus = vehicle.status;
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Editar Veículo',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textDark,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Icon(Icons.close, size: 24),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),

                      // Tipo do Veículo (Van ou Lotação)
                      Text(
                        'Tipo de Veículo',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textDark,
                        ),
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setDialogState(() => selectedType = 'Van');
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: selectedType == 'Van'
                                      ? AppTheme.primaryStart
                                      : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: selectedType == 'Van'
                                        ? AppTheme.primaryStart
                                        : Colors.grey.shade300,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.airport_shuttle,
                                      size: 20,
                                      color: selectedType == 'Van'
                                          ? Colors.white
                                          : Colors.grey.shade600,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Van',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: selectedType == 'Van'
                                            ? Colors.white
                                            : Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setDialogState(() => selectedType = 'Lotação');
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: selectedType == 'Lotação'
                                      ? AppTheme.primaryStart
                                      : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: selectedType == 'Lotação'
                                        ? AppTheme.primaryStart
                                        : Colors.grey.shade300,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.directions_car,
                                      size: 20,
                                      color: selectedType == 'Lotação'
                                          ? Colors.white
                                          : Colors.grey.shade600,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Lotação',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: selectedType == 'Lotação'
                                            ? Colors.white
                                            : Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),

                      // Marca
                      _buildTextField(
                        controller: brandController,
                        label: 'Marca',
                        hintText: 'Mercedes-Benz',
                      ),
                      SizedBox(height: 12),

                      // Modelo
                      _buildTextField(
                        controller: modelController,
                        label: 'Modelo',
                        hintText: 'Sprinter',
                      ),
                      SizedBox(height: 12),

                      // Capacidade e Ano
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: capacityController,
                              label: 'Capacidade',
                              hintText: '10',
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: _buildTextField(
                              controller: yearController,
                              label: 'Ano',
                              hintText: '2022',
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),

                      // Placa e Quilometragem
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: plateController,
                              label: 'Placa',
                              hintText: 'ABC-1234',
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: _buildTextField(
                              controller: mileageController,
                              label: 'Km Rodados (mil)',
                              hintText: '145',
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),

                      // Status
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Status',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textDark,
                            ),
                          ),
                          SizedBox(height: 6),
                          DropdownButtonFormField<String>(
                            value: selectedStatus,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                            ),
                            items: ['Ativo', 'Inativo', 'Manutenção']
                                .map((status) => DropdownMenuItem(
                                      value: status,
                                      child: Text(status),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              setDialogState(() {
                                selectedStatus = value ?? 'Ativo';
                              });
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 20),

                      // Botões
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryStart,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              onPressed: isLoading
                                  ? null
                                  : () async {
                                      setDialogState(() => isLoading = true);

                                      try {
                                        final updatedVehicle = vehicle.copyWith(
                                          type: selectedType,
                                          brand: brandController.text.trim(),
                                          model: modelController.text.trim(),
                                          plate: plateController.text.trim(),
                                          seats: int.tryParse(
                                                  capacityController.text) ??
                                              vehicle.seats,
                                          year: int.tryParse(
                                                  yearController.text) ??
                                              vehicle.year,
                                          mileage: double.tryParse(
                                                  mileageController.text) ??
                                              vehicle.mileage,
                                          status: selectedStatus,
                                        );

                                        await _vehicleService
                                            .updateVehicle(updatedVehicle);

                                        if (mounted) {
                                          Navigator.pop(context);
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                  'Veículo atualizado com sucesso!'),
                                              backgroundColor:
                                                  Color(0xFF10B981),
                                            ),
                                          );
                                        }
                                      } catch (e) {
                                        setDialogState(() => isLoading = false);
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content:
                                                Text('Erro ao atualizar: $e'),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    },
                              child: isLoading
                                  ? SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.white),
                                      ),
                                    )
                                  : Text(
                                      'Salvar Alterações',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                padding: EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              onPressed: () => Navigator.pop(context),
                              child: Text(
                                'Cancelar',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
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

  /// Confirmação de exclusão
  void _showDeleteConfirmation(BuildContext context, VehicleModel vehicle) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Excluir Veículo'),
        content: Text(
            'Tem certeza que deseja excluir o veículo ${vehicle.fullName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _vehicleService.deleteVehicle(vehicle.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Veículo excluído com sucesso!'),
                    backgroundColor: Color(0xFF10B981),
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Erro ao excluir: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  /// Widget de campo de texto reutilizável
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppTheme.textDark,
          ),
        ),
        SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hintText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
        ),
      ],
    );
  }
}
