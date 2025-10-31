import 'package:one_atta/features/contact/data/models/contact_model.dart';

abstract class ContactRemoteDataSource {
  Future<ContactModel> getContactDetails();
}
