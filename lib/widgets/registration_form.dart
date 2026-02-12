import 'package:chronoflow/models/organiser_registration.dart';
import 'package:chronoflow/widgets/registration_form_controller.dart';
import 'package:flutter/material.dart';

class RegistrationForm extends StatefulWidget {
  final void Function(OrganiserRegistration orgReg) submitRegistrationForm;
  const RegistrationForm({required this.submitRegistrationForm, super.key});

  @override
  State<RegistrationForm> createState() => _RegistrationFormState();
}

class _RegistrationFormState extends State<RegistrationForm> {
  final _formKey = GlobalKey<FormState>();
  final _registrationController = RegistrationController();

  @override
  void dispose() {
    _registrationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          const Text('Contact number'),
          TextFormField(
            controller: _registrationController.contactNumberController,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter contact number';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          const Text('Organisation name'),
          TextFormField(
            controller: _registrationController.organisationNameController,
            textAlign: TextAlign.center,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter organisation name';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          const Text('Organisation address'),
          TextFormField(
            controller: _registrationController.organisationAddressController,
            textAlign: TextAlign.center,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter organisation address';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          const Text('Organisation code'),
          TextFormField(
            controller: _registrationController.organisationCodeController,
            textAlign: TextAlign.center,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter organisation code';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                // Get the registration object from the controller
                widget.submitRegistrationForm(
                  _registrationController.getRegistration(),
                );
              }
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}
