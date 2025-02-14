class Device {
  final String id;
  final String name;
  final String platform;
  final bool isAvailable;

  Device({
    required this.id,
    required this.name,
    required this.platform,
    this.isAvailable = true,
  });
}