import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class VehicleManagementCard extends StatelessWidget {
  final String brand;
  final String plate;
  final String type;
  final String seats;
  final String year;
  final String mileage;
  final String status;
  final Color statusColor;
  final String lastReview;
  final List<String> amenities;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const VehicleManagementCard({
    Key? key,
    required this.brand,
    required this.plate,
    this.type = 'Van',
    required this.seats,
    required this.year,
    required this.mileage,
    required this.status,
    required this.statusColor,
    required this.lastReview,
    required this.amenities,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      padding: EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Color(0xFFE0F2FE),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: EdgeInsets.all(8),
                child: Icon(
                  type == 'Lotação'
                      ? Icons.directions_car
                      : Icons.airport_shuttle,
                  color: AppTheme.primaryStart,
                  size: 24,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          brand,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textDark,
                          ),
                        ),
                        SizedBox(width: 8),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: type == 'Lotação'
                                ? Color(0xFFFEF3C7)
                                : Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            type,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: type == 'Lotação'
                                  ? Color(0xFFD97706)
                                  : Color(0xFF059669),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 2),
                    Text(
                      plate,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 12),

          // Vehicle info
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      Icons.event_seat,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                    SizedBox(width: 4),
                    Text(
                      '$seats lugares',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                    SizedBox(width: 4),
                    Text(
                      year,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    Icon(Icons.speed, size: 16, color: Colors.grey.shade600),
                    SizedBox(width: 4),
                    Text(
                      '$mileage viagens',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 12),

          // Amenities
          Wrap(
            spacing: 8,
            children: amenities.map((amenity) {
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Text(
                  amenity,
                  style: TextStyle(
                    fontSize: 11,
                    color: AppTheme.primaryStart,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),

          SizedBox(height: 12),

          // Footer with date and actions
          Row(
            children: [
              Expanded(
                child: Text(
                  'Próxima revisão: $lastReview',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
              ),
              IconButton(
                icon: Icon(Icons.edit, size: 18, color: AppTheme.primaryStart),
                onPressed: onEdit,
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(),
              ),
              SizedBox(width: 8),
              IconButton(
                icon: Icon(Icons.delete, size: 18, color: Colors.red),
                onPressed: onDelete,
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
