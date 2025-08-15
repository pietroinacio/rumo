import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:rumo/features/diary/models/create_diary_model.dart';
import 'package:rumo/features/diary/repositories/diary_repository.dart';
import 'package:rumo/features/diary/widgets/diary_form/diary_form.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class CreateDiaryBottomSheet extends StatefulWidget {
  const CreateDiaryBottomSheet({super.key});

  @override
  State<CreateDiaryBottomSheet> createState() => _CreateDiaryBottomSheetState();
}

class _CreateDiaryBottomSheetState extends State<CreateDiaryBottomSheet> {
  void showSuccess() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Diário criado com sucesso!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void showError(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Erro'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
    child: ListView(
      children: [
        Padding(
          padding: const EdgeInsets.only(
            top: 16,
            left: 24,
            right: 24,
            bottom: 8,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Novo Diário',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.primary,
                  textStyle: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                child: Text('Cancelar'),
              ),
            ],
          ),
        ),
        DiaryForm(
          buttonTitle: 'Salvar Diário',
          onError: (message) {
            if(message == null) {
              showError("Erro ao criar diário");
              return;
            }
            showError(message);
          },
          onSubmit: (result) async {

            if(result.selectedPlace == null || result.latitude == null || result.longitude == null) {
              showError("Por favor, selecione um local");
              return;
            }

            final coverUrl = await uploadImage(result.selectedImage);

            final tripImagesUploads = result.tripImages.map((image) {
              return uploadImage(image);
            });

            final tripImagesUrls = await Future.wait(tripImagesUploads);

            final diary = CreateDiaryModel(
              ownerId: result.ownerId,
              location: result.selectedPlace!.formattedLocation,
              name: result.name,
              coverImage: coverUrl,
              resume: result.resume,
              images: tripImagesUrls,
              rating: result.rating,
              isPrivate: result.isPrivate,
              latitude: result.latitude!,
              longitude: result.longitude!,
            );

            await DiaryRepository().createDiary(diary: diary);
            if (context.mounted) {
              Navigator.of(context).pop();
              showSuccess();
            }
          },
        ),
      ],
    ),
  );

  Future<String> uploadImage(File image) async {
    final fileType = image.path.split('.').last;
    final imageId = Uuid().v4();
    final filename = '$imageId.$fileType';
    final supabase = Supabase.instance.client;
    await supabase.storage.from('images').upload(filename, image);
    return supabase.storage.from('images').getPublicUrl(filename);
  }
}