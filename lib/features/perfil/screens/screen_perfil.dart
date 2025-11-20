import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/perfil_bloc.dart';
import '../bloc/perfil_state.dart';
import '../bloc/perfil_event.dart';
import 'perfil_data.dart';

const Color kPrimaryGold = Color(0xFFF7BC3C);
const Color kSecondaryGold = Color(0xFFFFD54F);
const Color kDarkBackground = Color(0xFF1A1A2E);
const Color kCardBackground = Color(0xFFFFFFFF);
const Color kSuccessGreen = Color(0xFF4CAF50);
const Color kWarningOrange = Color(0xFFFF9800);
const Color kInfoBlue = Color(0xFF2196F3);
const Color kTextPrimary = Color(0xFF212121);
const Color kTextSecondary = Color(0xFF757575);
const Color kDividerColor = Color(0xFFEEEEEE);

class RepartidorProfileScreen extends StatefulWidget {
  const RepartidorProfileScreen({super.key});

  @override
  State<RepartidorProfileScreen> createState() =>
      _RepartidorProfileScreenState();
}

class _RepartidorProfileScreenState extends State<RepartidorProfileScreen>
    with TickerProviderStateMixin {
  late AnimationController _headerController;
  late AnimationController _statsController;
  late Animation<double> _headerAnimation;
  late Animation<double> _statsAnimation;

 

  PerfilData _mapApiDataToModel(PerfilLoaded state) {
    final String nombre = state.perfilUsuario['nombre'] ?? '';
    final String apellidoP = state.perfilUsuario['apellidoP'] ?? '';
    final String apellidoM = state.perfilUsuario['apellidoM'] ?? '';
    final double rendMensual =
        (state.estadisticas['Rendimiento_Mensual_Porcentaje'] ?? 0.0) / 100.0;
    final double rendSemanal =
        (state.estadisticas['Rendimiento_Semanal_Porcentaje'] ?? 0.0) / 100.0;
    final String? fotoUrl = state.perfilUsuario['fotoPerfil'];

    return PerfilData(
      nombreCompleto: '$nombre $apellidoP $apellidoM',
      email: state.perfilUsuario['correo'] ?? 'N/A',
      telefono: state.perfilUsuario['telefono'] ?? 'N/A',
      fechaAlta: state.perfilUsuario['fechaCreacion'] ?? 'N/A',
      fotoUrl: fotoUrl,
      rendimientoMensual: rendMensual.clamp(0.0, 1.0),
      rendimientoSemanal: rendSemanal.clamp(0.0, 1.0),
      pedidosPendientes: state.datosRepartidor['entregasPendientes'] ?? 0,
      pedidosCompletados: state.datosRepartidor['entregasFinalizadas'] ?? 0,
      clientesAtendidos: state.datosRepartidor['clientesAtendidos'] ?? 0,
    );
  }

  @override
  void initState() {
    super.initState();

    _headerController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _statsController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _headerAnimation = CurvedAnimation(
      parent: _headerController,
      curve: Curves.easeOutCubic,
    );
    _statsAnimation = CurvedAnimation(
      parent: _statsController,
      curve: Curves.easeOutCubic,
    );

    _headerController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _statsController.forward();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PerfilBloc>().add(const FetchPerfilData());
    });
  }

  @override
  void dispose() {
    _headerController.dispose();
    _statsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmall = size.width < 380;
    final isMedium = size.width >= 380 && size.width < 450;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: BlocBuilder<PerfilBloc, PerfilState>(
        builder: (context, state) {
        
          if (state is PerfilLoading || state is PerfilInitial) {
            return const Center(child: CircularProgressIndicator());
          }

       
          if (state is PerfilError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error de carga: ${state.message}',
                      style: const TextStyle(color: Colors.red)),
                
                  TextButton(
                    onPressed: () =>
                        context.read<PerfilBloc>().add(const FetchPerfilData()),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

         
          if (state is PerfilLoaded) {
            final data = _mapApiDataToModel(state); 

            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
               
                _buildPremiumHeader(size, isSmall, isMedium, data),

               
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                    
                      _buildAnimatedKPIs(size, isSmall, isMedium, data),

                   
                      _buildCircularStats(size, isSmall, data),

                     
                      _buildPersonalInfoTabs(size, isSmall, data),

                     
                      _buildActionButtons(size, isSmall),

                      SizedBox(height: size.height * 0.02),
                    ],
                  ),
                ),
              ],
            );
          }
          return const SizedBox.shrink(); 
        },
      ),
    );
  }

  String _formatDateString(String dateString) {
    if (dateString == 'N/A' || dateString.isEmpty) {
      return 'N/A';
    }
    try {
      final dateTime = DateTime.parse(dateString);

      final day = dateTime.day.toString().padLeft(2, '0');
      final month = dateTime.month.toString().padLeft(2, '0');
      final year = dateTime.year.toString();

      return '$day/$month/$year';
    } catch (e) {
      return 'Error fecha';
    }
  }


  Widget _buildPremiumHeader(
      Size size, bool isSmall, bool isMedium, PerfilData data) {
    return SliverAppBar(
      expandedHeight: size.height * 0.35,
      pinned: false,
      backgroundColor: const Color.fromARGB(0, 191, 37, 37),
      flexibleSpace: FlexibleSpaceBar(
        background: FadeTransition(
          opacity: _headerAnimation,
          child: Stack(
            children: [
            
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color.fromARGB(255, 175, 129, 0),
                      Color.fromARGB(255, 144, 108, 10),
                      Color.fromARGB(255, 255, 187, 0),
                    ],
                  ),
                ),
              ),

              Positioned.fill(
                child: CustomPaint(
                  painter: _HeaderPatternPainter(),
                ),
              ),

           
              SafeArea(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmall ? 20 : 24,
                    vertical: 20,
                  ),
                  child: Column(
                    children: [
                    
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildLevelBadge(isSmall),
                          _buildPointsBadge(isSmall, data.fechaAlta),
                        ],
                      ),

                      const Spacer(),

                     
                      _buildPremiumAvatar(isSmall, isMedium, data),

                      SizedBox(height: isSmall ? 12 : 16),

                     
                      Text(
                        data.nombreCompleto,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: isSmall ? 22 : 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),

                      SizedBox(height: isSmall ? 6 : 8),

                      const Spacer(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLevelBadge(bool isSmall) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 12 : 14,
        vertical: isSmall ? 6 : 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.workspace_premium_rounded,
            color: Colors.white,
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            'Verificado',
            style: TextStyle(
              color: Colors.white,
              fontSize: isSmall ? 11 : 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPointsBadge(bool isSmall, String date) {
    final formattedDate = _formatDateString(date);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 10 : 12,
        vertical: isSmall ? 5 : 7,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.calendar_month_rounded,
            color: Colors.white,
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            'Activo: $formattedDate',
            style: TextStyle(
              color: Colors.white,
              fontSize: isSmall ? 11 : 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumAvatar(bool isSmall, bool isMedium, PerfilData data) {
    final size = isSmall ? 100.0 : (isMedium ? 110.0 : 120.0);

    final bool hasPicture = data.fotoUrl != null && data.fotoUrl!.isNotEmpty;

    return Container(
      width: size,
      height: size,
   
      padding: const EdgeInsets.all(4),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          border: Border.all(color: Colors.white, width: 3),
        ),
        child: ClipOval(
        
          child: hasPicture
              ? Image.network(
                  data.fotoUrl!,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                 
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(kPrimaryGold),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                   
                    return Icon(Icons.person_rounded,
                        size: size * 0.5, color: kTextSecondary);
                  },
                )
              : Icon(
              
                  Icons.person_rounded,
                  size: size * 0.5,
                  color: kTextSecondary,
                ),
          // ----------------------------------------------
        ),
      ),
    );
  }

  Widget _buildRatingStars() {
    return Row(
      children: List.generate(5, (index) {
        return Icon(
          index < 4 ? Icons.star_rounded : Icons.star_half_rounded,
          color: kPrimaryGold,
          size: 18,
        );
      }),
    );
  }


  Widget _buildAnimatedKPIs(
      Size size, bool isSmall, bool isMedium, PerfilData data) {
    return ScaleTransition(
      scale: _statsAnimation,
      child: Container(
        margin: EdgeInsets.fromLTRB(
          isSmall ? 16 : 20,
          20,
          isSmall ? 16 : 20,
          24,
        ),
        child: Row(
          children: [
            Expanded(
              child: _buildModernKPI(
                data.pedidosPendientes.toString(),
                'Pendientes',
                Icons.access_time_rounded,
                kWarningOrange,
                isSmall,
              ),
            ),
            SizedBox(width: isSmall ? 12 : 16),
            Expanded(
              child: _buildModernKPI(
                data.pedidosCompletados.toString(),
                'Finalizados',
                Icons.check_circle_rounded,
                kSuccessGreen,
                isSmall,
              ),
            ),
            SizedBox(width: isSmall ? 12 : 16),
            Expanded(
              child: _buildModernKPI(
                data.clientesAtendidos.toString(),
                'Clientes',
                Icons.people_rounded,
                kInfoBlue,
                isSmall,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernKPI(
    String value,
    String label,
    IconData icon,
    Color color,
    bool isSmall,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: isSmall ? 16 : 20,
        horizontal: isSmall ? 8 : 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: isSmall ? 22 : 24),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: isSmall ? 24 : 28,
              fontWeight: FontWeight.bold,
              color: kTextPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: isSmall ? 11 : 12,
              fontWeight: FontWeight.w600,
              color: kTextSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }


  Widget _buildCircularStats(Size size, bool isSmall, PerfilData data) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: isSmall ? 16 : 20),
      padding: EdgeInsets.all(isSmall ? 20 : 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: kInfoBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.analytics_rounded,
                  color: kInfoBlue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Desempeño General', 
                style: TextStyle(
                  fontSize: isSmall ? 17 : 19,
                  fontWeight: FontWeight.bold,
                  color: kTextPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
        
          Row(
            mainAxisAlignment: MainAxisAlignment
                .spaceEvenly, 
            children: [
           
              _buildCircularProgress(data.rendimientoMensual,
                  'Rendimiento Mensual', kSuccessGreen, isSmall),

            
              _buildCircularProgress(data.rendimientoSemanal,
                  'Rendimiento Semanal', kInfoBlue, isSmall),

            
            ],
          ),
         
        ],
      ),
    );
  }

  Widget _buildCircularProgress(
    double value,
    String label,
    Color color,
    bool isSmall,
  ) {
    final size = isSmall ? 80.0 : 90.0;

    return Column(
      children: [
        SizedBox(
          width: size,
          height: size,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: value),
            duration: const Duration(milliseconds: 1500),
            curve: Curves.easeOutCubic,
            builder: (context, val, child) {
              return CustomPaint(
                painter: _CircularProgressPainter(
                  progress: val,
                  color: color,
                ),
                child: Center(
                  child: Text(
                    '${(val * 100).toInt()}%',
                    style: TextStyle(
                      fontSize: isSmall ? 16 : 18,
                      fontWeight: FontWeight.bold,
                      color: kTextPrimary,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: isSmall ? 11 : 12,
            fontWeight: FontWeight.w600,
            color: kTextSecondary,
          ),
        ),
      ],
    );
  }

 
  Widget _buildPersonalInfoTabs(Size size, bool isSmall, PerfilData data) {
    final formattedDate = _formatDateString(data.fechaAlta);
    return Container(
      margin: EdgeInsets.fromLTRB(
        isSmall ? 16 : 20,
        24,
        isSmall ? 16 : 20,
        24,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(isSmall ? 20 : 24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: kPrimaryGold.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.badge_rounded,
                    color: kPrimaryGold,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Datos Personales',
                  style: TextStyle(
                    fontSize: isSmall ? 17 : 19,
                    fontWeight: FontWeight.bold,
                    color: kTextPrimary,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: kDividerColor),
          Padding(
            padding: EdgeInsets.all(isSmall ? 20 : 24),
            child: Column(
              children: [
                _buildInfoRow(Icons.person_outline, 'Nombre',
                    data.nombreCompleto, isSmall), 
                if (data.telefono != 'N/A' && data.telefono.isNotEmpty)
                  _buildInfoRow(
                      Icons.phone_outlined, 'Teléfono', data.telefono, isSmall),
                _buildInfoRow(Icons.email_outlined, 'Email', data.email,
                    isSmall), 
                _buildInfoRow(Icons.calendar_today_outlined, 'Ingreso',
                    formattedDate, isSmall), 
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value,
    bool isSmall,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F7FA),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: kTextSecondary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: isSmall ? 11 : 12,
                    color: kTextSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: isSmall ? 14 : 15,
                    color: kTextPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String emoji, String label, Color color, bool isSmall) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 12 : 16,
        vertical: isSmall ? 8 : 10,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: TextStyle(fontSize: isSmall ? 16 : 18)),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: isSmall ? 12 : 13,
              fontWeight: FontWeight.w600,
              color: kTextPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(Size size, bool isSmall) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        isSmall ? 16 : 20,
        24,
        isSmall ? 16 : 20,
        0,
      ),
      child: Row(
        children: [],
      ),
    );
  }
}


class _HeaderPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..style = PaintingStyle.fill;

    for (var i = 0; i < 5; i++) {
      for (var j = 0; j < 5; j++) {
        canvas.drawCircle(
          Offset(
            (size.width / 4) * i + (j % 2) * 20,
            (size.height / 4) * j,
          ),
          30,
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}


class _CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color color;

  _CircularProgressPainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

   
    final bgPaint = Paint()
      ..color = color.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius - 4, bgPaint);

  
    final progressPaint = Paint()
      ..shader = LinearGradient(
        colors: [color, color.withOpacity(0.6)],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 4),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _CircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
