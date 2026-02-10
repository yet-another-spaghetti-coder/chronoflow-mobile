import 'package:chronoflow/models/organiser_registration.dart';
import 'package:flutter/material.dart';

class RegistrationController {
  final contactNumberController = TextEditingController();
  final organisationNameController = TextEditingController();
  final organisationAddressController = TextEditingController();
  final organisationCodeController = TextEditingController();

  // Get the registration object from all controllers
  OrganiserRegistration getRegistration() {
    return OrganiserRegistration(
      contactNumber: contactNumberController.text,
      organisationName: organisationNameController.text,
      organisationAddress: organisationAddressController.text,
      organisationCode: organisationCodeController.text,
    );
  }

  // Set values from a registration object
  void setRegistration(OrganiserRegistration registration) {
    contactNumberController.text = registration.contactNumber;
    organisationNameController.text = registration.organisationName;
    organisationAddressController.text = registration.organisationAddress;
    organisationCodeController.text = registration.organisationCode;
  }

  // Clear all fields
  void clear() {
    contactNumberController.clear();
    organisationNameController.clear();
    organisationAddressController.clear();
    organisationCodeController.clear();
  }

  // Dispose all controllers
  void dispose() {
    contactNumberController.dispose();
    organisationNameController.dispose();
    organisationAddressController.dispose();
    organisationCodeController.dispose();
  }
}