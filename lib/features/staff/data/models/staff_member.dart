import 'package:freezed_annotation/freezed_annotation.dart';

part 'staff_member.freezed.dart';
part 'staff_member.g.dart';

@freezed
class StaffMember with _$StaffMember {
  const factory StaffMember({
    required String id,
    @JsonKey(name: 'user_id') String? userId,
    @JsonKey(name: 'full_name') required String fullName,
    String? designation,
    @JsonKey(name: 'join_date') DateTime? joinDate,
    @JsonKey(name: 'is_active') required bool isActive,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _StaffMember;

  factory StaffMember.fromJson(Map<String, dynamic> json) => _$StaffMemberFromJson(json);
}