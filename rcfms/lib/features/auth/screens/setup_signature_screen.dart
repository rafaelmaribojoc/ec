import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../bloc/auth_bloc.dart';

class SetupSignatureScreen extends StatefulWidget {
  const SetupSignatureScreen({super.key});

  @override
  State<SetupSignatureScreen> createState() => _SetupSignatureScreenState();
}

class _SetupSignatureScreenState extends State<SetupSignatureScreen> {
  final List<List<Offset>> _strokes = [];
  List<Offset> _currentStroke = [];
  bool _isSaving = false;
  bool _hasSignature = false;

  void _onPanStart(DragStartDetails details) {
    setState(() {
      _currentStroke = [details.localPosition];
      _hasSignature = true;
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _currentStroke = [..._currentStroke, details.localPosition];
    });
  }

  void _onPanEnd(DragEndDetails details) {
    setState(() {
      _strokes.add(_currentStroke);
      _currentStroke = [];
    });
  }

  void _clearSignature() {
    setState(() {
      _strokes.clear();
      _currentStroke = [];
      _hasSignature = false;
    });
  }

  Future<Uint8List?> _exportSignature(Size size) async {
    if (_strokes.isEmpty) return null;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    // White background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = Colors.white,
    );

    // Draw strokes
    final paint = Paint()
      ..color = AppColors.textPrimary
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    for (final stroke in _strokes) {
      if (stroke.length < 2) continue;
      final path = Path()..moveTo(stroke.first.dx, stroke.first.dy);
      for (int i = 1; i < stroke.length; i++) {
        path.lineTo(stroke[i].dx, stroke[i].dy);
      }
      canvas.drawPath(path, paint);
    }

    final picture = recorder.endRecording();
    final image = await picture.toImage(size.width.toInt(), size.height.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    return byteData?.buffer.asUint8List();
  }

  Future<void> _saveSignature() async {
    if (!_hasSignature || _strokes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please draw your signature first'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      // Get the actual signature pad size from context
      final renderBox = context.findRenderObject() as RenderBox?;
      final size = renderBox?.size ?? const Size(400, 200);
      final signatureSize = Size(
        size.width.clamp(200, 600),
        size.height.clamp(100, 300),
      );

      debugPrint('[Signature] Exporting signature with size: $signatureSize');
      final bytes = await _exportSignature(signatureSize);

      if (bytes == null) {
        throw Exception('Failed to export signature image');
      }

      debugPrint('[Signature] Exported ${bytes.length} bytes');

      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        throw Exception('Not authenticated. Please log in again.');
      }

      debugPrint('[Signature] Uploading for user: ${user.id}');

      // Upload to Supabase Storage
      final fileName = 'signature_${user.id}.png';
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final uniqueFileName = 'signature_${user.id}_$timestamp.png';

      try {
        // Try to upload with upsert
        await Supabase.instance.client.storage.from('signatures').uploadBinary(
              uniqueFileName,
              bytes,
              fileOptions: const FileOptions(
                contentType: 'image/png',
                upsert: true,
              ),
            );
        debugPrint('[Signature] Upload successful');
      } catch (storageError) {
        debugPrint('[Signature] Storage error: $storageError');
        
        // If storage bucket doesn't exist or RLS issue, skip storage and encode as base64
        final base64Signature = 'data:image/png;base64,${base64Encode(bytes)}';
        debugPrint('[Signature] Using base64 fallback');
        
        // Update profile with base64 signature directly
        await Supabase.instance.client
            .from('profiles')
            .update({'signature_url': base64Signature}).eq('id', user.id);
            
        if (mounted) {
          // Update the auth state with the new signature URL directly
          final currentState = context.read<AuthBloc>().state;
          if (currentState is AuthAuthenticated) {
            final updatedUser = currentState.user.copyWith(signatureUrl: base64Signature);
            context.read<AuthBloc>().add(AuthUserUpdated(updatedUser));
          }
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Signature saved successfully'),
              backgroundColor: AppColors.success,
            ),
          );
          // Navigate back 
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          } else {
            context.go('/dashboard');
          }
        }
        return;
      }

      // Get public URL
      final signatureUrl = Supabase.instance.client.storage
          .from('signatures')
          .getPublicUrl(uniqueFileName);

      debugPrint('[Signature] URL: $signatureUrl');

      // Update user profile
      await Supabase.instance.client
          .from('profiles')
          .update({'signature_url': signatureUrl}).eq('id', user.id);

      debugPrint('[Signature] Profile updated successfully');

      if (mounted) {
        // Update the auth state with the new signature URL directly
        final currentState = context.read<AuthBloc>().state;
        if (currentState is AuthAuthenticated) {
          final updatedUser = currentState.user.copyWith(signatureUrl: signatureUrl);
          context.read<AuthBloc>().add(AuthUserUpdated(updatedUser));
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Signature saved successfully'),
            backgroundColor: AppColors.success,
          ),
        );
        // Navigate back
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        } else {
          context.go('/dashboard');
        }
      }
    } catch (e) {
      debugPrint('[Signature] Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              context.go('/dashboard');
            }
          },
        ),
        title: const Text('Setup Signature'),
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Text(
                'Create your digital signature',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'Draw your signature below. This will be used to sign forms electronically.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              const SizedBox(height: 32),

              // Signature pad
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    border: Border.all(
                      color: _hasSignature ? AppColors.primary : AppColors.border,
                      width: _hasSignature ? 2 : 1,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd - 1),
                    child: Stack(
                      children: [
                        // Drawing area
                        Positioned.fill(
                          child: GestureDetector(
                            onPanStart: _onPanStart,
                            onPanUpdate: _onPanUpdate,
                            onPanEnd: _onPanEnd,
                            child: CustomPaint(
                              painter: _SignaturePainter(
                                strokes: _strokes,
                                currentStroke: _currentStroke,
                              ),
                            ),
                          ),
                        ),

                        // Placeholder text
                        if (!_hasSignature)
                          Center(
                            child: IgnorePointer(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.gesture,
                                    size: 48,
                                    color: AppColors.textTertiary,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Draw your signature here',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          color: AppColors.textTertiary,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                        // Clear button
                        if (_hasSignature)
                          Positioned(
                            top: 12,
                            right: 12,
                            child: Material(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                              child: InkWell(
                                onTap: _clearSignature,
                                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                                    border: Border.all(color: AppColors.border),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.refresh,
                                        size: 16,
                                        color: AppColors.textSecondary,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Clear',
                                        style: Theme.of(context).textTheme.labelMedium,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => context.go('/dashboard'),
                      child: const Text('Skip for now'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _saveSignature,
                      child: _isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Save Signature'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SignaturePainter extends CustomPainter {
  final List<List<Offset>> strokes;
  final List<Offset> currentStroke;

  _SignaturePainter({
    required this.strokes,
    required this.currentStroke,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.textPrimary
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    // Draw completed strokes
    for (final stroke in strokes) {
      if (stroke.length < 2) continue;
      final path = Path()..moveTo(stroke.first.dx, stroke.first.dy);
      for (int i = 1; i < stroke.length; i++) {
        path.lineTo(stroke[i].dx, stroke[i].dy);
      }
      canvas.drawPath(path, paint);
    }

    // Draw current stroke
    if (currentStroke.length >= 2) {
      final path = Path()..moveTo(currentStroke.first.dx, currentStroke.first.dy);
      for (int i = 1; i < currentStroke.length; i++) {
        path.lineTo(currentStroke[i].dx, currentStroke[i].dy);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SignaturePainter oldDelegate) {
    return true;
  }
}
