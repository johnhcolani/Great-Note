import 'package:bloc/bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../data/data_source/background_local_data_source.dart';

part 'background_event.dart';
part 'background_state.dart';

class BackgroundBloc extends Bloc<BackgroundEvent, BackgroundState> {
  final BackgroundLocalDataSource backgroundDataSource;

  BackgroundBloc(this.backgroundDataSource) : super(BackgroundInitial()) {
    on<ChangeBackgroundEvent>((event, emit) async {
      // This event now shows a dialog to choose between camera and gallery
      // The actual implementation will be handled in the UI layer
    });

    on<ChangeBackgroundFromGalleryEvent>((event, emit) async {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        try {
          await backgroundDataSource.saveBackgroundImage(pickedFile.path);
          emit(BackgroundLoaded(pickedFile.path));
        } catch (e) {
          emit(BackgroundError('Failed to save background: ${e.toString()}'));
        }
      } else {
        emit(BackgroundError('No image selected'));
      }
    });

    on<ChangeBackgroundFromCameraEvent>((event, emit) async {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.camera);

      if (pickedFile != null) {
        try {
          await backgroundDataSource.saveBackgroundImage(pickedFile.path);
          emit(BackgroundLoaded(pickedFile.path));
        } catch (e) {
          emit(BackgroundError('Failed to take photo: ${e.toString()}'));
        }
      } else {
        emit(BackgroundError('No photo taken'));
      }
    });

    on<LoadBackgroundEvent>((event, emit) async {
      try {
        final imagePath = await backgroundDataSource.getBackgroundImage();
        if (imagePath != null) {
          emit(BackgroundLoaded(imagePath));
        } else {
          emit(BackgroundInitial());
        }
      } catch (e) {
        emit(BackgroundError('Failed to load background: ${e.toString()}'));
      }
    });
  }
}
