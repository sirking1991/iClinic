import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iclinic/core/theme/app_colors.dart';
import 'package:iclinic/features/consultation/presentation/consultation_controller.dart';
import 'widgets/vitals_input_sheet.dart';
import 'widgets/prescription_pad.dart';
import 'widgets/lab_request_sheet.dart';
import '../domain/attachment_helper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:io';

class ConsultationStream extends ConsumerStatefulWidget {
  final int patientId;
  const ConsultationStream({required this.patientId, super.key});

  @override
  ConsumerState<ConsultationStream> createState() => _ConsultationStreamState();
}

class _ConsultationStreamState extends ConsumerState<ConsultationStream> {
  final _textController = TextEditingController();
  final _attachmentHelper = AttachmentHelper();

  @override
  void initState() {
    super.initState();
    AttachmentHelper.ensureDirectory();
  }

  void _pickAttachment(int consultationId) async {
    final path = await _attachmentHelper.pickImage(ImageSource.gallery);
    if (path != null) {
      await ref
          .read(consultationControllerProvider)
          .addImage(consultationId, path);
    }
  }

  void _openPrescriptionPad(int consultationId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => PrescriptionPad(consultationId: consultationId),
    );
  }

  void _openVitals(int consultationId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => VitalsInputSheet(consultationId: consultationId),
    );
  }

  void _openLabs() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const LabRequestSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeAsync = ref.watch(activeConsultationProvider(widget.patientId));

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: activeAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, st) => Center(child: Text('Error: $err')),
        data: (consultation) {
          final streamAsync = ref.watch(
            consultationStreamProvider(consultation.id),
          );

          return Column(
            children: [
              Expanded(
                child: streamAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (err, st) =>
                      Center(child: Text('Error loading stream: $err')),
                  data: (events) {
                    if (events.isEmpty) {
                      return const Center(
                        child: Text(
                          "No events yet.\nStart by adding a note.",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColors.sage400),
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: events.length,
                      itemBuilder: (context, index) {
                        final event = events[index];
                        final timeStr = DateFormat(
                          'h:mm a',
                        ).format(event.timestamp);
                        Map<String, dynamic> content = {};
                        try {
                          content = jsonDecode(event.contentJson);
                        } catch (_) {}

                        String displayText = "Unknown event type";
                        IconData icon = Icons.info;

                        if (event.type == 'note') {
                          displayText = content['text'] ?? '';
                          icon = Icons.text_snippet;
                        } else if (event.type == 'vitals') {
                          displayText =
                              "Vitals Recorded:\nBP: ${content['bp_sys']}/${content['bp_dia']} mmHg\nHR: ${content['heart_rate']} bpm\nTemp: ${content['temp']}°C";
                          icon = Icons.favorite;
                        } else if (event.type == 'image') {
                          displayText = "Image Attachment";
                          icon = Icons.image;
                        } else if (event.type == 'prescription') {
                          displayText =
                              "Rx: ${content['drugName']} - ${content['dosage']}";
                          if (content['frequency'] != null &&
                              content['frequency'].isNotEmpty) {
                            displayText += " (${content['frequency']})";
                          }
                          icon = Icons.medication;
                        }

                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.sage100),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.02),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    icon,
                                    size: 14,
                                    color: AppColors.sage400,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    "$timeStr • ${event.authorName}",
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.sage400,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              if (event.type == 'image')
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.file(
                                      File(content['path'] ?? ''),
                                      height: 200,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              const Center(
                                                child: Text(
                                                  "Image not available",
                                                ),
                                              ),
                                    ),
                                  ),
                                )
                              else
                                Text(
                                  displayText,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    height: 1.4,
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),

              // Chat Input Bar
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: AppColors.sage100)),
                ),
                child: SafeArea(
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.add_circle_outline,
                          color: AppColors.sage500,
                        ),
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            builder: (ctx) => Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ListTile(
                                  leading: const Icon(
                                    Icons.favorite,
                                    color: Colors.redAccent,
                                  ),
                                  title: const Text('Vitals'),
                                  onTap: () {
                                    Navigator.pop(ctx);
                                    _openVitals(consultation.id);
                                  },
                                ),
                                ListTile(
                                  leading: const Icon(
                                    Icons.medication,
                                    color: Colors.blueAccent,
                                  ),
                                  title: const Text('Prescription'),
                                  onTap: () {
                                    Navigator.pop(ctx);
                                    _openPrescriptionPad(consultation.id);
                                  },
                                ),
                                ListTile(
                                  leading: const Icon(
                                    Icons.science,
                                    color: Colors.purpleAccent,
                                  ),
                                  title: const Text('Lab Request'),
                                  onTap: () {
                                    Navigator.pop(ctx);
                                    _openLabs();
                                  },
                                ),
                                ListTile(
                                  leading: const Icon(
                                    Icons.image,
                                    color: Colors.green,
                                  ),
                                  title: const Text('Image'),
                                  onTap: () {
                                    Navigator.pop(ctx);
                                    _pickAttachment(consultation.id);
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      Expanded(
                        child: TextField(
                          controller: _textController,
                          decoration: InputDecoration(
                            hintText: "Type a note...",
                            hintStyle: const TextStyle(
                              color: AppColors.sage300,
                            ),
                            filled: true,
                            fillColor: AppColors.sage50,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          onSubmitted: (value) {
                            if (value.isNotEmpty) {
                              ref
                                  .read(consultationControllerProvider)
                                  .addNote(consultation.id, value);
                              _textController.clear();
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.send, color: AppColors.sage500),
                        onPressed: () {
                          final text = _textController.text;
                          if (text.isNotEmpty) {
                            ref
                                .read(consultationControllerProvider)
                                .addNote(consultation.id, text);
                            _textController.clear();
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
