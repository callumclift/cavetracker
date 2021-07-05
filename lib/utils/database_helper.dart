import 'dart:async';
import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import '../shared/global_config.dart';
import '../shared/strings.dart';

class DatabaseHelper {

  //Singleton DatabaseHelper - only one instance throughout the app
  static DatabaseHelper _databaseHelper;
  //Singleton Database object
  static Database _database;
  //Form version number
  static String formVersion = 'form_version';
  static String formCustomerId = 'customer_document_id';

  //Organisation Table
  static String organisationTable = 'organisation_table';
  static String localId = 'local_id';
  static String documentId = 'document_id';
  static String name = 'name';
  static String licenses = 'licenses';
  static String organisationEmail = 'email';
  static String organisationContactEmail = 'contact_email';
  static String organisationTelephone = 'telephone';
  static String gasSafeRegNo = 'gas_safe_reg_no';
  static String address = 'address';
  static String postcode = 'postcode';
  static String vatRegNo = 'vat_reg_no';
  static String latitude = 'latitude';
  static String longitude = 'longitude';
  static String sortCode = 'sort_code';
  static String accountNumber = 'account_number';
  static String accountName = 'account_name';
  static String accountBank = 'account_bank';
  static String engineersFullName = 'engineers_name';
  static String logo = 'logo';

  //Customers Table
  static String customersTable = 'customers_table';
  static String customerPrefix = 'prefix';
  static String customerFirstName = 'first_name';
  static String customerLastName = 'last_name';
  static String customerFullName = 'full_name';
  static String customerAddress = 'address';
  static String customerPostcode = 'postcode';
  static String customerEmail = 'email';
  static String customerTelephone = 'telephone';
  static String customerMobile = 'mobile';
  static String boilerCare = 'boiler_care';
  static String boilerCarePlus = 'boiler_care_plus';
  static String private = 'private';
  static String tenant = 'tenant';
  static String tenantLandlordName = 'tenant_landlord_name';
  static String tenantLandlordAddress = 'tenant_landlord_address';
  static String tenantLandlordPostcode = 'tenant_landlord_postcode';
  static String tenantLandlordContact = 'tenant_landlord_contact';
  static String tenantLandlordEmail = 'tenant_landlord_email';
  static String customerBoilerMake = 'customer_boiler_make';
  static String customerBoilerModel = 'customer_boiler_model';
  static String customerBoilerType = 'customer_boiler_type';
  static String customerBoilerFire = 'customer_boiler_fire';
  static String customerJobOutstanding = 'customer_job_outstanding';


  //Users Table
  static String usersTable = 'users_table';
  static String uid = 'uid';
  static String firstName = 'first_name';
  static String lastName = 'last_name';
  static String fullName = 'full_name';
  static String password = 'password';
  static String email = 'email';
  static String mobile = 'mobile';
  static String organisationId = 'organisation_id';
  static String organisationName = 'organisation_name';
  static String role = 'role';
  static String suspended = 'suspended';
  static String deleted = 'deleted';
  static String termsAccepted = 'terms_accepted';
  static String gasSafeId = 'gas_safe_id';
  static String forcePasswordReset = 'force_password_reset';

  //Warning Advisory Record table
  static String warningAdvisoryRecordTable = 'warning_advisory_record_table';
  static String escapeOfGas = 'escape_of_gas';
  static String escapeOfGasYes = 'escape_of_gas_yes';
  static String escapeOfGasNo = 'escape_of_gas_no';
  static String gasInstallation = 'gas_installation';
  static String gasAppliance = 'gas_appliance';
  static String applianceManufacturer = 'appliance_manufacturer';
  static String applianceModel = 'appliance_model';
  static String applianceType = 'appliance_type';
  static String applianceSerialNo = 'appliance_serialno';
  static String applianceLocation = 'appliance_location';
  static String immediatelyDangerous = 'immediately_dangerous';
  static String immediatelyDangerousReason = 'immediately_dangerous_reason';
  static String disconnectedYes = 'diconnected_yes';
  static String disconnectedNo = 'diconnected_no';
  static String permissionRefusedYes = 'permission_refused_yes';
  static String permissionRefusedNo = 'permission_refused_no';
  static String isAtRisk = 'is_at_risk';
  static String isAtRiskReason = 'is_at_risk_reason';
  static String turnedOffYes = 'turned_off_yes';
  static String turnedOffNo = 'turned_off_no';
  static String notToCurrentStandards = 'not_to_current_standards';
  static String ncsManufacturer = 'ncs_manufacturer';
  static String ncsModel = 'ncs_model';
  static String ncsType = 'ncs_type';
  static String ncsSerialNo = 'ncs_serialno';
  static String ncsLocation = 'ncs_location';
  static String notToCurrentStandardsReason = 'not_to_current_standards_reason';
  static String responsiblePersonsSignature = 'responsible_persons_signature';
  static String responsiblePersonsSignaturePoints = 'responsible_persons_signature_points';
  static String responsiblePersonPrintName = 'responsible_person_print_name';
  static String responsiblePersonDate = 'responsible_person_date';
  static String responsiblePersonNotPresent = 'responsible_person_not_present';

  //Warning Advisory Record table
  static String temporaryWarningAdvisoryRecordTable = 'temporary_warning_advisory_record_table';
  static String temporaryEscapeOfGas = 'escape_of_gas';
  static String temporaryEscapeOfGasYes = 'escape_of_gas_yes';
  static String temporaryEscapeOfGasNo = 'escape_of_gas_no';
  static String temporaryGasInstallation = 'gas_installation';
  static String temporaryGasAppliance = 'gas_appliance';
  static String temporaryApplianceManufacturer = 'appliance_manufacturer';
  static String temporaryApplianceModel = 'appliance_model';
  static String temporaryApplianceType = 'appliance_type';
  static String temporaryApplianceSerialNo = 'appliance_serialno';
  static String temporaryApplianceLocation = 'appliance_location';
  static String temporaryImmediatelyDangerous = 'immediately_dangerous';
  static String temporaryImmediatelyDangerousReason = 'immediately_dangerous_reason';
  static String temporaryDisconnectedYes = 'diconnected_yes';
  static String temporaryDisconnectedNo = 'diconnected_no';
  static String temporaryPermissionRefusedYes = 'permission_refused_yes';
  static String temporaryPermissionRefusedNo = 'permission_refused_no';
  static String temporaryIsAtRisk = 'is_at_risk';
  static String temporaryIsAtRiskReason = 'is_at_risk_reason';
  static String temporaryTurnedOffYes = 'turned_off_yes';
  static String temporaryTurnedOffNo = 'turned_off_no';
  static String temporaryNotToCurrentStandards = 'not_to_current_standards';
  static String temporaryNcsManufacturer = 'ncs_manufacturer';
  static String temporaryNcsModel = 'ncs_model';
  static String temporaryNcsType = 'ncs_type';
  static String temporaryNcsSerialNo = 'ncs_serialno';
  static String temporaryNcsLocation = 'ncs_location';
  static String temporaryNotToCurrentStandardsReason = 'not_to_current_standards_reason';
  static String temporaryResponsiblePersonsSignature = 'responsible_persons_signature';
  static String temporaryResponsiblePersonsSignaturePoints = 'responsible_persons_signature_points';
  static String temporaryResponsiblePersonPrintName = 'responsible_person_print_name';
  static String temporaryResponsiblePersonDate = 'responsible_person_date';
  static String temporaryResponsiblePersonNotPresent = 'responsible_person_not_present';


  //Gas Safety Record table
  static String gasSafetyRecordTable = 'gas_safety_record_table';
  static String installerName = 'installer_name';
  static String inspectionAddressName = 'inspection_address_name';
  static String inspectionAddress = 'inspection_address';
  static String inspectionPostcode = 'inspection_postcode';
  static String inspectionTelephone = 'inspection_telephone';
  static String inspectionEmail = 'inspection_email';
  static String landlordName = 'landlord_name';
  static String landlordAddress = 'landlord_address';
  static String landlordPostcode = 'landlord_postcode';
  static String landlordTelephone = 'landlord_telephone';
  static String landlordEmail = 'landlord_email';
  static String gsrLocation1 = 'location1';
  static String gsrMake1 = 'make1';
  static String gsrModel1 = 'model1';
  static String gsrType1 = 'type1';
  static String gsrFlueType1 = 'flue_type1';
  static String gsrOperationPressure1 = 'operating_pressure1';
  static String gsrSafetyDevice1 = 'safety_device1';
  static String gsrFlueOperation1 = 'flue_operation1';
  static String gsrCombustionAnalyser1 = 'combustion_analyser1';
  static String gsrSatisfactoryTermination1 = 'satisfactory_termination1';
  static String gsrVisualCondition1 = 'visual_condition1';
  static String gsrAdequateVentilation1 = 'adequate_ventilation1';
  static String gsrApplianceSafe1 = 'appliance_safe1';
  static String gsrLandlordsAppliance1 = 'landlords_appliance1';
  static String gsrInspected1 = 'inspected1';
  static String gsrApplianceServiced1 = 'appliance_serviced1';
  static String gsrLocation2 = 'location2';
  static String gsrMake2 = 'make2';
  static String gsrModel2 = 'model2';
  static String gsrType2 = 'type2';
  static String gsrFlueType2 = 'flue_type2';
  static String gsrOperationPressure2 = 'operating_pressure2';
  static String gsrSafetyDevice2 = 'safety_device2';
  static String gsrFlueOperation2 = 'flue_operation2';
  static String gsrCombustionAnalyser2 = 'combustion_analyser2';
  static String gsrSatisfactoryTermination2 = 'satisfactory_termination2';
  static String gsrVisualCondition2 = 'visual_condition2';
  static String gsrAdequateVentilation2 = 'adequate_ventilation2';
  static String gsrApplianceSafe2 = 'appliance_safe2';
  static String gsrLandlordsAppliance2 = 'landlords_appliance2';
  static String gsrInspected2 = 'inspected2';
  static String gsrApplianceServiced2 = 'appliance_serviced2';
  static String gsrLocation3 = 'location3';
  static String gsrMake3 = 'make3';
  static String gsrModel3 = 'model3';
  static String gsrType3 = 'type3';
  static String gsrFlueType3 = 'flue_type3';
  static String gsrOperationPressure3 = 'operating_pressure3';
  static String gsrSafetyDevice3 = 'safety_device3';
  static String gsrFlueOperation3 = 'flue_operation3';
  static String gsrCombustionAnalyser3 = 'combustion_analyser3';
  static String gsrSatisfactoryTermination3 = 'satisfactory_termination3';
  static String gsrVisualCondition3 = 'visual_condition3';
  static String gsrAdequateVentilation3 = 'adequate_ventilation3';
  static String gsrApplianceSafe3 = 'appliance_safe3';
  static String gsrLandlordsAppliance3 = 'landlords_appliance3';
  static String gsrInspected3 = 'inspected3';
  static String gsrApplianceServiced3 = 'appliance_serviced3';
  static String gsrLocation4 = 'location4';
  static String gsrMake4 = 'make4';
  static String gsrModel4 = 'model4';
  static String gsrType4 = 'type4';
  static String gsrFlueType4 = 'flue_type4';
  static String gsrOperationPressure4 = 'operating_pressure4';
  static String gsrSafetyDevice4 = 'safety_device4';
  static String gsrFlueOperation4 = 'flue_operation4';
  static String gsrCombustionAnalyser4 = 'combustion_analyser4';
  static String gsrSatisfactoryTermination4 = 'satisfactory_termination4';
  static String gsrVisualCondition4 = 'visual_condition4';
  static String gsrAdequateVentilation4 = 'adequate_ventilation4';
  static String gsrApplianceSafe4 = 'appliance_safe4';
  static String gsrLandlordsAppliance4 = 'landlords_appliance4';
  static String gsrInspected4 = 'inspected4';
  static String gsrApplianceServiced4 = 'appliance_serviced4';
  static String gsrLocation5 = 'location5';
  static String gsrMake5 = 'make5';
  static String gsrModel5 = 'model5';
  static String gsrType5 = 'type5';
  static String gsrFlueType5 = 'flue_type5';
  static String gsrOperationPressure5 = 'operating_pressure5';
  static String gsrSafetyDevice5 = 'safety_device5';
  static String gsrFlueOperation5 = 'flue_operation5';
  static String gsrCombustionAnalyser5 = 'combustion_analyser5';
  static String gsrSatisfactoryTermination5 = 'satisfactory_termination5';
  static String gsrVisualCondition5 = 'visual_condition5';
  static String gsrAdequateVentilation5 = 'adequate_ventilation5';
  static String gsrApplianceSafe5 = 'appliance_safe5';
  static String gsrLandlordsAppliance5 = 'landlords_appliance5';
  static String gsrInspected5 = 'inspected5';
  static String gsrApplianceServiced5 = 'appliance_serviced5';
  static String visualInspectionYes = 'visual_inspection_yes';
  static String visualInspectionNo = 'visual_inspection_no';
  static String emergencyControlYes = 'emergency_control_yes';
  static String emergencyControlNo = 'emergency_control_no';
  static String satisfactorySoundnessYes = 'satisfactory_soundness_yes';
  static String satisfactorySoundnessNo = 'satisfactory_soundness_no';
  static String faultDetails1 = 'fault_details1';
  static String warningNotice1 = 'warning_notice1';
  static String warningSticker1 = 'warning_sticker1';
  static String faultDetails2 = 'fault_details2';
  static String warningNotice2 = 'warning_notice2';
  static String warningSticker2 = 'warning_sticker2';
  static String faultDetails3 = 'fault_details3';
  static String warningNotice3 = 'warning_notice3';
  static String warningSticker3 = 'warning_sticker3';
  static String numberAppliancesTested = 'number_appliances_tested';
  static String issuersSignature = 'issuers_signature';
  static String issuersSignaturePoints = 'issuers_signature_points';
  static String issuerPrintName = 'issuer_print_name';
  static String issuerDate = 'issuer_date';
  static String landlordsSignature = 'landlords_signature';
  static String landlordsSignaturePoints = 'landlords_signature_points';
  static String signatureType = 'signature_type';
  static String landlordDate = 'landlord_date';

  //Temporary Gas Safety Record table
  static String temporaryGasSafetyRecordTable = 'temporary_gas_safety_record_table';
  static String temporaryInstallerName = 'installer_name';
  static String temporaryInspectionAddressName = 'inspection_address_name';
  static String temporaryInspectionAddress = 'inspection_address';
  static String temporaryInspectionPostcode = 'inspection_postcode';
  static String temporaryInspectionTelephone = 'inspection_telephone';
  static String temporaryInspectionEmail = 'inspection_email';
  static String temporaryLandlordName = 'landlord_name';
  static String temporaryLandlordAddress = 'landlord_address';
  static String temporaryLandlordPostcode = 'landlord_postcode';
  static String temporaryLandlordTelephone = 'landlord_telephone';
  static String temporaryLandlordEmail = 'landlord_email';
  static String temporaryGsrLocation1 = 'location1';
  static String temporaryGsrMake1 = 'make1';
  static String temporaryGsrModel1 = 'model1';
  static String temporaryGsrType1 = 'type1';
  static String temporaryGsrFlueType1 = 'flue_type1';
  static String temporaryGsrOperationPressure1 = 'operating_pressure1';
  static String temporaryGsrSafetyDevice1 = 'safety_device1';
  static String temporaryGsrFlueOperation1 = 'flue_operation1';
  static String temporaryGsrCombustionAnalyser1 = 'combustion_analyser1';
  static String temporaryGsrSatisfactoryTermination1 = 'satisfactory_termination1';
  static String temporaryGsrVisualCondition1 = 'visual_condition1';
  static String temporaryGsrAdequateVentilation1 = 'adequate_ventilation1';
  static String temporaryGsrApplianceSafe1 = 'appliance_safe1';
  static String temporaryGsrLandlordsAppliance1 = 'landlords_appliance1';
  static String temporaryGsrInspected1 = 'inspected1';
  static String temporaryGsrApplianceServiced1 = 'appliance_serviced1';
  static String temporaryGsrLocation2 = 'location2';
  static String temporaryGsrMake2 = 'make2';
  static String temporaryGsrModel2 = 'model2';
  static String temporaryGsrType2 = 'type2';
  static String temporaryGsrFlueType2 = 'flue_type2';
  static String temporaryGsrOperationPressure2 = 'operating_pressure2';
  static String temporaryGsrSafetyDevice2 = 'safety_device2';
  static String temporaryGsrFlueOperation2 = 'flue_operation2';
  static String temporaryGsrCombustionAnalyser2 = 'combustion_analyser2';
  static String temporaryGsrSatisfactoryTermination2 = 'satisfactory_termination2';
  static String temporaryGsrVisualCondition2 = 'visual_condition2';
  static String temporaryGsrAdequateVentilation2 = 'adequate_ventilation2';
  static String temporaryGsrApplianceSafe2 = 'appliance_safe2';
  static String temporaryGsrLandlordsAppliance2 = 'landlords_appliance2';
  static String temporaryGsrInspected2 = 'inspected2';
  static String temporaryGsrApplianceServiced2 = 'appliance_serviced2';
  static String temporaryGsrLocation3 = 'location3';
  static String temporaryGsrMake3 = 'make3';
  static String temporaryGsrModel3 = 'model3';
  static String temporaryGsrType3 = 'type3';
  static String temporaryGsrFlueType3 = 'flue_type3';
  static String temporaryGsrOperationPressure3 = 'operating_pressure3';
  static String temporaryGsrSafetyDevice3 = 'safety_device3';
  static String temporaryGsrFlueOperation3 = 'flue_operation3';
  static String temporaryGsrCombustionAnalyser3 = 'combustion_analyser3';
  static String temporaryGsrSatisfactoryTermination3 = 'satisfactory_termination3';
  static String temporaryGsrVisualCondition3 = 'visual_condition3';
  static String temporaryGsrAdequateVentilation3 = 'adequate_ventilation3';
  static String temporaryGsrApplianceSafe3 = 'appliance_safe3';
  static String temporaryGsrLandlordsAppliance3 = 'landlords_appliance3';
  static String temporaryGsrInspected3 = 'inspected3';
  static String temporaryGsrApplianceServiced3 = 'appliance_serviced3';
  static String temporaryGsrLocation4 = 'location4';
  static String temporaryGsrMake4 = 'make4';
  static String temporaryGsrModel4 = 'model4';
  static String temporaryGsrType4 = 'type4';
  static String temporaryGsrFlueType4 = 'flue_type4';
  static String temporaryGsrOperationPressure4 = 'operating_pressure4';
  static String temporaryGsrSafetyDevice4 = 'safety_device4';
  static String temporaryGsrFlueOperation4 = 'flue_operation4';
  static String temporaryGsrCombustionAnalyser4 = 'combustion_analyser4';
  static String temporaryGsrSatisfactoryTermination4 = 'satisfactory_termination4';
  static String temporaryGsrVisualCondition4 = 'visual_condition4';
  static String temporaryGsrAdequateVentilation4 = 'adequate_ventilation4';
  static String temporaryGsrApplianceSafe4 = 'appliance_safe4';
  static String temporaryGsrLandlordsAppliance4 = 'landlords_appliance4';
  static String temporaryGsrInspected4 = 'inspected4';
  static String temporaryGsrApplianceServiced4 = 'appliance_serviced4';
  static String temporaryGsrLocation5 = 'location5';
  static String temporaryGsrMake5 = 'make5';
  static String temporaryGsrModel5 = 'model5';
  static String temporaryGsrType5 = 'type5';
  static String temporaryGsrFlueType5 = 'flue_type5';
  static String temporaryGsrOperationPressure5 = 'operating_pressure5';
  static String temporaryGsrSafetyDevice5 = 'safety_device5';
  static String temporaryGsrFlueOperation5 = 'flue_operation5';
  static String temporaryGsrCombustionAnalyser5 = 'combustion_analyser5';
  static String temporaryGsrSatisfactoryTermination5 = 'satisfactory_termination5';
  static String temporaryGsrVisualCondition5 = 'visual_condition5';
  static String temporaryGsrAdequateVentilation5 = 'adequate_ventilation5';
  static String temporaryGsrApplianceSafe5 = 'appliance_safe5';
  static String temporaryGsrLandlordsAppliance5 = 'landlords_appliance5';
  static String temporaryGsrInspected5 = 'inspected5';
  static String temporaryGsrApplianceServiced5 = 'appliance_serviced5';
  static String temporaryVisualInspectionYes = 'visual_inspection_yes';
  static String temporaryVisualInspectionNo = 'visual_inspection_no';
  static String temporaryEmergencyControlYes = 'emergency_control_yes';
  static String temporaryEmergencyControlNo = 'emergency_control_no';
  static String temporarySatisfactorySoundnessYes = 'satisfactory_soundness_yes';
  static String temporarySatisfactorySoundnessNo = 'satisfactory_soundness_no';
  static String temporaryFaultDetails1 = 'fault_details1';
  static String temporaryWarningNotice1 = 'warning_notice1';
  static String temporaryWarningSticker1 = 'warning_sticker1';
  static String temporaryFaultDetails2 = 'fault_details2';
  static String temporaryWarningNotice2 = 'warning_notice2';
  static String temporaryWarningSticker2 = 'warning_sticker2';
  static String temporaryFaultDetails3 = 'fault_details3';
  static String temporaryWarningNotice3 = 'warning_notice3';
  static String temporaryWarningSticker3 = 'warning_sticker3';
  static String temporaryNumberAppliancesTested = 'number_appliances_tested';
  static String temporaryIssuersSignature = 'issuers_signature';
  static String temporaryIssuersSignaturePoints = 'issuers_signature_points';
  static String temporaryIssuerPrintName = 'issuer_print_name';
  static String temporaryIssuerDate = 'issuer_date';
  static String temporaryLandlordsSignature = 'landlords_signature';
  static String temporaryLandlordsSignaturePoints = 'landlords_signature_points';
  static String temporarySignatureType = 'signature_type';
  static String temporaryLandlordDate = 'landlord_date';

  //Caravan Gas Safety Record table
  static String caravanGasSafetyRecordTable = 'caravan_gas_safety_record_table';
  static String caravanInstallerName = 'caravan_installer_name';
  static String caravanPark = 'caravan_park';
  static String caravanLocation = 'caravan_location';
  static String caravanManufacturer = 'caravan_manufacturer';
  static String caravanModel = 'caravan_model';
  static String caravanManufactureDate = 'caravan_manufacture_date';
  static String caravanOwnerName = 'caravan_owner_name';
  static String caravanOwnerAddress = 'caravan_owner_address';
  static String caravanOwnerPostCode = 'caravan_owner_post_code';
  static String caravanOwnerTelNo = 'caravan_owner_tel_no';
  static String caravanOwnerEmail = 'caravan_owner_email';
  static String caravanInspectionDate = 'caravan_inspection_date';
  static String caravanRecordSerialNo = 'caravan_record_serial_no';
  static String caravanStockCardNo = 'caravan_stock_card_no';
  static String caravanWaterHeaterMake = 'caravan_water_heater_make';
  static String caravanWaterHeaterModel = 'caravan_water_heater_model';
  static String caravanWaterHeaterOperatingPressure = 'caravan_water_heater_operating_pressure';
  static String caravanWaterHeaterOperationOfSafetyDevicesPass = 'caravan_water_heater_operation_of_safety_devices_pass';
  static String caravanWaterHeaterOperationOfSafetyDevicesFail = 'caravan_water_heater_operation_of_safety_devices_fail';
  static String caravanWaterHeaterVentilationPass = 'caravan_water_heater_ventilation_pass';
  static String caravanWaterHeaterVentilationFail = 'caravan_water_heater_ventilation_fail';
  static String caravanWaterHeaterFlueType = 'caravan_water_heater_flue_type';
  static String caravanWaterHeaterFlueSpillagePass = 'caravan_water_heater_flue_spillage_pass';
  static String caravanWaterHeaterFlueSpillageFail = 'caravan_water_heater_flue_spillage_fail';
  static String caravanWaterHeaterFlueTerminationYes = 'caravan_water_heater_flue_termination_yes';
  static String caravanWaterHeaterFlueTerminationNo = 'caravan_water_heater_flue_termination_no';
  static String caravanWaterHeaterExtendedFlueYes = 'caravan_water_heater_extended_flue_yes';
  static String caravanWaterHeaterExtendedFlueNo = 'caravan_water_heater_extended_flue_no';
  static String caravanWaterHeaterExtendedFlueNa = 'caravan_water_heater_extended_flue_na';
  static String caravanWaterHeaterFlueConditionPass = 'caravan_water_heater_flue_condition_pass';
  static String caravanWaterHeaterFlueConditionFail = 'caravan_water_heater_flue_condition_fail';
  static String caravanWaterHeaterApplianceSafeYes = 'caravan_water_heater_appliance_safe_yes';
  static String caravanWaterHeaterApplianceSafeNo = 'caravan_water_heater_appliance_safe_no';
  static String caravanFireMake = 'caravan_fire_make';
  static String caravanFireModel = 'caravan_fire_model';
  static String caravanFireOperatingPressure = 'caravan_fire_operating_pressure';
  static String caravanFireOperationOfSafetyDevicesPass = 'caravan_fire_operation_of_safety_devices_pass';
  static String caravanFireOperationOfSafetyDevicesFail = 'caravan_fire_operation_of_safety_devices_fail';
  static String caravanFireVentilationPass = 'caravan_fire_ventilation_pass';
  static String caravanFireVentilationFail = 'caravan_fire_ventilation_fail';
  static String caravanFireFlueType = 'caravan_fire_flue_type';
  static String caravanFireFlueSpillagePass = 'caravan_fire_flue_spillage_pass';
  static String caravanFireFlueSpillageFail = 'caravan_fire_flue_spillage_fail';
  static String caravanFireFlueTerminationYes = 'caravan_fire_flue_termination_yes';
  static String caravanFireFlueTerminationNo = 'caravan_fire_flue_termination_no';
  static String caravanFireExtendedFlueYes = 'caravan_fire_extended_flue_yes';
  static String caravanFireExtendedFlueNo = 'caravan_fire_extended_flue_no';
  static String caravanFireExtendedFlueNa = 'caravan_fire_extended_flue_na';
  static String caravanFireFlueConditionPass = 'caravan_fire_flue_condition_pass';
  static String caravanFireFlueConditionFail = 'caravan_fire_flue_condition_fail';
  static String caravanFireApplianceSafeYes = 'caravan_fire_appliance_safe_yes';
  static String caravanFireApplianceSafeNo = 'caravan_fire_appliance_safe_no';
  static String caravanCookerMake = 'caravan_cooker_make';
  static String caravanCookerModel = 'caravan_cooker_model';
  static String caravanCookerOperatingPressure = 'caravan_cooker_operating_pressure';
  static String caravanCookerOperationOfSafetyDevicesPass = 'caravan_cooker_operation_of_safety_devices_pass';
  static String caravanCookerOperationOfSafetyDevicesFail = 'caravan_cooker_operation_of_safety_devices_fail';
  static String caravanCookerVentilationPass = 'caravan_cooker_ventilation_pass';
  static String caravanCookerVentilationFail = 'caravan_cooker_ventilation_fail';
  static String caravanCookerFlueType = 'caravan_cooker_flue_type';
  static String caravanCookerFlueSpillagePass = 'caravan_cooker_flue_spillage_pass';
  static String caravanCookerFlueSpillageFail = 'caravan_cooker_flue_spillage_fail';
  static String caravanCookerFlueTerminationYes = 'caravan_cooker_flue_termination_yes';
  static String caravanCookerFlueTerminationNo = 'caravan_cooker_flue_termination_no';
  static String caravanCookerExtendedFlueYes = 'caravan_cooker_extended_flue_yes';
  static String caravanCookerExtendedFlueNo = 'caravan_cooker_extended_flue_no';
  static String caravanCookerExtendedFlueNa = 'caravan_cooker_extended_flue_na';
  static String caravanCookerFlueConditionPass = 'caravan_cooker_flue_condition_pass';
  static String caravanCookerFlueConditionFail = 'caravan_cooker_flue_condition_fail';
  static String caravanCookerApplianceSafeYes = 'caravan_cooker_appliance_safe_yes';
  static String caravanCookerApplianceSafeNo = 'caravan_cooker_appliance_safe_no';
  static String caravanOtherMake = 'caravan_other_make';
  static String caravanOtherModel = 'caravan_other_model';
  static String caravanOtherOperatingPressure = 'caravan_other_operating_pressure';
  static String caravanOtherOperationOfSafetyDevicesPass = 'caravan_other_operation_of_safety_devices_pass';
  static String caravanOtherOperationOfSafetyDevicesFail = 'caravan_other_operation_of_safety_devices_fail';
  static String caravanOtherVentilationPass = 'caravan_other_ventilation_pass';
  static String caravanOtherVentilationFail = 'caravan_other_ventilation_fail';
  static String caravanOtherFlueType = 'caravan_other_flue_type';
  static String caravanOtherFlueSpillagePass = 'caravan_other_flue_spillage_pass';
  static String caravanOtherFlueSpillageFail = 'caravan_other_flue_spillage_fail';
  static String caravanOtherFlueTerminationYes = 'caravan_other_flue_termination_yes';
  static String caravanOtherFlueTerminationNo = 'caravan_other_flue_termination_no';
  static String caravanOtherExtendedFlueYes = 'caravan_other_extended_flue_yes';
  static String caravanOtherExtendedFlueNo = 'caravan_other_extended_flue_no';
  static String caravanOtherExtendedFlueNa = 'caravan_other_extended_flue_na';
  static String caravanOtherFlueConditionPass = 'caravan_other_flue_condition_pass';
  static String caravanOtherFlueConditionFail = 'caravan_other_flue_condition_fail';
  static String caravanOtherApplianceSafeYes = 'caravan_other_appliance_safe_yes';
  static String caravanOtherApplianceSafeNo = 'caravan_other_appliance_safe_no';
  static String caravanSoundnessCheckPass = 'caravan_soundness_check_pass';
  static String caravanSoundnessCheckFail = 'caravan_soundness_check_fail';
  static String caravanHoseCheckPass = 'caravan_hose_check_pass';
  static String caravanHoseCheckFail = 'caravan_hose_check_fail';
  static String caravanRegulatorOperatingPressurePass = 'caravan_regulator_operating_pressure_pass';
  static String caravanRegulatorOperatingPressureFail = 'caravan_regulator_operating_pressure_fail';
  static String caravanRegulatorLockUpPressure = 'caravan_regulator_lock_up_pressure';
  static String caravanRegulatorLockUpPressurePass = 'caravan_regulator_lock_up_pressure_pass';
  static String caravanRegulatorLockUpPressureFail = 'caravan_regulator_lock_up_pressure_fail';
  static String caravanFaultDetails1 = 'caravan_fault_details1';
  static String caravanRectificationWork1 = 'caravan_rectification_work1';
  static String caravanByWhom1 = 'caravan_by_whom1';
  static String caravanOwnerInformedYes1 = 'caravan_owner_informed_yes1';
  static String caravanOwnerInformedNo1 = 'caravan_owner_informed_no1';
  static String caravanWarningNoticeYes1 = 'caravan_warning_notice_yes1';
  static String caravanWarningNoticeNo1 = 'caravan_warning_notice_no1';
  static String caravanWarningTagYes1 = 'caravan_warning_tag_yes1';
  static String caravanWarningTagNo1 = 'caravan_warning_tag_no1';
  static String caravanFaultDetails2 = 'caravan_fault_details2';
  static String caravanRectificationWork2 = 'caravan_rectification_work2';
  static String caravanByWhom2 = 'caravan_by_whom2';
  static String caravanOwnerInformedYes2 = 'caravan_owner_informed_yes2';
  static String caravanOwnerInformedNo2 = 'caravan_owner_informed_no2';
  static String caravanWarningNoticeYes2 = 'caravan_warning_notice_yes2';
  static String caravanWarningNoticeNo2 = 'caravan_warning_notice_no2';
  static String caravanWarningTagYes2 = 'caravan_warning_tag_yes2';
  static String caravanWarningTagNo2 = 'caravan_warning_tag_no2';
  static String caravanFaultDetails3 = 'caravan_fault_details3';
  static String caravanRectificationWork3 = 'caravan_rectification_work3';
  static String caravanByWhom3 = 'caravan_by_whom3';
  static String caravanOwnerInformedYes3 = 'caravan_owner_informed_yes3';
  static String caravanOwnerInformedNo3 = 'caravan_owner_informed_no3';
  static String caravanWarningNoticeYes3 = 'caravan_warning_notice_yes3';
  static String caravanWarningNoticeNo3 = 'caravan_warning_notice_no3';
  static String caravanWarningTagYes3 = 'caravan_warning_tag_yes3';
  static String caravanWarningTagNo3 = 'caravan_warning_tag_no3';
  static String caravanFaultDetails4 = 'caravan_fault_details4';
  static String caravanRectificationWork4 = 'caravan_rectification_work4';
  static String caravanByWhom4 = 'caravan_by_whom4';
  static String caravanOwnerInformedYes4 = 'caravan_owner_informed_yes4';
  static String caravanOwnerInformedNo4 = 'caravan_owner_informed_no4';
  static String caravanWarningNoticeYes4 = 'caravan_warning_notice_yes4';
  static String caravanWarningNoticeNo4 = 'caravan_warning_notice_no4';
  static String caravanWarningTagYes4 = 'caravan_warning_tag_yes4';
  static String caravanWarningTagNo4 = 'caravan_warning_tag_no4';
  static String caravanFaultDetails5 = 'caravan_fault_details5';
  static String caravanRectificationWork5 = 'caravan_rectification_work5';
  static String caravanByWhom5 = 'caravan_by_whom5';
  static String caravanOwnerInformedYes5 = 'caravan_owner_informed_yes5';
  static String caravanOwnerInformedNo5 = 'caravan_owner_informed_no5';
  static String caravanWarningNoticeYes5 = 'caravan_warning_notice_yes5';
  static String caravanWarningNoticeNo5 = 'caravan_warning_notice_no5';
  static String caravanWarningTagYes5 = 'caravan_warning_tag_yes5';
  static String caravanWarningTagNo5 = 'caravan_warning_tag_no5';
  static String caravanNumberOfAppliancesTested = 'caravan_number_of_appliances_tested';
  static String caravanSerialNo = 'caravan_serial_no';
  static String caravanIssuerSignature = 'caravan_issuer_signature';
  static String caravanIssuerSignaturePoints = 'caravan_issuer_signature_points';
  static String caravanIssuerPrintName = 'caravan_issuer_print_name';
  static String caravanIssuerDate = 'caravan_issuer_date';
  static String caravanAgentSignature = 'caravan_agent_signature';
  static String caravanAgentSignaturePoints = 'caravan_agent_signature_points';
  static String caravanAgentDate = 'caravan_agent_date';
  static String caravanApplianceType1 = 'caravan_appliance_type1';
  static String caravanApplianceType2 = 'caravan_appliance_type2';
  static String caravanApplianceType3 = 'caravan_appliance_type3';
  static String caravanApplianceType4 = 'caravan_appliance_type4';

  //Temporary Caravan Gas Safety Record table
  static String temporaryCaravanGasSafetyRecordTable = 'temporary_caravan_gas_safety_record_table';
  static String temporaryCaravanInstallerName = 'caravan_installer_name';
  static String temporaryCaravanPark = 'caravan_park';
  static String temporaryCaravanLocation = 'caravan_location';
  static String temporaryCaravanManufacturer = 'caravan_manufacturer';
  static String temporaryCaravanModel = 'caravan_model';
  static String temporaryCaravanManufactureDate = 'caravan_manufacture_date';
  static String temporaryCaravanOwnerName = 'caravan_owner_name';
  static String temporaryCaravanOwnerAddress = 'caravan_owner_address';
  static String temporaryCaravanOwnerPostCode = 'caravan_owner_post_code';
  static String temporaryCaravanOwnerTelNo = 'caravan_owner_tel_no';
  static String temporaryCaravanOwnerEmail = 'caravan_owner_email';
  static String temporaryCaravanInspectionDate = 'caravan_inspection_date';
  static String temporaryCaravanRecordSerialNo = 'caravan_record_serial_no';
  static String temporaryCaravanStockCardNo = 'caravan_stock_card_no';
  static String temporaryCaravanWaterHeaterMake = 'caravan_water_heater_make';
  static String temporaryCaravanWaterHeaterModel = 'caravan_water_heater_model';
  static String temporaryCaravanWaterHeaterOperatingPressure = 'caravan_water_heater_operating_pressure';
  static String temporaryCaravanWaterHeaterOperationOfSafetyDevicesPass = 'caravan_water_heater_operation_of_safety_devices_pass';
  static String temporaryCaravanWaterHeaterOperationOfSafetyDevicesFail = 'caravan_water_heater_operation_of_safety_devices_fail';
  static String temporaryCaravanWaterHeaterVentilationPass = 'caravan_water_heater_ventilation_pass';
  static String temporaryCaravanWaterHeaterVentilationFail = 'caravan_water_heater_ventilation_fail';
  static String temporaryCaravanWaterHeaterFlueType = 'caravan_water_heater_flue_type';
  static String temporaryCaravanWaterHeaterFlueSpillagePass = 'caravan_water_heater_flue_spillage_pass';
  static String temporaryCaravanWaterHeaterFlueSpillageFail = 'caravan_water_heater_flue_spillage_fail';
  static String temporaryCaravanWaterHeaterFlueTerminationYes = 'caravan_water_heater_flue_termination_yes';
  static String temporaryCaravanWaterHeaterFlueTerminationNo = 'caravan_water_heater_flue_termination_no';
  static String temporaryCaravanWaterHeaterExtendedFlueYes = 'caravan_water_heater_extended_flue_yes';
  static String temporaryCaravanWaterHeaterExtendedFlueNo = 'caravan_water_heater_extended_flue_no';
  static String temporaryCaravanWaterHeaterExtendedFlueNa = 'caravan_water_heater_extended_flue_na';
  static String temporaryCaravanWaterHeaterFlueConditionPass = 'caravan_water_heater_flue_condition_pass';
  static String temporaryCaravanWaterHeaterFlueConditionFail = 'caravan_water_heater_flue_condition_fail';
  static String temporaryCaravanWaterHeaterApplianceSafeYes = 'caravan_water_heater_appliance_safe_yes';
  static String temporaryCaravanWaterHeaterApplianceSafeNo = 'caravan_water_heater_appliance_safe_no';
  static String temporaryCaravanFireMake = 'caravan_fire_make';
  static String temporaryCaravanFireModel = 'caravan_fire_model';
  static String temporaryCaravanFireOperatingPressure = 'caravan_fire_operating_pressure';
  static String temporaryCaravanFireOperationOfSafetyDevicesPass = 'caravan_fire_operation_of_safety_devices_pass';
  static String temporaryCaravanFireOperationOfSafetyDevicesFail = 'caravan_fire_operation_of_safety_devices_fail';
  static String temporaryCaravanFireVentilationPass = 'caravan_fire_ventilation_pass';
  static String temporaryCaravanFireVentilationFail = 'caravan_fire_ventilation_fail';
  static String temporaryCaravanFireFlueType = 'caravan_fire_flue_type';
  static String temporaryCaravanFireFlueSpillagePass = 'caravan_fire_flue_spillage_pass';
  static String temporaryCaravanFireFlueSpillageFail = 'caravan_fire_flue_spillage_fail';
  static String temporaryCaravanFireFlueTerminationYes = 'caravan_fire_flue_termination_yes';
  static String temporaryCaravanFireFlueTerminationNo = 'caravan_fire_flue_termination_no';
  static String temporaryCaravanFireExtendedFlueYes = 'caravan_fire_extended_flue_yes';
  static String temporaryCaravanFireExtendedFlueNo = 'caravan_fire_extended_flue_no';
  static String temporaryCaravanFireExtendedFlueNa = 'caravan_fire_extended_flue_na';
  static String temporaryCaravanFireFlueConditionPass = 'caravan_fire_flue_condition_pass';
  static String temporaryCaravanFireFlueConditionFail = 'caravan_fire_flue_condition_fail';
  static String temporaryCaravanFireApplianceSafeYes = 'caravan_fire_appliance_safe_yes';
  static String temporaryCaravanFireApplianceSafeNo = 'caravan_fire_appliance_safe_no';
  static String temporaryCaravanCookerMake = 'caravan_cooker_make';
  static String temporaryCaravanCookerModel = 'caravan_cooker_model';
  static String temporaryCaravanCookerOperatingPressure = 'caravan_cooker_operating_pressure';
  static String temporaryCaravanCookerOperationOfSafetyDevicesPass = 'caravan_cooker_operation_of_safety_devices_pass';
  static String temporaryCaravanCookerOperationOfSafetyDevicesFail = 'caravan_cooker_operation_of_safety_devices_fail';
  static String temporaryCaravanCookerVentilationPass = 'caravan_cooker_ventilation_pass';
  static String temporaryCaravanCookerVentilationFail = 'caravan_cooker_ventilation_fail';
  static String temporaryCaravanCookerFlueType = 'caravan_cooker_flue_type';
  static String temporaryCaravanCookerFlueSpillagePass = 'caravan_cooker_flue_spillage_pass';
  static String temporaryCaravanCookerFlueSpillageFail = 'caravan_cooker_flue_spillage_fail';
  static String temporaryCaravanCookerFlueTerminationYes = 'caravan_cooker_flue_termination_yes';
  static String temporaryCaravanCookerFlueTerminationNo = 'caravan_cooker_flue_termination_no';
  static String temporaryCaravanCookerExtendedFlueYes = 'caravan_cooker_extended_flue_yes';
  static String temporaryCaravanCookerExtendedFlueNo = 'caravan_cooker_extended_flue_no';
  static String temporaryCaravanCookerExtendedFlueNa = 'caravan_cooker_extended_flue_na';
  static String temporaryCaravanCookerFlueConditionPass = 'caravan_cooker_flue_condition_pass';
  static String temporaryCaravanCookerFlueConditionFail = 'caravan_cooker_flue_condition_fail';
  static String temporaryCaravanCookerApplianceSafeYes = 'caravan_cooker_appliance_safe_yes';
  static String temporaryCaravanCookerApplianceSafeNo = 'caravan_cooker_appliance_safe_no';
  static String temporaryCaravanOtherMake = 'caravan_other_make';
  static String temporaryCaravanOtherModel = 'caravan_other_model';
  static String temporaryCaravanOtherOperatingPressure = 'caravan_other_operating_pressure';
  static String temporaryCaravanOtherOperationOfSafetyDevicesPass = 'caravan_other_operation_of_safety_devices_pass';
  static String temporaryCaravanOtherOperationOfSafetyDevicesFail = 'caravan_other_operation_of_safety_devices_fail';
  static String temporaryCaravanOtherVentilationPass = 'caravan_other_ventilation_pass';
  static String temporaryCaravanOtherVentilationFail = 'caravan_other_ventilation_fail';
  static String temporaryCaravanOtherFlueType = 'caravan_other_flue_type';
  static String temporaryCaravanOtherFlueSpillagePass = 'caravan_other_flue_spillage_pass';
  static String temporaryCaravanOtherFlueSpillageFail = 'caravan_other_flue_spillage_fail';
  static String temporaryCaravanOtherFlueTerminationYes = 'caravan_other_flue_termination_yes';
  static String temporaryCaravanOtherFlueTerminationNo = 'caravan_other_flue_termination_no';
  static String temporaryCaravanOtherExtendedFlueYes = 'caravan_other_extended_flue_yes';
  static String temporaryCaravanOtherExtendedFlueNo = 'caravan_other_extended_flue_no';
  static String temporaryCaravanOtherExtendedFlueNa = 'caravan_other_extended_flue_na';
  static String temporaryCaravanOtherFlueConditionPass = 'caravan_other_flue_condition_pass';
  static String temporaryCaravanOtherFlueConditionFail = 'caravan_other_flue_condition_fail';
  static String temporaryCaravanOtherApplianceSafeYes = 'caravan_other_appliance_safe_yes';
  static String temporaryCaravanOtherApplianceSafeNo = 'caravan_other_appliance_safe_no';
  static String temporaryCaravanSoundnessCheckPass = 'caravan_soundness_check_pass';
  static String temporaryCaravanSoundnessCheckFail = 'caravan_soundness_check_fail';
  static String temporaryCaravanHoseCheckPass = 'caravan_hose_check_pass';
  static String temporaryCaravanHoseCheckFail = 'caravan_hose_check_fail';
  static String temporaryCaravanRegulatorOperatingPressurePass = 'caravan_regulator_operating_pressure_pass';
  static String temporaryCaravanRegulatorOperatingPressureFail = 'caravan_regulator_operating_pressure_fail';
  static String temporaryCaravanRegulatorLockUpPressure = 'caravan_regulator_lock_up_pressure';
  static String temporaryCaravanRegulatorLockUpPressurePass = 'caravan_regulator_lock_up_pressure_pass';
  static String temporaryCaravanRegulatorLockUpPressureFail = 'caravan_regulator_lock_up_pressure_fail';
  static String temporaryCaravanFaultDetails1 = 'caravan_fault_details1';
  static String temporaryCaravanRectificationWork1 = 'caravan_rectification_work1';
  static String temporaryCaravanByWhom1 = 'caravan_by_whom1';
  static String temporaryCaravanOwnerInformedYes1 = 'caravan_owner_informed_yes1';
  static String temporaryCaravanOwnerInformedNo1 = 'caravan_owner_informed_no1';
  static String temporaryCaravanWarningNoticeYes1 = 'caravan_warning_notice_yes1';
  static String temporaryCaravanWarningNoticeNo1 = 'caravan_warning_notice_no1';
  static String temporaryCaravanWarningTagYes1 = 'caravan_warning_tag_yes1';
  static String temporaryCaravanWarningTagNo1 = 'caravan_warning_tag_no1';
  static String temporaryCaravanFaultDetails2 = 'caravan_fault_details2';
  static String temporaryCaravanRectificationWork2 = 'caravan_rectification_work2';
  static String temporaryCaravanByWhom2 = 'caravan_by_whom2';
  static String temporaryCaravanOwnerInformedYes2 = 'caravan_owner_informed_yes2';
  static String temporaryCaravanOwnerInformedNo2 = 'caravan_owner_informed_no2';
  static String temporaryCaravanWarningNoticeYes2 = 'caravan_warning_notice_yes2';
  static String temporaryCaravanWarningNoticeNo2 = 'caravan_warning_notice_no2';
  static String temporaryCaravanWarningTagYes2 = 'caravan_warning_tag_yes2';
  static String temporaryCaravanWarningTagNo2 = 'caravan_warning_tag_no2';
  static String temporaryCaravanFaultDetails3 = 'caravan_fault_details3';
  static String temporaryCaravanRectificationWork3 = 'caravan_rectification_work3';
  static String temporaryCaravanByWhom3 = 'caravan_by_whom3';
  static String temporaryCaravanOwnerInformedYes3 = 'caravan_owner_informed_yes3';
  static String temporaryCaravanOwnerInformedNo3 = 'caravan_owner_informed_no3';
  static String temporaryCaravanWarningNoticeYes3 = 'caravan_warning_notice_yes3';
  static String temporaryCaravanWarningNoticeNo3 = 'caravan_warning_notice_no3';
  static String temporaryCaravanWarningTagYes3 = 'caravan_warning_tag_yes3';
  static String temporaryCaravanWarningTagNo3 = 'caravan_warning_tag_no3';
  static String temporaryCaravanFaultDetails4 = 'caravan_fault_details4';
  static String temporaryCaravanRectificationWork4 = 'caravan_rectification_work4';
  static String temporaryCaravanByWhom4 = 'caravan_by_whom4';
  static String temporaryCaravanOwnerInformedYes4 = 'caravan_owner_informed_yes4';
  static String temporaryCaravanOwnerInformedNo4 = 'caravan_owner_informed_no4';
  static String temporaryCaravanWarningNoticeYes4 = 'caravan_warning_notice_yes4';
  static String temporaryCaravanWarningNoticeNo4 = 'caravan_warning_notice_no4';
  static String temporaryCaravanWarningTagYes4 = 'caravan_warning_tag_yes4';
  static String temporaryCaravanWarningTagNo4 = 'caravan_warning_tag_no4';
  static String temporaryCaravanFaultDetails5 = 'caravan_fault_details5';
  static String temporaryCaravanRectificationWork5 = 'caravan_rectification_work5';
  static String temporaryCaravanByWhom5 = 'caravan_by_whom5';
  static String temporaryCaravanOwnerInformedYes5 = 'caravan_owner_informed_yes5';
  static String temporaryCaravanOwnerInformedNo5 = 'caravan_owner_informed_no5';
  static String temporaryCaravanWarningNoticeYes5 = 'caravan_warning_notice_yes5';
  static String temporaryCaravanWarningNoticeNo5 = 'caravan_warning_notice_no5';
  static String temporaryCaravanWarningTagYes5 = 'caravan_warning_tag_yes5';
  static String temporaryCaravanWarningTagNo5 = 'caravan_warning_tag_no5';
  static String temporaryCaravanNumberOfAppliancesTested = 'caravan_number_of_appliances_tested';
  static String temporaryCaravanSerialNo = 'caravan_serial_no';
  static String temporaryCaravanIssuerSignature = 'caravan_issuer_signature';
  static String temporaryCaravanIssuerSignaturePoints = 'caravan_issuer_signature_points';
  static String temporaryCaravanIssuerPrintName = 'caravan_issuer_print_name';
  static String temporaryCaravanIssuerDate = 'caravan_issuer_date';
  static String temporaryCaravanAgentSignature = 'caravan_agent_signature';
  static String temporaryCaravanAgentSignaturePoints = 'caravan_agent_signature_points';
  static String temporaryCaravanAgentDate = 'caravan_agent_date';
  static String temporaryCaravanApplianceType1 = 'caravan_appliance_type1';
  static String temporaryCaravanApplianceType2 = 'caravan_appliance_type2';
  static String temporaryCaravanApplianceType3 = 'caravan_appliance_type3';
  static String temporaryCaravanApplianceType4 = 'caravan_appliance_type4';



  //Maintenance/Service Checklist
  static String maintenanceChecklistTable = 'maintenance_checklist_table';
  static String jobId = 'job_id';
  static String pendingTime = 'pending_time';
  static String clientName = 'client_name';
  static String clientAddress = 'client_address';
  static String clientPostcode = 'client_postcode';
  static String clientTelephone = 'client_telephone';
  static String clientEmail = 'client_email';
  static String routineService = 'routine_service';
  static String callOut = 'call_out';
  static String install = 'install';
  static String companyName = 'company_name';
  static String companyAddress = 'company_address';
  static String companyPostcode = 'company_postcode';
  static String companyTelephone = 'company_telephone';
  static String companyVatRegNo = 'vat_reg_no';
  static String engineersGasSafeId = 'gas_safe_id';
  static String applianceMake1 = 'appliance_make1';
  static String applianceType1 = 'appliance_type1';
  static String applianceModel1 = 'appliance_model1';
  static String applianceLocation1 = 'appliance_location1';
  static String applianceHeatExchanger1 = 'appliance_heat_exchanger1';
  static String applianceBurnerInjectors1 = 'appliance_burner_injectors1';
  static String applianceFlamePicture1 = 'appliance_flame_picture1';
  static String applianceIgnition1 = 'appliance_ignition1';
  static String applianceElectrics1 = 'appliance_electrics1';
  static String applianceControls1 = 'appliance_controls1';
  static String applianceLeaksGasWater1 = 'appliance_leaks_gas_water1';
  static String applianceGasConnections1 = 'appliance_gas_connections1';
  static String applianceSeals1 = 'appliance_seals1';
  static String appliancePipework1 = 'appliance_pipework1';
  static String applianceFans1 = 'appliance_fans1';
  static String applianceFireplaceClosurePlate1 = 'appliance_fireplace_closure1';
  static String applianceAllowableLocation1 = 'appliance_allowable_location1';
  static String applianceChamberGasket1 = 'appliance_chamber_gasket1';
  static String applianceCondensate1 = 'appliance_condensate1';
  static String safetyVentilation1 = 'safety_ventilation1';
  static String safetyFlueTermination1 = 'safety_flue_termination1';
  static String safetySmokePelletFlueFlowTest1 = 'safety_smoke_pellet_flue_flow_test1';
  static String safetySmokeMatchSpillageTest1 = 'safety_smoke_match_spillage_test1';
  static String safetyWorkingPressure1 = 'safety_working_pressure1';
  static String safetyDevice1 = 'safety_device1';
  static String safetyFlueCombustionTestCo21 = 'safety_flue_combustion_test_co21';
  static String safetyFlueCombustionTestCo1 = 'safety_flue_combustion_test_co1';
  static String safetyFlueCombustionTestRatio1 = 'safety_flue_combustion_test_ratio1';
  static String safetyGasTightnessTestPerformedPass = 'safety_gas_tightness_test_performed_pass';
  static String safetyGasTightnessTestPerformedFail = 'safety_gas_tightness_test_performed_fail';
  static String safetyOperatingPressure1 = 'safety_operating_pressure1';
  static String safetyGasMeterEarthBondedYes = 'safety_gas_meter_earth_bonded_yes';
  static String safetyGasMeterEarthBondedNo = 'safety_gas_meter_earth_bonded_no';
  static String applianceMake2 = 'appliance_make2';
  static String applianceType2 = 'appliance_type2';
  static String applianceModel2 = 'appliance_model2';
  static String applianceLocation2 = 'appliance_location2';
  static String applianceHeatExchanger2 = 'appliance_heat_exchanger2';
  static String applianceBurnerInjectors2 = 'appliance_burner_injectors2';
  static String applianceFlamePicture2 = 'appliance_flame_picture2';
  static String applianceIgnition2 = 'appliance_ignition2';
  static String applianceElectrics2 = 'appliance_electrics2';
  static String applianceControls2 = 'appliance_controls2';
  static String applianceLeaksGasWater2 = 'appliance_leaks_gas_water2';
  static String applianceGasConnections2 = 'appliance_gas_connections2';
  static String applianceSeals2 = 'appliance_seals2';
  static String appliancePipework2 = 'appliance_pipework2';
  static String applianceFans2 = 'appliance_fans2';
  static String applianceFireplaceClosurePlate2 = 'appliance_fireplace_closure2';
  static String applianceAllowableLocation2 = 'appliance_allowable_location2';
  static String applianceChamberGasket2 = 'appliance_chamber_gasket2';
  static String applianceCondensate2 = 'appliance_condensate2';
  static String safetyVentilation2 = 'safety_ventilation2';
  static String safetyFlueTermination2 = 'safety_flue_termination2';
  static String safetySmokePelletFlueFlowTest2 = 'safety_smoke_pellet_flue_flow_test2';
  static String safetySmokeMatchSpillageTest2 = 'safety_smoke_match_spillage_test2';
  static String safetyWorkingPressure2 = 'safety_working_pressure2';
  static String safetyDevice2 = 'safety_device2';
  static String safetyFlueCombustionTestCo22 = 'safety_flue_combustion_test_co22';
  static String safetyFlueCombustionTestCo2 = 'safety_flue_combustion_test_co2';
  static String safetyFlueCombustionTestRatio2 = 'safety_flue_combustion_test_ratio2';
  static String safetyOperatingPressure2 = 'safety_operating_pressure2';
  static String installationApplianceSafeYes = 'installation_appliance_safe_yes';
  static String installationApplianceSafeNo = 'installation_appliance_safe_no';
  static String warningLabelAttachedYes = 'warning_label_attached_yes';
  static String warningLabelAttachedNo = 'warning_label_attached_no';
  static String maintenanceFaultDetails1 = 'fault_details1';
  static String maintenanceWarningNoticeYes1 = 'warning_notice_yes1';
  static String maintenanceWarningNoticeNo1 = 'warning_notice_no1';
  static String maintenanceWarningStickerYes1 = 'warning_sticker_yes1';
  static String maintenanceWarningStickerNo1 = 'warning_sticker_no1';
  static String maintenanceFaultDetails2 = 'fault_details2';
  static String maintenanceWarningNoticeYes2 = 'warning_notice_yes2';
  static String maintenanceWarningNoticeNo2 = 'warning_notice_no2';
  static String maintenanceWarningStickerYes2 = 'warning_sticker_yes2';
  static String maintenanceWarningStickerNo2 = 'warning_sticker_no2';
  static String maintenanceFaultDetails3 = 'fault_details3';
  static String maintenanceWarningNoticeYes3 = 'warning_notice_yes3';
  static String maintenanceWarningNoticeNo3 = 'warning_notice_no3';
  static String maintenanceWarningStickerYes3 = 'warning_sticker_yes3';
  static String maintenanceWarningStickerNo3 = 'warning_sticker_no3';
  static String paymentReceived = 'payment_received';
  static String paymentReceivedType = 'payment_type';
  static String invoiceTotal = 'invoice_total';
  static String sendBillOut = 'send_bill_out';
  static String appliancesVisiblyCheckedYes = 'appliances_visibly_checked_yes';
  static String appliancesVisiblyCheckedNo = 'appliances_visibly_checked_no';
  static String appliancesVisiblyCheckedText = 'appliances_visibly_checked_text';
  static String customersSignature = 'customers_signature';
  static String customersSignaturePoints = 'customers_signature_points';
  static String customerPrintName = 'customer_print_name';
  static String customerDate = 'customer_date';
  static String engineersSignature = 'engineers_signature';
  static String engineersSignaturePoints = 'engineers_signature_points';
  static String engineerPrintName = 'engineer_print_name';
  static String engineerDate = 'engineer_date';
  static String engineersComments = 'engineers_comments';
  static String serverUploaded = 'server_uploaded';
  static String signaturesUploaded = 'signatures_uploaded';
  static String timestamp = 'timestamp';


  //Maintenance/Service Checklist
  static String temporaryMaintenanceChecklistTable = 'temporary_maintenance_checklist_table';
  static String temporaryJobId = 'job_id';
  static String temporaryClientName = 'client_name';
  static String temporaryClientAddress = 'client_address';
  static String temporaryClientPostcode = 'client_postcode';
  static String temporaryClientTelephone = 'client_telephone';
  static String temporaryClientEmail = 'client_email';
  static String temporaryRoutineService = 'routine_service';
  static String temporaryCallOut = 'call_out';
  static String temporaryInstall = 'install';
  static String temporaryCompanyName = 'company_name';
  static String temporaryGasSafeRegNo = 'gas_safe_reg_no';
  static String temporaryCompanyAddress = 'company_address';
  static String temporaryCompanyPostcode = 'company_postcode';
  static String temporaryCompanyTelephone = 'company_telephone';
  static String temporaryCompanyVatRegNo = 'vat_reg_no';
  static String temporaryEngineersGasSafeId = 'gas_safe_id';
  static String temporaryApplianceMake1 = 'appliance_make1';
  static String temporaryApplianceType1 = 'appliance_type1';
  static String temporaryApplianceModel1 = 'appliance_model1';
  static String temporaryApplianceLocation1 = 'appliance_location1';
  static String temporaryApplianceHeatExchanger1 = 'appliance_heat_exchanger1';
  static String temporaryApplianceBurnerInjectors1 = 'appliance_burner_injectors1';
  static String temporaryApplianceFlamePicture1 = 'appliance_flame_picture1';
  static String temporaryApplianceIgnition1 = 'appliance_ignition1';
  static String temporaryApplianceElectrics1 = 'appliance_electrics1';
  static String temporaryApplianceControls1 = 'appliance_controls1';
  static String temporaryApplianceLeaksGasWater1 = 'appliance_leaks_gas_water1';
  static String temporaryApplianceGasConnections1 = 'appliance_gas_connections1';
  static String temporaryApplianceSeals1 = 'appliance_seals1';
  static String temporaryAppliancePipework1 = 'appliance_pipework1';
  static String temporaryApplianceFans1 = 'appliance_fans1';
  static String temporaryApplianceFireplaceClosurePlate1 = 'appliance_fireplace_closure1';
  static String temporaryApplianceAllowableLocation1 = 'appliance_allowable_location1';
  static String temporaryApplianceChamberGasket1 = 'appliance_chamber_gasket1';
  static String temporarySafetyVentilation1 = 'safety_ventilation1';
  static String temporarySafetyFlueTermination1 = 'safety_flue_termination1';
  static String temporarySafetySmokePelletFlueFlowTest1 = 'safety_smoke_pellet_flue_flow_test1';
  static String temporarySafetySmokeMatchSpillageTest1 = 'safety_smoke_match_spillage_test1';
  static String temporarySafetyWorkingPressure1 = 'safety_working_pressure1';
  static String temporarySafetyDevice1 = 'safety_device1';
  static String temporaryApplianceCondensate1 = 'appliance_condensate1';
  static String temporarySafetyFlueCombustionTestCo21 = 'safety_flue_combustion_test_co21';
  static String temporarySafetyFlueCombustionTestCo1 = 'safety_flue_combustion_test_co1';
  static String temporarySafetyFlueCombustionTestRatio1 = 'safety_flue_combustion_test_ratio1';
  static String temporarySafetyGasTightnessTestPerformedPass = 'safety_gas_tightness_test_performed_pass';
  static String temporarySafetyGasTightnessTestPerformedFail = 'safety_gas_tightness_test_performed_fail';
  static String temporarySafetyOperatingPressure1 = 'safety_operating_pressure1';
  static String temporarySafetyGasMeterEarthBondedYes = 'safety_gas_meter_earth_bonded_yes';
  static String temporarySafetyGasMeterEarthBondedNo = 'safety_gas_meter_earth_bonded_no';
  static String temporaryApplianceMake2 = 'appliance_make2';
  static String temporaryApplianceType2 = 'appliance_type2';
  static String temporaryApplianceModel2 = 'appliance_model2';
  static String temporaryApplianceLocation2 = 'appliance_location2';
  static String temporaryApplianceHeatExchanger2 = 'appliance_heat_exchanger2';
  static String temporaryApplianceBurnerInjectors2 = 'appliance_burner_injectors2';
  static String temporaryApplianceFlamePicture2 = 'appliance_flame_picture2';
  static String temporaryApplianceIgnition2 = 'appliance_ignition2';
  static String temporaryApplianceElectrics2 = 'appliance_electrics2';
  static String temporaryApplianceControls2 = 'appliance_controls2';
  static String temporaryApplianceLeaksGasWater2 = 'appliance_leaks_gas_water2';
  static String temporaryApplianceGasConnections2 = 'appliance_gas_connections2';
  static String temporaryApplianceSeals2 = 'appliance_seals2';
  static String temporaryAppliancePipework2 = 'appliance_pipework2';
  static String temporaryApplianceFans2 = 'appliance_fans2';
  static String temporaryApplianceFireplaceClosurePlate2 = 'appliance_fireplace_closure2';
  static String temporaryApplianceAllowableLocation2 = 'appliance_allowable_location2';
  static String temporaryApplianceChamberGasket2 = 'appliance_chamber_gasket2';
  static String temporarySafetyVentilation2 = 'safety_ventilation2';
  static String temporarySafetyFlueTermination2 = 'safety_flue_termination2';
  static String temporarySafetySmokePelletFlueFlowTest2 = 'safety_smoke_pellet_flue_flow_test2';
  static String temporarySafetySmokeMatchSpillageTest2 = 'safety_smoke_match_spillage_test2';
  static String temporarySafetyWorkingPressure2 = 'safety_working_pressure2';
  static String temporarySafetyDevice2 = 'safety_device2';
  static String temporaryApplianceCondensate2 = 'appliance_condensate2';
  static String temporarySafetyFlueCombustionTestCo22 = 'safety_flue_combustion_test_co22';
  static String temporarySafetyFlueCombustionTestCo2 = 'safety_flue_combustion_test_co2';
  static String temporarySafetyFlueCombustionTestRatio2 = 'safety_flue_combustion_test_ratio2';
  static String temporarySafetyOperatingPressure2 = 'safety_operating_pressure2';
  static String temporaryInstallationApplianceSafeYes = 'installation_appliance_safe_yes';
  static String temporaryInstallationApplianceSafeNo = 'installation_appliance_safe_no';
  static String temporaryWarningLabelAttachedYes = 'warning_label_attached_yes';
  static String temporaryWarningLabelAttachedNo = 'warning_label_attached_no';
  static String temporaryMaintenanceFaultDetails1 = 'fault_details1';
  static String temporaryMaintenanceWarningNoticeYes1 = 'warning_notice_yes1';
  static String temporaryMaintenanceWarningNoticeNo1 = 'warning_notice_no1';
  static String temporaryMaintenanceWarningStickerYes1 = 'warning_sticker_yes1';
  static String temporaryMaintenanceWarningStickerNo1 = 'warning_sticker_no1';
  static String temporaryMaintenanceFaultDetails2 = 'fault_details2';
  static String temporaryMaintenanceWarningNoticeYes2 = 'warning_notice_yes2';
  static String temporaryMaintenanceWarningNoticeNo2 = 'warning_notice_no2';
  static String temporaryMaintenanceWarningStickerYes2 = 'warning_sticker_yes2';
  static String temporaryMaintenanceWarningStickerNo2 = 'warning_sticker_no2';
  static String temporaryMaintenanceFaultDetails3 = 'fault_details3';
  static String temporaryMaintenanceWarningNoticeYes3 = 'warning_notice_yes3';
  static String temporaryMaintenanceWarningNoticeNo3 = 'warning_notice_no3';
  static String temporaryMaintenanceWarningStickerYes3 = 'warning_sticker_yes3';
  static String temporaryMaintenanceWarningStickerNo3 = 'warning_sticker_no3';
  static String temporaryPaymentReceived = 'payment_received';
  static String temporaryPaymentReceivedType = 'payment_type';
  static String temporaryInvoiceTotal = 'invoice_total';
  static String temporarySendBillOut = 'send_bill_out';
  static String temporaryAppliancesVisiblyCheckedYes = 'appliances_visibly_checked_yes';
  static String temporaryAppliancesVisiblyCheckedNo = 'appliances_visibly_checked_no';
  static String temporaryAppliancesVisiblyCheckedText = 'appliances_visibly_checked_text';
  static String temporaryCustomersSignature = 'customers_signature';
  static String temporaryCustomersSignaturePoints = 'customers_signature_points';
  static String temporaryCustomerPrintName = 'customer_print_name';
  static String temporaryCustomerDate = 'customer_date';
  static String temporaryEngineersSignature = 'engineers_signature';
  static String temporaryEngineersSignaturePoints = 'engineers_signature_points';
  static String temporaryEngineerPrintName = 'engineer_print_name';
  static String temporaryEngineerDate = 'engineer_date';
  static String temporaryEngineersComments = 'engineers_comments';

  //Vehicle Checklist Table
  static String vehicleChecklistTable = 'vehicle_checklist_table';
  static String driverName = 'driver_name';
  static String vehicleType = 'vehicle_type';
  static String currentMileage = 'current_mileage';
  static String treadDriversSideFrontTyre = 'tread_drivers_side_front_tyre';
  static String treadDriversSideRearTyre = 'tread_drivers_side_rear_tyre';
  static String treadPassengersSideFrontTyre = 'tread_passengers_side_front_tyre';
  static String treadPassengersSideRearTyre = 'tread_passengers_side_rear_tyre';
  static String pressureDriversSideFrontTyre = 'pressure_drivers_side_front_tyre';
  static String pressureDriversSideRearTyre = 'pressure_drivers_side_rear_tyre';
  static String pressurePassengersSideFrontTyre = 'pressure_passengers_side_front_tyre';
  static String pressurePassengersSideRearTyre = 'pressure_passengers_side_rear_tyre';
  static String warningLights = 'warning_lights';
  static String nextService = 'next_service';
  static String specialistEquipment = 'specialist_equipment';
  static String specialistEquipmentYesNoValue = 'specialist_equipment_yes_no_value';
  static String driverFeedback = 'driver_feedback';
  static String driversSignature = 'drivers_signature';
  static String driversSignaturePoints = 'drivers_signature_points';
  static String driverDate = 'driver_date';
  static String completedSheetTo = 'completed_sheet_to';
  static String deadlineForReturn = 'deadline_for_return';
  static String queryContact = 'query_contact';
  static String reviewDate = 'review_date';

  //Temporary Vehicle Checklist Table
  static String temporaryVehicleChecklistTable = 'temporary_vehicle_checklist_table';
  static String temporaryDriverName = 'driver_name';
  static String temporaryVehicleType = 'vehicle_type';
  static String temporaryCurrentMileage = 'current_mileage';
  static String temporaryTreadDriversSideFrontTyre = 'tread_drivers_side_front_tyre';
  static String temporaryTreadDriversSideRearTyre = 'tread_drivers_side_rear_tyre';
  static String temporaryTreadPassengersSideFrontTyre = 'tread_passengers_side_front_tyre';
  static String temporaryTreadPassengersSideRearTyre = 'tread_passengers_side_rear_tyre';
  static String temporaryPressureDriversSideFrontTyre = 'pressure_drivers_side_front_tyre';
  static String temporaryPressureDriversSideRearTyre = 'pressure_drivers_side_rear_tyre';
  static String temporaryPressurePassengersSideFrontTyre = 'pressure_passengers_side_front_tyre';
  static String temporaryPressurePassengersSideRearTyre = 'pressure_passengers_side_rear_tyre';
  static String temporaryWarningLights = 'warning_lights';
  static String temporaryNextService = 'next_service';
  static String temporarySpecialistEquipment = 'specialist_equipment';
  static String temporarySpecialistEquipmentYesNoValue = 'specialist_equipment_yes_no_value';
  static String temporaryDriverFeedback = 'driver_feedback';
  static String temporaryDriversSignature = 'drivers_signature';
  static String temporaryDriversSignaturePoints = 'drivers_signature_points';
  static String temporaryDriverDate = 'driver_date';
  static String temporaryCompletedSheetTo = 'completed_sheet_to';
  static String temporaryDeadlineForReturn = 'deadline_for_return';
  static String temporaryQueryContact = 'query_contact';
  static String temporaryReviewDate = 'review_date';

  //Parts Form Table
  static String partsFormTable = 'parts_form_table';
  static String partsFormCompanyAddress = 'parts_form_company_address';
  static String partsFormCompanyPostCode = 'parts_form_company_post_code';
  static String partsFormCompanyTelNo = 'parts_form_company_tel_no';
  static String partsFormCompanyGasSafeRegNo = 'parts_form_company_gas_safe_reg_no';
  static String partsFormDate = 'parts_form_date';
  static String partsFormRefNo = 'parts_form_ref_no';
  static String partsFormName = 'parts_form_name';
  static String partsFormAddress = 'parts_form_address';
  static String partsFormPostCode = 'parts_form_post_code';
  static String partsFormBillingAddress = 'parts_form_billing_address';
  static String partsFormBillingPostCode = 'parts_form_billing_post_code';
  static String partsFormTelNo = 'parts_form_tel_no';
  static String partsFormMobile = 'parts_form_mobile';
  static String partsFormAppliance = 'parts_form_appliance';
  static String partsFormMake = 'parts_form_make';
  static String partsFormModel = 'parts_form_model';
  static String partsFormGcNo = 'parts_form_gc_no';
  static String partsFormPartsRequired = 'parts_form_parts_required';
  static String partsFormOrderedYes = 'parts_form_ordered_yes';
  static String partsFormOrderedNo = 'parts_form_ordered_no';
  static String partsFormSupplier = 'parts_form_supplier';
  static String partsFormSupplierText = 'parts_form_supplier_text';
  static String partsFormManufacturer = 'parts_form_manufacturer';
  static String partsFormFurther = 'parts_form_further';
  static String partsFormPrice = 'parts_form_price';
  static String partsFormFurtherInfo = 'parts_form_further_info';
  static String partsFormCustomersSignature = 'parts_form_customers_signature';
  static String partsFormCustomersSignaturePoints = 'parts_form_customers_signature_points';
  static String partsFormCustomersEmail = 'parts_form_customers_email';
  static String partsFormEngineersSignature = 'parts_form_engineers_signature';
  static String partsFormEngineersSignaturePoints = 'parts_form_engineers_signature_points';
  static String partsFormImages = 'parts_form_images';
  static String partsFormImageFiles = 'parts_form_image_files';
  static String partsFormLocalImages = 'parts_form_local_images';

  //Temporary Parts Form Table
  static String temporaryPartsFormTable = 'temporary_parts_form_table';
  static String temporaryPartsFormCompanyAddress = 'parts_form_company_address';
  static String temporaryPartsFormCompanyPostCode = 'parts_form_company_post_code';
  static String temporaryPartsFormCompanyTelNo = 'parts_form_company_tel_no';
  static String temporaryPartsFormCompanyGasSafeRegNo = 'parts_form_company_gas_safe_reg_no';
  static String temporaryPartsFormDate = 'parts_form_date';
  static String temporaryPartsFormRefNo = 'parts_form_ref_no';
  static String temporaryPartsFormName = 'parts_form_name';
  static String temporaryPartsFormAddress= 'parts_form_address';
  static String temporaryPartsFormPostCode = 'parts_form_post_code';
  static String temporaryPartsFormBillingAddress = 'parts_form_billing_address';
  static String temporaryPartsFormBillingPostCode = 'parts_form_billing_post_code';
  static String temporaryPartsFormTelNo = 'parts_form_tel_no';
  static String temporaryPartsFormMobile = 'parts_form_mobile';
  static String temporaryPartsFormAppliance = 'parts_form_appliance';
  static String temporaryPartsFormMake = 'parts_form_make';
  static String temporaryPartsFormModel = 'parts_form_model';
  static String temporaryPartsFormGcNo = 'parts_form_gc_no';
  static String temporaryPartsFormPartsRequired = 'parts_form_parts_required';
  static String temporaryPartsFormOrderedYes = 'parts_form_ordered_yes';
  static String temporaryPartsFormOrderedNo = 'parts_form_ordered_no';
  static String temporaryPartsFormSupplier = 'parts_form_supplier';
  static String temporaryPartsFormSupplierText = 'parts_form_supplier_text';
  static String temporaryPartsFormManufacturer = 'parts_form_manufacturer';
  static String temporaryPartsFormFurther = 'parts_form_further';
  static String temporaryPartsFormPrice = 'parts_form_price';
  static String temporaryPartsFormFurtherInfo = 'parts_form_further_info';
  static String temporaryPartsFormCustomersSignature = 'parts_form_customers_signature';
  static String temporaryPartsFormCustomersSignaturePoints = 'parts_form_customers_signature_points';
  static String temporaryPartsFormCustomersEmail = 'parts_form_customers_email';
  static String temporaryPartsFormEngineersSignature = 'parts_form_engineers_signature';
  static String temporaryPartsFormEngineersSignaturePoints = 'parts_form_engineers_signature_points';
  static String temporaryPartsFormImages = 'parts_form_images';
  static String temporaryPartsFormImageFiles = 'parts_form_image_files';
  static String temporaryPartsFormLocalImages = 'parts_form_local_images';

  //Job Table
  static String jobTable = 'job_table';
  static String jobNo = 'job_no';
  static String jobClient = 'client';
  static String jobAddress = 'address';
  static String jobPostCode = 'post_code';
  static String jobContactNo = 'contact_no';
  static String jobMobile = 'mobile';
  static String jobEmail = 'email';
  static String jobTime = 'time';
  static String jobDescription = 'description';
  static String jobEng = 'eng';
  static String jobDate = 'date';
  static String jobEngUid = 'eng_uid';
  static String jobEngEmail = 'eng_email';
  static String jobEngDocumentId = 'eng_document_id';
  static String jobStatus = 'status';
  static String jobCustomerId = 'customer_document_id';
  static String jobPaid = 'paid';
  static String jobCancellationReason = 'cancellation_reason';
  static String jobRescheduleReason = 'reschedule_reason';
  static String jobPaymentMethod = 'payment_method';
  static String jobType = 'job_type';
  static String jobCustomerLandlordName = 'job_customer_landlord_name';
  static String jobCustomerLandlordAddress = 'job_customer_landlord_address';
  static String jobCustomerLandlordPostcode = 'job_customer_landlord_postcode';
  static String jobCustomerLandlordContact = 'job_customer_landlord_contact';
  static String jobCustomerLandlordEmail = 'job_customer_landlord_email';
  static String jobCustomerBoilerMake = 'job_customer_boiler_make';
  static String jobCustomerBoilerModel = 'job_customer_boiler_model';
  static String jobCustomerBoilerType = 'job_customer_boiler_type';
  static String jobCustomerBoilerFire = 'job_customer_boiler_fire';


  //Temporary Job Table
  static String temporaryJobTable = 'temporary_job_table';
  static String temporaryJobNo = 'job_no';
  static String temporaryJobClient = 'client';
  static String temporaryJobAddress = 'address';
  static String temporaryJobPostCode = 'post_code';
  static String temporaryJobContactNo = 'contact_no';
  static String temporaryJobMobile = 'mobile';
  static String temporaryJobEmail = 'email';
  static String temporaryJobTime = 'time';
  static String temporaryJobDescription = 'description';
  static String temporaryJobEng = 'eng';
  static String temporaryJobEngEmail = 'eng_email';
  static String temporaryJobEngDocumentId = 'eng_document_id';
  static String temporaryJobDate = 'date';
  static String temporaryJobEngUid = 'eng_uid';
  static String temporaryJobCustomerId = 'customer_document_id';
  static String temporaryJobPaid = 'paid';
  static String temporaryJobType = 'job_type';
  static String temporaryJobCustomerLandlordName = 'job_customer_landlord_name';
  static String temporaryJobCustomerLandlordAddress = 'job_customer_landlord_address';
  static String temporaryJobCustomerLandlordPostcode = 'job_customer_landlord_postcode';
  static String temporaryJobCustomerLandlordContact = 'job_customer_landlord_contact';
  static String temporaryJobCustomerLandlordEmail = 'job_customer_landlord_email';
  static String temporaryJobCustomerBoilerMake = 'job_customer_boiler_make';
  static String temporaryJobCustomerBoilerModel = 'job_customer_boiler_model';
  static String temporaryJobCustomerBoilerType = 'job_customer_boiler_type';
  static String temporaryJobCustomerBoilerFire = 'job_customer_boiler_fire';


  //Temporary Organisation Table
  static String temporaryOrganisationTable = 'temporary_organisation_table';
  static String logoImagePath = 'logo_image_path';

  //Invoice Table
  static String invoiceTable = 'invoice_table';
  static String invoiceCompanyName = 'invoice_company_name';
  static String invoiceCompanyAddress = 'invoice_company_address';
  static String invoiceCompanyPostCode = 'invoice_company_post_code';
  static String invoiceCompanyTelNo = 'invoice_company_tel_no';
  static String invoiceCompanyVatRegNo = 'invoice_company_vat_reg_no';
  static String invoiceCompanyEmail = 'invoice_company_email';
  static String invoiceCustomerName = 'invoice_customer_name';
  static String invoiceCustomerAddress = 'invoice_customer_address';
  static String invoiceCustomerPostCode = 'invoice_customer_post_code';
  static String invoiceCustomerTelNo = 'invoice_customer_tel_no';
  static String invoiceCustomerMobile = 'invoice_customer_mobile';
  static String invoiceCustomerEmail = 'invoice_customer_email';
  static String invoiceNo = 'invoice_no';
  static String invoiceDate = 'invoice_date';
  static String invoiceDueDate = 'invoice_due_date';
  static String invoiceTerms = 'invoice_terms';
  static String invoiceComment = 'invoice_comment';
  static String invoiceItems = 'invoice_items';
  static String invoiceSubtotal = 'invoice_subtotal';
  static String invoiceVatAmount = 'invoice_vat_amount';
  static String invoiceTotalAmount = 'invoice_total_amount';
  static String invoicePaidAmount = 'invoice_paid_amount';
  static String invoiceBalanceDue = 'invoice_balance_due';
  static String invoicePaidFull = 'invoice_paid_full';
  static String invoiceJobNo = 'invoice_job_no';

  //Temporary Invoice Table
  static String temporaryInvoiceTable = 'temporary_invoice_table';
  static String temporaryInvoiceCompanyName = 'invoice_company_name';
  static String temporaryInvoiceCompanyAddress = 'invoice_company_address';
  static String temporaryInvoiceCompanyPostCode = 'invoice_company_post_code';
  static String temporaryInvoiceCompanyTelNo = 'invoice_company_tel_no';
  static String temporaryInvoiceCompanyVatRegNo = 'invoice_company_vat_reg_no';
  static String temporaryInvoiceCompanyEmail = 'invoice_company_email';
  static String temporaryInvoiceCustomerName = 'invoice_customer_name';
  static String temporaryInvoiceCustomerAddress = 'invoice_customer_address';
  static String temporaryInvoiceCustomerPostCode = 'invoice_customer_post_code';
  static String temporaryInvoiceCustomerTelNo = 'invoice_customer_tel_no';
  static String temporaryInvoiceCustomerMobile = 'invoice_customer_mobile';
  static String temporaryInvoiceCustomerEmail = 'invoice_customer_email';
  static String temporaryInvoiceNo = 'invoice_no';
  static String temporaryInvoiceDate = 'invoice_date';
  static String temporaryInvoiceDueDate = 'invoice_due_date';
  static String temporaryInvoiceTerms = 'invoice_terms';
  static String temporaryInvoiceComment = 'invoice_comment';
  static String temporaryInvoiceItems = 'invoice_items';
  static String temporaryInvoiceSubtotal = 'invoice_subtotal';
  static String temporaryInvoiceVatAmount = 'invoice_vat_amount';
  static String temporaryInvoiceTotalAmount = 'invoice_total_amount';
  static String temporaryInvoicePaidAmount = 'invoice_paid_amount';
  static String temporaryInvoiceBalanceDue = 'invoice_balance_due';
  static String temporaryInvoicePaidFull = 'invoice_paid_full';
  static String temporaryInvoiceJobNo = 'invoice_job_no';

  //Estimates Table
  static String estimatesTable = 'estimates_table';
  static String estimatesCompanyAddress = 'estimates_company_address';
  static String estimatesCompanyPostCode = 'estimates_company_post_code';
  static String estimatesCompanyTelephone = 'estimates_company_telephone';
  static String estimatesCompanyVatRegNo = 'estimates_company_vat_reg_no';
  static String estimatesCompanyGasSafeRegNo = 'estimates_company_gas_safe_reg_no';
  static String estimatesDate = 'estimates_date';
  static String estimatesEngineerName = 'estimates_engineer_name';
  static String estimatesCustomerName = 'estimates_customer_name';
  static String estimatesAddress = 'estimates_address';
  static String estimatesContactNo = 'estimates_contact_no';
  static String estimatesPostCode = 'estimates_post_code';
  static String estimatesPrice = 'estimates_price';
  static String estimatesCustomerEmail = 'estimates_customer_email';
  static String estimatesTypeConversion = 'estimates_type_conversion';
  static String estimatesTypeCombiSwap = 'estimates_type_combi_swap';
  static String estimatesTypeHeatOnly = 'estimates_type_heat_only';
  static String estimatesTypeFullHeat = 'estimates_type_full_heat';
  static String estimatesCurrentBoilerLocation = 'estimates_current_boiler_location';
  static String estimatesNewBoilerLocation = 'estimates_new_boiler_location';
  static String estimatesGuarantee = 'estimates_guarantee';
  static String estimatesFlueTypeStandard = 'estimates_flue_type_standard';
  static String estimatesFlueTypeVerticalFlat = 'estimates_flue_type_vertical_flat';
  static String estimatesFlueTypeVerticalPitched = 'estimates_flue_type_vertical_pitched';
  static String estimatesMagnaCleanYes = 'estimates_magna_clean_yes';
  static String estimatesMagnaCleanNo = 'estimates_magna_clean_no';
  static String estimatesMagnaCleanNa = 'estimates_magna_clean_na';
  static String estimatesRoomStat = 'estimates_room_stat';
  static String estimatesClockYes = 'estimates_clock_yes';
  static String estimatesClockNo = 'estimates_clock_no';
  static String estimatesClockNa = 'estimates_clock_na';
  static String estimatesTrvSize15 = 'estimates_trv_size_15';
  static String estimatesTrvSize10 = 'estimates_trv_size_10';
  static String estimatesTrvSize8 = 'estimates_trv_size_8';
  static String estimatesTrvSizeNa = 'estimates_trv_size_na';
  static String estimatesGasPipe = 'estimates_gas_pipe';
  static String estimatesCondensateRoute = 'estimates_condensate_route';
  static String estimatesFlowReturn = 'estimates_flow_return';
  static String estimatesHotCold = 'estimates_hot_cold';
  static String estimatesPressureRelief = 'estimates_pressure_relief';
  static String estimatesNumberOfShowers = 'estimates_number_of_shadows';
  static String estimatesGasMeterStopCock = 'estimates_gas_meter_stop_cock';
  static String estimatesElectricianRequiredYes = 'estimates_electritian_required_yes';
  static String estimatesElectricianRequiredNo = 'estimates_electritian_required_no';
  static String estimatesElectricianRequiredNa = 'estimates_electritian_required_na';
  static String estimatesRooferRequiredYes = 'estimates_roofer_required_yes';
  static String estimatesRooferRequiredNo = 'estimates_roofer_required_no';
  static String estimatesRooferRequiredNa = 'estimates_roofer_required_na';
  static String estimatesBrickworkPlasteringRequiredYes = 'estimates_brickwork_plastering_required_yes';
  static String estimatesBrickworkPlasteringRequiredNo = 'estimates_brickwork_plastering_required_no';
  static String estimatesBrickworkPlasteringRequiredNa = 'estimates_brickwork_plastering_required_na';
  static String estimatesCustomerWork = 'estimates_customer_work';
  static String estimatesOtherNotes = 'estimates_other_notes';
  static String estimatesTrvNotes = 'estimates_trv_notes';
  static String estimatesBrickworkNotes = 'estimates_brickwork_notes';
  static String estimatesImages = 'estimates_images';
  static String estimatesImageFiles = 'estimates_image_files';
  static String estimatesLocalImages = 'estimates_local_images';

  //Temporary Estimates Table
  static String temporaryEstimatesTable = 'temporary_estimates_table';
  static String temporaryEstimatesCompanyAddress = 'estimates_company_address';
  static String temporaryEstimatesCompanyPostCode = 'estimates_company_post_code';
  static String temporaryEstimatesCompanyTelephone = 'estimates_company_telephone';
  static String temporaryEstimatesCompanyVatRegNo = 'estimates_company_vat_reg_no';
  static String temporaryEstimatesCompanyGasSafeRegNo = 'estimates_company_gas_safe_reg_no';
  static String temporaryEstimatesDate = 'estimates_date';
  static String temporaryEstimatesEngineerName = 'estimates_engineer_name';
  static String temporaryEstimatesCustomerName = 'estimates_customer_name';
  static String temporaryEstimatesAddress = 'estimates_address';
  static String temporaryEstimatesContactNo = 'estimates_contact_no';
  static String temporaryEstimatesPostCode = 'estimates_post_code';
  static String temporaryEstimatesPrice = 'estimates_price';
  static String temporaryEstimatesCustomerEmail = 'estimates_customer_email';
  static String temporaryEstimatesTypeConversion = 'estimates_type_conversion';
  static String temporaryEstimatesTypeCombiSwap = 'estimates_type_combi_swap';
  static String temporaryEstimatesTypeHeatOnly = 'estimates_type_heat_only';
  static String temporaryEstimatesTypeFullHeat = 'estimates_type_full_heat';
  static String temporaryEstimatesCurrentBoilerLocation = 'estimates_current_boiler_location';
  static String temporaryEstimatesNewBoilerLocation = 'estimates_new_boiler_location';
  static String temporaryEstimatesGuarantee = 'estimates_guarantee';
  static String temporaryEstimatesFlueTypeStandard = 'estimates_flue_type_standard';
  static String temporaryEstimatesFlueTypeVerticalFlat = 'estimates_flue_type_vertical_flat';
  static String temporaryEstimatesFlueTypeVerticalPitched = 'estimates_flue_type_vertical_pitched';
  static String temporaryEstimatesMagnaCleanYes = 'estimates_magna_clean_yes';
  static String temporaryEstimatesMagnaCleanNo = 'estimates_magna_clean_no';
  static String temporaryEstimatesMagnaCleanNa = 'estimates_magna_clean_na';
  static String temporaryEstimatesRoomStat = 'estimates_room_stat';
  static String temporaryEstimatesClockYes = 'estimates_clock_yes';
  static String temporaryEstimatesClockNo = 'estimates_clock_no';
  static String temporaryEstimatesClockNa = 'estimates_clock_na';
  static String temporaryEstimatesTrvSize15 = 'estimates_trv_size_15';
  static String temporaryEstimatesTrvSize10 = 'estimates_trv_size_10';
  static String temporaryEstimatesTrvSize8 = 'estimates_trv_size_8';
  static String temporaryEstimatesTrvSizeNa = 'estimates_trv_size_na';
  static String temporaryEstimatesGasPipe = 'estimates_gas_pipe';
  static String temporaryEstimatesCondensateRoute = 'estimates_condensate_route';
  static String temporaryEstimatesFlowReturn = 'estimates_flow_return';
  static String temporaryEstimatesHotCold = 'estimates_hot_cold';
  static String temporaryEstimatesPressureRelief = 'estimates_pressure_relief';
  static String temporaryEstimatesNumberOfShowers = 'estimates_number_of_shadows';
  static String temporaryEstimatesGasMeterStopCock = 'estimates_gas_meter_stop_cock';
  static String temporaryEstimatesElectricianRequiredYes = 'estimates_electritian_required_yes';
  static String temporaryEstimatesElectricianRequiredNo = 'estimates_electritian_required_no';
  static String temporaryEstimatesElectricianRequiredNa = 'estimates_electritian_required_na';
  static String temporaryEstimatesRooferRequiredYes = 'estimates_roofer_required_yes';
  static String temporaryEstimatesRooferRequiredNo = 'estimates_roofer_required_no';
  static String temporaryEstimatesRooferRequiredNa = 'estimates_roofer_required_na';
  static String temporaryEstimatesBrickworkPlasteringRequiredYes = 'estimates_brickwork_plastering_required_yes';
  static String temporaryEstimatesBrickworkPlasteringRequiredNo = 'estimates_brickwork_plastering_required_no';
  static String temporaryEstimatesBrickworkPlasteringRequiredNa = 'estimates_brickwork_plastering_required_na';
  static String temporaryEstimatesCustomerWork = 'estimates_customer_work';
  static String temporaryEstimatesOtherNotes = 'estimates_other_notes';
  static String temporaryEstimatesTrvNotes = 'estimates_trv_notes';
  static String temporaryEstimatesBrickworkNotes = 'estimates_brickwork_notes';
  static String temporaryEstimatesImages = 'estimates_images';

  //Basic Estimates Table
  static String estimatesBasicTable = 'estimates_basic_table';
  static String estimatesBasicCompanyAddress = 'estimates_basic_company_address';
  static String estimatesBasicCompanyPostCode = 'estimates_basic_company_post_code';
  static String estimatesBasicCompanyTelephone = 'estimates_basic_company_telephone';
  static String estimatesBasicCompanyVatRegNo = 'estimates_basic_company_vat_reg_no';
  static String estimatesBasicCompanyGasSafeRegNo = 'estimates_basic_company_gas_safe_reg_no';
  static String estimatesBasicDate = 'estimates_basic_date';
  static String estimatesBasicEngineerName = 'estimates_basic_engineer_name';
  static String estimatesBasicCustomerName = 'estimates_basic_customer_name';
  static String estimatesBasicAddress = 'estimates_basic_address';
  static String estimatesBasicContactNo = 'estimates_basic_contact_no';
  static String estimatesBasicPostCode = 'estimates_basic_post_code';
  static String estimatesBasicPrice = 'estimates_basic_price';
  static String estimatesBasicCustomerEmail = 'estimates_basic_customer_email';
  static String estimatesBasicDescription = 'estimates_basic_description';
  static String estimatesBasicImages = 'estimates_basic_images';
  static String estimatesBasicImageFiles = 'estimates_basic_image_files';
  static String estimatesBasicLocalImages = 'estimates_basic_local_images';

  //Temporary Basic Estimates Table
  static String temporaryEstimatesBasicTable = 'temporary_estimates_basic_table';
  static String temporaryEstimatesBasicCompanyAddress = 'estimates_basic_company_address';
  static String temporaryEstimatesBasicCompanyPostCode = 'estimates_basic_company_post_code';
  static String temporaryEstimatesBasicCompanyTelephone = 'estimates_basic_company_telephone';
  static String temporaryEstimatesBasicCompanyVatRegNo = 'estimates_basic_company_vat_reg_no';
  static String temporaryEstimatesBasicCompanyGasSafeRegNo = 'estimates_basic_company_gas_safe_reg_no';
  static String temporaryEstimatesBasicDate = 'estimates_basic_date';
  static String temporaryEstimatesBasicEngineerName = 'estimates_basic_engineer_name';
  static String temporaryEstimatesBasicCustomerName = 'estimates_basic_customer_name';
  static String temporaryEstimatesBasicAddress = 'estimates_basic_address';
  static String temporaryEstimatesBasicContactNo = 'estimates_basic_contact_no';
  static String temporaryEstimatesBasicPostCode = 'estimates_basic_post_code';
  static String temporaryEstimatesBasicPrice = 'estimates_basic_price';
  static String temporaryEstimatesBasicCustomerEmail = 'estimates_basic_customer_email';
  static String temporaryEstimatesBasicDescription = 'estimates_basic_description';
  static String temporaryEstimatesBasicImages = 'estimates_basic_images';
  static String temporaryEstimatesBasicImageFiles = 'estimates_basic_image_files';
  static String temporaryEstimatesBasicLocalImages = 'estimates_basic_local_images';

  //Parts Fitted Table
  static String partsFittedTable = 'parts_fitted_table';
  static String partsFittedDescription = 'parts_fitted_description';
  static String partsFittedImages = 'parts_fitted_images';
  static String partsFittedImageFiles = 'parts_fitted_image_files';
  static String partsFittedLocalImages = 'parts_fitted_local_images';
  static String clientMobile = 'client_mobile';

  //Parts Fitted Table
  static String temporaryPartsFittedTable = 'temporary_parts_fitted_table';
  static String temporaryPartsFittedDescription = 'parts_fitted_description';
  static String temporaryPartsFittedImages = 'parts_fitted_images';
  static String temporaryPartsFittedImageFiles = 'parts_fitted_image_files';
  static String temporaryPartsFittedLocalImages = 'parts_fitted_local_images';
  static String temporaryClientMobile = 'client_mobile';


  //General Work Table
  static String generalWorkTable = 'general_work_table';
  static String generalWorkDescription = 'general_work_description';
  static String generalWorkImages = 'general_work_images';
  static String generalWorkImageFiles = 'general_work_image_files';
  static String generalWorkLocalImages = 'general_work_local_images';

  //Temporary General Work Table
  static String temporaryGeneralWorkTable = 'temporary_general_work_table';
  static String temporaryGeneralWorkDescription = 'general_work_description';
  static String temporaryGeneralWorkImages = 'general_work_images';
  static String temporaryGeneralWorkImageFiles = 'general_work_image_files';
  static String temporaryGeneralWorkLocalImages = 'general_work_local_images';


  //Engineer Notes Table
  static String engineerNotesTable = 'engineer_notes_table';
  static String engineerNotesName = 'engineer_notes_name';
  static String engineerNotesDate = 'engineer_notes_date';
  static String engineerNotesDescription = 'engineer_notes_description';
  static String engineerNotesImages = 'engineer_notes_images';
  static String engineerNotesImageFiles = 'engineer_notes_image_files';
  static String engineerNotesLocalImages = 'engineer_notes_local_images';

  //Engineer Notes Table
  static String temporaryEngineerNotesTable = 'temporary_engineer_notes_table';
  static String temporaryEngineerNotesName = 'engineer_notes_name';
  static String temporaryEngineerNotesDate = 'engineer_notes_date';
  static String temporaryEngineerNotesDescription = 'engineer_notes_description';
  static String temporaryEngineerNotesImages = 'engineer_notes_images';
  static String temporaryEngineerNotesImageFiles = 'engineer_notes_image_files';
  static String temporaryEngineerNotesLocalImages = 'engineer_notes_local_images';

  //Firebase Storage URl List Table
  static String firebaseStorageUrlTable = 'firebase_storage_url_table';
  static String urlList = 'url_list';


  //Image Path Table
  static String imagePathTable = 'image_path_table';
  static String imagePath = 'image_path';

  //Cached Image Path Table
  String cachedImagePathTable = 'cached_path_table';
  String cachedImagePath = 'cached_path';

  //Camera Table
  static String cameraCrashTable = 'camera_table';
  static String hasCrashed = 'custom_camera';
  static String imageIndex = 'image_index';
  static String formName = 'form_name';

  //Timesheets Table
  static String timesheetsTable = 'timesheets_table';
  static String timesheetDate = 'timesheet_date';
  static String clockedIn = 'clocked_in';
  static String clockInLatitude = 'clock_in_latitude';
  static String clockInLongitude = 'clock_in_longitude';
  static String clockInTime = 'clock_in_time';
  static String clockInServerUploaded = 'clock_in_server_uploaded';
  static String clockedOut = 'clocked_out';
  static String clockOutLatitude = 'clock_out_latitude';
  static String clockOutLongitude = 'clock_out_longitude';
  static String clockOutTime = 'clock_out_time';
  static String clockOutServerUploaded = 'clock_out_server_uploaded';


  static String createAuthenticationTableSql = 'CREATE TABLE IF NOT EXISTS ${Strings.authenticationTable}('
      '${Strings.localId} INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, '
      '${Strings.uid} VARCHAR(255) default NULL, '
      '${Strings.username} VARCHAR(255) default NULL, '
      '${Strings.clubId} VARCHAR(255) default NULL, '
      '${Strings.clubName} VARCHAR(255) default NULL, '
      '${Strings.clubRole} VARCHAR(255) default NULL, '
      '${Strings.requestedClubId} VARCHAR(255) default NULL, '
      '${Strings.suspended} TINYINT(1) default NULL, '
      '${Strings.deleted} TINYINT(1) default NULL, '
      '${Strings.termsAccepted} TINYINT(1) default NULL, '
      '${Strings.forcePasswordReset} TINYINT(1) default NULL)';

  static String createFirebaseStorageUrlTable = 'CREATE TABLE IF NOT EXISTS ${Strings.firebaseStorageUrlTable}('
      '${Strings.localId} INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, '
      '${Strings.uid} VARCHAR(255) default NULL, '
      '${Strings.urlList} JSON default NULL)';

  static String createCameraCrashTableSql = 'CREATE TABLE IF NOT EXISTS ${Strings.cameraCrashTable}('
      '${Strings.localId} INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, '
      '${Strings.hasCrashed} TINYINT(1) default NULL, '
      '${Strings.imageIndex} INT(11) default NULL, '
      '${Strings.formName} VARCHAR(255) default NULL)';

  static String createClubTableSql = 'CREATE TABLE IF NOT EXISTS ${Strings.clubTable}('
      '${Strings.localId} INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, '
      '${Strings.documentId} VARCHAR(255) default NULL, '
      '${Strings.name} VARCHAR(255) default NULL, '
      '${Strings.nameLowercase} VARCHAR(255) default NULL, '
      '${Strings.description} VARCHAR(255) default NULL, '
      '${Strings.requests} JSON default NULL)';

  static String createAnnouncementTableSql = 'CREATE TABLE IF NOT EXISTS ${Strings.announcementTable}('
      '${Strings.localId} INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, '
      '${Strings.documentId} VARCHAR(255) default NULL, '
      '${Strings.uid} VARCHAR(255) default NULL, '
      '${Strings.username} VARCHAR(255) default NULL, '
      '${Strings.clubId} VARCHAR(255) default NULL, '
      '${Strings.body} VARCHAR(255) default NULL, '
      '${Strings.timestamp} VARCHAR(255) default NULL)';



  static String createActivityLogTableSql = 'CREATE TABLE IF NOT EXISTS ${Strings.activityLogTable}('
      '${Strings.localId} INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, '
      '${Strings.documentId} VARCHAR(255) default NULL, '
      '${Strings.uid} VARCHAR(255) default NULL, '
      '${Strings.username} VARCHAR(255) default NULL, '
      '${Strings.title} VARCHAR(255) default NULL, '
      '${Strings.caveName} VARCHAR(255) default NULL, '
      '${Strings.details} TEXT default NULL, '
      '${Strings.pendingTime} VARCHAR(255) default NULL, '
      '${Strings.date} VARCHAR(255) default NULL, '
      '${Strings.images} JSON default NULL, '
      '${Strings.localImages} JSON default NULL, '
      '${Strings.imageFiles} JSON default NULL, '
      '${Strings.share} TINYINT(1) default NULL, '
      '${Strings.serverUploaded} TINYINT(1) default NULL, '
      '${Strings.timestamp} VARCHAR(255) default NULL)';

  static String createTemporaryActivityLogTableSql = 'CREATE TABLE IF NOT EXISTS ${Strings.temporaryActivityLogTable}('
      '${Strings.localId} INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, '
      '${Strings.documentId} VARCHAR(255) default NULL, '
      '${Strings.uid} VARCHAR(255) default NULL, '
      '${Strings.username} VARCHAR(255) default NULL, '
      '${Strings.title} VARCHAR(255) default NULL, '
      '${Strings.caveName} VARCHAR(255) default NULL, '
      '${Strings.details} TEXT default NULL, '
      '${Strings.date} VARCHAR(255) default NULL, '
      '${Strings.share} TINYINT(1) default NULL, '
      '${Strings.images} JSON default NULL, '
      '${Strings.localImages} JSON default NULL, '
      '${Strings.imageFiles} JSON default NULL)';

  static String createCallOutTableSql = 'CREATE TABLE IF NOT EXISTS ${Strings.callOutTable}('
      '${Strings.localId} INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, '
      '${Strings.documentId} VARCHAR(255) default NULL, '
      '${Strings.uid} VARCHAR(255) default NULL, '
      '${Strings.details} TEXT default NULL, '
      '${Strings.pendingTime} VARCHAR(255) default NULL, '
      '${Strings.entryDate} VARCHAR(255) default NULL, '
      '${Strings.exitDate} VARCHAR(255) default NULL, '
      '${Strings.cavers} JSON default NULL, '
      '${Strings.cave} JSON default NULL, '
      '${Strings.serverUploaded} TINYINT(1) default NULL, '
      '${Strings.timestamp} VARCHAR(255) default NULL)';

  static String createTemporaryCallOutTableSql = 'CREATE TABLE IF NOT EXISTS ${Strings.temporaryCallOutTable}('
      '${Strings.localId} INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, '
      '${Strings.documentId} VARCHAR(255) default NULL, '
      '${Strings.uid} VARCHAR(255) default NULL, '
      '${Strings.details} TEXT default NULL, '
      '${Strings.cavers} JSON default NULL, '
      '${Strings.cave} JSON default NULL, '
      '${Strings.entryDate} VARCHAR(255) default NULL, '
      '${Strings.exitDate} VARCHAR(255) default NULL)';

  static String createCaveTableSql = 'CREATE TABLE IF NOT EXISTS ${Strings.caveTable}('
      '${Strings.localId} INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, '
      '${Strings.documentId} VARCHAR(255) default NULL, '
      '${Strings.uid} VARCHAR(255) default NULL, '
      '${Strings.name} VARCHAR(255) default NULL, '
      '${Strings.nameLowercase} VARCHAR(255) default NULL, '
      '${Strings.description} TEXT default NULL, '
      '${Strings.pendingTime} VARCHAR(255) default NULL, '
      '${Strings.caveLatitude} TEXT default NULL, '
      '${Strings.caveLongitude} TEXT default NULL, '
      '${Strings.parkingLatitude} TEXT default NULL, '
      '${Strings.parkingLongitude} TEXT default NULL, '
      '${Strings.parkingPostCode} TEXT default NULL, '
      '${Strings.verticalRange} VARCHAR(255) default NULL, '
      '${Strings.length} VARCHAR(255) default NULL, '
      '${Strings.county} VARCHAR(255) default NULL, '
      '${Strings.images} JSON default NULL, '
      '${Strings.localImages} JSON default NULL, '
      '${Strings.imageFiles} JSON default NULL, '
      '${Strings.serverUploaded} TINYINT(1) default NULL, '
      '${Strings.timestamp} VARCHAR(255) default NULL)';

  static String createTemporaryCaveTableSql = 'CREATE TABLE IF NOT EXISTS ${Strings.temporaryCaveTable}('
      '${Strings.localId} INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, '
      '${Strings.documentId} VARCHAR(255) default NULL, '
      '${Strings.uid} VARCHAR(255) default NULL, '
      '${Strings.name} VARCHAR(255) default NULL, '
      '${Strings.nameLowercase} VARCHAR(255) default NULL, '
      '${Strings.description} TEXT default NULL, '
      '${Strings.caveLatitude} TEXT default NULL, '
      '${Strings.caveLongitude} TEXT default NULL, '
      '${Strings.parkingLatitude} TEXT default NULL, '
      '${Strings.parkingLongitude} TEXT default NULL, '
      '${Strings.parkingPostCode} TEXT default NULL, '
      '${Strings.verticalRange} VARCHAR(255) default NULL, '
      '${Strings.length} VARCHAR(255) default NULL, '
      '${Strings.county} VARCHAR(255) default NULL, '
      '${Strings.images} JSON default NULL, '
      '${Strings.localImages} JSON default NULL, '
      '${Strings.imageFiles} JSON default NULL)';


  static String createOrganisationTableSql = 'CREATE TABLE IF NOT EXISTS ${Strings.organisationTable}('
      '${Strings.localId} INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, '
      '${Strings.documentId} VARCHAR(255) default NULL, '
      '${Strings.organisationName} VARCHAR(255) default NULL, '
      '${Strings.email} VARCHAR(255) default NULL, '
      '${Strings.contactEmail} VARCHAR(255) default NULL, '
      '${Strings.telephone} VARCHAR(255) default NULL, '
      '${Strings.licenses} INT(11) default NULL, '
      '${Strings.address} VARCHAR(255) default NULL, '
      '${Strings.postCode} VARCHAR(255) default NULL, '
      '${Strings.vatRegNo} VARCHAR(255) default NULL, '
      '${Strings.sortCode} VARCHAR(255) default NULL, '
      '${Strings.accountNumber} VARCHAR(255) default NULL, '
      '${Strings.accountName} VARCHAR(255) default NULL, '
      '${Strings.accountBank} VARCHAR(255) default NULL, '
      '${Strings.latitude} DOUBLE default NULL, '
      '${Strings.longitude} DOUBLE default NULL, '
      '${Strings.logo} TEXT default NULL)';

  static String createCustomersTableSql = 'CREATE TABLE IF NOT EXISTS ${Strings.customersTable}('
      '${Strings.localId} INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, '
      '${Strings.documentId} VARCHAR(255) default NULL, '
      '${Strings.organisationId} VARCHAR(255) default NULL, '
      '${Strings.prefix} VARCHAR(255) default NULL, '
      '${Strings.firstName} VARCHAR(255) default NULL, '
      '${Strings.lastName} VARCHAR(255) default NULL, '
      '${Strings.fullName} VARCHAR(255) default NULL, '
      '${Strings.address} VARCHAR(255) default NULL, '
      '${Strings.postCode} VARCHAR(255) default NULL, '
      '${Strings.email} VARCHAR(255) default NULL, '
      '${Strings.telephone} VARCHAR(255) default NULL, '
      '${Strings.mobile} VARCHAR(255) default NULL, '
      '${Strings.customerJobOutstanding} TINYINT(1) default NULL)';
  


  static String createTimesheetTableSql = 'CREATE TABLE IF NOT EXISTS $timesheetsTable('
      '$localId INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, '
      '$documentId VARCHAR(255) default NULL, '
      '$organisationId VARCHAR(255) default NULL, '
      '$uid VARCHAR(255) default NULL, '
      '$name VARCHAR(255) default NULL, '
      '$timesheetDate VARCHAR(255) default NULL, '
      '$jobId VARCHAR(255) default NULL, '
      '$jobNo VARCHAR(255) default NULL, '
      '$jobPostCode VARCHAR(255) default NULL, '
      '$latitude DOUBLE default NULL, '
      '$longitude DOUBLE default NULL, '
      '$clockedIn TINYINT(1) default NULL, '
      '$clockInTime VARCHAR(255) default NULL, '
      '$clockInLatitude DOUBLE default NULL, '
      '$clockInLongitude DOUBLE default NULL, '
      '$clockInServerUploaded TINYINT(1) default NULL, '
      '$clockedOut TINYINT(1) default NULL, '
      '$clockOutTime VARCHAR(255) default NULL, '
      '$clockOutLatitude DOUBLE default NULL, '
      '$clockOutLongitude DOUBLE default NULL, '
      '$clockOutServerUploaded TINYINT(1) default NULL)';


  static String createImagePathTableSql = 'CREATE TABLE IF NOT EXISTS $imagePathTable($localId INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, $imagePath VARCHAR(255) default NULL)';

  static String createUsersTableSql = 'CREATE TABLE IF NOT EXISTS $usersTable($localId INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, $documentId VARCHAR(255) default NULL, $uid VARCHAR(255) default NULL, '
      '$firstName VARCHAR(255) default NULL, $lastName VARCHAR(255) default NULL, $fullName VARCHAR(255) default NULL, $password VARCHAR(255) default NULL, $email VARCHAR(255) default NULL, $mobile VARCHAR(255) default NULL,'
      '$organisationId VARCHAR(255) default NULL, $organisationName VARCHAR(255) default NULL, $role VARCHAR(255) default NULL, $suspended TINYINT(1) default NULL, $deleted TINYINT(1) default NULL, $termsAccepted TINYINT(1) default NULL, $gasSafeId VARCHAR(255) default NULL, $forcePasswordReset TINYINT(1) default NULL)';

  static String createWarningAdvisoryRecordTableSql = 'CREATE TABLE IF NOT EXISTS $warningAdvisoryRecordTable($localId INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, $formVersion INT(11) default NULL, $formCustomerId VARCHAR(255) default NULL, $documentId VARCHAR(255) default NULL, $uid VARCHAR(255) default NULL,'
      '$jobId VARCHAR(255) default NULL, $pendingTime VARCHAR(255) default NULL, $gasSafeRegNo VARCHAR(255) default NULL, $engineersFullName VARCHAR(255) default NULL, $engineersGasSafeId VARCHAR(255) default NULL, $organisationId VARCHAR(255) default NULL, $organisationName VARCHAR(255) default NULL, $companyAddress VARCHAR(255) default NULL, $companyPostcode VARCHAR(255) default NULL, $companyTelephone VARCHAR(255) default NULL,'
      '$inspectionAddressName VARCHAR(255) default NULL, $inspectionAddress VARCHAR(255) default NULL, $inspectionPostcode VARCHAR(255) default NULL, $inspectionTelephone VARCHAR(255) default NULL,'
      '$inspectionEmail VARCHAR(255) default NULL, $landlordName VARCHAR(255) default NULL, $landlordAddress VARCHAR(255) default NULL, $landlordPostcode VARCHAR(255) default NULL, $landlordTelephone VARCHAR(255) default NULL, $landlordEmail VARCHAR(255) default NULL,'
      '$escapeOfGas TINYINT(1) default NULL, $escapeOfGasYes TINYINT(1) default NULL, $escapeOfGasNo TINYINT(1) default NULL, $gasInstallation TINYINT(1) default NULL, $gasAppliance TINYINT(1) default NULL, $applianceManufacturer VARCHAR(255) default NULL, $applianceModel VARCHAR(255) default NULL, $applianceType VARCHAR(255) default NULL, $applianceSerialNo VARCHAR(255) default NULL, $applianceLocation VARCHAR(255) default NULL,'
      '$immediatelyDangerous TINYINT(1) default NULL, $immediatelyDangerousReason TEXT default NULL, $disconnectedYes TINYINT(1) default NULL, $disconnectedNo TINYINT(1) default NULL, $permissionRefusedYes TINYINT(1) default NULL, $permissionRefusedNo TINYINT(1) default NULL, $isAtRisk TINYINT(1) default NULL, $isAtRiskReason TEXT default NULL, $turnedOffYes TINYINT(1) default NULL, $turnedOffNo TINYINT(1) default NULL, $notToCurrentStandards TINYINT(1) default NULL,'
      '$ncsManufacturer VARCHAR(255) default NULL, $ncsModel VARCHAR(255) default NULL, $ncsType VARCHAR(255) default NULL, $ncsSerialNo VARCHAR(255) default NULL, $ncsLocation VARCHAR(255) default NULL, $notToCurrentStandardsReason TEXT default NULL, $responsiblePersonsSignature BLOB default NULL, $responsiblePersonsSignaturePoints JSON default NULL, $responsiblePersonPrintName VARCHAR(255) default NULL, $responsiblePersonDate VARCHAR(255) default NULL, $engineersSignature BLOB default NULL, $engineersSignaturePoints JSON default NULL, $engineerDate VARCHAR(255) default NULL, $responsiblePersonNotPresent TINYINT(1) default NULL, $serverUploaded TINYINT(1) default NULL, $timestamp VARCHAR(255) default NULL)';

  static String createTemporaryWarningAdvisoryRecordTableSql = 'CREATE TABLE IF NOT EXISTS $temporaryWarningAdvisoryRecordTable($localId INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, $formVersion INT(11) default NULL, $documentId VARCHAR(255) default NULL, $formCustomerId VARCHAR(255) default NULL, $uid VARCHAR(255) default NULL,'
      '$temporaryJobId VARCHAR(255) default NULL, $gasSafeRegNo VARCHAR(255) default NULL, $engineersFullName VARCHAR(255) default NULL, $engineersGasSafeId VARCHAR(255) default NULL, $organisationId VARCHAR(255) default NULL, $organisationName VARCHAR(255) default NULL, $companyAddress VARCHAR(255) default NULL, $companyPostcode VARCHAR(255) default NULL, $companyTelephone VARCHAR(255) default NULL,'
      '$temporaryInspectionAddressName VARCHAR(255) default NULL, $temporaryInspectionAddress VARCHAR(255) default NULL, $temporaryInspectionPostcode VARCHAR(255) default NULL, $temporaryInspectionTelephone VARCHAR(255) default NULL,'
      '$temporaryInspectionEmail VARCHAR(255) default NULL, $temporaryLandlordName VARCHAR(255) default NULL, $temporaryLandlordAddress VARCHAR(255) default NULL, $temporaryLandlordPostcode VARCHAR(255) default NULL, $temporaryLandlordTelephone VARCHAR(255) default NULL, $temporaryLandlordEmail VARCHAR(255) default NULL,'
      '$temporaryEscapeOfGas TINYINT(1) default NULL, $temporaryEscapeOfGasYes TINYINT(1) default NULL, $temporaryEscapeOfGasNo TINYINT(1) default NULL, $temporaryGasInstallation TINYINT(1) default NULL, $temporaryGasAppliance TINYINT(1) default NULL, $temporaryApplianceManufacturer VARCHAR(255) default NULL, $temporaryApplianceModel VARCHAR(255) default NULL, $temporaryApplianceType VARCHAR(255) default NULL, $temporaryApplianceSerialNo VARCHAR(255) default NULL, $temporaryApplianceLocation VARCHAR(255) default NULL,'
      '$temporaryImmediatelyDangerous TINYINT(1) default NULL, $temporaryImmediatelyDangerousReason TEXT default NULL, $temporaryDisconnectedYes TINYINT(1) default NULL, $temporaryDisconnectedNo TINYINT(1) default NULL, $temporaryPermissionRefusedYes TINYINT(1) default NULL, $temporaryPermissionRefusedNo TINYINT(1) default NULL, $temporaryIsAtRisk TINYINT(1) default NULL, $temporaryIsAtRiskReason TEXT default NULL, $temporaryTurnedOffYes TINYINT(1) default NULL, $temporaryTurnedOffNo TINYINT(1) default NULL, $temporaryNotToCurrentStandards TINYINT(1) default NULL,'
      '$temporaryNcsManufacturer VARCHAR(255) default NULL, $temporaryNcsModel VARCHAR(255) default NULL, $temporaryNcsType VARCHAR(255) default NULL, $temporaryNcsSerialNo VARCHAR(255) default NULL, $temporaryNcsLocation VARCHAR(255) default NULL, $temporaryNotToCurrentStandardsReason TEXT default NULL, $temporaryResponsiblePersonsSignature BLOB default NULL, $temporaryResponsiblePersonsSignaturePoints JSON default NULL, $temporaryResponsiblePersonPrintName VARCHAR(255) default NULL, $temporaryResponsiblePersonDate VARCHAR(255) default NULL, $temporaryEngineersSignature BLOB default NULL, $temporaryEngineersSignaturePoints JSON default NULL, $temporaryEngineerDate VARCHAR(255) default NULL, $temporaryResponsiblePersonNotPresent TINYINT(1) default NULL)';


  static String createGasSafetyRecordTableSql = 'CREATE TABLE IF NOT EXISTS $gasSafetyRecordTable($localId INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, $formVersion INT(11) default NULL, $documentId VARCHAR(255) default NULL, $formCustomerId VARCHAR(255) default NULL, $uid VARCHAR(255) default NULL,'
      '$jobId VARCHAR(255) default NULL, $pendingTime VARCHAR(255) default NULL, $installerName VARCHAR(255) default NULL, $gasSafeRegNo VARCHAR(255) default NULL, $organisationId VARCHAR(255) default NULL, $organisationName VARCHAR(255) default NULL, $companyAddress VARCHAR(255) default NULL, $companyPostcode VARCHAR(255) default NULL, $companyTelephone VARCHAR(255) default NULL,'
      '$engineersSignature BLOB default NULL, $engineersSignaturePoints JSON default NULL, $engineerDate VARCHAR(255) default NULL, $inspectionAddressName VARCHAR(255) default NULL, $inspectionAddress VARCHAR(255) default NULL, $inspectionPostcode VARCHAR(255) default NULL, $inspectionTelephone VARCHAR(255) default NULL,'
      '$inspectionEmail VARCHAR(255) default NULL, $landlordName VARCHAR(255) default NULL, $landlordAddress VARCHAR(255) default NULL, $landlordPostcode VARCHAR(255) default NULL, $landlordTelephone VARCHAR(255) default NULL, $landlordEmail VARCHAR(255) default NULL,'
      '$gsrLocation1 VARCHAR(255) default NULL, $gsrMake1 VARCHAR(255) default NULL, $gsrModel1 VARCHAR(255) default NULL, $gsrType1 VARCHAR(255) default NULL, $gsrFlueType1 VARCHAR(255) default NULL, $gsrOperationPressure1 VARCHAR(255) default NULL, $gsrSafetyDevice1 VARCHAR(255) default NULL, $gsrFlueOperation1 VARCHAR(255) default NULL, $gsrCombustionAnalyser1 VARCHAR(255) default NULL, $gsrSatisfactoryTermination1 VARCHAR(255) default NULL, $gsrVisualCondition1 VARCHAR(255) default NULL, $gsrAdequateVentilation1 VARCHAR(255) default NULL, $gsrApplianceSafe1 VARCHAR(255) default NULL, $gsrLandlordsAppliance1 VARCHAR(255) default NULL, $gsrInspected1 VARCHAR(255) default NULL, $gsrApplianceServiced1 VARCHAR(255) default NULL,'
      '$gsrLocation2 VARCHAR(255) default NULL, $gsrMake2 VARCHAR(255) default NULL, $gsrModel2 VARCHAR(255) default NULL, $gsrType2 VARCHAR(255) default NULL, $gsrFlueType2 VARCHAR(255) default NULL, $gsrOperationPressure2 VARCHAR(255) default NULL, $gsrSafetyDevice2 VARCHAR(255) default NULL, $gsrFlueOperation2 VARCHAR(255) default NULL, $gsrCombustionAnalyser2 VARCHAR(255) default NULL, $gsrSatisfactoryTermination2 VARCHAR(255) default NULL, $gsrVisualCondition2 VARCHAR(255) default NULL, $gsrAdequateVentilation2 VARCHAR(255) default NULL, $gsrApplianceSafe2 VARCHAR(255) default NULL, $gsrLandlordsAppliance2 VARCHAR(255) default NULL, $gsrInspected2 VARCHAR(255) default NULL, $gsrApplianceServiced2 VARCHAR(255) default NULL,'
      '$gsrLocation3 VARCHAR(255) default NULL, $gsrMake3 VARCHAR(255) default NULL, $gsrModel3 VARCHAR(255) default NULL, $gsrType3 VARCHAR(255) default NULL, $gsrFlueType3 VARCHAR(255) default NULL, $gsrOperationPressure3 VARCHAR(255) default NULL, $gsrSafetyDevice3 VARCHAR(255) default NULL, $gsrFlueOperation3 VARCHAR(255) default NULL, $gsrCombustionAnalyser3 VARCHAR(255) default NULL, $gsrSatisfactoryTermination3 VARCHAR(255) default NULL, $gsrVisualCondition3 VARCHAR(255) default NULL, $gsrAdequateVentilation3 VARCHAR(255) default NULL, $gsrApplianceSafe3 VARCHAR(255) default NULL, $gsrLandlordsAppliance3 VARCHAR(255) default NULL, $gsrInspected3 VARCHAR(255) default NULL, $gsrApplianceServiced3 VARCHAR(255) default NULL,'
      '$gsrLocation4 VARCHAR(255) default NULL, $gsrMake4 VARCHAR(255) default NULL, $gsrModel4 VARCHAR(255) default NULL, $gsrType4 VARCHAR(255) default NULL, $gsrFlueType4 VARCHAR(255) default NULL, $gsrOperationPressure4 VARCHAR(255) default NULL, $gsrSafetyDevice4 VARCHAR(255) default NULL, $gsrFlueOperation4 VARCHAR(255) default NULL, $gsrCombustionAnalyser4 VARCHAR(255) default NULL, $gsrSatisfactoryTermination4 VARCHAR(255) default NULL, $gsrVisualCondition4 VARCHAR(255) default NULL, $gsrAdequateVentilation4 VARCHAR(255) default NULL, $gsrApplianceSafe4 VARCHAR(255) default NULL, $gsrLandlordsAppliance4 VARCHAR(255) default NULL, $gsrInspected4 VARCHAR(255) default NULL, $gsrApplianceServiced4 VARCHAR(255) default NULL,'
      '$gsrLocation5 VARCHAR(255) default NULL, $gsrMake5 VARCHAR(255) default NULL, $gsrModel5 VARCHAR(255) default NULL, $gsrType5 VARCHAR(255) default NULL, $gsrFlueType5 VARCHAR(255) default NULL, $gsrOperationPressure5 VARCHAR(255) default NULL, $gsrSafetyDevice5 VARCHAR(255) default NULL, $gsrFlueOperation5 VARCHAR(255) default NULL, $gsrCombustionAnalyser5 VARCHAR(255) default NULL, $gsrSatisfactoryTermination5 VARCHAR(255) default NULL, $gsrVisualCondition5 VARCHAR(255) default NULL, $gsrAdequateVentilation5 VARCHAR(255) default NULL, $gsrApplianceSafe5 VARCHAR(255) default NULL, $gsrLandlordsAppliance5 VARCHAR(255) default NULL, $gsrInspected5 VARCHAR(255) default NULL, $gsrApplianceServiced5 VARCHAR(255) default NULL,'
      '$visualInspectionYes TINYINT(1) default NULL, $visualInspectionNo TINYINT(1) default NULL, $emergencyControlYes TINYINT(1) default NULL, $emergencyControlNo TINYINT(1) default NULL, $satisfactorySoundnessYes TINYINT(1) default NULL, $satisfactorySoundnessNo TINYINT(1) default NULL, $safetyGasMeterEarthBondedYes TINYINT(1) default NULL, $safetyGasMeterEarthBondedNo TINYINT(1) default NULL,'
      '$faultDetails1 TEXT default NULL, $warningNotice1 VARCHAR(255) default NULL, $warningSticker1 VARCHAR(255) default NULL, $faultDetails2 TEXT default NULL, $warningNotice2 VARCHAR(255) default NULL, $warningSticker2 VARCHAR(255) default NULL, $faultDetails3 TEXT default NULL, $warningNotice3 VARCHAR(255) default NULL, $warningSticker3 VARCHAR(255) default NULL,'
      '$numberAppliancesTested VARCHAR(255) default NULL, $issuersSignature BLOB default NULL, $issuersSignaturePoints JSON default NULL, $issuerPrintName VARCHAR(255) default NULL, $issuerDate VARCHAR(255) default NULL,'
      '$landlordsSignature BLOB default NULL, $landlordsSignaturePoints JSON default NULL, $signatureType VARCHAR(255) default NULL, $landlordDate VARCHAR(255) default NULL, $serverUploaded TINYINT(1) default NULL, $timestamp VARCHAR(255) default NULL)';

  static String createTemporaryGasSafetyRecordTableSql = 'CREATE TABLE IF NOT EXISTS $temporaryGasSafetyRecordTable($localId INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, $formVersion INT(11) default NULL, $documentId VARCHAR(255) default NULL, $formCustomerId VARCHAR(255) default NULL, $uid VARCHAR(255) default NULL,'
      '$temporaryJobId VARCHAR(255) default NULL, $temporaryInstallerName VARCHAR(255) default NULL, $gasSafeRegNo VARCHAR(255) default NULL, $organisationId VARCHAR(255) default NULL, $organisationName VARCHAR(255) default NULL, $companyAddress VARCHAR(255) default NULL, $companyPostcode VARCHAR(255) default NULL, $companyTelephone VARCHAR(255) default NULL,'
      '$temporaryEngineersSignature BLOB default NULL, $temporaryEngineersSignaturePoints JSON default NULL, $temporaryEngineerDate VARCHAR(255) default NULL, $temporaryInspectionAddressName VARCHAR(255) default NULL, $temporaryInspectionAddress VARCHAR(255) default NULL, $temporaryInspectionPostcode VARCHAR(255) default NULL, $temporaryInspectionTelephone VARCHAR(255) default NULL,'
      '$temporaryInspectionEmail VARCHAR(255) default NULL, $temporaryLandlordName VARCHAR(255) default NULL, $temporaryLandlordAddress VARCHAR(255) default NULL, $temporaryLandlordPostcode VARCHAR(255) default NULL, $temporaryLandlordTelephone VARCHAR(255) default NULL, $temporaryLandlordEmail VARCHAR(255) default NULL,'
      '$temporaryGsrLocation1 VARCHAR(255) default NULL, $temporaryGsrMake1 VARCHAR(255) default NULL, $temporaryGsrModel1 VARCHAR(255) default NULL, $temporaryGsrType1 VARCHAR(255) default NULL, $temporaryGsrFlueType1 VARCHAR(255) default NULL, $temporaryGsrOperationPressure1 VARCHAR(255) default NULL, $temporaryGsrSafetyDevice1 VARCHAR(255) default NULL, $temporaryGsrFlueOperation1 VARCHAR(255) default NULL, $temporaryGsrCombustionAnalyser1 VARCHAR(255) default NULL, $temporaryGsrSatisfactoryTermination1 VARCHAR(255) default NULL, $temporaryGsrVisualCondition1 VARCHAR(255) default NULL, $temporaryGsrAdequateVentilation1 VARCHAR(255) default NULL, $temporaryGsrApplianceSafe1 VARCHAR(255) default NULL, $temporaryGsrLandlordsAppliance1 VARCHAR(255) default NULL, $temporaryGsrInspected1 VARCHAR(255) default NULL, $temporaryGsrApplianceServiced1 VARCHAR(255) default NULL,'
      '$temporaryGsrLocation2 VARCHAR(255) default NULL, $temporaryGsrMake2 VARCHAR(255) default NULL, $temporaryGsrModel2 VARCHAR(255) default NULL, $temporaryGsrType2 VARCHAR(255) default NULL, $temporaryGsrFlueType2 VARCHAR(255) default NULL, $temporaryGsrOperationPressure2 VARCHAR(255) default NULL, $temporaryGsrSafetyDevice2 VARCHAR(255) default NULL, $temporaryGsrFlueOperation2 VARCHAR(255) default NULL, $temporaryGsrCombustionAnalyser2 VARCHAR(255) default NULL, $temporaryGsrSatisfactoryTermination2 VARCHAR(255) default NULL, $temporaryGsrVisualCondition2 VARCHAR(255) default NULL, $temporaryGsrAdequateVentilation2 VARCHAR(255) default NULL, $temporaryGsrApplianceSafe2 VARCHAR(255) default NULL, $temporaryGsrLandlordsAppliance2 VARCHAR(255) default NULL, $temporaryGsrInspected2 VARCHAR(255) default NULL, $temporaryGsrApplianceServiced2 VARCHAR(255) default NULL,'
      '$temporaryGsrLocation3 VARCHAR(255) default NULL, $temporaryGsrMake3 VARCHAR(255) default NULL, $temporaryGsrModel3 VARCHAR(255) default NULL, $temporaryGsrType3 VARCHAR(255) default NULL, $temporaryGsrFlueType3 VARCHAR(255) default NULL, $temporaryGsrOperationPressure3 VARCHAR(255) default NULL, $temporaryGsrSafetyDevice3 VARCHAR(255) default NULL, $temporaryGsrFlueOperation3 VARCHAR(255) default NULL, $temporaryGsrCombustionAnalyser3 VARCHAR(255) default NULL, $temporaryGsrSatisfactoryTermination3 VARCHAR(255) default NULL, $temporaryGsrVisualCondition3 VARCHAR(255) default NULL, $temporaryGsrAdequateVentilation3 VARCHAR(255) default NULL, $temporaryGsrApplianceSafe3 VARCHAR(255) default NULL, $temporaryGsrLandlordsAppliance3 VARCHAR(255) default NULL, $temporaryGsrInspected3 VARCHAR(255) default NULL, $temporaryGsrApplianceServiced3 VARCHAR(255) default NULL,'
      '$temporaryGsrLocation4 VARCHAR(255) default NULL, $temporaryGsrMake4 VARCHAR(255) default NULL, $temporaryGsrModel4 VARCHAR(255) default NULL, $temporaryGsrType4 VARCHAR(255) default NULL, $temporaryGsrFlueType4 VARCHAR(255) default NULL, $temporaryGsrOperationPressure4 VARCHAR(255) default NULL, $temporaryGsrSafetyDevice4 VARCHAR(255) default NULL, $temporaryGsrFlueOperation4 VARCHAR(255) default NULL, $temporaryGsrCombustionAnalyser4 VARCHAR(255) default NULL, $temporaryGsrSatisfactoryTermination4 VARCHAR(255) default NULL, $temporaryGsrVisualCondition4 VARCHAR(255) default NULL, $temporaryGsrAdequateVentilation4 VARCHAR(255) default NULL, $temporaryGsrApplianceSafe4 VARCHAR(255) default NULL, $temporaryGsrLandlordsAppliance4 VARCHAR(255) default NULL, $temporaryGsrInspected4 VARCHAR(255) default NULL, $temporaryGsrApplianceServiced4 VARCHAR(255) default NULL,'
      '$temporaryGsrLocation5 VARCHAR(255) default NULL, $temporaryGsrMake5 VARCHAR(255) default NULL, $temporaryGsrModel5 VARCHAR(255) default NULL, $temporaryGsrType5 VARCHAR(255) default NULL, $temporaryGsrFlueType5 VARCHAR(255) default NULL, $temporaryGsrOperationPressure5 VARCHAR(255) default NULL, $temporaryGsrSafetyDevice5 VARCHAR(255) default NULL, $temporaryGsrFlueOperation5 VARCHAR(255) default NULL, $temporaryGsrCombustionAnalyser5 VARCHAR(255) default NULL, $temporaryGsrSatisfactoryTermination5 VARCHAR(255) default NULL, $temporaryGsrVisualCondition5 VARCHAR(255) default NULL, $temporaryGsrAdequateVentilation5 VARCHAR(255) default NULL, $temporaryGsrApplianceSafe5 VARCHAR(255) default NULL, $temporaryGsrLandlordsAppliance5 VARCHAR(255) default NULL, $temporaryGsrInspected5 VARCHAR(255) default NULL, $temporaryGsrApplianceServiced5 VARCHAR(255) default NULL,'
      '$temporaryVisualInspectionYes TINYINT(1) default NULL, $temporaryVisualInspectionNo TINYINT(1) default NULL, $temporaryEmergencyControlYes TINYINT(1) default NULL, $temporaryEmergencyControlNo TINYINT(1) default NULL, $temporarySatisfactorySoundnessYes TINYINT(1) default NULL, $temporarySatisfactorySoundnessNo TINYINT(1) default NULL, $temporarySafetyGasMeterEarthBondedYes TINYINT(1) default NULL, $temporarySafetyGasMeterEarthBondedNo TINYINT(1) default NULL,'
      '$temporaryFaultDetails1 TEXT default NULL, $temporaryWarningNotice1 VARCHAR(255) default NULL, $temporaryWarningSticker1 VARCHAR(255) default NULL, $temporaryFaultDetails2 TEXT default NULL, $temporaryWarningNotice2 VARCHAR(255) default NULL, $temporaryWarningSticker2 VARCHAR(255) default NULL, $temporaryFaultDetails3 TEXT default NULL, $temporaryWarningNotice3 VARCHAR(255) default NULL, $temporaryWarningSticker3 VARCHAR(255) default NULL,'
      '$numberAppliancesTested VARCHAR(255) default NULL, $temporaryIssuersSignature BLOB default NULL, $temporaryIssuersSignaturePoints JSON default NULL, $temporaryIssuerPrintName VARCHAR(255) default NULL, $temporaryIssuerDate VARCHAR(255) default NULL,'
      '$temporaryLandlordsSignature BLOB default NULL, $temporaryLandlordsSignaturePoints JSON default NULL, $temporarySignatureType VARCHAR(255) default NULL, $temporaryLandlordDate VARCHAR(255) default NULL)';

  static String createCaravanGasSafetyRecordTableSql = 'CREATE TABLE IF NOT EXISTS $caravanGasSafetyRecordTable($localId INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, $formVersion INT(11) default NULL, $documentId VARCHAR(255) default NULL, $formCustomerId VARCHAR(255) default NULL, $uid VARCHAR(255) default NULL, '
      '$jobId VARCHAR(255) default NULL, $pendingTime VARCHAR(255) default NULL, $caravanInstallerName VARCHAR(255) default NULL, $gasSafeRegNo VARCHAR(255) default NULL, $organisationId VARCHAR(255) default NULL, $organisationName VARCHAR(255) default NULL, $companyAddress VARCHAR(255) default NULL, $companyPostcode VARCHAR(255) default NULL, $companyTelephone VARCHAR(255) default NULL, '
      '$caravanPark VARCHAR(255) default NULL, $caravanLocation VARCHAR(255) default NULL, $caravanManufacturer VARCHAR(255) default NULL, $caravanModel VARCHAR(255) default NULL, $caravanManufactureDate VARCHAR(255) default NULL, $caravanOwnerName VARCHAR(255) default NULL, '
      '$caravanOwnerAddress VARCHAR(255) default NULL, $caravanOwnerPostCode VARCHAR(255) default NULL, $caravanOwnerTelNo VARCHAR(255) default NULL, $caravanOwnerEmail VARCHAR(255) default NULL, $caravanInspectionDate VARCHAR(255) default NULL, $caravanRecordSerialNo VARCHAR(255) default NULL,'
      '$caravanStockCardNo VARCHAR(255) default NULL, $caravanWaterHeaterMake VARCHAR(255) default NULL, $caravanWaterHeaterModel VARCHAR(255) default NULL, $caravanWaterHeaterOperatingPressure VARCHAR(255) default NULL, $caravanWaterHeaterOperationOfSafetyDevicesPass TINYINT(1) default NULL, $caravanWaterHeaterOperationOfSafetyDevicesFail TINYINT(1) default NULL, '
      '$caravanWaterHeaterVentilationPass TINYINT(1) default NULL, $caravanWaterHeaterVentilationFail TINYINT(1) default NULL, $caravanWaterHeaterFlueType VARCHAR(255) default NULL, $caravanWaterHeaterFlueSpillagePass TINYINT(1) default NULL, $caravanWaterHeaterFlueSpillageFail TINYINT(1) default NULL, '
      '$caravanWaterHeaterFlueTerminationYes TINYINT(1) default NULL, $caravanWaterHeaterFlueTerminationNo TINYINT(1) default NULL, $caravanWaterHeaterExtendedFlueYes TINYINT(1) default NULL, $caravanWaterHeaterExtendedFlueNo TINYINT(1) default NULL, $caravanWaterHeaterExtendedFlueNa TINYINT(1) default NULL, $caravanWaterHeaterFlueConditionPass TINYINT(1) default NULL, '
      '$caravanWaterHeaterFlueConditionFail TINYINT(1) default NULL, $caravanWaterHeaterApplianceSafeYes TINYINT(1) default NULL, $caravanWaterHeaterApplianceSafeNo TINYINT(1) default NULL, '
      '$caravanFireMake VARCHAR(255) default NULL, $caravanFireModel VARCHAR(255) default NULL, $caravanFireOperatingPressure VARCHAR(255) default NULL, $caravanFireOperationOfSafetyDevicesPass TINYINT(1) default NULL, $caravanFireOperationOfSafetyDevicesFail TINYINT(1) default NULL, '
      '$caravanFireVentilationPass TINYINT(1) default NULL, $caravanFireVentilationFail TINYINT(1) default NULL, $caravanFireFlueType VARCHAR(255) default NULL, $caravanFireFlueSpillagePass TINYINT(1) default NULL, $caravanFireFlueSpillageFail TINYINT(1) default NULL, '
      '$caravanFireFlueTerminationYes TINYINT(1) default NULL, $caravanFireFlueTerminationNo TINYINT(1) default NULL, $caravanFireExtendedFlueYes TINYINT(1) default NULL, $caravanFireExtendedFlueNo TINYINT(1) default NULL, $caravanFireExtendedFlueNa TINYINT(1) default NULL, $caravanFireFlueConditionPass TINYINT(1) default NULL, '
      '$caravanFireFlueConditionFail TINYINT(1) default NULL, $caravanFireApplianceSafeYes TINYINT(1) default NULL, $caravanFireApplianceSafeNo TINYINT(1) default NULL, '
      '$caravanCookerMake VARCHAR(255) default NULL, $caravanCookerModel VARCHAR(255) default NULL, $caravanCookerOperatingPressure VARCHAR(255) default NULL, $caravanCookerOperationOfSafetyDevicesPass TINYINT(1) default NULL, $caravanCookerOperationOfSafetyDevicesFail TINYINT(1) default NULL, '
      '$caravanCookerVentilationPass TINYINT(1) default NULL, $caravanCookerVentilationFail TINYINT(1) default NULL, $caravanCookerFlueType VARCHAR(255) default NULL, $caravanCookerFlueSpillagePass TINYINT(1) default NULL, $caravanCookerFlueSpillageFail TINYINT(1) default NULL, '
      '$caravanCookerFlueTerminationYes TINYINT(1) default NULL, $caravanCookerFlueTerminationNo TINYINT(1) default NULL, $caravanCookerExtendedFlueYes TINYINT(1) default NULL, $caravanCookerExtendedFlueNo TINYINT(1) default NULL, $caravanCookerExtendedFlueNa TINYINT(1) default NULL, $caravanCookerFlueConditionPass TINYINT(1) default NULL, '
      '$caravanCookerFlueConditionFail TINYINT(1) default NULL, $caravanCookerApplianceSafeYes TINYINT(1) default NULL, $caravanCookerApplianceSafeNo TINYINT(1) default NULL, '
      '$caravanOtherMake VARCHAR(255) default NULL, $caravanOtherModel VARCHAR(255) default NULL, $caravanOtherOperatingPressure VARCHAR(255) default NULL, $caravanOtherOperationOfSafetyDevicesPass TINYINT(1) default NULL, $caravanOtherOperationOfSafetyDevicesFail TINYINT(1) default NULL, '
      '$caravanOtherVentilationPass TINYINT(1) default NULL, $caravanOtherVentilationFail TINYINT(1) default NULL, $caravanOtherFlueType VARCHAR(255) default NULL, $caravanOtherFlueSpillagePass TINYINT(1) default NULL, $caravanOtherFlueSpillageFail TINYINT(1) default NULL, '
      '$caravanOtherFlueTerminationYes TINYINT(1) default NULL, $caravanOtherFlueTerminationNo TINYINT(1) default NULL, $caravanOtherExtendedFlueYes TINYINT(1) default NULL, $caravanOtherExtendedFlueNo TINYINT(1) default NULL, $caravanOtherExtendedFlueNa TINYINT(1) default NULL, $caravanOtherFlueConditionPass TINYINT(1) default NULL, '
      '$caravanOtherFlueConditionFail TINYINT(1) default NULL, $caravanOtherApplianceSafeYes TINYINT(1) default NULL, $caravanOtherApplianceSafeNo TINYINT(1) default NULL, '
      '$caravanSoundnessCheckPass TINYINT(1) default NULL, $caravanSoundnessCheckFail TINYINT(1) default NULL, $caravanHoseCheckPass TINYINT(1) default NULL, $caravanHoseCheckFail TINYINT(1) default NULL, $caravanRegulatorOperatingPressurePass TINYINT(1) default NULL, '
      '$caravanRegulatorOperatingPressureFail TINYINT(1) default NULL, $caravanRegulatorLockUpPressure VARCHAR(255) default NULL, $caravanRegulatorLockUpPressurePass TINYINT(1) default NULL, $caravanRegulatorLockUpPressureFail TINYINT(1) default NULL, '
      '$caravanFaultDetails1 VARCHAR(255) default NULL, $caravanRectificationWork1 VARCHAR(255) default NULL, $caravanByWhom1 VARCHAR(255) default NULL, $caravanOwnerInformedYes1 TINYINT(1) default NULL, $caravanOwnerInformedNo1 TINYINT(1) default NULL, $caravanWarningNoticeYes1 TINYINT(1) default NULL, '
      '$caravanWarningNoticeNo1 TINYINT(1) default NULL, $caravanWarningTagYes1 TINYINT(1) default NULL, $caravanWarningTagNo1 TINYINT(1) default NULL, $caravanFaultDetails2 VARCHAR(255) default NULL, $caravanRectificationWork2 VARCHAR(255) default NULL, $caravanByWhom2 VARCHAR(255) default NULL, $caravanOwnerInformedYes2 TINYINT(2) default NULL, $caravanOwnerInformedNo2 TINYINT(2) default NULL, $caravanWarningNoticeYes2 TINYINT(2) default NULL, '
      '$caravanWarningNoticeNo2 TINYINT(2) default NULL, $caravanWarningTagYes2 TINYINT(2) default NULL, $caravanWarningTagNo2 TINYINT(2) default NULL, $caravanFaultDetails3 VARCHAR(355) default NULL, $caravanRectificationWork3 VARCHAR(355) default NULL, $caravanByWhom3 VARCHAR(355) default NULL, $caravanOwnerInformedYes3 TINYINT(3) default NULL, $caravanOwnerInformedNo3 TINYINT(3) default NULL, $caravanWarningNoticeYes3 TINYINT(3) default NULL, '
      '$caravanWarningNoticeNo3 TINYINT(3) default NULL, $caravanWarningTagYes3 TINYINT(3) default NULL, $caravanWarningTagNo3 TINYINT(3) default NULL, $caravanFaultDetails4 VARCHAR(455) default NULL, $caravanRectificationWork4 VARCHAR(455) default NULL, $caravanByWhom4 VARCHAR(455) default NULL, $caravanOwnerInformedYes4 TINYINT(4) default NULL, $caravanOwnerInformedNo4 TINYINT(4) default NULL, $caravanWarningNoticeYes4 TINYINT(4) default NULL, '
      '$caravanWarningNoticeNo4 TINYINT(4) default NULL, $caravanWarningTagYes4 TINYINT(4) default NULL, $caravanWarningTagNo4 TINYINT(4) default NULL, $caravanFaultDetails5 VARCHAR(555) default NULL, $caravanRectificationWork5 VARCHAR(555) default NULL, $caravanByWhom5 VARCHAR(555) default NULL, $caravanOwnerInformedYes5 TINYINT(5) default NULL, $caravanOwnerInformedNo5 TINYINT(5) default NULL, $caravanWarningNoticeYes5 TINYINT(5) default NULL, '
      '$caravanWarningNoticeNo5 TINYINT(5) default NULL, $caravanWarningTagYes5 TINYINT(5) default NULL, $caravanWarningTagNo5 TINYINT(5) default NULL, '
      '$caravanNumberOfAppliancesTested VARCHAR(255) default NULL, $caravanSerialNo VARCHAR(255) default NULL, $caravanIssuerSignature BLOB default NULL, $caravanIssuerSignaturePoints JSON default NULL, '
      '$caravanIssuerPrintName VARCHAR(255) default NULL, $caravanIssuerDate VARCHAR(255) default NULL, $caravanAgentSignature BLOB default NULL, $caravanAgentSignaturePoints JSON default NULL, $caravanAgentDate VARCHAR(255) default NULL, $serverUploaded TINYINT(1) default NULL, $timestamp VARCHAR(255) default NULL, $caravanApplianceType1 VARCHAR(255) default NULL, $caravanApplianceType2 VARCHAR(255) default NULL, $caravanApplianceType3 VARCHAR(255) default NULL, $caravanApplianceType4 VARCHAR(255) default NULL)';

  static String createTemporaryCaravanGasSafetyRecordTableSql = 'CREATE TABLE IF NOT EXISTS $temporaryCaravanGasSafetyRecordTable($localId INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, $formVersion INT(11) default NULL, $documentId VARCHAR(255) default NULL, $formCustomerId VARCHAR(255) default NULL, $uid VARCHAR(255) default NULL, '
      '$temporaryJobId VARCHAR(255) default NULL, $temporaryCaravanInstallerName VARCHAR(255) default NULL, $gasSafeRegNo VARCHAR(255) default NULL, $organisationId VARCHAR(255) default NULL, $organisationName VARCHAR(255) default NULL, $companyAddress VARCHAR(255) default NULL, $companyPostcode VARCHAR(255) default NULL, $companyTelephone VARCHAR(255) default NULL, '
      '$temporaryCaravanPark VARCHAR(255) default NULL, $temporaryCaravanLocation VARCHAR(255) default NULL, $temporaryCaravanManufacturer VARCHAR(255) default NULL, $temporaryCaravanModel VARCHAR(255) default NULL, $temporaryCaravanManufactureDate VARCHAR(255) default NULL, $temporaryCaravanOwnerName VARCHAR(255) default NULL, '
      '$temporaryCaravanOwnerAddress VARCHAR(255) default NULL, $temporaryCaravanOwnerPostCode VARCHAR(255) default NULL, $temporaryCaravanOwnerTelNo VARCHAR(255) default NULL, $temporaryCaravanOwnerEmail VARCHAR(255) default NULL, $temporaryCaravanInspectionDate VARCHAR(255) default NULL, $temporaryCaravanRecordSerialNo VARCHAR(255) default NULL,'
      '$temporaryCaravanStockCardNo VARCHAR(255) default NULL, $temporaryCaravanWaterHeaterMake VARCHAR(255) default NULL, $temporaryCaravanWaterHeaterModel VARCHAR(255) default NULL, $temporaryCaravanWaterHeaterOperatingPressure VARCHAR(255) default NULL, $temporaryCaravanWaterHeaterOperationOfSafetyDevicesPass TINYINT(1) default NULL, $temporaryCaravanWaterHeaterOperationOfSafetyDevicesFail TINYINT(1) default NULL, '
      '$temporaryCaravanWaterHeaterVentilationPass TINYINT(1) default NULL, $temporaryCaravanWaterHeaterVentilationFail TINYINT(1) default NULL, $temporaryCaravanWaterHeaterFlueType VARCHAR(255) default NULL, $temporaryCaravanWaterHeaterFlueSpillagePass TINYINT(1) default NULL, $temporaryCaravanWaterHeaterFlueSpillageFail TINYINT(1) default NULL, '
      '$temporaryCaravanWaterHeaterFlueTerminationYes TINYINT(1) default NULL, $temporaryCaravanWaterHeaterFlueTerminationNo TINYINT(1) default NULL, $temporaryCaravanWaterHeaterExtendedFlueYes TINYINT(1) default NULL, $temporaryCaravanWaterHeaterExtendedFlueNo TINYINT(1) default NULL, $temporaryCaravanWaterHeaterExtendedFlueNa TINYINT(1) default NULL, $temporaryCaravanWaterHeaterFlueConditionPass TINYINT(1) default NULL, '
      '$temporaryCaravanWaterHeaterFlueConditionFail TINYINT(1) default NULL, $temporaryCaravanWaterHeaterApplianceSafeYes TINYINT(1) default NULL, $temporaryCaravanWaterHeaterApplianceSafeNo TINYINT(1) default NULL, '
      '$temporaryCaravanFireMake VARCHAR(255) default NULL, $temporaryCaravanFireModel VARCHAR(255) default NULL, $temporaryCaravanFireOperatingPressure VARCHAR(255) default NULL, $temporaryCaravanFireOperationOfSafetyDevicesPass TINYINT(1) default NULL, $temporaryCaravanFireOperationOfSafetyDevicesFail TINYINT(1) default NULL, '
      '$temporaryCaravanFireVentilationPass TINYINT(1) default NULL, $temporaryCaravanFireVentilationFail TINYINT(1) default NULL, $temporaryCaravanFireFlueType VARCHAR(255) default NULL, $temporaryCaravanFireFlueSpillagePass TINYINT(1) default NULL, $temporaryCaravanFireFlueSpillageFail TINYINT(1) default NULL, '
      '$temporaryCaravanFireFlueTerminationYes TINYINT(1) default NULL, $temporaryCaravanFireFlueTerminationNo TINYINT(1) default NULL, $temporaryCaravanFireExtendedFlueYes TINYINT(1) default NULL, $temporaryCaravanFireExtendedFlueNo TINYINT(1) default NULL, $temporaryCaravanFireExtendedFlueNa TINYINT(1) default NULL, $temporaryCaravanFireFlueConditionPass TINYINT(1) default NULL, '
      '$temporaryCaravanFireFlueConditionFail TINYINT(1) default NULL, $temporaryCaravanFireApplianceSafeYes TINYINT(1) default NULL, $temporaryCaravanFireApplianceSafeNo TINYINT(1) default NULL, '
      '$temporaryCaravanCookerMake VARCHAR(255) default NULL, $temporaryCaravanCookerModel VARCHAR(255) default NULL, $temporaryCaravanCookerOperatingPressure VARCHAR(255) default NULL, $temporaryCaravanCookerOperationOfSafetyDevicesPass TINYINT(1) default NULL, $temporaryCaravanCookerOperationOfSafetyDevicesFail TINYINT(1) default NULL, '
      '$temporaryCaravanCookerVentilationPass TINYINT(1) default NULL, $temporaryCaravanCookerVentilationFail TINYINT(1) default NULL, $temporaryCaravanCookerFlueType VARCHAR(255) default NULL, $temporaryCaravanCookerFlueSpillagePass TINYINT(1) default NULL, $temporaryCaravanCookerFlueSpillageFail TINYINT(1) default NULL, '
      '$temporaryCaravanCookerFlueTerminationYes TINYINT(1) default NULL, $temporaryCaravanCookerFlueTerminationNo TINYINT(1) default NULL, $temporaryCaravanCookerExtendedFlueYes TINYINT(1) default NULL, $temporaryCaravanCookerExtendedFlueNo TINYINT(1) default NULL, $temporaryCaravanCookerExtendedFlueNa TINYINT(1) default NULL, $temporaryCaravanCookerFlueConditionPass TINYINT(1) default NULL, '
      '$temporaryCaravanCookerFlueConditionFail TINYINT(1) default NULL, $temporaryCaravanCookerApplianceSafeYes TINYINT(1) default NULL, $temporaryCaravanCookerApplianceSafeNo TINYINT(1) default NULL, '
      '$temporaryCaravanOtherMake VARCHAR(255) default NULL, $temporaryCaravanOtherModel VARCHAR(255) default NULL, $temporaryCaravanOtherOperatingPressure VARCHAR(255) default NULL, $temporaryCaravanOtherOperationOfSafetyDevicesPass TINYINT(1) default NULL, $temporaryCaravanOtherOperationOfSafetyDevicesFail TINYINT(1) default NULL, '
      '$temporaryCaravanOtherVentilationPass TINYINT(1) default NULL, $temporaryCaravanOtherVentilationFail TINYINT(1) default NULL, $temporaryCaravanOtherFlueType VARCHAR(255) default NULL, $temporaryCaravanOtherFlueSpillagePass TINYINT(1) default NULL, $temporaryCaravanOtherFlueSpillageFail TINYINT(1) default NULL, '
      '$temporaryCaravanOtherFlueTerminationYes TINYINT(1) default NULL, $temporaryCaravanOtherFlueTerminationNo TINYINT(1) default NULL, $temporaryCaravanOtherExtendedFlueYes TINYINT(1) default NULL, $temporaryCaravanOtherExtendedFlueNo TINYINT(1) default NULL, $temporaryCaravanOtherExtendedFlueNa TINYINT(1) default NULL, $temporaryCaravanOtherFlueConditionPass TINYINT(1) default NULL, '
      '$temporaryCaravanOtherFlueConditionFail TINYINT(1) default NULL, $temporaryCaravanOtherApplianceSafeYes TINYINT(1) default NULL, $temporaryCaravanOtherApplianceSafeNo TINYINT(1) default NULL, '
      '$temporaryCaravanSoundnessCheckPass TINYINT(1) default NULL, $temporaryCaravanSoundnessCheckFail TINYINT(1) default NULL, $temporaryCaravanHoseCheckPass TINYINT(1) default NULL, $temporaryCaravanHoseCheckFail TINYINT(1) default NULL, $temporaryCaravanRegulatorOperatingPressurePass TINYINT(1) default NULL, '
      '$temporaryCaravanRegulatorOperatingPressureFail TINYINT(1) default NULL, $temporaryCaravanRegulatorLockUpPressure VARCHAR(255) default NULL, $temporaryCaravanRegulatorLockUpPressurePass TINYINT(1) default NULL, $temporaryCaravanRegulatorLockUpPressureFail TINYINT(1) default NULL, '
      '$temporaryCaravanFaultDetails1 VARCHAR(255) default NULL, $temporaryCaravanRectificationWork1 VARCHAR(255) default NULL, $temporaryCaravanByWhom1 VARCHAR(255) default NULL, $temporaryCaravanOwnerInformedYes1 TINYINT(1) default NULL, $temporaryCaravanOwnerInformedNo1 TINYINT(1) default NULL, $temporaryCaravanWarningNoticeYes1 TINYINT(1) default NULL, '
      '$temporaryCaravanWarningNoticeNo1 TINYINT(1) default NULL, $temporaryCaravanWarningTagYes1 TINYINT(1) default NULL, $temporaryCaravanWarningTagNo1 TINYINT(1) default NULL, $temporaryCaravanFaultDetails2 VARCHAR(255) default NULL, $temporaryCaravanRectificationWork2 VARCHAR(255) default NULL, $temporaryCaravanByWhom2 VARCHAR(255) default NULL, $temporaryCaravanOwnerInformedYes2 TINYINT(2) default NULL, $temporaryCaravanOwnerInformedNo2 TINYINT(2) default NULL, $temporaryCaravanWarningNoticeYes2 TINYINT(2) default NULL, '
      '$temporaryCaravanWarningNoticeNo2 TINYINT(2) default NULL, $temporaryCaravanWarningTagYes2 TINYINT(2) default NULL, $temporaryCaravanWarningTagNo2 TINYINT(2) default NULL, $temporaryCaravanFaultDetails3 VARCHAR(355) default NULL, $temporaryCaravanRectificationWork3 VARCHAR(355) default NULL, $temporaryCaravanByWhom3 VARCHAR(355) default NULL, $temporaryCaravanOwnerInformedYes3 TINYINT(3) default NULL, $temporaryCaravanOwnerInformedNo3 TINYINT(3) default NULL, $temporaryCaravanWarningNoticeYes3 TINYINT(3) default NULL, '
      '$temporaryCaravanWarningNoticeNo3 TINYINT(3) default NULL, $temporaryCaravanWarningTagYes3 TINYINT(3) default NULL, $temporaryCaravanWarningTagNo3 TINYINT(3) default NULL, $temporaryCaravanFaultDetails4 VARCHAR(455) default NULL, $temporaryCaravanRectificationWork4 VARCHAR(455) default NULL, $temporaryCaravanByWhom4 VARCHAR(455) default NULL, $temporaryCaravanOwnerInformedYes4 TINYINT(4) default NULL, $temporaryCaravanOwnerInformedNo4 TINYINT(4) default NULL, $temporaryCaravanWarningNoticeYes4 TINYINT(4) default NULL, '
      '$temporaryCaravanWarningNoticeNo4 TINYINT(4) default NULL, $temporaryCaravanWarningTagYes4 TINYINT(4) default NULL, $temporaryCaravanWarningTagNo4 TINYINT(4) default NULL, $temporaryCaravanFaultDetails5 VARCHAR(555) default NULL, $temporaryCaravanRectificationWork5 VARCHAR(555) default NULL, $temporaryCaravanByWhom5 VARCHAR(555) default NULL, $temporaryCaravanOwnerInformedYes5 TINYINT(5) default NULL, $temporaryCaravanOwnerInformedNo5 TINYINT(5) default NULL, $temporaryCaravanWarningNoticeYes5 TINYINT(5) default NULL, '
      '$temporaryCaravanWarningNoticeNo5 TINYINT(5) default NULL, $temporaryCaravanWarningTagYes5 TINYINT(5) default NULL, $temporaryCaravanWarningTagNo5 TINYINT(5) default NULL, '
      '$temporaryCaravanNumberOfAppliancesTested VARCHAR(255) default NULL, $temporaryCaravanSerialNo VARCHAR(255) default NULL, $temporaryCaravanIssuerSignature BLOB default NULL, $temporaryCaravanIssuerSignaturePoints JSON default NULL, '
      '$temporaryCaravanIssuerPrintName VARCHAR(255) default NULL, $temporaryCaravanIssuerDate VARCHAR(255) default NULL, $temporaryCaravanAgentSignature BLOB default NULL, $temporaryCaravanAgentSignaturePoints JSON default NULL, $temporaryCaravanAgentDate VARCHAR(255) default NULL, $serverUploaded TINYINT(1) default NULL, $timestamp VARCHAR(255) default NULL, $temporaryCaravanApplianceType1 VARCHAR(255) default NULL, $temporaryCaravanApplianceType2 VARCHAR(255) default NULL, $temporaryCaravanApplianceType3 VARCHAR(255) default NULL, $temporaryCaravanApplianceType4 VARCHAR(255) default NULL)';




  static String createMaintenanceChecklistTableSql = 'CREATE TABLE IF NOT EXISTS $maintenanceChecklistTable($localId INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, $formVersion INT(11) default NULL, $documentId VARCHAR(255) default NULL, $formCustomerId VARCHAR(255) default NULL, $uid VARCHAR(255) default NULL, $organisationId VARCHAR(255) default NULL, $jobId VARCHAR(255) default NULL, $pendingTime VARCHAR(255) default NULL, $clientName VARCHAR(255) default NULL, '
      '$clientAddress VARCHAR(255) default NULL, $clientPostcode VARCHAR(255) default NULL,  $clientTelephone VARCHAR(255) default NULL, $clientEmail VARCHAR(255) default NULL, $routineService TINYINT(1) default NULL, $callOut TINYINT(1) default NULL, $install TINYINT(1) default NULL,'
      '$companyName VARCHAR(255) default NULL, $gasSafeRegNo VARCHAR(255) default NULL, $companyAddress VARCHAR(255) default NULL, $companyPostcode VARCHAR(255) default NULL, $companyTelephone VARCHAR(255) default NULL, $companyVatRegNo VARCHAR(255) default NULL, $engineersFullName VARCHAR(255) default NULL, $engineersGasSafeId VARCHAR(255) default NULL,'
      '$applianceMake1 VARCHAR(255) default NULL, $applianceType1 VARCHAR(255) default NULL, $applianceModel1 VARCHAR(255) default NULL, $applianceLocation1 VARCHAR(255) default NULL, $applianceHeatExchanger1 VARCHAR(255) default NULL,'
      '$applianceBurnerInjectors1 VARCHAR(255) default NULL, $applianceFlamePicture1 VARCHAR(255) default NULL, $applianceIgnition1 VARCHAR(255) default NULL, $applianceElectrics1 VARCHAR(255) default NULL, $applianceControls1 VARCHAR(255) default NULL, '
      '$applianceLeaksGasWater1 VARCHAR(255) default NULL, $applianceGasConnections1 VARCHAR(255) default NULL, $applianceSeals1 VARCHAR(255) default NULL, $appliancePipework1 VARCHAR(255) default NULL, $applianceFans1 VARCHAR(255) default NULL, '
      '$applianceFireplaceClosurePlate1 VARCHAR(255) default NULL, $applianceAllowableLocation1 VARCHAR(255) default NULL, $applianceChamberGasket1 VARCHAR(255) default NULL, $safetyVentilation1 VARCHAR(255) default NULL, $safetyFlueTermination1 VARCHAR(255) default NULL, '
      '$safetySmokePelletFlueFlowTest1 VARCHAR(255) default NULL, $safetySmokeMatchSpillageTest1 VARCHAR(255) default NULL, $safetyWorkingPressure1 VARCHAR(255) default NULL, $safetyDevice1 VARCHAR(255) default NULL, $applianceCondensate1 VARCHAR(255) default NULL, '
      '$safetyFlueCombustionTestCo21 VARCHAR(255) default NULL, $safetyFlueCombustionTestCo1 VARCHAR(255) default NULL, $safetyFlueCombustionTestRatio1 VARCHAR(255) default NULL, $safetyGasTightnessTestPerformedPass TINYINT(1) default NULL, $safetyGasTightnessTestPerformedFail TINYINT(1) default NULL, $safetyOperatingPressure1 VARCHAR(255) default NULL,'
      '$safetyGasMeterEarthBondedYes TINYINT(1) default NULL, $safetyGasMeterEarthBondedNo TINYINT(1) default NULL, $applianceMake2 VARCHAR(255) default NULL, $applianceType2 VARCHAR(255) default NULL, $applianceModel2 VARCHAR(255) default NULL, $applianceLocation2 VARCHAR(255) default NULL, $applianceHeatExchanger2 VARCHAR(255) default NULL,'
      '$applianceBurnerInjectors2 VARCHAR(255) default NULL, $applianceFlamePicture2 VARCHAR(255) default NULL, $applianceIgnition2 VARCHAR(255) default NULL, $applianceElectrics2 VARCHAR(255) default NULL, $applianceControls2 VARCHAR(255) default NULL, '
      '$applianceLeaksGasWater2 VARCHAR(255) default NULL, $applianceGasConnections2 VARCHAR(255) default NULL, $applianceSeals2 VARCHAR(255) default NULL, $appliancePipework2 VARCHAR(255) default NULL, $applianceFans2 VARCHAR(255) default NULL, '
      '$applianceFireplaceClosurePlate2 VARCHAR(255) default NULL, $applianceAllowableLocation2 VARCHAR(255) default NULL, $applianceChamberGasket2 VARCHAR(255) default NULL, $safetyVentilation2 VARCHAR(255) default NULL, $safetyFlueTermination2 VARCHAR(255) default NULL, '
      '$safetySmokePelletFlueFlowTest2 VARCHAR(255) default NULL, $safetySmokeMatchSpillageTest2 VARCHAR(255) default NULL, $safetyWorkingPressure2 VARCHAR(255) default NULL, $safetyDevice2 VARCHAR(255) default NULL, $applianceCondensate2 VARCHAR(255) default NULL, '
      '$safetyFlueCombustionTestCo22 VARCHAR(255) default NULL, $safetyFlueCombustionTestCo2 VARCHAR(255) default NULL, $safetyFlueCombustionTestRatio2 VARCHAR(255) default NULL, $safetyOperatingPressure2 VARCHAR(255) default NULL, $installationApplianceSafeYes TINYINT(1) default NULL, $installationApplianceSafeNo TINYINT(1) default NULL, $warningLabelAttachedYes TINYINT(1) default NULL, $warningLabelAttachedNo TINYINT(1) default NULL, '
      '$maintenanceFaultDetails1 TEXT default NULL, $maintenanceWarningNoticeYes1 TINYINT(1) default NULL, $maintenanceWarningNoticeNo1 TINYINT(1) default NULL, $maintenanceWarningStickerYes1 TINYINT(1) default NULL, $maintenanceWarningStickerNo1 TINYINT(1) default NULL, '
      '$maintenanceFaultDetails2 TEXT default NULL, $maintenanceWarningNoticeYes2 TINYINT(1) default NULL, $maintenanceWarningNoticeNo2 TINYINT(1) default NULL, $maintenanceWarningStickerYes2 TINYINT(1) default NULL, $maintenanceWarningStickerNo2 TINYINT(1) default NULL, '
      '$maintenanceFaultDetails3 TEXT default NULL, $maintenanceWarningNoticeYes3 TINYINT(1) default NULL, $maintenanceWarningNoticeNo3 TINYINT(1) default NULL, $maintenanceWarningStickerYes3 TINYINT(1) default NULL, $maintenanceWarningStickerNo3 TINYINT(1) default NULL, '
      '$paymentReceived TINYINT(1) default NULL, $paymentReceivedType VARCHAR(255) default NULL, $invoiceTotal VARCHAR(255) default NULL, $sendBillOut TINYINT(1) default NULL, $appliancesVisiblyCheckedYes TINYINT(1) default NULL, $appliancesVisiblyCheckedNo TINYINT(1) default NULL, $appliancesVisiblyCheckedText VARCHAR(255) default NULL, $customersSignature BLOB default NULL, $customersSignaturePoints JSON default NULL,'
      '$customerPrintName VARCHAR(255) default NULL, $customerDate VARCHAR(255) default NULL, $engineersSignature BLOB default NULL, $engineersSignaturePoints JSON default NULL, $engineerPrintName VARCHAR(255) default NULL, $engineerDate VARCHAR(255) default NULL, $engineersComments TEXT default NULL, $serverUploaded TINYINT(1) default NULL, $timestamp VARCHAR(255) default NULL)';

  static String createTemporaryMaintenanceChecklistTableSql = 'CREATE TABLE IF NOT EXISTS $temporaryMaintenanceChecklistTable($localId INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, $formVersion INT(11) default NULL, $documentId VARCHAR(255) default NULL, $formCustomerId VARCHAR(255) default NULL, $uid VARCHAR(255) default NULL, $organisationId VARCHAR(255) default NULL, $temporaryJobId VARCHAR(255) default NULL, $temporaryClientName VARCHAR(255) default NULL, '
      '$temporaryClientAddress VARCHAR(255) default NULL, $temporaryClientPostcode VARCHAR(255) default NULL,  $temporaryClientTelephone VARCHAR(255) default NULL, $temporaryClientEmail VARCHAR(255) default NULL, $temporaryRoutineService TINYINT(1) default NULL, $temporaryCallOut TINYINT(1) default NULL, $temporaryInstall TINYINT(1) default NULL,'
      '$temporaryCompanyName VARCHAR(255) default NULL, $temporaryGasSafeRegNo VARCHAR(255) default NULL, $temporaryCompanyAddress VARCHAR(255) default NULL, $temporaryCompanyPostcode VARCHAR(255) default NULL, $temporaryCompanyTelephone VARCHAR(255) default NULL, $temporaryCompanyVatRegNo VARCHAR(255) default NULL, $engineersFullName VARCHAR(255) default NULL, $temporaryEngineersGasSafeId VARCHAR(255) default NULL,'
      '$temporaryApplianceMake1 VARCHAR(255) default NULL, $temporaryApplianceType1 VARCHAR(255) default NULL, $temporaryApplianceModel1 VARCHAR(255) default NULL, $temporaryApplianceLocation1 VARCHAR(255) default NULL, $temporaryApplianceHeatExchanger1 VARCHAR(255) default NULL,'
      '$temporaryApplianceBurnerInjectors1 VARCHAR(255) default NULL, $temporaryApplianceFlamePicture1 VARCHAR(255) default NULL, $temporaryApplianceIgnition1 VARCHAR(255) default NULL, $temporaryApplianceElectrics1 VARCHAR(255) default NULL, $temporaryApplianceControls1 VARCHAR(255) default NULL, '
      '$temporaryApplianceLeaksGasWater1 VARCHAR(255) default NULL, $temporaryApplianceGasConnections1 VARCHAR(255) default NULL, $temporaryApplianceSeals1 VARCHAR(255) default NULL, $temporaryAppliancePipework1 VARCHAR(255) default NULL, $temporaryApplianceFans1 VARCHAR(255) default NULL, '
      '$temporaryApplianceFireplaceClosurePlate1 VARCHAR(255) default NULL, $temporaryApplianceAllowableLocation1 VARCHAR(255) default NULL, $temporaryApplianceChamberGasket1 VARCHAR(255) default NULL, $temporarySafetyVentilation1 VARCHAR(255) default NULL, $temporarySafetyFlueTermination1 VARCHAR(255) default NULL, '
      '$temporarySafetySmokePelletFlueFlowTest1 VARCHAR(255) default NULL, $temporarySafetySmokeMatchSpillageTest1 VARCHAR(255) default NULL, $temporarySafetyWorkingPressure1 VARCHAR(255) default NULL, $temporarySafetyDevice1 VARCHAR(255) default NULL, $temporaryApplianceCondensate1 VARCHAR(255) default NULL, '
      '$temporarySafetyFlueCombustionTestCo21 VARCHAR(255) default NULL, $temporarySafetyFlueCombustionTestCo1 VARCHAR(255) default NULL, $temporarySafetyFlueCombustionTestRatio1 VARCHAR(255) default NULL, $temporarySafetyGasTightnessTestPerformedPass TINYINT(1) default NULL, $temporarySafetyGasTightnessTestPerformedFail TINYINT(1) default NULL, $temporarySafetyOperatingPressure1 VARCHAR(255) default NULL, $temporarySafetyGasMeterEarthBondedYes TINYINT(1) default NULL, $temporarySafetyGasMeterEarthBondedNo TINYINT(1) default NULL,'
      '$temporaryApplianceMake2 VARCHAR(255) default NULL, $temporaryApplianceType2 VARCHAR(255) default NULL, $temporaryApplianceModel2 VARCHAR(255) default NULL, $temporaryApplianceLocation2 VARCHAR(255) default NULL, $temporaryApplianceHeatExchanger2 VARCHAR(255) default NULL,'
      '$temporaryApplianceBurnerInjectors2 VARCHAR(255) default NULL, $temporaryApplianceFlamePicture2 VARCHAR(255) default NULL, $temporaryApplianceIgnition2 VARCHAR(255) default NULL, $temporaryApplianceElectrics2 VARCHAR(255) default NULL, $temporaryApplianceControls2 VARCHAR(255) default NULL, '
      '$temporaryApplianceLeaksGasWater2 VARCHAR(255) default NULL, $temporaryApplianceGasConnections2 VARCHAR(255) default NULL, $temporaryApplianceSeals2 VARCHAR(255) default NULL, $temporaryAppliancePipework2 VARCHAR(255) default NULL, $temporaryApplianceFans2 VARCHAR(255) default NULL, '
      '$temporaryApplianceFireplaceClosurePlate2 VARCHAR(255) default NULL, $temporaryApplianceAllowableLocation2 VARCHAR(255) default NULL, $temporaryApplianceChamberGasket2 VARCHAR(255) default NULL, $temporarySafetyVentilation2 VARCHAR(255) default NULL, $temporarySafetyFlueTermination2 VARCHAR(255) default NULL, '
      '$temporarySafetySmokePelletFlueFlowTest2 VARCHAR(255) default NULL, $temporarySafetySmokeMatchSpillageTest2 VARCHAR(255) default NULL, $temporarySafetyWorkingPressure2 VARCHAR(255) default NULL, $temporarySafetyDevice2 VARCHAR(255) default NULL, $temporaryApplianceCondensate2 VARCHAR(255) default NULL, '
      '$temporarySafetyFlueCombustionTestCo22 VARCHAR(255) default NULL, $temporarySafetyFlueCombustionTestCo2 VARCHAR(255) default NULL, $temporarySafetyFlueCombustionTestRatio2 VARCHAR(255) default NULL, $temporarySafetyOperatingPressure2 VARCHAR(255) default NULL, $temporaryInstallationApplianceSafeYes TINYINT(1) default NULL, $temporaryInstallationApplianceSafeNo TINYINT(1) default NULL, $temporaryWarningLabelAttachedYes TINYINT(1) default NULL, $temporaryWarningLabelAttachedNo TINYINT(1) default NULL, '
      '$temporaryMaintenanceFaultDetails1 TEXT default NULL, $temporaryMaintenanceWarningNoticeYes1 TINYINT(1) default NULL, $temporaryMaintenanceWarningNoticeNo1 TINYINT(1) default NULL, $temporaryMaintenanceWarningStickerYes1 TINYINT(1) default NULL, $temporaryMaintenanceWarningStickerNo1 TINYINT(1) default NULL, '
      '$temporaryMaintenanceFaultDetails2 TEXT default NULL, $temporaryMaintenanceWarningNoticeYes2 TINYINT(1) default NULL, $temporaryMaintenanceWarningNoticeNo2 TINYINT(1) default NULL, $temporaryMaintenanceWarningStickerYes2 TINYINT(1) default NULL, $temporaryMaintenanceWarningStickerNo2 TINYINT(1) default NULL, '
      '$temporaryMaintenanceFaultDetails3 TEXT default NULL, $temporaryMaintenanceWarningNoticeYes3 TINYINT(1) default NULL, $temporaryMaintenanceWarningNoticeNo3 TINYINT(1) default NULL, $temporaryMaintenanceWarningStickerYes3 TINYINT(1) default NULL, $temporaryMaintenanceWarningStickerNo3 TINYINT(1) default NULL, '
      '$temporaryPaymentReceived TINYINT(1) default NULL, $temporaryPaymentReceivedType VARCHAR(255) default NULL, $temporaryInvoiceTotal VARCHAR(255) default NULL, $temporarySendBillOut TINYINT(1) default NULL, $temporaryAppliancesVisiblyCheckedYes TINYINT(1) default NULL, $temporaryAppliancesVisiblyCheckedNo TINYINT(1) default NULL, $temporaryAppliancesVisiblyCheckedText VARCHAR(255) default NULL, $temporaryCustomersSignature BLOB default NULL, $temporaryCustomersSignaturePoints JSON default NULL,'
      '$temporaryCustomerPrintName VARCHAR(255) default NULL, $temporaryCustomerDate VARCHAR(255) default NULL, $temporaryEngineersSignature BLOB default NULL, $temporaryEngineersSignaturePoints JSON default NULL, $temporaryEngineerPrintName VARCHAR(255) default NULL, $temporaryEngineerDate VARCHAR(255) default NULL, $temporaryEngineersComments TEXT default NULL)';

  static String createVehicleChecklistTableSql = 'CREATE TABLE IF NOT EXISTS $vehicleChecklistTable($localId INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, $formVersion INT(11) default NULL, $documentId VARCHAR(255) default NULL, $formCustomerId VARCHAR(255) default NULL, $uid VARCHAR(255) default NULL, '
      '$organisationId VARCHAR(255) default NULL, $organisationName VARCHAR(255) default NULL, $jobId VARCHAR(255) default NULL, $pendingTime VARCHAR(255) default NULL, $driverName VARCHAR(255) default NULL, $vehicleType VARCHAR(255) default NULL, $currentMileage VARCHAR(255) default NULL, '
      '$treadDriversSideFrontTyre VARCHAR(255) default NULL, $treadDriversSideRearTyre VARCHAR(255) default NULL, $treadPassengersSideFrontTyre VARCHAR(255) default NULL, $treadPassengersSideRearTyre VARCHAR(255) default NULL, '
      '$pressureDriversSideFrontTyre VARCHAR(255) default NULL, $pressureDriversSideRearTyre VARCHAR(255) default NULL, $pressurePassengersSideFrontTyre VARCHAR(255) default NULL, $pressurePassengersSideRearTyre VARCHAR(255) default NULL, '
      '$warningLights VARCHAR(255) default NULL, $nextService VARCHAR(255) default NULL, $specialistEquipment VARCHAR(255) default NULL, $specialistEquipmentYesNoValue VARCHAR(255) default NULL, '
      '$driverFeedback VARCHAR(255) default NULL, $driversSignature BLOB default NULL, $driversSignaturePoints BLOB default NULL, $driverDate VARCHAR(255) default NULL, $completedSheetTo VARCHAR(255) default NULL, $deadlineForReturn VARCHAR(255) default NULL, '
      '$queryContact VARCHAR(255) default NULL, $reviewDate VARCHAR(255) default NULL, $serverUploaded TINYINT(1) default NULL, $timestamp VARCHAR(255) default NULL)';

  static String createTemporaryVehicleChecklistTableSql = 'CREATE TABLE IF NOT EXISTS $temporaryVehicleChecklistTable($localId INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, $formVersion INT(11) default NULL, $documentId VARCHAR(255) default NULL, $formCustomerId VARCHAR(255) default NULL, $uid VARCHAR(255) default NULL, '
      '$organisationId VARCHAR(255) default NULL, $organisationName VARCHAR(255) default NULL, $temporaryJobId VARCHAR(255) default NULL, $temporaryDriverName VARCHAR(255) default NULL, $temporaryVehicleType VARCHAR(255) default NULL, $temporaryCurrentMileage VARCHAR(255) default NULL, '
      '$temporaryTreadDriversSideFrontTyre VARCHAR(255) default NULL, $temporaryTreadDriversSideRearTyre VARCHAR(255) default NULL, $temporaryTreadPassengersSideFrontTyre VARCHAR(255) default NULL, $temporaryTreadPassengersSideRearTyre VARCHAR(255) default NULL, '
      '$temporaryPressureDriversSideFrontTyre VARCHAR(255) default NULL, $temporaryPressureDriversSideRearTyre VARCHAR(255) default NULL, $temporaryPressurePassengersSideFrontTyre VARCHAR(255) default NULL, $temporaryPressurePassengersSideRearTyre VARCHAR(255) default NULL, '
      '$temporaryWarningLights VARCHAR(255) default NULL, $temporaryNextService VARCHAR(255) default NULL, $temporarySpecialistEquipment VARCHAR(255) default NULL, $temporarySpecialistEquipmentYesNoValue VARCHAR(255) default NULL, '
      '$temporaryDriverFeedback VARCHAR(255) default NULL, $temporaryDriversSignature BLOB default NULL, $temporaryDriversSignaturePoints JSON default NULL, $temporaryDriverDate VARCHAR(255) default NULL, $temporaryCompletedSheetTo VARCHAR(255) default NULL, $temporaryDeadlineForReturn VARCHAR(255) default NULL, '
      '$temporaryQueryContact VARCHAR(255) default NULL, $temporaryReviewDate VARCHAR(255) default NULL)';

  static String createJobTableSql = 'CREATE TABLE IF NOT EXISTS $jobTable($localId INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, $formVersion INT(11) default NULL, $documentId VARCHAR(255) default NULL, $uid VARCHAR(255) default NULL, '
      '$organisationId VARCHAR(255) default NULL, $organisationName VARCHAR(255) default NULL, $companyAddress VARCHAR(255) default NULL, $companyPostcode VARCHAR(255) default NULL, $jobNo VARCHAR(255) default NULL, $jobClient VARCHAR(255) default NULL, $jobAddress VARCHAR(255) default NULL, '
      '$jobPostCode VARCHAR(255) default NULL, $latitude DOUBLE default NULL, $longitude DOUBLE default NULL, $jobContactNo VARCHAR(255) default NULL, $jobMobile VARCHAR(255) default NULL, $jobEmail VARCHAR(255) default NULL, $jobTime VARCHAR(255) default NULL, $jobDescription VARCHAR(255) default NULL, $jobEng VARCHAR(255) default NULL, '
      '$jobDate VARCHAR(255) default NULL, $jobEngUid VARCHAR(255) default NULL, $jobEngEmail VARCHAR(255) default NULL, $jobEngDocumentId VARCHAR(255) default NULL, $jobStatus VARCHAR(255) default NULL, $jobCustomerId VARCHAR(255) default NULL, $jobPaid TINYINT(1) default NULL, $jobCancellationReason VARCHAR(255) default NULL, $jobRescheduleReason VARCHAR(255) default NULL, $jobPaymentMethod VARCHAR(255) default NULL, $jobType VARCHAR(255) default NULL,'
      '$jobCustomerLandlordName VARCHAR(255) default NULL, $jobCustomerLandlordAddress VARCHAR(255) default NULL, $jobCustomerLandlordPostcode VARCHAR(255) default NULL, $jobCustomerLandlordContact VARCHAR(255) default NULL, $jobCustomerLandlordEmail VARCHAR(255) default NULL, $jobCustomerBoilerMake VARCHAR(255) default NULL, $jobCustomerBoilerModel VARCHAR(255) default NULL, $jobCustomerBoilerType VARCHAR(255) default NULL, $jobCustomerBoilerFire TINYINT(1) default NULL, $serverUploaded TINYINT(1) default NULL, $timestamp VARCHAR(255) default NULL)';

  static String createTemporaryJobTableSql = 'CREATE TABLE IF NOT EXISTS $temporaryJobTable($localId INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, $formVersion INT(11) default NULL, $documentId VARCHAR(255) default NULL, $uid VARCHAR(255) default NULL, '
      '$organisationId VARCHAR(255) default NULL, $organisationName VARCHAR(255) default NULL, $temporaryCompanyAddress VARCHAR(255) default NULL, $temporaryCompanyPostcode VARCHAR(255) default NULL, $jobNo VARCHAR(255) default NULL, $temporaryJobClient VARCHAR(255) default NULL, $temporaryJobAddress VARCHAR(255) default NULL, '
      '$temporaryJobPostCode VARCHAR(255) default NULL, $temporaryJobContactNo VARCHAR(255) default NULL, $temporaryJobMobile VARCHAR(255) default NULL, $temporaryJobEmail VARCHAR(255) default NULL, $temporaryJobTime VARCHAR(255) default NULL, $temporaryJobDescription VARCHAR(255) default NULL, $temporaryJobEng VARCHAR(255) default NULL, $temporaryJobEngEmail VARCHAR(255) default NULL, $temporaryJobEngDocumentId VARCHAR(255) default NULL, $temporaryJobDate VARCHAR(255) default NULL, $temporaryJobEngUid VARCHAR(255) default NULL, '
      '$temporaryJobCustomerId VARCHAR(255) default NULL, $temporaryJobPaid TINYINT(1) default NULL, $temporaryJobType VARCHAR(255) default NULL, $temporaryJobCustomerLandlordName VARCHAR(255) default NULL, $temporaryJobCustomerLandlordAddress VARCHAR(255) default NULL, $temporaryJobCustomerLandlordPostcode VARCHAR(255) default NULL, $temporaryJobCustomerLandlordContact VARCHAR(255) default NULL, $temporaryJobCustomerLandlordEmail VARCHAR(255) default NULL, $temporaryJobCustomerBoilerMake VARCHAR(255) default NULL, $temporaryJobCustomerBoilerModel VARCHAR(255) default NULL, $temporaryJobCustomerBoilerType VARCHAR(255) default NULL, $temporaryJobCustomerBoilerFire TINYINT(1) default NULL)';

  static String createTemporaryOrganisationTableSql = 'CREATE TABLE IF NOT EXISTS $temporaryOrganisationTable($localId INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, $logoImagePath TEXT default NULL)';

  static String createPartsFormTableSql = 'CREATE TABLE IF NOT EXISTS $partsFormTable($localId INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, $formVersion INT(11) default NULL, $documentId VARCHAR(255) default NULL, $formCustomerId VARCHAR(255) default NULL, $uid VARCHAR(255) default NULL, '
      '$organisationId VARCHAR(255) default NULL, $organisationName VARCHAR(255) default NULL, $jobId VARCHAR(255) default NULL, $pendingTime VARCHAR(255) default NULL, $partsFormCompanyAddress VARCHAR(255) default NULL, $partsFormCompanyPostCode VARCHAR(255) default NULL, '
      '$partsFormCompanyTelNo VARCHAR(255) default NULL, $partsFormCompanyGasSafeRegNo VARCHAR(255) default NULL, $partsFormDate VARCHAR(255) default NULL, $partsFormRefNo VARCHAR(255) default NULL, '
      '$partsFormName VARCHAR(255) default NULL, $partsFormAddress VARCHAR(255) default NULL, $partsFormBillingAddress VARCHAR(255) default NULL, $partsFormPostCode VARCHAR(255) default NULL, $partsFormBillingPostCode VARCHAR(255) default NULL, $partsFormTelNo VARCHAR(255) default NULL, '
      '$partsFormMobile VARCHAR(255) default NULL, $partsFormAppliance VARCHAR(255) default NULL, $partsFormMake VARCHAR(255) default NULL, $partsFormModel VARCHAR(255) default NULL, '
      '$partsFormGcNo VARCHAR(255) default NULL, $partsFormPartsRequired VARCHAR(255) default NULL, $partsFormOrderedYes TINYINT(1) default NULL, $partsFormOrderedNo TINYINT(1) default NULL, $partsFormSupplier TINYINT(1) default NULL, $partsFormSupplierText VARCHAR(255) default NULL, '
      '$partsFormManufacturer TINYINT(1) default NULL, $partsFormFurther TINYINT(1) default NULL, $partsFormPrice VARCHAR(255) default NULL, $partsFormFurtherInfo VARCHAR(255) default NULL, '
      '$partsFormCustomersSignature BLOB default NULL, $partsFormCustomersSignaturePoints JSON default NULL, $partsFormCustomersEmail VARCHAR(255) default NULL, $partsFormEngineersSignature BLOB default NULL, $partsFormEngineersSignaturePoints JSON default NULL, $partsFormImages JSON default NULL, $partsFormLocalImages JSON default NULL, $partsFormImageFiles JSON default NULL, '
      '$serverUploaded TINYINT(1) default NULL, $timestamp VARCHAR(255) default NULL)';

  static String createTemporaryPartsFormTableSql = 'CREATE TABLE IF NOT EXISTS $temporaryPartsFormTable($localId INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, $formVersion INT(11) default NULL, $documentId VARCHAR(255) default NULL, $formCustomerId VARCHAR(255) default NULL, $uid VARCHAR(255) default NULL, '
      '$organisationId VARCHAR(255) default NULL, $organisationName VARCHAR(255) default NULL, $temporaryJobId VARCHAR(255) default NULL, $temporaryPartsFormCompanyAddress VARCHAR(255) default NULL, $temporaryPartsFormCompanyPostCode VARCHAR(255) default NULL, '
      '$temporaryPartsFormCompanyTelNo VARCHAR(255) default NULL, $temporaryPartsFormCompanyGasSafeRegNo VARCHAR(255) default NULL, $temporaryPartsFormDate VARCHAR(255) default NULL, $temporaryPartsFormRefNo VARCHAR(255) default NULL, '
      '$temporaryPartsFormName VARCHAR(255) default NULL, $temporaryPartsFormAddress VARCHAR(255) default NULL, $temporaryPartsFormBillingAddress VARCHAR(255) default NULL, $temporaryPartsFormPostCode VARCHAR(255) default NULL, $temporaryPartsFormBillingPostCode VARCHAR(255) default NULL, $temporaryPartsFormTelNo VARCHAR(255) default NULL, '
      '$temporaryPartsFormMobile VARCHAR(255) default NULL, $temporaryPartsFormAppliance VARCHAR(255) default NULL, $temporaryPartsFormMake VARCHAR(255) default NULL, $temporaryPartsFormModel VARCHAR(255) default NULL, '
      '$temporaryPartsFormGcNo VARCHAR(255) default NULL, $temporaryPartsFormPartsRequired VARCHAR(255) default NULL, $temporaryPartsFormOrderedYes TINYINT(1) default NULL, $temporaryPartsFormOrderedNo TINYINT(1) default NULL, $temporaryPartsFormSupplier TINYINT(1) default NULL, $temporaryPartsFormSupplierText VARCHAR(255) default NULL,'
      '$temporaryPartsFormManufacturer TINYINT(1) default NULL, $temporaryPartsFormFurther TINYINT(1) default NULL, $temporaryPartsFormPrice VARCHAR(255) default NULL, $temporaryPartsFormFurtherInfo VARCHAR(255) default NULL, '
      '$temporaryPartsFormCustomersSignature BLOB default NULL, $temporaryPartsFormCustomersSignaturePoints JSON default NULL, $temporaryPartsFormCustomersEmail VARCHAR(255) default NULL, $temporaryPartsFormEngineersSignature BLOB default NULL, $temporaryPartsFormEngineersSignaturePoints JSON default NULL, $temporaryPartsFormImages JSON default NULL, $temporaryPartsFormLocalImages JSON default NULL, $temporaryPartsFormImageFiles JSON default NULL)';

  static String createInvoiceTableSql = 'CREATE TABLE IF NOT EXISTS $invoiceTable($localId INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, $formVersion INT(11) default NULL, $documentId VARCHAR(255) default NULL, $formCustomerId VARCHAR(255) default NULL, $uid VARCHAR(255) default NULL, '
      '$organisationId VARCHAR(255) default NULL, $jobId VARCHAR(255) default NULL, $organisationName VARCHAR(255) default NULL, $invoiceCompanyName VARCHAR(255) default NULL, $invoiceCompanyAddress VARCHAR(255) default NULL, $invoiceCompanyPostCode VARCHAR(255) default NULL, '
      '$invoiceCompanyTelNo VARCHAR(255) default NULL, $invoiceCompanyVatRegNo VARCHAR(255) default NULL, $invoiceCompanyEmail VARCHAR(255) default NULL, '
      '$invoiceCustomerName VARCHAR(255) default NULL, $invoiceCustomerAddress VARCHAR(255) default NULL, $invoiceCustomerPostCode VARCHAR(255) default NULL, $invoiceCustomerTelNo VARCHAR(255) default NULL, $invoiceCustomerMobile VARCHAR(255) default NULL, '
      '$invoiceCustomerEmail VARCHAR(255) default NULL, $invoiceNo VARCHAR(255) default NULL, $invoiceDate VARCHAR(255) default NULL, '
      '$invoiceDueDate VARCHAR(255) default NULL, $invoiceTerms VARCHAR(255) default NULL, '
      '$invoiceComment VARCHAR(255) default NULL, $invoiceItems JSON default NULL, $invoiceSubtotal VARCHAR(255) default NULL, $invoiceVatAmount VARCHAR(255) default NULL, '
      '$invoiceTotalAmount VARCHAR(255) default NULL, $invoicePaidAmount VARCHAR(255) default NULL, $invoiceBalanceDue VARCHAR(255) default NULL, $invoicePaidFull TINYINT(1) default NULL, $invoiceJobNo VARCHAR(255) default NULL, $serverUploaded TINYINT(1) default NULL, $timestamp VARCHAR(255) default NULL)';

  static String createTemporaryInvoiceTableSql = 'CREATE TABLE IF NOT EXISTS $temporaryInvoiceTable($localId INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, $formVersion INT(11) default NULL, $documentId VARCHAR(255) default NULL, $formCustomerId VARCHAR(255) default NULL, $uid VARCHAR(255) default NULL, '
      '$organisationId VARCHAR(255) default NULL, $temporaryJobId VARCHAR(255) default NULL, $organisationName VARCHAR(255) default NULL, $temporaryInvoiceCompanyName VARCHAR(255) default NULL, $temporaryInvoiceCompanyAddress VARCHAR(255) default NULL, $temporaryInvoiceCompanyPostCode VARCHAR(255) default NULL, '
      '$temporaryInvoiceCompanyTelNo VARCHAR(255) default NULL, $temporaryInvoiceCompanyVatRegNo VARCHAR(255) default NULL, $temporaryInvoiceCompanyEmail VARCHAR(255) default NULL, '
      '$temporaryInvoiceCustomerName VARCHAR(255) default NULL, $temporaryInvoiceCustomerAddress VARCHAR(255) default NULL, $temporaryInvoiceCustomerPostCode VARCHAR(255) default NULL, $temporaryInvoiceCustomerTelNo VARCHAR(255) default NULL, $temporaryInvoiceCustomerMobile VARCHAR(255) default NULL, '
      '$temporaryInvoiceCustomerEmail VARCHAR(255) default NULL, $temporaryInvoiceNo VARCHAR(255) default NULL, $temporaryInvoiceDate VARCHAR(255) default NULL, '
      '$temporaryInvoiceDueDate VARCHAR(255) default NULL, $temporaryInvoiceTerms VARCHAR(255) default NULL, '
      '$temporaryInvoiceComment VARCHAR(255) default NULL, $temporaryInvoiceItems JSON default NULL, $temporaryInvoiceSubtotal VARCHAR(255) default NULL, $temporaryInvoiceVatAmount VARCHAR(255) default NULL, '
      '$temporaryInvoiceTotalAmount VARCHAR(255) default NULL, $temporaryInvoicePaidAmount VARCHAR(255) default NULL, $temporaryInvoiceBalanceDue VARCHAR(255) default NULL, $temporaryInvoicePaidFull TINYINT(1) default NULL, $temporaryInvoiceJobNo VARCHAR(255) default NULL)';

  static String createEstimatesTableSql = 'CREATE TABLE IF NOT EXISTS $estimatesTable('
      '$localId INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, '
      '$formVersion INT(11) default NULL, '
      '$documentId VARCHAR(255) default NULL, '
      '$formCustomerId VARCHAR(255) default NULL, '
      '$uid VARCHAR(255) default NULL, '
      '$organisationId VARCHAR(255) default NULL, '
      '$organisationName VARCHAR(255) default NULL, '
      '$jobId VARCHAR(255) default NULL, '
      '$pendingTime VARCHAR(255) default NULL, '
      '$estimatesCompanyAddress VARCHAR(255) default NULL, '
      '$estimatesCompanyPostCode VARCHAR(255) default NULL, '
      '$estimatesCompanyTelephone VARCHAR(255) default NULL, '
      '$estimatesCompanyVatRegNo VARCHAR(255) default NULL, '
      '$estimatesCompanyGasSafeRegNo VARCHAR(255) default NULL, '
      '$estimatesDate VARCHAR(255) default NULL, '
      '$estimatesEngineerName VARCHAR(255) default NULL, '
      '$estimatesCustomerName VARCHAR(255) default NULL, '
      '$estimatesAddress VARCHAR(255) default NULL, '
      '$estimatesContactNo VARCHAR(255) default NULL, '
      '$estimatesPostCode VARCHAR(255) default NULL, '
      '$estimatesPrice VARCHAR(255) default NULL, '
      '$estimatesCustomerEmail VARCHAR(255) default NULL, '
      '$estimatesTypeConversion TINYINT(1) default NULL, '
      '$estimatesTypeCombiSwap TINYINT(1) default NULL, '
      '$estimatesTypeHeatOnly TINYINT(1) default NULL, '
      '$estimatesTypeFullHeat TINYINT(1) default NULL, '
      '$estimatesCurrentBoilerLocation VARCHAR(255) default NULL, '
      '$estimatesNewBoilerLocation VARCHAR(255) default NULL, '
      '$estimatesGuarantee VARCHAR(255) default NULL, '
      '$estimatesFlueTypeStandard TINYINT(1) default NULL, '
      '$estimatesFlueTypeVerticalFlat TINYINT(1) default NULL, '
      '$estimatesFlueTypeVerticalPitched TINYINT(1) default NULL, '
      '$estimatesMagnaCleanYes TINYINT(1) default NULL, '
      '$estimatesMagnaCleanNo TINYINT(1) default NULL, '
      '$estimatesMagnaCleanNa TINYINT(1) default NULL, '
      '$estimatesRoomStat VARCHAR(255) default NULL, '
      '$estimatesClockYes TINYINT(1) default NULL, '
      '$estimatesClockNo TINYINT(1) default NULL, '
      '$estimatesClockNa TINYINT(1) default NULL, '
      '$estimatesTrvSize15 TINYINT(1) default NULL, '
      '$estimatesTrvSize10 TINYINT(1) default NULL, '
      '$estimatesTrvSize8 TINYINT(1) default NULL, '
      '$estimatesTrvSizeNa TINYINT(1) default NULL, '
      '$estimatesGasPipe VARCHAR(255) default NULL, '
      '$estimatesCondensateRoute VARCHAR(255) default NULL, '
      '$estimatesFlowReturn VARCHAR(255) default NULL, '
      '$estimatesHotCold VARCHAR(255) default NULL, '
      '$estimatesPressureRelief VARCHAR(255) default NULL, '
      '$estimatesNumberOfShowers VARCHAR(255) default NULL, '
      '$estimatesGasMeterStopCock VARCHAR(255) default NULL, '
      '$estimatesElectricianRequiredYes TINYINT(1) default NULL, '
      '$estimatesElectricianRequiredNo TINYINT(1) default NULL, '
      '$estimatesElectricianRequiredNa TINYINT(1) default NULL, '
      '$estimatesRooferRequiredYes TINYINT(1) default NULL, '
      '$estimatesRooferRequiredNo TINYINT(1) default NULL, '
      '$estimatesRooferRequiredNa TINYINT(1) default NULL, '
      '$estimatesBrickworkPlasteringRequiredYes TINYINT(1) default NULL, '
      '$estimatesBrickworkPlasteringRequiredNo TINYINT(1) default NULL, '
      '$estimatesBrickworkPlasteringRequiredNa TINYINT(1) default NULL, '
      '$estimatesCustomerWork VARCHAR(255) default NULL, '
      '$estimatesOtherNotes TEXT default NULL, '
      '$estimatesTrvNotes TEXT default NULL, '
      '$estimatesBrickworkNotes TEXT default NULL, '
      '$estimatesImages JSON default NULL, '
      '$estimatesLocalImages JSON default NULL, '
      '$estimatesImageFiles JSON default NULL, '
      '$serverUploaded TINYINT(1) default NULL, '
      '$timestamp VARCHAR(255) default NULL)';

  static String createTemporaryEstimatesTableSql = 'CREATE TABLE IF NOT EXISTS  $temporaryEstimatesTable('
      '$localId INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, '
      '$formVersion INT(11) default NULL, '
      '$documentId VARCHAR(255) default NULL, '
      '$formCustomerId VARCHAR(255) default NULL, '
      '$uid VARCHAR(255) default NULL, '
      '$organisationId VARCHAR(255) default NULL, '
      '$organisationName VARCHAR(255) default NULL, '
      '$temporaryJobId VARCHAR(255) default NULL, '
      '$temporaryEstimatesCompanyAddress VARCHAR(255) default NULL, '
      '$temporaryEstimatesCompanyPostCode VARCHAR(255) default NULL, '
      '$temporaryEstimatesCompanyTelephone VARCHAR(255) default NULL, '
      '$temporaryEstimatesCompanyVatRegNo VARCHAR(255) default NULL, '
      '$temporaryEstimatesCompanyGasSafeRegNo VARCHAR(255) default NULL, '
      '$temporaryEstimatesDate VARCHAR(255) default NULL, '
      '$temporaryEstimatesEngineerName VARCHAR(255) default NULL, '
      '$temporaryEstimatesCustomerName VARCHAR(255) default NULL, '
      '$temporaryEstimatesAddress VARCHAR(255) default NULL, '
      '$temporaryEstimatesContactNo VARCHAR(255) default NULL, '
      '$temporaryEstimatesPostCode VARCHAR(255) default NULL, '
      '$temporaryEstimatesPrice VARCHAR(255) default NULL, '
      '$temporaryEstimatesCustomerEmail VARCHAR(255) default NULL, '
      '$temporaryEstimatesTypeConversion TINYINT(1) default NULL, '
      '$temporaryEstimatesTypeCombiSwap TINYINT(1) default NULL, '
      '$temporaryEstimatesTypeHeatOnly TINYINT(1) default NULL, '
      '$temporaryEstimatesTypeFullHeat TINYINT(1) default NULL, '
      '$temporaryEstimatesCurrentBoilerLocation VARCHAR(255) default NULL, '
      '$temporaryEstimatesNewBoilerLocation VARCHAR(255) default NULL, '
      '$temporaryEstimatesGuarantee VARCHAR(255) default NULL, '
      '$temporaryEstimatesFlueTypeStandard TINYINT(1) default NULL, '
      '$temporaryEstimatesFlueTypeVerticalFlat TINYINT(1) default NULL, '
      '$temporaryEstimatesFlueTypeVerticalPitched TINYINT(1) default NULL, '
      '$temporaryEstimatesMagnaCleanYes TINYINT(1) default NULL, '
      '$temporaryEstimatesMagnaCleanNo TINYINT(1) default NULL, '
      '$temporaryEstimatesMagnaCleanNa TINYINT(1) default NULL, '
      '$temporaryEstimatesRoomStat VARCHAR(255) default NULL, '
      '$temporaryEstimatesClockYes TINYINT(1) default NULL, '
      '$temporaryEstimatesClockNo TINYINT(1) default NULL, '
      '$temporaryEstimatesClockNa TINYINT(1) default NULL, '
      '$temporaryEstimatesTrvSize15 TINYINT(1) default NULL, '
      '$temporaryEstimatesTrvSize10 TINYINT(1) default NULL, '
      '$temporaryEstimatesTrvSize8 TINYINT(1) default NULL, '
      '$temporaryEstimatesTrvSizeNa TINYINT(1) default NULL, '
      '$temporaryEstimatesGasPipe VARCHAR(255) default NULL, '
      '$temporaryEstimatesCondensateRoute VARCHAR(255) default NULL, '
      '$temporaryEstimatesFlowReturn VARCHAR(255) default NULL, '
      '$temporaryEstimatesHotCold VARCHAR(255) default NULL, '
      '$temporaryEstimatesPressureRelief VARCHAR(255) default NULL, '
      '$temporaryEstimatesNumberOfShowers VARCHAR(255) default NULL, '
      '$temporaryEstimatesGasMeterStopCock VARCHAR(255) default NULL, '
      '$temporaryEstimatesElectricianRequiredYes TINYINT(1) default NULL, '
      '$temporaryEstimatesElectricianRequiredNo TINYINT(1) default NULL, '
      '$temporaryEstimatesElectricianRequiredNa TINYINT(1) default NULL, '
      '$temporaryEstimatesRooferRequiredYes TINYINT(1) default NULL, '
      '$temporaryEstimatesRooferRequiredNo TINYINT(1) default NULL, '
      '$temporaryEstimatesRooferRequiredNa TINYINT(1) default NULL, '
      '$temporaryEstimatesBrickworkPlasteringRequiredYes TINYINT(1) default NULL, '
      '$temporaryEstimatesBrickworkPlasteringRequiredNo TINYINT(1) default NULL, '
      '$temporaryEstimatesBrickworkPlasteringRequiredNa TINYINT(1) default NULL, '
      '$temporaryEstimatesCustomerWork VARCHAR(255) default NULL, '
      '$temporaryEstimatesOtherNotes TEXT default NULL, '
      '$temporaryEstimatesTrvNotes TEXT default NULL, '
      '$temporaryEstimatesBrickworkNotes TEXT default NULL, '
      '$temporaryEstimatesImages JSON default NULL)';

  static String createEstimatesBasicTableSql = 'CREATE TABLE IF NOT EXISTS $estimatesBasicTable('
      '$localId INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, '
      '$formVersion INT(11) default NULL, '
      '$documentId VARCHAR(255) default NULL, '
      '$formCustomerId VARCHAR(255) default NULL, '
      '$uid VARCHAR(255) default NULL, '
      '$organisationId VARCHAR(255) default NULL, '
      '$organisationName VARCHAR(255) default NULL, '
      '$jobId VARCHAR(255) default NULL, '
      '$pendingTime VARCHAR(255) default NULL, '
      '$estimatesBasicCompanyAddress VARCHAR(255) default NULL, '
      '$estimatesBasicCompanyPostCode VARCHAR(255) default NULL, '
      '$estimatesBasicCompanyTelephone VARCHAR(255) default NULL, '
      '$estimatesBasicCompanyVatRegNo VARCHAR(255) default NULL, '
      '$estimatesBasicCompanyGasSafeRegNo VARCHAR(255) default NULL, '
      '$estimatesBasicDate VARCHAR(255) default NULL, '
      '$estimatesBasicEngineerName VARCHAR(255) default NULL, '
      '$estimatesBasicCustomerName VARCHAR(255) default NULL, '
      '$estimatesBasicAddress VARCHAR(255) default NULL, '
      '$estimatesBasicContactNo VARCHAR(255) default NULL, '
      '$estimatesBasicPostCode VARCHAR(255) default NULL, '
      '$estimatesBasicPrice VARCHAR(255) default NULL, '
      '$estimatesBasicCustomerEmail VARCHAR(255) default NULL, '
      '$estimatesBasicDescription TEXT default NULL, '
      '$estimatesBasicImages JSON default NULL, '
      '$estimatesBasicLocalImages JSON default NULL, '
      '$estimatesBasicImageFiles JSON default NULL, '
      '$serverUploaded TINYINT(1) default NULL, '
      '$timestamp VARCHAR(255) default NULL)';

  static String createTemporaryEstimatesBasicTableSql = 'CREATE TABLE IF NOT EXISTS $temporaryEstimatesBasicTable('
      '$localId INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, '
      '$formVersion INT(11) default NULL, '
      '$documentId VARCHAR(255) default NULL, '
      '$formCustomerId VARCHAR(255) default NULL, '
      '$uid VARCHAR(255) default NULL, '
      '$organisationId VARCHAR(255) default NULL, '
      '$organisationName VARCHAR(255) default NULL, '
      '$jobId VARCHAR(255) default NULL, '
      '$pendingTime VARCHAR(255) default NULL, '
      '$temporaryEstimatesBasicCompanyAddress VARCHAR(255) default NULL, '
      '$temporaryEstimatesBasicCompanyPostCode VARCHAR(255) default NULL, '
      '$temporaryEstimatesBasicCompanyTelephone VARCHAR(255) default NULL, '
      '$temporaryEstimatesBasicCompanyVatRegNo VARCHAR(255) default NULL, '
      '$temporaryEstimatesBasicCompanyGasSafeRegNo VARCHAR(255) default NULL, '
      '$temporaryEstimatesBasicDate VARCHAR(255) default NULL, '
      '$temporaryEstimatesBasicEngineerName VARCHAR(255) default NULL, '
      '$temporaryEstimatesBasicCustomerName VARCHAR(255) default NULL, '
      '$temporaryEstimatesBasicAddress VARCHAR(255) default NULL, '
      '$temporaryEstimatesBasicContactNo VARCHAR(255) default NULL, '
      '$temporaryEstimatesBasicPostCode VARCHAR(255) default NULL, '
      '$temporaryEstimatesBasicPrice VARCHAR(255) default NULL, '
      '$temporaryEstimatesBasicCustomerEmail VARCHAR(255) default NULL, '
      '$temporaryEstimatesBasicDescription TEXT default NULL, '
      '$temporaryEstimatesBasicImages JSON default NULL, '
      '$temporaryEstimatesBasicLocalImages JSON default NULL, '
      '$temporaryEstimatesBasicImageFiles JSON default NULL, '
      '$serverUploaded TINYINT(1) default NULL, '
      '$timestamp VARCHAR(255) default NULL)';

  static String createPartsFittedTableSql = 'CREATE TABLE IF NOT EXISTS $partsFittedTable('
      '$localId INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,'
      '$formVersion INT(11) default NULL,'
      '$documentId VARCHAR(255) default NULL, '
      '$formCustomerId VARCHAR(255) default NULL, '
      '$uid VARCHAR(255) default NULL, '
      '$organisationId VARCHAR(255) default NULL, '
      '$jobId VARCHAR(255) default NULL, '
      '$pendingTime VARCHAR(255) default NULL, '
      '$clientName VARCHAR(255) default NULL, '
      '$clientAddress VARCHAR(255) default NULL, '
      '$clientPostcode VARCHAR(255) default NULL, '
      '$clientTelephone VARCHAR(255) default NULL, '
      '$clientMobile VARCHAR(255) default NULL, '
      '$clientEmail VARCHAR(255) default NULL, '
      '$companyName VARCHAR(255) default NULL, '
      '$gasSafeRegNo VARCHAR(255) default NULL, '
      '$companyAddress VARCHAR(255) default NULL, '
      '$companyPostcode VARCHAR(255) default NULL, '
      '$companyTelephone VARCHAR(255) default NULL, '
      '$companyVatRegNo VARCHAR(255) default NULL, '
      '$engineersFullName VARCHAR(255) default NULL, '
      '$engineersGasSafeId VARCHAR(255) default NULL,'
      '$applianceMake1 VARCHAR(255) default NULL, '
      '$applianceType1 VARCHAR(255) default NULL, '
      '$applianceModel1 VARCHAR(255) default NULL, '
      '$applianceLocation1 VARCHAR(255) default NULL, '
      '$safetyVentilation1 VARCHAR(255) default NULL, '
      '$safetyFlueTermination1 VARCHAR(255) default NULL, '
      '$safetySmokePelletFlueFlowTest1 VARCHAR(255) default NULL, '
      '$safetySmokeMatchSpillageTest1 VARCHAR(255) default NULL, '
      '$safetyWorkingPressure1 VARCHAR(255) default NULL, '
      '$safetyDevice1 VARCHAR(255) default NULL, '
      '$applianceCondensate1 VARCHAR(255) default NULL, '
      '$safetyFlueCombustionTestCo21 VARCHAR(255) default NULL, '
      '$safetyFlueCombustionTestCo1 VARCHAR(255) default NULL, '
      '$safetyFlueCombustionTestRatio1 VARCHAR(255) default NULL, '
      '$safetyGasTightnessTestPerformedPass TINYINT(1) default NULL, '
      '$safetyGasTightnessTestPerformedFail TINYINT(1) default NULL, '
      '$safetyOperatingPressure1 VARCHAR(255) default NULL,'
      '$safetyGasMeterEarthBondedYes TINYINT(1) default NULL, '
      '$safetyGasMeterEarthBondedNo TINYINT(1) default NULL, '
      '$paymentReceived TINYINT(1) default NULL, '
      '$paymentReceivedType VARCHAR(255) default NULL, '
      '$invoiceTotal VARCHAR(255) default NULL, '
      '$sendBillOut TINYINT(1) default NULL, '
      '$appliancesVisiblyCheckedYes TINYINT(1) default NULL, '
      '$appliancesVisiblyCheckedNo TINYINT(1) default NULL, '
      '$appliancesVisiblyCheckedText VARCHAR(255) default NULL, '
      '$customersSignature BLOB default NULL, '
      '$customersSignaturePoints JSON default NULL,'
      '$customerPrintName VARCHAR(255) default NULL, '
      '$customerDate VARCHAR(255) default NULL, '
      '$engineersSignature BLOB default NULL, '
      '$engineersSignaturePoints JSON default NULL, '
      '$engineerPrintName VARCHAR(255) default NULL, '
      '$engineerDate VARCHAR(255) default NULL, '
      '$engineersComments TEXT default NULL, '
      '$partsFittedDescription TEXT default NULL, '
      '$partsFittedImages JSON default NULL, '
      '$partsFittedLocalImages JSON default NULL, '
      '$partsFittedImageFiles JSON default NULL, '
      '$serverUploaded TINYINT(1) default NULL, '
      '$timestamp VARCHAR(255) default NULL)';

  static String createTemporaryPartsFittedTableSql = 'CREATE TABLE IF NOT EXISTS $temporaryPartsFittedTable('
      '$localId INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, '
      '$formVersion INT(11) default NULL, '
      '$documentId VARCHAR(255) default NULL, '
      '$formCustomerId VARCHAR(255) default NULL, '
      '$uid VARCHAR(255) default NULL, '
      '$organisationId VARCHAR(255) default NULL, '
      '$temporaryJobId VARCHAR(255) default NULL, '
      '$temporaryClientName VARCHAR(255) default NULL, '
      '$temporaryClientAddress VARCHAR(255) default NULL, '
      '$temporaryClientPostcode VARCHAR(255) default NULL,  '
      '$temporaryClientTelephone VARCHAR(255) default NULL, '
      '$temporaryClientMobile VARCHAR(255) default NULL, '
      '$temporaryClientEmail VARCHAR(255) default NULL, '
      '$temporaryRoutineService TINYINT(1) default NULL, '
      '$temporaryCallOut TINYINT(1) default NULL, '
      '$temporaryInstall TINYINT(1) default NULL,'
      '$temporaryCompanyName VARCHAR(255) default NULL, '
      '$temporaryGasSafeRegNo VARCHAR(255) default NULL, '
      '$temporaryCompanyAddress VARCHAR(255) default NULL, '
      '$temporaryCompanyPostcode VARCHAR(255) default NULL, '
      '$temporaryCompanyTelephone VARCHAR(255) default NULL, '
      '$temporaryCompanyVatRegNo VARCHAR(255) default NULL, '
      '$engineersFullName VARCHAR(255) default NULL, '
      '$temporaryEngineersGasSafeId VARCHAR(255) default NULL,'
      '$temporaryApplianceMake1 VARCHAR(255) default NULL, '
      '$temporaryApplianceType1 VARCHAR(255) default NULL, '
      '$temporaryApplianceModel1 VARCHAR(255) default NULL, '
      '$temporaryApplianceLocation1 VARCHAR(255) default NULL, '
      '$temporarySafetyVentilation1 VARCHAR(255) default NULL, '
      '$temporarySafetyFlueTermination1 VARCHAR(255) default NULL, '
      '$temporarySafetySmokePelletFlueFlowTest1 VARCHAR(255) default NULL, '
      '$temporarySafetySmokeMatchSpillageTest1 VARCHAR(255) default NULL, '
      '$temporarySafetyWorkingPressure1 VARCHAR(255) default NULL, '
      '$temporarySafetyDevice1 VARCHAR(255) default NULL, '
      '$temporaryApplianceCondensate1 VARCHAR(255) default NULL, '
      '$temporarySafetyFlueCombustionTestCo21 VARCHAR(255) default NULL, '
      '$temporarySafetyFlueCombustionTestCo1 VARCHAR(255) default NULL, '
      '$temporarySafetyFlueCombustionTestRatio1 VARCHAR(255) default NULL, '
      '$temporarySafetyGasTightnessTestPerformedPass TINYINT(1) default NULL, '
      '$temporarySafetyGasTightnessTestPerformedFail TINYINT(1) default NULL, '
      '$temporarySafetyOperatingPressure1 VARCHAR(255) default NULL, '
      '$temporarySafetyGasMeterEarthBondedYes TINYINT(1) default NULL, '
      '$temporarySafetyGasMeterEarthBondedNo TINYINT(1) default NULL,'
      '$temporaryPaymentReceived TINYINT(1) default NULL, '
      '$temporaryPaymentReceivedType VARCHAR(255) default NULL, '
      '$temporaryInvoiceTotal VARCHAR(255) default NULL, '
      '$temporarySendBillOut TINYINT(1) default NULL, '
      '$temporaryAppliancesVisiblyCheckedYes TINYINT(1) default NULL, '
      '$temporaryAppliancesVisiblyCheckedNo TINYINT(1) default NULL, '
      '$temporaryAppliancesVisiblyCheckedText VARCHAR(255) default NULL, $temporaryCustomersSignature BLOB default NULL, '
      '$temporaryCustomersSignaturePoints JSON default NULL,'
      '$temporaryCustomerPrintName VARCHAR(255) default NULL, '
      '$temporaryCustomerDate VARCHAR(255) default NULL, '
      '$temporaryEngineersSignature BLOB default NULL, '
      '$temporaryEngineersSignaturePoints JSON default NULL, '
      '$temporaryEngineerPrintName VARCHAR(255) default NULL, '
      '$temporaryEngineerDate VARCHAR(255) default NULL, '
      '$temporaryEngineersComments TEXT default NULL, '
      '$temporaryPartsFittedDescription TEXT default NULL, '
      '$temporaryPartsFittedImages JSON default NULL, '
      '$temporaryPartsFittedLocalImages JSON default NULL, '
      '$temporaryPartsFittedImageFiles JSON default NULL)';

  static String createGeneralWorkTableSql = 'CREATE TABLE IF NOT EXISTS $generalWorkTable('
      '$localId INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,'
      '$formVersion INT(11) default NULL,'
      '$documentId VARCHAR(255) default NULL, '
      '$formCustomerId VARCHAR(255) default NULL, '
      '$uid VARCHAR(255) default NULL, '
      '$organisationId VARCHAR(255) default NULL, '
      '$jobId VARCHAR(255) default NULL, '
      '$pendingTime VARCHAR(255) default NULL, '
      '$clientName VARCHAR(255) default NULL, '
      '$clientAddress VARCHAR(255) default NULL, '
      '$clientPostcode VARCHAR(255) default NULL, '
      '$clientTelephone VARCHAR(255) default NULL, '
      '$clientEmail VARCHAR(255) default NULL, '
      '$companyName VARCHAR(255) default NULL, '
      '$gasSafeRegNo VARCHAR(255) default NULL, '
      '$companyAddress VARCHAR(255) default NULL, '
      '$companyPostcode VARCHAR(255) default NULL, '
      '$companyTelephone VARCHAR(255) default NULL, '
      '$companyVatRegNo VARCHAR(255) default NULL, '
      '$engineersFullName VARCHAR(255) default NULL, '
      '$engineersGasSafeId VARCHAR(255) default NULL,'
      '$paymentReceived TINYINT(1) default NULL, '
      '$paymentReceivedType VARCHAR(255) default NULL, '
      '$invoiceTotal VARCHAR(255) default NULL, '
      '$sendBillOut TINYINT(1) default NULL, '
      '$appliancesVisiblyCheckedYes TINYINT(1) default NULL, '
      '$appliancesVisiblyCheckedNo TINYINT(1) default NULL, '
      '$appliancesVisiblyCheckedText VARCHAR(255) default NULL, '
      '$customersSignature BLOB default NULL, '
      '$customersSignaturePoints JSON default NULL,'
      '$customerPrintName VARCHAR(255) default NULL, '
      '$customerDate VARCHAR(255) default NULL, '
      '$engineersSignature BLOB default NULL, '
      '$engineersSignaturePoints JSON default NULL, '
      '$engineerPrintName VARCHAR(255) default NULL, '
      '$engineerDate VARCHAR(255) default NULL, '
      '$engineersComments TEXT default NULL, '
      '$generalWorkDescription TEXT default NULL, '
      '$generalWorkImages JSON default NULL, '
      '$generalWorkLocalImages JSON default NULL, '
      '$generalWorkImageFiles JSON default NULL, '
      '$serverUploaded TINYINT(1) default NULL, '
      '$timestamp VARCHAR(255) default NULL)';

  static String createTemporaryGeneralWorkTableSql = 'CREATE TABLE IF NOT EXISTS $temporaryGeneralWorkTable('
      '$localId INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, '
      '$formVersion INT(11) default NULL, '
      '$documentId VARCHAR(255) default NULL, '
      '$formCustomerId VARCHAR(255) default NULL, '
      '$uid VARCHAR(255) default NULL, '
      '$organisationId VARCHAR(255) default NULL, '
      '$temporaryJobId VARCHAR(255) default NULL, '
      '$temporaryClientName VARCHAR(255) default NULL, '
      '$temporaryClientAddress VARCHAR(255) default NULL, '
      '$temporaryClientPostcode VARCHAR(255) default NULL,  '
      '$temporaryClientTelephone VARCHAR(255) default NULL, '
      '$temporaryClientEmail VARCHAR(255) default NULL, '
      '$temporaryRoutineService TINYINT(1) default NULL, '
      '$temporaryCallOut TINYINT(1) default NULL, '
      '$temporaryInstall TINYINT(1) default NULL,'
      '$temporaryCompanyName VARCHAR(255) default NULL, '
      '$temporaryGasSafeRegNo VARCHAR(255) default NULL, '
      '$temporaryCompanyAddress VARCHAR(255) default NULL, '
      '$temporaryCompanyPostcode VARCHAR(255) default NULL, '
      '$temporaryCompanyTelephone VARCHAR(255) default NULL, '
      '$temporaryCompanyVatRegNo VARCHAR(255) default NULL, '
      '$engineersFullName VARCHAR(255) default NULL, '
      '$temporaryEngineersGasSafeId VARCHAR(255) default NULL,'
      '$temporaryPaymentReceived TINYINT(1) default NULL, '
      '$temporaryPaymentReceivedType VARCHAR(255) default NULL, '
      '$temporaryInvoiceTotal VARCHAR(255) default NULL, '
      '$temporarySendBillOut TINYINT(1) default NULL, '
      '$temporaryAppliancesVisiblyCheckedYes TINYINT(1) default NULL, '
      '$temporaryAppliancesVisiblyCheckedNo TINYINT(1) default NULL, '
      '$temporaryAppliancesVisiblyCheckedText VARCHAR(255) default NULL, '
      '$temporaryCustomersSignature BLOB default NULL, '
      '$temporaryCustomersSignaturePoints JSON default NULL,'
      '$temporaryCustomerPrintName VARCHAR(255) default NULL, '
      '$temporaryCustomerDate VARCHAR(255) default NULL, '
      '$temporaryEngineersSignature BLOB default NULL, '
      '$temporaryEngineersSignaturePoints JSON default NULL, '
      '$temporaryEngineerPrintName VARCHAR(255) default NULL, '
      '$temporaryEngineerDate VARCHAR(255) default NULL, '
      '$temporaryEngineersComments TEXT default NULL, '
      '$temporaryGeneralWorkDescription TEXT default NULL, '
      '$temporaryGeneralWorkImages JSON default NULL, '
      '$temporaryGeneralWorkLocalImages JSON default NULL, '
      '$temporaryGeneralWorkImageFiles JSON default NULL)';

  static String createEngineerNotesTableSql = 'CREATE TABLE IF NOT EXISTS $engineerNotesTable('
      '$localId INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,'
      '$formVersion INT(11) default NULL,'
      '$documentId VARCHAR(255) default NULL, '
      '$formCustomerId VARCHAR(255) default NULL, '
      '$uid VARCHAR(255) default NULL, '
      '$organisationId VARCHAR(255) default NULL, '
      '$jobId VARCHAR(255) default NULL, '
      '$jobNo VARCHAR(255) default NULL, '
      '$engineerNotesName VARCHAR(255) default NULL, '
      '$pendingTime VARCHAR(255) default NULL, '
      '$engineerNotesDate VARCHAR(255) default NULL, '
      '$engineerNotesDescription TEXT default NULL, '
      '$engineerNotesImages JSON default NULL, '
      '$engineerNotesLocalImages JSON default NULL, '
      '$engineerNotesImageFiles JSON default NULL, '
      '$serverUploaded TINYINT(1) default NULL, '
      '$timestamp VARCHAR(255) default NULL)';

  static String createTemporaryEngineerNotesTableSql = 'CREATE TABLE IF NOT EXISTS $temporaryEngineerNotesTable('
      '$localId INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, '
      '$formVersion INT(11) default NULL, '
      '$documentId VARCHAR(255) default NULL, '
      '$formCustomerId VARCHAR(255) default NULL, '
      '$uid VARCHAR(255) default NULL, '
      '$organisationId VARCHAR(255) default NULL, '
      '$temporaryJobId VARCHAR(255) default NULL, '
      '$temporaryJobNo VARCHAR(255) default NULL, '
      '$temporaryEngineerNotesName VARCHAR(255) default NULL, '
      '$temporaryEngineerNotesDate VARCHAR(255) default NULL, '
      '$temporaryEngineerNotesDescription TEXT default NULL, '
      '$temporaryEngineerNotesImages JSON default NULL, '
      '$temporaryEngineerNotesLocalImages JSON default NULL, '
      '$temporaryEngineerNotesImageFiles JSON default NULL)';

  List<String> createAllTables = [createAuthenticationTableSql, createFirebaseStorageUrlTable, createActivityLogTableSql, createTemporaryActivityLogTableSql, createCaveTableSql, createTemporaryCaveTableSql, createImagePathTableSql, createCameraCrashTableSql, createCallOutTableSql, createTemporaryCallOutTableSql, createClubTableSql, createAnnouncementTableSql];

  //Named constructor to create instance of DatabaseHelper
  DatabaseHelper._createInstance();

  //factory keyword allows the constructor to return some value
  factory DatabaseHelper() {
    //initialize our object as well and add a null check so we will create the instance of the database helper only if it is null, this statement will
    //only be executed once in the application

    if (_databaseHelper == null) {
      _databaseHelper = DatabaseHelper._createInstance();
    }
    return _databaseHelper;
  }

  //getter for our database
  Future<Database> get database async {
    //if it is null initialize it otherwise return the older instance
    if (_database == null) {
      _database = await initializeDatabase();
    }
    return _database;
  }

  //function to initialise our database
  Future<Database> initializeDatabase() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = join(directory.path, 'hytechGas.db');

    //open/create the database at this given path
    var appDatabase =
    await openDatabase(path, version: 1, onCreate: _createDb, onUpgrade: _onUpgrade);
    return appDatabase;
  }

  //create a function to help us to execute a statement to create our database
  void _createDb(Database db, int newVersion) async {

    try {
      for (String table in createAllTables) {
        db.execute(table);
      }
    } catch (e){
      print(e);
    }

    await db.insert(Strings.cameraCrashTable, {Strings.hasCrashed : 0, Strings.imageIndex: 0});

  }

  void _onUpgrade(Database db, int oldVersion, int newVersion) async {

    print('running on upgrade');

    try {
      for (String table in createAllTables) {
        db.execute(table);
      }
    } catch (e){
      print(e);
    }

  }

  //Get all items from a database table
  Future<List<Map<String, dynamic>>> get(String tableName, String orderBy, String direction) async {
    Database db = await this.database;

    var result = await db
        .rawQuery('SELECT * FROM $tableName order by $orderBy ' '$direction');
    return result;
  }

  Future<List<Map<String, dynamic>>> getLast10(String tableName, String orderBy, String direction) async {
    Database db = await this.database;

    var result = await db
        .rawQuery('SELECT * FROM $tableName order by $orderBy ' '$direction'' LIMIT 10');
    return result;
  }

  Future<List<Map<String, dynamic>>> get10More(String tableName, String field, String direction, String timestamp) async {
    Database db = await this.database;

    var result = await db
        .rawQuery('SELECT * FROM $tableName WHERE $field < ? order by $field ' '$direction'' LIMIT 10', [timestamp]);
    return result;
  }

  Future<List<Map<String, dynamic>>> get10MoreWhereAndWhereAndWhere(String tableName, String field1, var value1, String field2, var value2, String field3, var value3, String direction) async {
    Database db = await this.database;

    var result = await db
        .rawQuery('SELECT * FROM $tableName WHERE $field1 = ? AND $field2 < ? AND $field3 < ? order by $field2 ' '$direction'' LIMIT 10', [value1,value2, value3]);
    return result;
  }

  Future<List<Map<String, dynamic>>> get10MoreWhereAndWhereOrderByOrderBy(String tableName, String field1, var value1, String field2, var value2, String direction) async {
    Database db = await this.database;

    var result = await db
        .rawQuery('SELECT * FROM $tableName WHERE $field1 < ? AND $field2 < ? order by $field1 $direction, $field2 $direction LIMIT 10', [value1,value2]);
    return result;
  }

  Future<List<Map<String, dynamic>>> get10MoreWhereAndWhereAndWhereOrderByOrderBy(String tableName, String field1, var value1, String field2, var value2, String field3, var value3, String direction) async {
    Database db = await this.database;

    var result = await db
        .rawQuery('SELECT * FROM $tableName WHERE $field1 = ? AND $field2 < ? AND $field3 < ? order by $field2 $direction, $field3 $direction LIMIT 10', [value1,value2, value3]);
    return result;
  }

  Future<List<Map<String, dynamic>>> get10MoreWhereAndWhereAndWhereAndWhereOrderByOrderBy(String tableName, String field1, var value1, String field2, var value2, String field3, var value3, String field4, var value4, String direction) async {
    Database db = await this.database;

    var result = await db
        .rawQuery('SELECT * FROM $tableName WHERE $field1 = ? AND $field2 = ? AND $field3 < ? AND $field4 < ? order by $field3 $direction, $field4 $direction LIMIT 10', [value1,value2, value3, value4]);
    return result;
  }

  Future<List<Map<String, dynamic>>> get10MoreWhereAndWhereAndWhereAndWhereAndWhereOrderByOrderBy(String tableName, String field1, var value1, String field2, var value2, String field3, var value3, String field4, var value4, String field5, var value5, String direction) async {
    Database db = await this.database;

    var result = await db
        .rawQuery('SELECT * FROM $tableName WHERE $field1 = ? AND $field2 = ? AND $field3 = ? AND $field4 < ? AND $field5 < ? order by $field4 $direction, $field5 $direction LIMIT 10', [value1,value2, value3, value4, value5]);
    return result;
  }



  //Insert Operation: Insert an item into a database table
  Future<int> add(String tableName, Map<String, dynamic> data) async {
    Database db = await this.database;

    int result;

    try{
      result = await db.insert(tableName, data);
    } catch(e){
      print(e);
    }
    return result;
  }

  Future<int> addOrganisation() async {
    Database db = await this.database;

    int result = await db.insert(organisationTable, {'document_id' : 'tttt', 'name': 'rr', 'telephone' : 'rrrrrr', 'email' : 'hi@hi.com', 'licenses' : 111});

    return result;
  }

  Future<int> update(String tableName, Map<String, dynamic> data) async {
    Database db = await this.database;

    int result = await db.update(tableName, data);

    return result;
  }

  Future<int> updateRow(String tableName, Map<String, dynamic> data, String field1, var value1) async {
    Database db = await this.database;

    int result;

    try{

      result = await db.update(tableName, data, where: '$field1 = ?', whereArgs: [value1]);


    } catch(e){
      print(e);
    }


    return result;
  }



  Future<int> updateTemporaryActivityLogField(Map<String, dynamic> data, userUid) async {
    Database db = await this.database;

    int result = await db.update(Strings.temporaryActivityLogTable, data, where: '${Strings.uid} = ?', whereArgs: [userUid]);

    return result;
  }

  Future<int> updateTemporaryCallOutField(Map<String, dynamic> data, userUid) async {
    Database db = await this.database;

    int result = await db.update(Strings.temporaryCallOutTable, data, where: '${Strings.uid} = ?', whereArgs: [userUid]);

    return result;
  }

  Future<int> updateTemporaryCaveField(Map<String, dynamic> data, userUid) async {
    Database db = await this.database;

    int result = await db.update(Strings.temporaryCaveTable, data, where: '${Strings.uid} = ?', whereArgs: [userUid]);

    return result;
  }

  Future<int> updateTimesheet(Map<String, dynamic> data, userUid, String selectedTimesheetDate) async {
    Database db = await this.database;

    int result = await db.update(timesheetsTable, data, where: '$uid = ? AND $timesheetDate = ?', whereArgs: [userUid, selectedTimesheetDate]);

    return result;
  }

  Future<int> updateTemporaryMaintenanceChecklistField(Map<String, dynamic> data, userUid, String selectedJobId) async {
    Database db = await this.database;

    int result = await db.update(temporaryMaintenanceChecklistTable, data, where: '$uid = ? AND $temporaryJobId = ?', whereArgs: [userUid, selectedJobId]);

    return result;
  }

  Future<int> updateTemporaryGasSafetyRecordField(Map<String, dynamic> data, userUid, String selectedJobId) async {
    Database db = await this.database;

    int result = await db.update(temporaryGasSafetyRecordTable, data, where: '$uid = ? AND $temporaryJobId = ?', whereArgs: [userUid, selectedJobId]);

    return result;
  }

  Future<int> updateTemporaryCaravanGasSafetyRecordField(Map<String, dynamic> data, userUid, String selectedJobId) async {
    Database db = await this.database;

    int result = await db.update(temporaryCaravanGasSafetyRecordTable, data, where: '$uid = ? AND $temporaryJobId = ?', whereArgs: [userUid, selectedJobId]);

    return result;
  }

  Future<int> updateTemporaryWarningAdvisoryRecordField(Map<String, dynamic> data, userUid, String selectedJobId) async {
    Database db = await this.database;

    int result = await db.update(temporaryWarningAdvisoryRecordTable, data, where: '$uid = ? AND $temporaryJobId = ?', whereArgs: [userUid, selectedJobId]);

    return result;
  }

  Future<int> updateTemporaryVehicleChecklistField(Map<String, dynamic> data, userUid, String selectedJobId) async {
    Database db = await this.database;

    int result = await db.update(temporaryVehicleChecklistTable, data, where: '$uid = ? AND $temporaryJobId = ?', whereArgs: [userUid, selectedJobId]);

    return result;
  }

  Future<int> updateTemporaryJobField(Map<String, dynamic> data, userUid) async {
    Database db = await this.database;

    int result = await db.update(temporaryJobTable, data, where: '$uid = ?', whereArgs: [userUid]);

    return result;
  }

  Future<int> updateTemporaryPartsFormField(Map<String, dynamic> data, userUid, String selectedJobId) async {
    Database db = await this.database;

    int result = await db.update(temporaryPartsFormTable, data, where: '$uid = ? AND $temporaryJobId = ?', whereArgs: [userUid, selectedJobId]);

    return result;
  }

  Future<int> updateTemporaryInvoiceField(Map<String, dynamic> data, userUid, String selectedJobId) async {
    Database db = await this.database;

    int result = await db.update(temporaryInvoiceTable, data, where: '$uid = ? AND $temporaryJobId = ?', whereArgs: [userUid, selectedJobId]);

    return result;
  }

  Future<int> updateTemporaryEstimatesFormField(Map<String, dynamic> data, userUid, String selectedJobId) async {
    Database db = await this.database;

    int result = await db.update(temporaryEstimatesTable, data, where: '$uid = ? AND $temporaryJobId = ?', whereArgs: [userUid, selectedJobId]);

    return result;
  }

  Future<int> updateTemporaryEstimatesBasicFormField(Map<String, dynamic> data, userUid, String selectedJobId) async {
    Database db = await this.database;

    int result = await db.update(temporaryEstimatesBasicTable, data, where: '$uid = ? AND $temporaryJobId = ?', whereArgs: [userUid, selectedJobId]);

    return result;
  }

  Future<int> updateTemporaryPartsFittedField(Map<String, dynamic> data, userUid, String selectedJobId) async {
    Database db = await this.database;

    int result = await db.update(temporaryPartsFittedTable, data, where: '$uid = ? AND $temporaryJobId = ?', whereArgs: [userUid, selectedJobId]);

    return result;
  }

  Future<int> updateTemporaryGeneralWorkField(Map<String, dynamic> data, userUid, String selectedJobId) async {
    Database db = await this.database;

    int result = await db.update(temporaryGeneralWorkTable, data, where: '$uid = ? AND $temporaryJobId = ?', whereArgs: [userUid, selectedJobId]);

    return result;
  }

  Future<int> updateTemporaryEngineerNotesField(Map<String, dynamic> data, userUid, String selectedJobId) async {
    Database db = await this.database;

    int result = await db.update(temporaryEngineerNotesTable, data, where: '$uid = ? AND $temporaryJobId = ?', whereArgs: [userUid, selectedJobId]);

    return result;
  }

  Future<int> updateCustomerJobOutstandingField(String docId, bool boolValue) async {
    Database db = await this.database;

    var result = await db.update(customersTable, {customerJobOutstanding : boolValue}, where: '$documentId = ?', whereArgs: [docId]);
    return result;
  }

  Future<int> delete(String tableName, String userDocumentId) async {
    Database db = await this.database;

    var result =
    await db.delete(tableName,
        where: '${Strings.documentId} = ?', whereArgs: [userDocumentId]);
    return result;
  }

  Future<int> deleteAllRows(String tableName) async {
    Database db = await this.database;

    var result =
    await db.rawDelete('DELETE FROM $tableName');
    return result;
  }

  Future<int> deleteLocalForm(String tableName) async {
    Database db = await this.database;

    var result = db.rawDelete('DELETE FROM $tableName ORDER BY $localId ASC limit 1');

    return result;
  }

  Future<int> deleteLocalImages(String tableName) async {
    Database db = await this.database;

    var result = db.rawUpdate('UPDATE $tableName SET $estimatesImages = NULL WHERE $localId = (SELECT $localId FROM $tableName ORDER BY $localId ASC LIMIT 1)');

    return result;
  }

  Future<int> deleteFirebaseRow(String tableName, String uidInput) async {
    Database db = await this.database;

    var result =
    await db.delete(firebaseStorageUrlTable,
        where: '$uid = ?', whereArgs: [uidInput]);
    return result;
  }

  Future<int> deleteTemporaryActivityLog(String inputUid) async {
    Database db = await this.database;

    var result =
    await db.delete(Strings.temporaryActivityLogTable,
        where: '${Strings.uid} = ?', whereArgs: [inputUid]);
    return result;
  }

  Future<int> deleteTemporaryForm(String tableName, String inputJobId) async {
    Database db = await this.database;

    var result =
    await db.delete(tableName,
        where: '$temporaryJobId = ?', whereArgs: [inputJobId]);
    return result;
  }

  Future<int> getRowCount(String tableName) async {
    Database db = await this.database;
    List<Map<String, dynamic>> x =
    await db.rawQuery('SELECT COUNT (*) from $tableName');
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  Future<int> getRowCountWhere(String tableName, String field1, var value1) async {
    Database db = await this.database;
    List<Map<String, dynamic>> x =
    await db.rawQuery('SELECT COUNT (*) from $tableName WHERE $field1 = ?', [value1]);
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  Future<int> getRowCountWhereAndWhere(String tableName, String field1, var value1, String field2, var value2) async {
    Database db = await this.database;
    List<Map<String, dynamic>> x =
    await db.rawQuery('SELECT COUNT (*) from $tableName WHERE $field1 = ? AND $field2 = ?', [value1, value2]);
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  Future<int> getRowCountWhereAndWhereAndWhere(String tableName, String field1, var value1, String field2, var value2, String field3, var value3) async {
    Database db = await this.database;
    List<Map<String, dynamic>> x =
    await db.rawQuery('SELECT COUNT (*) from $tableName WHERE $field1 = ? AND $field2 = ? AND $field3 = ?', [value1, value2, value3]);
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  Future<int> getRowCountWhereAndWhereAndWhereAndWhere(String tableName, String field1, var value1, String field2, var value2, String field3, var value3, String field4, var value4) async {
    Database db = await this.database;
    List<Map<String, dynamic>> x =
    await db.rawQuery('SELECT COUNT (*) from $tableName WHERE $field1 = ? AND $field2 = ? AND $field3 = ? AND $field4 = ?', [value1, value2, value3, value4]);
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  Future<int> checkExists(String tableName, String field1, var value1) async {
    Database db = await this.database;
    List<Map<String, dynamic>> resultQuery = await db.rawQuery('SELECT EXISTS(SELECT * FROM $tableName WHERE $field1 = ?)', [value1]);
    int result = resultQuery.length;
    return result;
  }

  Future<int> checkUserExists(String inputUid) async {
    Database db = await this.database;
    List<Map<String, dynamic>> x = await db.rawQuery(
        "SELECT EXISTS(SELECT 1 FROM $usersTable WHERE $uid = ?)", [inputUid]);
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  Future<int> checkAuthenticatedUserExists(String inputUid) async {
    Database db = await this.database;
    List<Map<String, dynamic>> x = await db.rawQuery(
        "SELECT EXISTS(SELECT 1 FROM ${Strings.authenticationTable} WHERE ${Strings.uid} = ?)", [inputUid]);
    int result = Sqflite.firstIntValue(x);
    return result;
  }


  Future<int> checkMaintenanceChecklistExists(String inputDocumentId) async {
    Database db = await this.database;
    List<Map<String, dynamic>> x = await db.rawQuery(
        "SELECT EXISTS(SELECT 1 FROM $maintenanceChecklistTable WHERE $documentId = ?)", [inputDocumentId]);
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  Future<int> checkGasSafetyRecordExists(String inputDocumentId) async {
    Database db = await this.database;
    List<Map<String, dynamic>> x = await db.rawQuery(
        "SELECT EXISTS(SELECT 1 FROM $gasSafetyRecordTable WHERE $documentId = ?)", [inputDocumentId]);
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  Future<int> checkCaravanGasSafetyRecordExists(String inputDocumentId) async {
    Database db = await this.database;
    List<Map<String, dynamic>> x = await db.rawQuery(
        "SELECT EXISTS(SELECT 1 FROM $caravanGasSafetyRecordTable WHERE $documentId = ?)", [inputDocumentId]);
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  Future<int> checkWarningAdvisoryRecordExists(String inputDocumentId) async {
    Database db = await this.database;
    List<Map<String, dynamic>> x = await db.rawQuery(
        "SELECT EXISTS(SELECT 1 FROM $warningAdvisoryRecordTable WHERE $documentId = ?)", [inputDocumentId]);
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  Future<int> checkVehicleChecklistExists(String inputDocumentId) async {
    Database db = await this.database;
    List<Map<String, dynamic>> x = await db.rawQuery(
        "SELECT EXISTS(SELECT 1 FROM $vehicleChecklistTable WHERE $documentId = ?)", [inputDocumentId]);
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  Future<int> checkCustomerExists(String inputDocumentId) async {
    Database db = await this.database;
    List<Map<String, dynamic>> x = await db.rawQuery(
        "SELECT EXISTS(SELECT 1 FROM ${Strings.customersTable} WHERE ${Strings.documentId} = ?)", [inputDocumentId]);
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  Future<int> checkJobExists(String inputDocumentId) async {
    Database db = await this.database;
    List<Map<String, dynamic>> x = await db.rawQuery(
        "SELECT EXISTS(SELECT 1 FROM $jobTable WHERE $documentId = ?)", [inputDocumentId]);
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  Future<int> checkPartsFormExists(String inputDocumentId) async {
    Database db = await this.database;
    List<Map<String, dynamic>> x = await db.rawQuery(
        "SELECT EXISTS(SELECT 1 FROM $partsFormTable WHERE $documentId = ?)", [inputDocumentId]);
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  Future<int> checkActivityLogExists(String inputDocumentId) async {
    Database db = await this.database;
    List<Map<String, dynamic>> x = await db.rawQuery(
        "SELECT EXISTS(SELECT 1 FROM ${Strings.activityLogTable} WHERE ${Strings.documentId} = ?)", [inputDocumentId]);
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  Future<int> checkAnnouncementExists(String inputDocumentId) async {
    Database db = await this.database;
    List<Map<String, dynamic>> x = await db.rawQuery(
        "SELECT EXISTS(SELECT 1 FROM ${Strings.announcementTable} WHERE ${Strings.documentId} = ?)", [inputDocumentId]);
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  Future<int> checkCaveExists(String inputDocumentId) async {
    Database db = await this.database;
    List<Map<String, dynamic>> x = await db.rawQuery(
        "SELECT EXISTS(SELECT 1 FROM ${Strings.caveTable} WHERE ${Strings.documentId} = ?)", [inputDocumentId]);
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  Future<int> checkInvoiceExists(String inputDocumentId) async {
    Database db = await this.database;
    List<Map<String, dynamic>> x = await db.rawQuery(
        "SELECT EXISTS(SELECT 1 FROM $invoiceTable WHERE $documentId = ?)", [inputDocumentId]);
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  Future<int> checkEstimatesFormExists(String inputDocumentId) async {
    Database db = await this.database;
    List<Map<String, dynamic>> x = await db.rawQuery(
        "SELECT EXISTS(SELECT 1 FROM $estimatesTable WHERE $documentId = ?)", [inputDocumentId]);
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  Future<int> checkEstimatesBasicFormExists(String inputDocumentId) async {
    Database db = await this.database;
    List<Map<String, dynamic>> x = await db.rawQuery(
        "SELECT EXISTS(SELECT 1 FROM $estimatesBasicTable WHERE $documentId = ?)", [inputDocumentId]);
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  Future<int> checkPartsFittedFormExists(String inputDocumentId) async {
    Database db = await this.database;
    List<Map<String, dynamic>> x = await db.rawQuery(
        "SELECT EXISTS(SELECT 1 FROM $partsFittedTable WHERE $documentId = ?)", [inputDocumentId]);
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  Future<int> checkGeneralWorkFormExists(String inputDocumentId) async {
    Database db = await this.database;
    List<Map<String, dynamic>> x = await db.rawQuery(
        "SELECT EXISTS(SELECT 1 FROM $generalWorkTable WHERE $documentId = ?)", [inputDocumentId]);
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  Future<int> checkEngineerNotesFormExists(String inputDocumentId) async {
    Database db = await this.database;
    List<Map<String, dynamic>> x = await db.rawQuery(
        "SELECT EXISTS(SELECT 1 FROM $engineerNotesTable WHERE $documentId = ?)", [inputDocumentId]);
    int result = Sqflite.firstIntValue(x);
    return result;
  }


  Future<int> checkOrganisationExists(String inputId) async {
    Database db = await this.database;
    List<Map<String, dynamic>> x = await db.rawQuery(
        "SELECT EXISTS(SELECT 1 FROM $organisationTable WHERE $documentId = ?)", [inputId]);
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  Future<Map<String, dynamic>> getOrganisation(String orgId) async {
    Database db = await this.database;

    var result = await db
        .rawQuery('SELECT * FROM $organisationTable WHERE $documentId = ?', [orgId]);
    return result[0];
  }

  Future<int> checkFirebaseStorageRowExists(String inputUid) async {
    Database db = await this.database;
    List<Map<String, dynamic>> x = await db.rawQuery(
        "SELECT EXISTS(SELECT 1 FROM $firebaseStorageUrlTable WHERE $uid = ?)", [inputUid]);
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  Future<int> checkTemporaryInvoiceExists(String inputUid, String selectedJobId) async {
    Database db = await this.database;
    List<Map<String, dynamic>> x = await db.rawQuery(
        "SELECT EXISTS(SELECT 1 FROM $temporaryInvoiceTable WHERE $uid = ? AND $temporaryJobId = ?)", [inputUid, selectedJobId]);
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  Future<int> checkTemporaryMaintenanceChecklistExists(String inputUid, String selectedJobId) async {
    Database db = await this.database;
    List<Map<String, dynamic>> x = await db.rawQuery(
        "SELECT EXISTS(SELECT 1 FROM $temporaryMaintenanceChecklistTable WHERE $uid = ? AND $temporaryJobId = ?)", [inputUid, selectedJobId]);
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  Future<int> checkTemporaryGasSafetyRecordExists(String inputUid, String selectedJobId) async {
    Database db = await this.database;
    List<Map<String, dynamic>> x = await db.rawQuery(
        "SELECT EXISTS(SELECT 1 FROM $temporaryGasSafetyRecordTable WHERE $uid = ? AND $temporaryJobId = ?)", [inputUid, selectedJobId]);
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  Future<int> checkTemporaryCaravanGasSafetyRecordExists(String inputUid, String selectedJobId) async {
    Database db = await this.database;
    List<Map<String, dynamic>> x = await db.rawQuery(
        "SELECT EXISTS(SELECT 1 FROM $temporaryCaravanGasSafetyRecordTable WHERE $uid = ? AND $temporaryJobId = ?)", [inputUid, selectedJobId]);
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  Future<int> checkTemporaryWarningAdvisoryRecordExists(String inputUid, String selectedJobId) async {
    Database db = await this.database;
    List<Map<String, dynamic>> x = await db.rawQuery(
        "SELECT EXISTS(SELECT 1 FROM $temporaryWarningAdvisoryRecordTable WHERE $uid = ? AND $temporaryJobId = ?)", [inputUid, selectedJobId]);
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  Future<int> checkTemporaryVehicleChecklistExists(String inputUid, String selectedJobId) async {
    Database db = await this.database;
    List<Map<String, dynamic>> x = await db.rawQuery(
        "SELECT EXISTS(SELECT 1 FROM $temporaryVehicleChecklistTable WHERE $uid = ? AND $temporaryJobId = ?)", [inputUid, selectedJobId]);
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  Future<int> checkTemporaryJobExists(String inputUid) async {
    Database db = await this.database;
    List<Map<String, dynamic>> x = await db.rawQuery(
        "SELECT EXISTS(SELECT 1 FROM $temporaryJobTable WHERE $uid = ?)", [inputUid]);
    int result = Sqflite.firstIntValue(x);
    return result;
  }


  Future<int> checkTemporaryActivityLogExists(String inputUid) async {
    Database db = await this.database;
    List<Map<String, dynamic>> x = await db.rawQuery(
        "SELECT EXISTS(SELECT 1 FROM ${Strings.temporaryActivityLogTable} WHERE ${Strings.uid} = ?)", [inputUid]);
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  Future<int> checkTemporaryCallOutExists(String inputUid) async {
    Database db = await this.database;
    List<Map<String, dynamic>> x = await db.rawQuery(
        "SELECT EXISTS(SELECT 1 FROM ${Strings.temporaryCallOutTable} WHERE ${Strings.uid} = ?)", [inputUid]);
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  Future<int> checkTemporaryCaveExists(String inputUid) async {
    Database db = await this.database;
    List<Map<String, dynamic>> x = await db.rawQuery(
        "SELECT EXISTS(SELECT 1 FROM ${Strings.temporaryCaveTable} WHERE ${Strings.uid} = ?)", [inputUid]);
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  Future<int> checkTemporaryPartsFormExists(String inputUid, String selectedJobId) async {
    Database db = await this.database;
    List<Map<String, dynamic>> x = await db.rawQuery(
        "SELECT EXISTS(SELECT 1 FROM $temporaryPartsFormTable WHERE $uid = ? AND $temporaryJobId = ?)", [inputUid, selectedJobId]);
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  Future<int> checkTemporaryEstimatesFormExists(String inputUid, String selectedJobId) async {
    Database db = await this.database;
    List<Map<String, dynamic>> x = await db.rawQuery(
        "SELECT EXISTS(SELECT 1 FROM $temporaryEstimatesTable WHERE $uid = ? AND $temporaryJobId = ?)", [inputUid, selectedJobId]);
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  Future<int> checkTemporaryEstimatesBasicFormExists(String inputUid, String selectedJobId) async {
    Database db = await this.database;
    List<Map<String, dynamic>> x = await db.rawQuery(
        "SELECT EXISTS(SELECT 1 FROM $temporaryEstimatesBasicTable WHERE $uid = ? AND $temporaryJobId = ?)", [inputUid, selectedJobId]);
    int result = Sqflite.firstIntValue(x);
    return result;
  }
  Future<int> checkPendingEstimatesBasicFormExists(String inputUid, String selectedJobId) async {
    Database db = await this.database;
    List<Map<String, dynamic>> x = await db.rawQuery(
        "SELECT EXISTS(SELECT 1 FROM $estimatesBasicTable WHERE $uid = ? AND $temporaryJobId = ?)", [inputUid, selectedJobId]);
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  Future<int> checkTemporaryPartsFittedFormExists(String inputUid, String selectedJobId) async {
    Database db = await this.database;
    List<Map<String, dynamic>> x = await db.rawQuery(
        "SELECT EXISTS(SELECT 1 FROM $temporaryPartsFittedTable WHERE $uid = ? AND $temporaryJobId = ?)", [inputUid, selectedJobId]);
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  Future<int> checkTemporaryGeneralWorkFormExists(String inputUid, String selectedJobId) async {
    Database db = await this.database;
    List<Map<String, dynamic>> x = await db.rawQuery(
        "SELECT EXISTS(SELECT 1 FROM $temporaryGeneralWorkTable WHERE $uid = ? AND $temporaryJobId = ?)", [inputUid, selectedJobId]);
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  Future<int> checkTemporaryEngineerNotesFormExists(String inputUid, String selectedJobId) async {
    Database db = await this.database;
    List<Map<String, dynamic>> x = await db.rawQuery(
        "SELECT EXISTS(SELECT 1 FROM $temporaryEngineerNotesTable WHERE $uid = ? AND $temporaryJobId = ?)", [inputUid, selectedJobId]);
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  Future<int> checkTodayTimesheetExists(String inputUid, String selectedDate) async {
    Database db = await this.database;
    List<Map<String, dynamic>> x = await db.rawQuery(
        "SELECT EXISTS(SELECT 1 FROM $timesheetsTable WHERE $uid = ? AND $timesheetDate = ?)", [inputUid, selectedDate]);
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  Future<Map<String, dynamic>> getTemporaryMaintenanceChecklist(String userUid, String selectedJobId) async {
    Database db = await this.database;

    var result = await db
        .rawQuery('SELECT * FROM $temporaryMaintenanceChecklistTable WHERE $uid = ? AND $temporaryJobId = ?', [userUid, selectedJobId]);
    return result[0];
  }

  Future<Map<String, dynamic>> getTemporaryGasSafetyRecord(String userUid, String selectedJobId) async {
    Database db = await this.database;

    var result = await db
        .rawQuery('SELECT * FROM $temporaryGasSafetyRecordTable WHERE $uid = ? AND $temporaryJobId = ?', [userUid, selectedJobId]);
    return result[0];
  }

  Future<Map<String, dynamic>> getTemporaryCaravanGasSafetyRecord(String userUid, String selectedJobId) async {
    Database db = await this.database;

    var result = await db
        .rawQuery('SELECT * FROM $temporaryCaravanGasSafetyRecordTable WHERE $uid = ? AND $temporaryJobId = ?', [userUid, selectedJobId]);
    return result[0];
  }

  Future<Map<String, dynamic>> getTemporaryWarningAdvisoryRecord(String userUid, String selectedJobId) async {
    Database db = await this.database;

    var result = await db
        .rawQuery('SELECT * FROM $temporaryWarningAdvisoryRecordTable WHERE $uid = ? AND $temporaryJobId = ?', [userUid, selectedJobId]);
    return result[0];
  }

  Future<Map<String, dynamic>> getTemporaryVehicleChecklist(String userUid, String selectedJobId) async {
    Database db = await this.database;

    var result = await db
        .rawQuery('SELECT * FROM $temporaryVehicleChecklistTable WHERE $uid = ? AND $temporaryJobId = ?', [userUid, selectedJobId]);
    return result[0];
  }

  Future<Map<String, dynamic>> getTemporaryJob(String userUid) async {
    Database db = await this.database;

    var result = await db
        .rawQuery('SELECT * FROM $temporaryJobTable WHERE $uid = ?', [userUid]);
    return result[0];
  }

  Future<Map<String, dynamic>> getTemporaryPartsForm(String userUid, String selectedJobId) async {
    Database db = await this.database;

    var result = await db
        .rawQuery('SELECT * FROM $temporaryPartsFormTable WHERE $uid = ? AND $temporaryJobId = ?', [userUid, selectedJobId]);
    return result[0];
  }

  Future<Map<String, dynamic>> getTemporaryActivityLog(String userUid) async {
    Database db = await this.database;

    var result = await db
        .rawQuery('SELECT * FROM ${Strings.temporaryActivityLogTable} WHERE ${Strings.uid} = ?', [userUid]);
    return result[0];
  }

  Future<Map<String, dynamic>> getTemporaryCallOut(String userUid) async {
    Database db = await this.database;

    var result = await db
        .rawQuery('SELECT * FROM ${Strings.temporaryCallOutTable} WHERE ${Strings.uid} = ?', [userUid]);
    return result[0];
  }

  Future<Map<String, dynamic>> getTemporaryCave(String userUid) async {
    Database db = await this.database;

    var result = await db
        .rawQuery('SELECT * FROM ${Strings.temporaryCaveTable} WHERE ${Strings.uid} = ?', [userUid]);
    return result[0];
  }

  Future<Map<String, dynamic>> getTemporaryInvoice(String userUid, String selectedJobId) async {
    Database db = await this.database;

    var result = await db
        .rawQuery('SELECT * FROM $temporaryInvoiceTable WHERE $uid = ? AND $temporaryJobId = ?', [userUid, selectedJobId]);
    return result[0];
  }

  Future<Map<String, dynamic>> getTemporaryEstimatesForm(String userUid, String selectedJobId) async {
    Database db = await this.database;

    var result = await db
        .rawQuery('SELECT * FROM $temporaryEstimatesTable WHERE $uid = ? AND $temporaryJobId = ?', [userUid, selectedJobId]);
    return result[0];
  }

  Future<Map<String, dynamic>> getTemporaryEstimatesBasicForm(String userUid, String selectedJobId) async {
    Database db = await this.database;

    var result = await db
        .rawQuery('SELECT * FROM $temporaryEstimatesBasicTable WHERE $uid = ? AND $temporaryJobId = ?', [userUid, selectedJobId]);
    return result[0];
  }

  Future<Map<String, dynamic>> getPendingEstimatesBasicForm(String userUid, String selectedJobId) async {
    Database db = await this.database;

    var result = await db
        .rawQuery('SELECT * FROM $estimatesBasicTable WHERE $uid = ? AND $jobId = ?', [userUid, selectedJobId]);
    return result[0];
  }

  Future<Map<String, dynamic>> getTemporaryPartsFittedForm(String userUid, String selectedJobId) async {
    Database db = await this.database;

    var result = await db
        .rawQuery('SELECT * FROM $temporaryPartsFittedTable WHERE $uid = ? AND $temporaryJobId = ?', [userUid, selectedJobId]);
    return result[0];
  }

  Future<Map<String, dynamic>> getTemporaryGeneralWorkForm(String userUid, String selectedJobId) async {
    Database db = await this.database;

    var result = await db
        .rawQuery('SELECT * FROM $temporaryGeneralWorkTable WHERE $uid = ? AND $temporaryJobId = ?', [userUid, selectedJobId]);
    return result[0];
  }

  Future<Map<String, dynamic>> getTemporaryEngineerNotesForm(String userUid, String selectedJobId) async {
    Database db = await this.database;

    var result = await db
        .rawQuery('SELECT * FROM $temporaryEngineerNotesTable WHERE $uid = ? AND $temporaryJobId = ?', [userUid, selectedJobId]);
    return result[0];
  }

  Future<Map<String, dynamic>> getTodayTimesheet(String userUid, String selectedTimesheetDate) async {
    Database db = await this.database;

    var result = await db
        .rawQuery('SELECT * FROM $timesheetsTable WHERE $uid = ? AND $timesheetDate = ?', [userUid, selectedTimesheetDate]);
    return result[0];
  }


  Future<int> checkExistsTwoArguments(String tableName, String field1, var value1, String field2, var value2) async {
    Database db = await this.database;
    List<Map<String, dynamic>> x = await db.rawQuery(
        "SELECT EXISTS(SELECT 1 FROM $tableName WHERE $field1 = ? AND $field2 = ?)", [value1, value2]);
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  Future<int> checkPendingJobForm(String tableName, var pendingJobId, var userUid) async {
    Database db = await this.database;
    List<Map<String, dynamic>> x = await db.rawQuery(
        "SELECT EXISTS(SELECT 1 FROM $tableName WHERE $serverUploaded = 0 AND $jobId = ? AND $uid = ?)", [pendingJobId, userUid]);
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  Future<List<Map<String, dynamic>>> getAllWhereAndWhere(String tableName, field1, value1, field2, value2) async {
    Database db = await this.database;

    var result = await db
        .rawQuery("SELECT * FROM $tableName WHERE $field1 = ? AND $field2 = ?", [value1, value2]);
    return result;
  }

  Future<List<Map<String, dynamic>>> getPendingJobForms(String tableName, var pendingJobId, var userUid) async {
    Database db = await this.database;

    var result = await db
        .rawQuery("SELECT * FROM $tableName WHERE $serverUploaded = 0 AND $jobId = ? AND $uid = ?", [pendingJobId, userUid]);
    return result;
  }

  Future<List<Map<String, dynamic>>> getPendingJobFormsLocalId(String tableName, var pendingLocalId, var userUid) async {
    Database db = await this.database;

    var result = await db
        .rawQuery("SELECT * FROM $tableName WHERE $serverUploaded = 0 AND $localId = ? AND $uid = ?", [pendingLocalId, userUid]);
    return result;
  }

  Future<List<Map<String, dynamic>>> getAllPendingForms(String tableName, var userUid) async {
    Database db = await this.database;

    var result = await db
        .rawQuery("SELECT * FROM $tableName WHERE $serverUploaded = 0 AND $uid = ?", [userUid]);
    return result;
  }

  Future<List<Map<String, dynamic>>> getAllCaves() async {
    Database db = await this.database;

    var result = await db
        .rawQuery('SELECT * FROM ${Strings.caveTable} ORDER BY ${Strings.name} ASC');
    return result;
  }


  Future<List<Map<String, dynamic>>> getRowsWhereOrderByDirectionLast10(String tableName, field1, value1, String orderByField, String direction) async {
    Database db = await this.database;

    var result = await db
        .rawQuery('SELECT * FROM $tableName WHERE $field1 = ? ORDER BY $orderByField ' '$direction'' LIMIT 10', [value1]);
    return result;
  }

  Future<List<Map<String, dynamic>>> getRowsWhereOrderByDirectionLast20(String tableName, field1, value1, String orderByField, String direction) async {
    Database db = await this.database;

    var result = await db
        .rawQuery('SELECT * FROM $tableName WHERE $field1 = ? ORDER BY $orderByField ' '$direction'' LIMIT 20', [value1]);
    return result;
  }

  Future<List<Map<String, dynamic>>> getCustomersLocally(String orgId) async {
    Database db = await this.database;


    var result = await db
        .rawQuery('SELECT * FROM ${Strings.customersTable} WHERE ${Strings.organisationId} = ?', [orgId]);

    return result;
  }

  Future<List<Map<String, dynamic>>> getCavesLocally() async {
    Database db = await this.database;


    var result = await db
        .rawQuery('SELECT * FROM ${Strings.caveTable}');

    return result;
  }

  Future<List<Map<String, dynamic>>> getSingleCustomer(String cusId) async {
    Database db = await this.database;


    var result = await db
        .rawQuery('SELECT * FROM ${Strings.customersTable} WHERE ${Strings.documentId} = ?', [cusId]);

    return result;
  }

  Future<List<Map<String, dynamic>>> getUsersLocally(String orgId) async {
    Database db = await this.database;


    var result = await db
        .rawQuery('SELECT * FROM $usersTable WHERE $organisationId = ?', [orgId]);

    return result;
  }

  Future<List<Map<String, dynamic>>> getRowsWhereAndWhereIsLessThanOrderByDirectionLast10(String tableName, field1, value1, field2, value2, String orderByField, String direction) async {
    Database db = await this.database;

    var result = await db
        .rawQuery('SELECT * FROM $tableName WHERE $field1 = ? AND $field2 < ? ORDER BY $orderByField ' '$direction'' LIMIT 10', [value1, value2]);
    return result;
  }

  Future<List<Map<String, dynamic>>> getRowsWhereAndWhereIsMoreThanOrEqualToOrderByDirectionLast10(String tableName, field1, value1, field2, value2, String orderByField, String direction) async {
    Database db = await this.database;

    var result = await db
        .rawQuery('SELECT * FROM $tableName WHERE $field1 = ? AND $field2 >= ? ORDER BY $orderByField ' '$direction'' LIMIT 10', [value1, value2]);
    return result;
  }

  Future<List<Map<String, dynamic>>> getRowsOrderByOrderByDirectionLast10(String tableName, String orderByField1, String orderByField2, String direction) async {
    Database db = await this.database;

    var result = await db
        .rawQuery('SELECT * FROM $tableName ORDER BY $orderByField1 $direction, $orderByField2 $direction LIMIT 10');
    return result;
  }

  Future<List<Map<String, dynamic>>> getRowsWhereOrderByOrderByDirectionLast10(String tableName, field1, value1, String orderByField1, String orderByField2, String direction) async {
    Database db = await this.database;

    var result = await db
        .rawQuery('SELECT * FROM $tableName WHERE $field1 = ? ORDER BY $orderByField1 $direction, $orderByField2 $direction LIMIT 10', [value1]);
    return result;
  }

  Future<List<Map<String, dynamic>>> getRowsWhereAndWhereOrderByOrderByDirectionLast10(String tableName, String field1, var value1, String field2, var value2, String orderByField1, String orderByField2, String direction) async {
    Database db = await this.database;

    var result = await db
        .rawQuery('SELECT * FROM $tableName WHERE $field1 = ? AND $field2 = ? ORDER BY $orderByField1 $direction, $orderByField2 $direction LIMIT 10', [value1, value2]);
    return result;
  }

  Future<List<Map<String, dynamic>>> getRowsWhereAndWhereOrderByOrderByDirection(String tableName, String field1, var value1, String field2, var value2, String orderByField1, String orderByField2, String direction) async {
    Database db = await this.database;

    var result = await db
        .rawQuery('SELECT * FROM $tableName WHERE $field1 = ? AND $field2 = ? ORDER BY $orderByField1 $direction, $orderByField2 $direction', [value1, value2]);
    return result;
  }

  Future<List<Map<String, dynamic>>> getRowsWhereAndWhereAndWhereOrderByOrderByDirection(String tableName, String field1, var value1, String field2, var value2, String field3, var value3, String orderByField1, String orderByField2, String direction) async {
    Database db = await this.database;

    var result = await db
        .rawQuery('SELECT * FROM $tableName WHERE $field1 = ? AND $field2 = ? AND $field3 = ? ORDER BY $orderByField1 $direction, $orderByField2 $direction', [value1, value2, value3]);
    return result;
  }

  Future<List<Map<String, dynamic>>> getRowsWhereAndWhereAndWhereAndWhereOrderByOrderByDirection(String tableName, String field1, var value1, String field2, var value2, String field3, var value3, String field4, var value4, String orderByField1, String orderByField2, String direction) async {
    Database db = await this.database;

    var result = await db
        .rawQuery('SELECT * FROM $tableName WHERE $field1 = ? AND $field2 = ? AND $field3 = ? AND $field4 = ? ORDER BY $orderByField1 $direction, $orderByField2 $direction', [value1, value2, value3, value4]);
    return result;
  }

  Future<List<Map<String, dynamic>>> getRowsWhereAndWhereAndWhereOrderByOrderByDirectionLast10(String tableName, String field1, var value1, String field2, var value2, String field3, var value3, String orderByField1, String orderByField2, String direction) async {
    Database db = await this.database;

    var result = await db
        .rawQuery('SELECT * FROM $tableName WHERE $field1 = ? AND $field2 = ? AND $field3 = ? ORDER BY $orderByField1 $direction, $orderByField2 $direction LIMIT 10', [value1, value2, value3]);
    return result;
  }

  Future<List<Map<String, dynamic>>> getRowsWhereOrderByDirection10More(String tableName, field1, value1, String field2, String direction, String timestamp) async {
    Database db = await this.database;

    var result = await db
        .rawQuery('SELECT * FROM $tableName WHERE $field1 = ? AND $field2 < ? ORDER BY $field2 ' '$direction'' LIMIT 10', [value1, timestamp]);
    return result;
  }

  Future<List<Map<String, dynamic>>> getRowsWhereOrderByDirection20More(String tableName, field1, value1, String field2, String direction, String name) async {
    Database db = await this.database;

    var result = await db
        .rawQuery('SELECT * FROM $tableName WHERE $field1 = ? AND $field2 > ? ORDER BY $field2 ' '$direction'' LIMIT 20', [value1, name]);
    return result;
  }

  Future<List<Map<String, dynamic>>> getRowsWhereAndWhereIsLessThanOrderByDirection10More(String tableName, field1, value1, field2, value2, String field3, String direction, String timestamp) async {
    Database db = await this.database;

    var result = await db
        .rawQuery('SELECT * FROM $tableName WHERE $field1 = ? AND $field2 < ? AND $field3 < ? ORDER BY $field3 ' '$direction'' LIMIT 10', [value1, value2, timestamp]);
    return result;
  }

  Future<List<Map<String, dynamic>>> getRowsWhereAndWhereIsMoreThanOrEqualToOrderByDirection10More(String tableName, field1, value1, field2, value2, String field3, String direction, String timestamp) async {
    Database db = await this.database;

    var result = await db
        .rawQuery('SELECT * FROM $tableName WHERE $field1 = ? AND $field2 >= ? AND $field3 < ? ORDER BY $field3 ' '$direction'' LIMIT 10', [value1, value2, timestamp]);
    return result;
  }

  Future<List<Map<String, dynamic>>> getRowsWhereAndWhereIsMoreThanOrderByDirection10More(String tableName, field1, value1, field2, value2, String field3, String direction, String timestamp) async {
    Database db = await this.database;

    var result = await db
        .rawQuery('SELECT * FROM $tableName WHERE $field1 = ? AND $field2 >= ? AND $field3 < ? ORDER BY $field3 ' '$direction'' LIMIT 10', [value1, value2, timestamp]);
    return result;
  }

  Future<List<Map<String, dynamic>>> getRowsOrderByDirection(String tableName, String orderByField, String direction) async {
    Database db = await this.database;

    var result = await db
        .rawQuery('SELECT * FROM $tableName ORDER BY $orderByField ' '$direction');
    return result;
  }

  Future<List<Map<String, dynamic>>> getRowsWhere(String tableName, field1, value1) async {
    Database db = await this.database;

    var result = await db
        .rawQuery('SELECT * FROM $tableName WHERE $field1 = ?', [value1]);
    return result;
  }

  Future<List<Map<String, dynamic>>> getRowsWhereOrderByDirection(String tableName, field1, value1, String orderByField, String direction) async {
    Database db = await this.database;

    var result = await db
        .rawQuery('SELECT * FROM $tableName WHERE $field1 = ? ORDER BY $orderByField ' '$direction', [value1]);
    return result;
  }
  Future<List<Map<String, dynamic>>> getRowsWhereOrderByOrderByDirection(String tableName, field1, value1, String orderByField1, String orderByField2, String direction) async {
    Database db = await this.database;

    var result = await db
        .rawQuery('SELECT * FROM $tableName WHERE $field1 = ? ORDER BY $orderByField1 $direction, $orderByField2 $direction', [value1]);
    return result;
  }

  Future<List<Map<String, dynamic>>> getRowsWhereAndWhereOrderByDirection(String tableName, field1, value1, field2, value2, String orderByField, String direction) async {
    Database db = await this.database;

    var result = await db
        .rawQuery('SELECT * FROM $tableName WHERE $field1 = ? AND $field2 = ? ORDER BY $orderByField ' '$direction', [value1, value2]);
    return result;
  }

  Future<List<Map<String, dynamic>>> getRowsWhereAndWhereAndWhereOrderByDirection(String tableName, field1, value1, field2, value2, field3, value3, String orderByField, String direction) async {
    Database db = await this.database;

    var result = await db
        .rawQuery('SELECT * FROM $tableName WHERE $field1 = ? AND $field2 = ? AND $field3 = ? ORDER BY $orderByField ' '$direction', [value1, value2, value3]);
    return result;
  }

  Future<List<Map<String, dynamic>>> getRowsWhereAndWhereOrderByDirectionLast10(String tableName, field1, value1, field2, value2, String orderByField, String direction) async {
    Database db = await this.database;

    var result = await db
        .rawQuery('SELECT * FROM $tableName WHERE $field1 = ? AND $field2 = ? ORDER BY $orderByField ' '$direction'' LIMIT 10', [value1, value2]);
    return result;
  }

  Future<List<Map<String, dynamic>>> getRowsWhereAndWhereAndWhereIsLessThanOrderByDirectionLast10(String tableName, field1, value1, field2, value2, field3, value3, String orderByField, String direction) async {
    Database db = await this.database;

    var result = await db
        .rawQuery('SELECT * FROM $tableName WHERE $field1 = ? AND $field2 = ? AND $field3 < ? ORDER BY $orderByField ' '$direction'' LIMIT 10', [value1, value2, value3]);
    return result;
  }

  Future<List<Map<String, dynamic>>> getRowsWhereAndWhereAndWhereIsMoreThanOrEqualToOrderByDirectionLast10(String tableName, field1, value1, field2, value2, field3, value3, String orderByField, String direction) async {
    Database db = await this.database;

    var result = await db
        .rawQuery('SELECT * FROM $tableName WHERE $field1 = ? AND $field2 = ? AND $field3 >= ? ORDER BY $orderByField ' '$direction'' LIMIT 10', [value1, value2, value3]);
    return result;
  }

  Future<List<Map<String, dynamic>>> getRowsWhereAndWhereAndWhereOrderByDirectionLast10(String tableName, field1, value1, field2, value2, field3, value3, String orderByField, String direction) async {
    Database db = await this.database;

    var result = await db
        .rawQuery('SELECT * FROM $tableName WHERE $field1 = ? AND $field2 = ? AND $field3 = ? ORDER BY $orderByField ' '$direction'' LIMIT 10', [value1, value2, value3]);
    return result;
  }

  Future<List<Map<String, dynamic>>> getRowsWhereAndWhereOrderByDirection10More(String tableName, field1, value1, field2, value2, String field3, String direction, String timestamp) async {
    Database db = await this.database;

    var result = await db
        .rawQuery('SELECT * FROM $tableName WHERE $field1 = ? AND $field2 = ? AND $field3 < ? ORDER BY $field3 ' '$direction'' LIMIT 10', [value1, value2, timestamp]);
    return result;
  }

  Future<List<Map<String, dynamic>>> getRowsWhereAndWhereAndWhereOrderByDirection10More(String tableName, field0, value0, field1, value1, field2, value2, String field3, String direction, String timestamp) async {
    Database db = await this.database;

    var result = await db
        .rawQuery('SELECT * FROM $tableName WHERE $field0 = ? AND $field1 = ? AND $field2 = ? AND $field3 < ? ORDER BY $field3 ' '$direction'' LIMIT 10', [value0, value1, value2, timestamp]);
    return result;
  }

  Future<List<Map<String, dynamic>>> getRowsWhereAndWhereAndWhereIsLessThanOrderByDirection10More(String tableName, field1, value1, field2, value2, field3, value3, String field4, String direction, String timestamp) async {
    Database db = await this.database;

    var result = await db
        .rawQuery('SELECT * FROM $tableName WHERE $field1 = ? AND $field2 = ? AND $field3 < ? and $field4 < ? ORDER BY $field4 ' '$direction'' LIMIT 10', [value1, value2, value3, timestamp]);
    return result;
  }

  Future<List<Map<String, dynamic>>> getRowsWhereAndWhereAndWhereIsMoreThanOrEqualToOrderByDirection10More(String tableName, field1, value1, field2, value2, field3, value3, String field4, String direction, String timestamp) async {
    Database db = await this.database;

    var result = await db
        .rawQuery('SELECT * FROM $tableName WHERE $field1 = ? AND $field2 = ? AND $field3 >= ? AND $field4 < ? ORDER BY $field4 ' '$direction'' LIMIT 10', [value1, value2, value3, timestamp]);
    return result;
  }

  Future<List<Map<String, dynamic>>> getJobsMonthSuperAdmin(searchFromDate, searchToDate) async {
    Database db = await this.database;

    var result = await db
        .rawQuery('SELECT * FROM $jobTable WHERE $jobDate >= ? AND $jobDate <= ? ORDER BY $jobNo DESC', [searchFromDate, searchToDate]);
    return result;
  }

  Future<List<Map<String, dynamic>>> getJobsMonthAdmin(orgId, searchFromDate, searchToDate) async {
    Database db = await this.database;

    var result = await db
        .rawQuery('SELECT * FROM $jobTable WHERE $organisationId = ? AND $jobDate >= ? AND $jobDate <= ? ORDER BY $jobNo DESC', [orgId, searchFromDate, searchToDate]);
    return result;
  }

  Future<List<Map<String, dynamic>>> getJobsDayAdmin(orgId, searchDate) async {
    Database db = await this.database;

    var result = await db
        .rawQuery('SELECT * FROM $jobTable WHERE $organisationId = ? AND $jobDate = ? ORDER BY $jobNo DESC', [orgId, searchDate]);
    return result;
  }

  Future<List<Map<String, dynamic>>> getJobsDayEngineer(orgId, engineerUid, searchDate) async {
    Database db = await this.database;

    var result = await db
        .rawQuery('SELECT * FROM $jobTable WHERE $organisationId = ? AND $jobEngUid = ? AND $jobDate = ? ORDER BY $jobNo DESC', [orgId, engineerUid, searchDate]);
    return result;
  }

  Future<List<Map<String, dynamic>>> getJobsMonthEngineer(searchFromDate, searchToDate, orgId, engineerUid) async {
    Database db = await this.database;

    var result = await db
        .rawQuery('SELECT * FROM $jobTable WHERE $organisationId = ? AND $jobEngUid = ? AND $jobDate >= ? AND $jobDate <= ? ORDER BY $jobNo DESC', [orgId, engineerUid, searchFromDate, searchToDate]);
    return result;
  }

  Future<List<Map<String, dynamic>>> getFormsJobSuperAdmin(tableName, searchedJobNo) async {
    Database db = await this.database;

    var result = await db
        .rawQuery('SELECT * FROM $tableName WHERE $jobId = ? AND $serverUploaded = 1 ORDER BY $jobId DESC', [searchedJobNo]);
    return result;
  }

  Future<List<Map<String, dynamic>>> getFormsJobAdmin(tableName, orgId, searchedJobNo) async {
    Database db = await this.database;

    var result = await db
        .rawQuery('SELECT * FROM $tableName WHERE $organisationId = ? AND $jobId = ? AND $serverUploaded = 1 ORDER BY $jobId DESC', [orgId, searchedJobNo]);
    return result;
  }

  Future<List<Map<String, dynamic>>> getFormsJobEngineer(tableName, orgId, engineerUid, searchedJobNo) async {
    Database db = await this.database;

    var result = await db
        .rawQuery('SELECT * FROM $tableName WHERE $organisationId = ? AND $uid = ? AND $jobId = ? AND $serverUploaded = 1 ORDER BY $jobId DESC', [orgId, engineerUid, searchedJobNo]);
    return result;
  }

  Future<Map<String, dynamic>> getCameraCrashValue() async {
    Database db = await this.database;

    var result = await db
        .rawQuery('SELECT * FROM $cameraCrashTable');
    return result[0];
  }

  Future<int> resetTemporaryMaintenanceChecklist(String userUid, String selectedJobId) async {
    Database db = await this.database;

    var result = await db.update(temporaryMaintenanceChecklistTable , {
      '$formVersion': 1,
      '$temporaryClientName': null,
      '$temporaryClientAddress' : null,
      '$temporaryClientPostcode' : null,
      '$temporaryClientTelephone' : null,
      '$temporaryClientEmail' : null,
      '$temporaryRoutineService' : null,
      '$temporaryCallOut' : null,
      '$temporaryInstall' : null,
      '$temporaryApplianceMake1' : null,
      '$temporaryApplianceType1': null,
      '$temporaryApplianceModel1': null,
      '$temporaryApplianceLocation1' : null,
      '$temporaryApplianceHeatExchanger1' : 'N/A',
      '$temporaryApplianceBurnerInjectors1' : 'N/A',
      '$temporaryApplianceIgnition1' : 'N/A',
      '$temporaryApplianceElectrics1' : 'N/A',
      '$temporaryApplianceControls1' : 'N/A',
      '$temporaryApplianceLeaksGasWater1': 'N/A',
      '$temporaryApplianceGasConnections1': 'N/A',
      '$temporaryApplianceSeals1': 'N/A',
      '$temporaryAppliancePipework1': 'N/A',
      '$temporaryApplianceFans1': 'N/A',
      '$temporaryApplianceFireplaceClosurePlate1': 'N/A',
      '$temporaryApplianceAllowableLocation1': 'N/A',
      '$temporaryApplianceChamberGasket1': 'N/A',
      '$temporarySafetyVentilation1': 'N/A',
      '$temporarySafetyFlueTermination1': 'N/A',
      '$temporarySafetySmokePelletFlueFlowTest1': 'N/A',
      '$temporarySafetySmokeMatchSpillageTest1': 'N/A',
      '$temporarySafetyWorkingPressure1': 'N/A',
      '$temporarySafetyDevice1': 'N/A',
      '$temporaryApplianceCondensate1': 'N/A',
      '$temporarySafetyFlueCombustionTestCo21': null,
      '$temporarySafetyFlueCombustionTestCo1': null,
      '$temporarySafetyFlueCombustionTestRatio1': null,
      '$temporarySafetyGasTightnessTestPerformedPass': null,
      '$temporarySafetyGasTightnessTestPerformedFail': null,
      '$temporarySafetyOperatingPressure1': null,
      '$temporarySafetyGasMeterEarthBondedYes': null,
      '$temporarySafetyGasMeterEarthBondedNo': null,
      '$temporaryApplianceMake2': null,
      '$temporaryApplianceType2': null,
      '$temporaryApplianceModel2': null,
      '$temporaryApplianceLocation2': null,
      '$temporaryApplianceHeatExchanger2': 'N/A',
      '$temporaryApplianceBurnerInjectors2': 'N/A',
      '$temporaryApplianceFlamePicture2': 'N/A',
      '$temporaryApplianceIgnition2': 'N/A',
      '$temporaryApplianceElectrics2': 'N/A',
      '$temporaryApplianceControls2': 'N/A',
      '$temporaryApplianceLeaksGasWater2': 'N/A',
      '$temporaryApplianceGasConnections2': 'N/A',
      '$temporaryApplianceSeals2': 'N/A',
      '$temporaryAppliancePipework2': 'N/A',
      '$temporaryApplianceFans2': 'N/A',
      '$temporaryApplianceFireplaceClosurePlate2': 'N/A',
      '$temporaryApplianceAllowableLocation2': 'N/A',
      '$temporaryApplianceChamberGasket2': 'N/A',
      '$temporarySafetyVentilation2': 'N/A',
      '$temporarySafetyFlueTermination2': 'N/A',
      '$temporarySafetySmokePelletFlueFlowTest2': 'N/A',
      '$temporarySafetySmokeMatchSpillageTest2': 'N/A',
      '$temporarySafetyWorkingPressure2': 'N/A',
      '$temporarySafetyDevice2': 'N/A',
      '$temporaryApplianceCondensate2': 'N/A',
      '$temporarySafetyFlueCombustionTestCo22': null,
      '$temporarySafetyFlueCombustionTestCo2': null,
      '$temporarySafetyFlueCombustionTestRatio2': null,
      '$temporarySafetyOperatingPressure2': null,
      '$temporaryInstallationApplianceSafeYes': null,
      '$temporaryInstallationApplianceSafeNo': null,
      '$temporaryWarningLabelAttachedYes': null,
      '$temporaryWarningLabelAttachedNo': null,
      '$temporaryMaintenanceFaultDetails1': null,
      '$temporaryMaintenanceWarningNoticeYes1': null,
      '$temporaryMaintenanceWarningNoticeNo1': null,
      '$temporaryMaintenanceWarningStickerYes1': null,
      '$temporaryMaintenanceWarningStickerNo1': null,
      '$temporaryMaintenanceFaultDetails2': null,
      '$temporaryMaintenanceWarningNoticeYes2': null,
      '$temporaryMaintenanceWarningNoticeNo2': null,
      '$temporaryMaintenanceWarningStickerYes2': null,
      '$temporaryMaintenanceWarningStickerNo2': null,
      '$temporaryMaintenanceFaultDetails3': null,
      '$temporaryMaintenanceWarningNoticeYes3': null,
      '$temporaryMaintenanceWarningNoticeNo3': null,
      '$temporaryMaintenanceWarningStickerYes3': null,
      '$temporaryMaintenanceWarningStickerNo3': null,
      '$temporaryPaymentReceived': null,
      '$temporaryPaymentReceivedType': null,
      '$temporaryInvoiceTotal': null,
      '$temporarySendBillOut': null,
      '$temporaryAppliancesVisiblyCheckedYes': null,
      '$temporaryAppliancesVisiblyCheckedNo': null,
      '$temporaryAppliancesVisiblyCheckedText': null,
      '$temporaryCustomersSignature': null,
      '$temporaryCustomersSignaturePoints': null,
      '$temporaryCustomerPrintName': null,
      '$temporaryCustomerDate': null,
      '$temporaryEngineersSignature': null,
      '$temporaryEngineersSignaturePoints': null,
      '$temporaryEngineerPrintName': null,
      '$temporaryEngineerDate': null,
      '$temporaryEngineersComments': null,
    },
        where: '$uid = ? AND $temporaryJobId = ?', whereArgs: [userUid, selectedJobId]);
    return result;
  }

  Future<int> resetTemporaryGasSafetyRecord(String userUid, String selectedJobId) async {
    Database db = await this.database;

    var result = await db.update(temporaryGasSafetyRecordTable , {
      formVersion: 1,
      temporaryEngineersSignature: null,
      temporaryEngineersSignaturePoints: null,
      temporaryEngineerDate: null,
      temporaryInspectionAddressName: null,
      temporaryInspectionAddress: null,
      temporaryInspectionPostcode: null,
      temporaryInspectionTelephone: null,
      temporaryInspectionEmail: null,
      temporaryLandlordName: null,
      temporaryLandlordAddress: null,
      temporaryLandlordPostcode: null,
      temporaryLandlordTelephone: null,
      temporaryLandlordEmail: null,
      temporaryGsrLocation1: null,
      temporaryGsrMake1: null,
      temporaryGsrModel1: null,
      temporaryGsrType1: null,
      temporaryGsrFlueType1: null,
      temporaryGsrOperationPressure1: null,
      temporaryGsrSafetyDevice1: null,
      temporaryGsrFlueOperation1: null,
      temporaryGsrCombustionAnalyser1: null,
      temporaryGsrSatisfactoryTermination1: null,
      temporaryGsrVisualCondition1: null,
      temporaryGsrAdequateVentilation1: null,
      temporaryGsrApplianceSafe1: null,
      temporaryGsrLandlordsAppliance1: null,
      temporaryGsrInspected1: null,
      temporaryGsrApplianceServiced1: null,
      temporaryGsrLocation2: null,
      temporaryGsrMake2: null,
      temporaryGsrModel2: null,
      temporaryGsrType2: null,
      temporaryGsrFlueType2: null,
      temporaryGsrOperationPressure2: null,
      temporaryGsrSafetyDevice2: null,
      temporaryGsrFlueOperation2: null,
      temporaryGsrCombustionAnalyser2: null,
      temporaryGsrSatisfactoryTermination2: null,
      temporaryGsrVisualCondition2: null,
      temporaryGsrAdequateVentilation2: null,
      temporaryGsrApplianceSafe2: null,
      temporaryGsrLandlordsAppliance2: null,
      temporaryGsrInspected2: null,
      temporaryGsrApplianceServiced2: null,
      temporaryGsrLocation3: null,
      temporaryGsrMake3: null,
      temporaryGsrModel3: null,
      temporaryGsrType3: null,
      temporaryGsrFlueType3: null,
      temporaryGsrOperationPressure3: null,
      temporaryGsrSafetyDevice3: null,
      temporaryGsrFlueOperation3: null,
      temporaryGsrCombustionAnalyser3: null,
      temporaryGsrSatisfactoryTermination3: null,
      temporaryGsrVisualCondition3: null,
      temporaryGsrAdequateVentilation3: null,
      temporaryGsrApplianceSafe3: null,
      temporaryGsrLandlordsAppliance3: null,
      temporaryGsrInspected3: null,
      temporaryGsrApplianceServiced3: null,
      temporaryGsrLocation4: null,
      temporaryGsrMake4: null,
      temporaryGsrModel4: null,
      temporaryGsrType4: null,
      temporaryGsrFlueType4: null,
      temporaryGsrOperationPressure4: null,
      temporaryGsrSafetyDevice4: null,
      temporaryGsrFlueOperation4: null,
      temporaryGsrCombustionAnalyser4: null,
      temporaryGsrSatisfactoryTermination4: null,
      temporaryGsrVisualCondition4: null,
      temporaryGsrAdequateVentilation4: null,
      temporaryGsrApplianceSafe4: null,
      temporaryGsrLandlordsAppliance4: null,
      temporaryGsrInspected4: null,
      temporaryGsrApplianceServiced4: null,
      temporaryGsrLocation5: null,
      temporaryGsrMake5: null,
      temporaryGsrModel5: null,
      temporaryGsrType5: null,
      temporaryGsrFlueType5: null,
      temporaryGsrOperationPressure5: null,
      temporaryGsrSafetyDevice5: null,
      temporaryGsrFlueOperation5: null,
      temporaryGsrCombustionAnalyser5: null,
      temporaryGsrSatisfactoryTermination5: null,
      temporaryGsrVisualCondition5: null,
      temporaryGsrAdequateVentilation5: null,
      temporaryGsrApplianceSafe5: null,
      temporaryGsrLandlordsAppliance5: null,
      temporaryGsrInspected5: null,
      temporaryGsrApplianceServiced5: null,
      temporaryVisualInspectionYes: null,
      temporaryVisualInspectionNo: null,
      temporaryEmergencyControlYes: null,
      temporaryEmergencyControlNo: null,
      temporarySatisfactorySoundnessYes: null,
      temporarySatisfactorySoundnessNo: null,
      temporarySafetyGasMeterEarthBondedYes: null,
      temporarySafetyGasMeterEarthBondedNo: null,
      temporaryFaultDetails1: null,
      temporaryWarningNotice1: null,
      temporaryWarningSticker1: null,
      temporaryFaultDetails2: null,
      temporaryWarningNotice2: null,
      temporaryWarningSticker2: null,
      temporaryFaultDetails3: null,
      temporaryWarningNotice3: null,
      temporaryWarningSticker3: null,
      temporaryNumberAppliancesTested: null,
      temporaryIssuersSignature: null,
      temporaryIssuersSignaturePoints: null,
      temporaryIssuerPrintName: null,
      temporaryIssuerDate: null,
      temporaryLandlordsSignature: null,
      temporaryLandlordsSignaturePoints: null,
      temporarySignatureType: null,
      temporaryLandlordDate: null
    },
        where: '$uid = ? AND $temporaryJobId = ?', whereArgs: [userUid, selectedJobId]);
    return result;
  }

  Future<int> resetTemporaryCaravanGasSafetyRecord(String userUid, String selectedJobId) async {
    Database db = await this.database;

    var result = await db.update(temporaryCaravanGasSafetyRecordTable , {
      formVersion: 1,
      temporaryCaravanPark: null,
      temporaryCaravanLocation: null,
      temporaryCaravanManufacturer: null,
      temporaryCaravanModel: null,
      temporaryCaravanManufactureDate: null,
      temporaryCaravanOwnerName: null,
      temporaryCaravanOwnerAddress: null,
      temporaryCaravanOwnerPostCode: null,
      temporaryCaravanOwnerTelNo: null,
      temporaryCaravanOwnerEmail: null,
      temporaryCaravanInspectionDate: null,
      temporaryCaravanRecordSerialNo: null,
      temporaryCaravanStockCardNo: null,
      temporaryCaravanWaterHeaterMake: null,
      temporaryCaravanWaterHeaterModel: null,
      temporaryCaravanWaterHeaterOperatingPressure: null,
      temporaryCaravanWaterHeaterOperationOfSafetyDevicesPass: null,
      temporaryCaravanWaterHeaterOperationOfSafetyDevicesFail: null,
      temporaryCaravanWaterHeaterVentilationPass: null,
      temporaryCaravanWaterHeaterVentilationFail: null,
      temporaryCaravanWaterHeaterFlueType: null,
      temporaryCaravanWaterHeaterFlueSpillagePass: null,
      temporaryCaravanWaterHeaterFlueSpillageFail: null,
      temporaryCaravanWaterHeaterFlueTerminationYes: null,
      temporaryCaravanWaterHeaterFlueTerminationNo: null,
      temporaryCaravanWaterHeaterExtendedFlueYes: null,
      temporaryCaravanWaterHeaterExtendedFlueNo: null,
      temporaryCaravanWaterHeaterExtendedFlueNa: null,
      temporaryCaravanWaterHeaterFlueConditionPass: null,
      temporaryCaravanWaterHeaterFlueConditionFail: null,
      temporaryCaravanWaterHeaterApplianceSafeYes: null,
      temporaryCaravanWaterHeaterApplianceSafeNo: null,
      temporaryCaravanFireMake: null,
      temporaryCaravanFireModel: null,
      temporaryCaravanFireOperatingPressure: null,
      temporaryCaravanFireOperationOfSafetyDevicesPass: null,
      temporaryCaravanFireOperationOfSafetyDevicesFail: null,
      temporaryCaravanFireVentilationPass: null,
      temporaryCaravanFireVentilationFail: null,
      temporaryCaravanFireFlueType: null,
      temporaryCaravanFireFlueSpillagePass: null,
      temporaryCaravanFireFlueSpillageFail: null,
      temporaryCaravanFireFlueTerminationYes: null,
      temporaryCaravanFireFlueTerminationNo: null,
      temporaryCaravanFireExtendedFlueYes: null,
      temporaryCaravanFireExtendedFlueNo: null,
      temporaryCaravanFireExtendedFlueNa: null,
      temporaryCaravanFireFlueConditionPass: null,
      temporaryCaravanFireFlueConditionFail: null,
      temporaryCaravanFireApplianceSafeYes: null,
      temporaryCaravanFireApplianceSafeNo: null,
      temporaryCaravanCookerMake: null,
      temporaryCaravanCookerModel: null,
      temporaryCaravanCookerOperatingPressure: null,
      temporaryCaravanCookerOperationOfSafetyDevicesPass: null,
      temporaryCaravanCookerOperationOfSafetyDevicesFail: null,
      temporaryCaravanCookerVentilationPass: null,
      temporaryCaravanCookerVentilationFail: null,
      temporaryCaravanCookerFlueType: null,
      temporaryCaravanCookerFlueSpillagePass: null,
      temporaryCaravanCookerFlueSpillageFail: null,
      temporaryCaravanCookerFlueTerminationYes: null,
      temporaryCaravanCookerFlueTerminationNo: null,
      temporaryCaravanCookerExtendedFlueYes: null,
      temporaryCaravanCookerExtendedFlueNo: null,
      temporaryCaravanCookerExtendedFlueNa: null,
      temporaryCaravanCookerFlueConditionPass: null,
      temporaryCaravanCookerFlueConditionFail: null,
      temporaryCaravanCookerApplianceSafeYes: null,
      temporaryCaravanCookerApplianceSafeNo: null,
      temporaryCaravanOtherMake: null,
      temporaryCaravanOtherModel: null,
      temporaryCaravanOtherOperatingPressure: null,
      temporaryCaravanOtherOperationOfSafetyDevicesPass: null,
      temporaryCaravanOtherOperationOfSafetyDevicesFail: null,
      temporaryCaravanOtherVentilationPass: null,
      temporaryCaravanOtherVentilationFail: null,
      temporaryCaravanOtherFlueType: null,
      temporaryCaravanOtherFlueSpillagePass: null,
      temporaryCaravanOtherFlueSpillageFail: null,
      temporaryCaravanOtherFlueTerminationYes: null,
      temporaryCaravanOtherFlueTerminationNo: null,
      temporaryCaravanOtherExtendedFlueYes: null,
      temporaryCaravanOtherExtendedFlueNo: null,
      temporaryCaravanOtherExtendedFlueNa: null,
      temporaryCaravanOtherFlueConditionPass: null,
      temporaryCaravanOtherFlueConditionFail: null,
      temporaryCaravanOtherApplianceSafeYes: null,
      temporaryCaravanOtherApplianceSafeNo: null,
      temporaryCaravanSoundnessCheckPass: null,
      temporaryCaravanSoundnessCheckFail: null,
      temporaryCaravanHoseCheckPass: null,
      temporaryCaravanHoseCheckFail: null,
      temporaryCaravanRegulatorOperatingPressurePass: null,
      temporaryCaravanRegulatorOperatingPressureFail: null,
      temporaryCaravanRegulatorLockUpPressure: null,
      temporaryCaravanRegulatorLockUpPressurePass: null,
      temporaryCaravanRegulatorLockUpPressureFail: null,
      temporaryCaravanFaultDetails1: null,
      temporaryCaravanRectificationWork1: null,
      temporaryCaravanByWhom1: null,
      temporaryCaravanOwnerInformedYes1: null,
      temporaryCaravanOwnerInformedNo1: null,
      temporaryCaravanWarningNoticeYes1: null,
      temporaryCaravanWarningNoticeNo1: null,
      temporaryCaravanWarningTagYes1: null,
      temporaryCaravanWarningTagNo1: null,
      temporaryCaravanFaultDetails2: null,
      temporaryCaravanRectificationWork2: null,
      temporaryCaravanByWhom2: null,
      temporaryCaravanOwnerInformedYes2: null,
      temporaryCaravanOwnerInformedNo2: null,
      temporaryCaravanWarningNoticeYes2: null,
      temporaryCaravanWarningNoticeNo2: null,
      temporaryCaravanWarningTagYes2: null,
      temporaryCaravanWarningTagNo2: null,
      temporaryCaravanFaultDetails3: null,
      temporaryCaravanRectificationWork3: null,
      temporaryCaravanByWhom3: null,
      temporaryCaravanOwnerInformedYes3: null,
      temporaryCaravanOwnerInformedNo3: null,
      temporaryCaravanWarningNoticeYes3: null,
      temporaryCaravanWarningNoticeNo3: null,
      temporaryCaravanWarningTagYes3: null,
      temporaryCaravanWarningTagNo3: null,
      temporaryCaravanFaultDetails4: null,
      temporaryCaravanRectificationWork4: null,
      temporaryCaravanByWhom4: null,
      temporaryCaravanOwnerInformedYes4: null,
      temporaryCaravanOwnerInformedNo4: null,
      temporaryCaravanWarningNoticeYes4: null,
      temporaryCaravanWarningNoticeNo4: null,
      temporaryCaravanWarningTagYes4: null,
      temporaryCaravanWarningTagNo4: null,
      temporaryCaravanFaultDetails5: null,
      temporaryCaravanRectificationWork5: null,
      temporaryCaravanByWhom5: null,
      temporaryCaravanOwnerInformedYes5: null,
      temporaryCaravanOwnerInformedNo5: null,
      temporaryCaravanWarningNoticeYes5: null,
      temporaryCaravanWarningNoticeNo5: null,
      temporaryCaravanWarningTagYes5: null,
      temporaryCaravanWarningTagNo5: null,
      temporaryCaravanNumberOfAppliancesTested: null,
      temporaryCaravanSerialNo: null,
      temporaryCaravanIssuerSignature: null,
      temporaryCaravanIssuerSignaturePoints: null,
      temporaryCaravanIssuerPrintName: null,
      temporaryCaravanIssuerDate: null,
      temporaryCaravanAgentSignature: null,
      temporaryCaravanAgentSignaturePoints: null,
      temporaryCaravanAgentDate: null,
      temporaryCaravanApplianceType1: null,
      temporaryCaravanApplianceType2: null,
      temporaryCaravanApplianceType3: null,
      temporaryCaravanApplianceType4: null,
    },
        where: '$uid = ? AND $temporaryJobId = ?', whereArgs: [userUid, selectedJobId]);
    return result;
  }

  Future<int> resetTemporaryWarningAdvisoryRecord(String userUid, String selectedJobId) async {
    Database db = await this.database;

    var result = await db.update(temporaryWarningAdvisoryRecordTable , {
      formVersion: 1,
      temporaryInspectionAddressName: null,
      temporaryInspectionAddress: null,
      temporaryInspectionPostcode: null,
      temporaryInspectionTelephone: null,
      temporaryInspectionEmail: null,
      temporaryLandlordName: null,
      temporaryLandlordAddress: null,
      temporaryLandlordPostcode: null,
      temporaryLandlordTelephone: null,
      temporaryLandlordEmail: null,
      temporaryEscapeOfGas : null,
      temporaryEscapeOfGasYes: null,
      temporaryEscapeOfGasNo: null,
      temporaryGasInstallation: null,
      temporaryGasAppliance: null,
      temporaryApplianceManufacturer: null,
      temporaryApplianceModel: null,
      temporaryApplianceType: null,
      temporaryApplianceSerialNo: null,
      temporaryApplianceLocation: null,
      temporaryImmediatelyDangerous: null,
      temporaryImmediatelyDangerousReason: null,
      temporaryDisconnectedYes: null,
      temporaryDisconnectedNo: null,
      temporaryPermissionRefusedYes: null,
      temporaryPermissionRefusedNo: null,
      temporaryIsAtRisk: null,
      temporaryIsAtRiskReason: null,
      temporaryTurnedOffYes: null,
      temporaryTurnedOffNo: null,
      temporaryNotToCurrentStandards: null,
      temporaryNcsManufacturer: null,
      temporaryNcsModel: null,
      temporaryNcsType: null,
      temporaryNcsSerialNo: null,
      temporaryNcsLocation: null,
      temporaryNotToCurrentStandardsReason: null,
      temporaryResponsiblePersonsSignature: null,
      temporaryResponsiblePersonsSignaturePoints: null,
      temporaryResponsiblePersonPrintName: null,
      temporaryResponsiblePersonDate: null,
      temporaryResponsiblePersonNotPresent: null,
      temporaryEngineersSignature: null,
      temporaryEngineersSignaturePoints: null,
      temporaryEngineerDate: null,
    },
        where: '$uid = ? AND $temporaryJobId = ?', whereArgs: [userUid, selectedJobId]);
    return result;
  }

  Future<int> resetTemporaryVehicleChecklist(String userUid, String selectedJobId) async {
    Database db = await this.database;

    var result = await db.update(temporaryVehicleChecklistTable , {
      formVersion: 1,
      temporaryDriverName: null,
      temporaryVehicleType: null,
      temporaryCurrentMileage: null,
      temporaryTreadDriversSideFrontTyre: null,
      temporaryTreadDriversSideRearTyre: null,
      temporaryTreadPassengersSideFrontTyre: null,
      temporaryTreadPassengersSideRearTyre: null,
      temporaryPressureDriversSideFrontTyre: null,
      temporaryPressureDriversSideRearTyre: null,
      temporaryPressurePassengersSideFrontTyre: null,
      temporaryPressurePassengersSideRearTyre: null,
      temporaryWarningLights: null,
      temporaryNextService: null,
      temporarySpecialistEquipment: null,
      temporarySpecialistEquipmentYesNoValue: null,
      temporaryDriverFeedback: null,
      temporaryDriversSignature: null,
      temporaryDriversSignaturePoints: null,
      temporaryDriverDate: null,
      temporaryCompletedSheetTo: null,
      temporaryDeadlineForReturn: null,
      temporaryQueryContact: null,
      temporaryReviewDate: null,
    },
        where: '$uid = ? AND $temporaryJobId = ?', whereArgs: [userUid, selectedJobId]);
    return result;
  }

  Future<int> resetTemporaryJob(String userUid) async {
    Database db = await this.database;

    var result = await db.update(temporaryJobTable , {
      formVersion: 1,
      temporaryJobNo: null,
      temporaryJobClient: null,
      temporaryJobAddress: null,
      temporaryJobPostCode: null,
      temporaryJobContactNo: null,
      temporaryJobMobile: null,
      temporaryJobEmail: null,
      temporaryJobTime: null,
      temporaryJobDescription: null,
      temporaryJobEng: null,
      temporaryJobDate: null,
      temporaryJobEngUid: null,
      temporaryJobEngEmail: null,
      temporaryJobEngDocumentId: null,
      temporaryJobCustomerId: null,
      temporaryJobPaid: null,
      temporaryJobType: null,
      temporaryJobCustomerLandlordName: null,
      temporaryJobCustomerLandlordAddress: null,
      temporaryJobCustomerLandlordPostcode: null,
      temporaryJobCustomerLandlordContact: null,
      temporaryJobCustomerLandlordEmail: null,
      temporaryJobCustomerBoilerMake: null,
      temporaryJobCustomerBoilerModel: null,
      temporaryJobCustomerBoilerType: null,
      temporaryJobCustomerBoilerFire: null,

    },
        where: '$uid = ?', whereArgs: [userUid]);
    return result;
  }

  Future<int> resetTemporaryPartsForm(String userUid, String selectedJobId) async {
    Database db = await this.database;

    var result = await db.update(temporaryPartsFormTable , {
      formVersion: 1,
      temporaryPartsFormDate: null,
      temporaryPartsFormRefNo: null,
      temporaryPartsFormName: null,
      temporaryPartsFormAddress: null,
      temporaryPartsFormBillingAddress: null,
      temporaryPartsFormPostCode: null,
      temporaryPartsFormBillingPostCode: null,
      temporaryPartsFormTelNo: null,
      temporaryPartsFormMobile: null,
      temporaryPartsFormAppliance: null,
      temporaryPartsFormMake: null,
      temporaryPartsFormModel: null,
      temporaryPartsFormGcNo: null,
      temporaryPartsFormPartsRequired: null,
      temporaryPartsFormOrderedYes: null,
      temporaryPartsFormOrderedNo: null,
      temporaryPartsFormSupplier: null,
      temporaryPartsFormSupplierText: null,
      temporaryPartsFormManufacturer: null,
      temporaryPartsFormFurther: null,
      temporaryPartsFormPrice: null,
      temporaryPartsFormFurtherInfo: null,
      temporaryPartsFormCustomersSignature: null,
      temporaryPartsFormCustomersSignaturePoints: null,
      temporaryPartsFormCustomersEmail: null,
      temporaryPartsFormEngineersSignature: null,
      temporaryPartsFormEngineersSignaturePoints: null,
      temporaryPartsFormImages: null,


    },
        where: '$uid = ? AND $temporaryJobId = ?', whereArgs: [userUid, selectedJobId]);
    return result;
  }

  Future<int> resetTemporaryInvoice(String userUid, String selectedJobId) async {
    Database db = await this.database;

    var result = await db.update(temporaryInvoiceTable , {
      formVersion: 1,
      temporaryInvoiceCustomerName: null,
      temporaryInvoiceCustomerAddress: null,
      temporaryInvoiceCustomerPostCode: null,
      temporaryInvoiceCustomerTelNo: null,
      temporaryInvoiceCustomerMobile: null,
      temporaryInvoiceCustomerEmail: null,
      temporaryInvoiceNo: null,
      temporaryInvoiceDate: null,
      temporaryInvoiceDueDate: null,
      temporaryInvoiceTerms: null,
      temporaryInvoiceComment: null,
      temporaryInvoiceItems: null,
      temporaryInvoiceSubtotal: '0.00',
      temporaryInvoiceVatAmount: '0.00',
      temporaryInvoiceTotalAmount: '0.00',
      temporaryInvoicePaidAmount: '0.00',
      temporaryInvoiceBalanceDue: '0.00',
      temporaryInvoicePaidFull: null,
      temporaryInvoiceJobNo: null



    },
        where: '$uid = ? AND $temporaryJobId = ?', whereArgs: [userUid, selectedJobId]);
    return result;
  }

//  Future<int> resetTemporaryEstimatesForm(String userUid, String selectedJobId) async {
//    Database db = await this.database;
//
//    var result = await db.update(temporaryEstimatesTable , {
//      formVersion: 1,
//      temporaryEstimatesDate: null,
//      temporaryEstimatesEngineerName: user.firstName + ' ' + user.lastName,
//      temporaryEstimatesCustomerName: null,
//      temporaryEstimatesAddress: null,
//      temporaryEstimatesContactNo: null,
//      temporaryEstimatesPostCode: null,
//      temporaryEstimatesPrice: null,
//      temporaryEstimatesCustomerEmail: null,
//      temporaryEstimatesTypeConversion: null,
//      temporaryEstimatesTypeCombiSwap: null,
//      temporaryEstimatesTypeHeatOnly: null,
//      temporaryEstimatesTypeFullHeat: null,
//      temporaryEstimatesCurrentBoilerLocation: null,
//      temporaryEstimatesNewBoilerLocation: null,
//      temporaryEstimatesGuarantee: null,
//      temporaryEstimatesFlueTypeStandard: null,
//      temporaryEstimatesFlueTypeVerticalFlat: null,
//      temporaryEstimatesFlueTypeVerticalPitched: null,
//      temporaryEstimatesMagnaCleanYes: null,
//      temporaryEstimatesMagnaCleanNo: null,
//      temporaryEstimatesMagnaCleanNa: null,
//      temporaryEstimatesRoomStat: null,
//      temporaryEstimatesClockYes: null,
//      temporaryEstimatesClockNo: null,
//      temporaryEstimatesClockNa: null,
//      temporaryEstimatesTrvSize15: null,
//      temporaryEstimatesTrvSize10: null,
//      temporaryEstimatesTrvSize8: null,
//      temporaryEstimatesTrvSizeNa: null,
//      temporaryEstimatesGasPipe: null,
//      temporaryEstimatesCondensateRoute: null,
//      temporaryEstimatesFlowReturn: null,
//      temporaryEstimatesHotCold: null,
//      temporaryEstimatesPressureRelief: null,
//      temporaryEstimatesNumberOfShowers: null,
//      temporaryEstimatesGasMeterStopCock: null,
//      temporaryEstimatesElectricianRequiredYes: null,
//      temporaryEstimatesElectricianRequiredNo: null,
//      temporaryEstimatesElectricianRequiredNa: null,
//      temporaryEstimatesRooferRequiredYes: null,
//      temporaryEstimatesRooferRequiredNo: null,
//      temporaryEstimatesRooferRequiredNa: null,
//      temporaryEstimatesBrickworkPlasteringRequiredYes: null,
//      temporaryEstimatesBrickworkPlasteringRequiredNo: null,
//      temporaryEstimatesBrickworkPlasteringRequiredNa: null,
//      temporaryEstimatesCustomerWork: null,
//      temporaryEstimatesOtherNotes: null,
//      temporaryEstimatesTrvNotes: null,
//      temporaryEstimatesBrickworkNotes: null,
//      temporaryEstimatesImages: null,
//    },
//        where: '$uid = ? AND $temporaryJobId = ?', whereArgs: [userUid, selectedJobId]);
//    return result;
//  }

//  Future<int> resetTemporaryEstimatesBasicForm(String userUid, String selectedJobId) async {
//    Database db = await this.database;
//
//    var result = await db.update(temporaryEstimatesBasicTable , {
//      formVersion: 1,
//      temporaryEstimatesBasicDate: null,
//      temporaryEstimatesBasicEngineerName: user.firstName + ' ' + user.lastName,
//      temporaryEstimatesBasicCustomerName: null,
//      temporaryEstimatesBasicAddress: null,
//      temporaryEstimatesBasicContactNo: null,
//      temporaryEstimatesBasicPostCode: null,
//      temporaryEstimatesBasicPrice: null,
//      temporaryEstimatesBasicCustomerEmail: null,
//      temporaryEstimatesBasicDescription: null,
//      temporaryEstimatesBasicImages: null,
//    },
//        where: '$uid = ? AND $temporaryJobId = ?', whereArgs: [userUid, selectedJobId]);
//    return result;
//  }

  Future<int> resetTemporaryPartsFittedForm(String userUid, String selectedJobId) async {
    Database db = await this.database;

    var result = await db.update(temporaryPartsFittedTable , {
      '$formVersion': 1,
      '$temporaryClientName': null,
      '$temporaryClientAddress' : null,
      '$temporaryClientPostcode' : null,
      '$temporaryClientTelephone' : null,
      '$temporaryClientMobile' : null,
      '$temporaryClientEmail' : null,
      '$temporaryApplianceMake1' : null,
      '$temporaryApplianceType1': null,
      '$temporaryApplianceModel1': null,
      '$temporaryApplianceLocation1' : null,
      '$temporarySafetyVentilation1': 'N/A',
      '$temporarySafetyFlueTermination1': 'N/A',
      '$temporarySafetySmokePelletFlueFlowTest1': 'N/A',
      '$temporarySafetySmokeMatchSpillageTest1': 'N/A',
      '$temporarySafetyWorkingPressure1': 'N/A',
      '$temporarySafetyDevice1': 'N/A',
      '$temporaryApplianceCondensate1': 'N/A',
      '$temporarySafetyFlueCombustionTestCo21': null,
      '$temporarySafetyFlueCombustionTestCo1': null,
      '$temporarySafetyFlueCombustionTestRatio1': null,
      '$temporarySafetyGasTightnessTestPerformedPass': null,
      '$temporarySafetyGasTightnessTestPerformedFail': null,
      '$temporarySafetyOperatingPressure1': null,
      '$temporarySafetyGasMeterEarthBondedYes': null,
      '$temporarySafetyGasMeterEarthBondedNo': null,
      '$temporaryPaymentReceived': null,
      '$temporaryPaymentReceivedType': null,
      '$temporaryInvoiceTotal': null,
      '$temporarySendBillOut': null,
      '$temporaryAppliancesVisiblyCheckedYes': null,
      '$temporaryAppliancesVisiblyCheckedNo': null,
      '$temporaryAppliancesVisiblyCheckedText': null,
      '$temporaryCustomersSignature': null,
      '$temporaryCustomersSignaturePoints': null,
      '$temporaryCustomerPrintName': null,
      '$temporaryCustomerDate': null,
      '$temporaryEngineersSignature': null,
      '$temporaryEngineersSignaturePoints': null,
      '$temporaryEngineerPrintName': null,
      '$temporaryEngineerDate': null,
      '$temporaryEngineersComments': null,
      '$temporaryPartsFittedDescription': null,
      '$temporaryPartsFittedImages': null,

    },
        where: '$uid = ? AND $temporaryJobId = ?', whereArgs: [userUid, selectedJobId]);
    return result;
  }

  Future<int> resetTemporaryGeneralWorkForm(String userUid, String selectedJobId) async {
    Database db = await this.database;

    var result = await db.update(temporaryGeneralWorkTable , {
      '$formVersion': 1,
      '$temporaryClientName': null,
      '$temporaryClientAddress' : null,
      '$temporaryClientPostcode' : null,
      '$temporaryClientTelephone' : null,
      '$temporaryClientEmail' : null,
      '$temporaryPaymentReceived': null,
      '$temporaryPaymentReceivedType': null,
      '$temporaryInvoiceTotal': null,
      '$temporarySendBillOut': null,
      '$temporaryAppliancesVisiblyCheckedYes': null,
      '$temporaryAppliancesVisiblyCheckedNo': null,
      '$temporaryAppliancesVisiblyCheckedText': null,
      '$temporaryCustomersSignature': null,
      '$temporaryCustomersSignaturePoints': null,
      '$temporaryCustomerPrintName': null,
      '$temporaryCustomerDate': null,
      '$temporaryEngineersSignature': null,
      '$temporaryEngineersSignaturePoints': null,
      '$temporaryEngineerPrintName': null,
      '$temporaryEngineerDate': null,
      '$temporaryEngineersComments': null,
      '$temporaryGeneralWorkDescription': null,
      '$temporaryGeneralWorkImages': null,

    },
        where: '$uid = ? AND $temporaryJobId = ?', whereArgs: [userUid, selectedJobId]);
    return result;
  }

//  Future<int> resetTemporaryEngineerNotesForm(String userUid, String selectedJobId) async {
//    Database db = await this.database;
//
//    var result = await db.update(temporaryEngineerNotesTable , {
//      '$formVersion': 1,
//      '$temporaryJobNo': null,
//      '$temporaryEngineerNotesName': user.firstName + ' ' + user.lastName,
//      '$temporaryEngineerNotesDate': null,
//      '$temporaryEngineerNotesDescription': null,
//      '$temporaryEngineerNotesImages': null,
//
//    },
//        where: '$uid = ? AND $temporaryJobId = ?', whereArgs: [userUid, selectedJobId]);
//    return result;
//  }


  Future<int> resetTemporaryActivityLog(String userUid) async {
    Database db = await this.database;

    var result = await db.update(Strings.temporaryActivityLogTable , {
      Strings.date: null,
      Strings.title: null,
      Strings.details: null,
      Strings.images: null,
      Strings.share: false,
      Strings.caveName: null,
    },
        where: '${Strings.uid} = ?', whereArgs: [userUid]);
    return result;
  }

  Future<int> resetTemporaryCallOut(String userUid) async {
    Database db = await this.database;

    var result = await db.update(Strings.temporaryCallOutTable , {
      Strings.entryDate: null,
      Strings.exitDate: null,
      Strings.details: null,
      Strings.cavers: null,
      Strings.cave: null,
    },
        where: '${Strings.uid} = ?', whereArgs: [userUid]);
    return result;
  }

  Future<int> resetTemporaryCave(String userUid) async {
    Database db = await this.database;

    var result = await db.update(Strings.temporaryCaveTable , {
      Strings.name: null,
      Strings.nameLowercase: null,
      Strings.description: null,
      Strings.caveLatitude: null,
      Strings.caveLongitude: null,
      Strings.parkingLatitude: null,
      Strings.parkingLongitude: null,
      Strings.parkingPostCode: null,
      Strings.verticalRange: null,
      Strings.length: null,
      Strings.county: null,
      Strings.images: null,
    },
        where: '${Strings.uid} = ?', whereArgs: [userUid]);
    return result;
  }

  Future<int> getImagePathCount() async {
    Database db = await this.database;
    List<Map<String, dynamic>> x =
    await db.rawQuery('SELECT COUNT (*) from ${Strings.imagePathTable}');
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  Future<int> addImagePath(Map<String, dynamic> imagePathData) async {
    Database db = await this.database;

    var result = await db.insert(Strings.imagePathTable, imagePathData);

    return result;
  }

  Future<String> getImagePath() async {
    Database db = await this.database;
    String imagePath;

    var result = await db
        .rawQuery('SELECT * FROM $imagePathTable');

    if(result != null){
      imagePath = result[0]['image_path'];
    }

    return imagePath;
  }

}
