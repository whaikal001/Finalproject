class Worker {
  final int id;
  final String fullName;
  final String email;
  final String? phone;   // Made nullable
  final String? address; // Made nullable

  Worker({
    required this.id,
    required this.fullName,
    required this.email,
    this.phone,   // No longer 'required'
    this.address, // No longer 'required'
  });

  factory Worker.fromJson(Map<String, dynamic> json) {
    return Worker(
      id: json['id'] as int,
      fullName: json['full_name'] as String,
      email: json['email'] as String,
      // Safely handle potentially null values using `as String? ?? ''`
      // Or simply `as String?` if the constructor handles null directly.
      // Given the constructor now accepts String?, `as String?` is sufficient.
      phone: json['phone'] as String?, 
      address: json['address'] as String?, 
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
      'phone': phone,
      'address': address,
    };
  }
}