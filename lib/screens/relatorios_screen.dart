import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class RelatoriosScreen extends StatefulWidget {
  const RelatoriosScreen({Key? key}) : super(key: key);

  @override
  _RelatoriosScreenState createState() => _RelatoriosScreenState();
}

class _RelatoriosScreenState extends State<RelatoriosScreen> {
  String selectedPeriodo = 'Semana';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Relatórios'),
        backgroundColor: AppTheme.primaryStart,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Center(
              child: Icon(Icons.notifications, size: 20),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Período Selection
            Container(
              color: Colors.white,
              padding: EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Período',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textDark,
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      _periodButton('Semana'),
                      SizedBox(width: 8),
                      _periodButton('Mês'),
                      SizedBox(width: 8),
                      _periodButton('Ano'),
                      SizedBox(width: 8),
                      _periodButton('Personalizado'),
                    ],
                  ),
                ],
              ),
            ),

            // Exportar PDF
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: SizedBox(
                width: double.infinity,
                height: 44,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primaryStart,
                    side: BorderSide(color: AppTheme.primaryStart),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {},
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.download, size: 16),
                      SizedBox(width: 8),
                      Text(
                        'Exportar PDF',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            SizedBox(height: 16),

            // Reservas, Confirmadas, Canceladas
            Container(
              color: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _statItem(
                    label: 'Reservas',
                    value: '145',
                    icon: Icons.calendar_today,
                    color: Color(0xFF3B82F6),
                  ),
                  _statItem(
                    label: 'Confirmadas',
                    value: '128',
                    icon: Icons.check_circle,
                    color: Color(0xFF10B981),
                  ),
                  _statItem(
                    label: 'Canceladas',
                    value: '17',
                    icon: Icons.cancel,
                    color: Color(0xFFEF4444),
                  ),
                ],
              ),
            ),

            SizedBox(height: 12),

            // Receita e Ticket Médio
            Container(
              color: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  Expanded(
                    child: _largeStatCard(
                      label: 'Receita',
                      value: 'R\$ 28.850,00',
                      icon: Icons.attach_money,
                      iconColor: Color(0xFF10B981),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _largeStatCard(
                      label: 'Ticket Médio',
                      value: 'R\$ 100,00',
                      icon: Icons.trending_up,
                      iconColor: Color(0xFF3B82F6),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 12),

            // Resumo Financeiro
            Container(
              color: Colors.white,
              padding: EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Resumo Financeiro',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textDark,
                    ),
                  ),
                  SizedBox(height: 12),
                  _financialRow(
                    label: 'Receita Bruta',
                    value: 'R\$ 28.850,00',
                    valueColor: AppTheme.textDark,
                  ),
                  SizedBox(height: 10),
                  _financialRow(
                    label: 'Taxas e Comissões',
                    value: 'R\$ 2.850,00',
                    valueColor: Color(0xFFEF4444),
                  ),
                  SizedBox(height: 10),
                  _financialRow(
                    label: 'Receita Líquida',
                    value: 'R\$ 28.000,00',
                    valueColor: Color(0xFF10B981),
                  ),
                ],
              ),
            ),

            SizedBox(height: 12),

            // Taxas
            Container(
              color: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  Expanded(
                    child: _taxCard(
                      label: 'Taxa de No-Show',
                      value: '8.5%',
                      icon: Icons.warning,
                      iconColor: Color(0xFFFB923C),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _taxCard(
                      label: 'Taxa de Ocupação',
                      value: '76.3%',
                      icon: Icons.trending_up,
                      iconColor: Color(0xFF10B981),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 12),

            // Rota Mais Popular
            Container(
              color: Colors.white,
              padding: EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: Container(
                padding: EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200, width: 1.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rota Mais Popular',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Caxias → Teresina',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textDark,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      '48 viagens realizadas',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _periodButton(String label) {
    bool isSelected = selectedPeriodo == label;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedPeriodo = label;
          });
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryStart : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : Colors.grey.shade600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _statItem({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Icon(icon, size: 18, color: color),
          ),
        ),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppTheme.textDark,
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _largeStatCard({
    required String label,
    required String value,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                padding: EdgeInsets.all(6),
                child: Icon(icon, size: 16, color: iconColor),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppTheme.textDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _financialRow({
    required String label,
    required String value,
    required Color valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  Widget _taxCard({
    required String label,
    required String value,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                padding: EdgeInsets.all(6),
                child: Icon(icon, size: 16, color: iconColor),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.textDark,
            ),
          ),
        ],
      ),
    );
  }
}
