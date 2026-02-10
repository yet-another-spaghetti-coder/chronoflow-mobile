class OrganiserRegistration {
  String contactNumber;
  String organisationName;
  String organisationAddress;
  String organisationCode;
  OrganiserRegistration({
    required this.contactNumber,
    required this.organisationName,
    required this.organisationAddress,
    required this.organisationCode,
  });

  OrganiserRegistration.empty()
      : contactNumber = '',
        organisationName = '',
        organisationAddress = '',
        organisationCode = '';

  Map<String, dynamic> toJson() {
    return {
      'mobile': contactNumber,
      'organizationName': organisationName,
      'organizationAddress': organisationAddress,
      'organizationCode': organisationCode,
    };
  }
}