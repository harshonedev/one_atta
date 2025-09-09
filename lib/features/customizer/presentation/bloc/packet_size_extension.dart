import 'package:one_atta/features/customizer/presentation/bloc/customizer_bloc.dart';

extension PacketSizeExtension on PacketSize {
  int get weightInKg {
    switch (this) {
      case PacketSize.kg1:
        return 1;
      case PacketSize.kg3:
        return 3;
      case PacketSize.kg5:
        return 5;
    }
  }
}
