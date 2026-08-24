/// A short-lived slot in Supabase Storage, from
/// `POST /v1/children/{child_id}/task-proofs/upload-url`.
///
/// The photo never passes through our API: it signs a URL, the device PUTs the
/// bytes straight to Storage, and only [objectKey] comes back on submit. That
/// keeps photos of children out of the API's logs and memory entirely.
class TaskProofUpload {
  /// Already carries its own `?token=`, so the PUT needs no Authorization
  /// header - and must not carry ours, which is for our API, not Supabase.
  final String uploadUrl;

  /// `{child_id}/{task_id}/{uuid}.{ext}`. The server re-derives ownership from
  /// this on submit, so a client cannot attach someone else's photo.
  final String objectKey;

  /// 10 MB at the time of writing; the server is the authority.
  final int maxBytes;

  const TaskProofUpload({
    required this.uploadUrl,
    required this.objectKey,
    required this.maxBytes,
  });

  factory TaskProofUpload.fromJson(Map<String, dynamic> json) {
    return TaskProofUpload(
      uploadUrl: (json['upload_url'] ?? '').toString(),
      objectKey: (json['object_key'] ?? '').toString(),
      maxBytes: json['max_bytes'] is num
          ? (json['max_bytes'] as num).toInt()
          : defaultMaxBytes,
    );
  }

  static const int defaultMaxBytes = 10 * 1024 * 1024;

  bool get isUsable => uploadUrl.isNotEmpty && objectKey.isNotEmpty;
}

/// What `ProofUploadUrlRequest.extension` accepts. Anything else is a 422, so
/// it is worth catching before the round trip.
const Set<String> proofImageExtensions = {'jpg', 'jpeg', 'png', 'heic', 'webp'};

/// The extension the API should sign for [path], or null when the picker
/// handed back something the bucket will not take.
String? proofExtensionFor(String path) {
  final dot = path.lastIndexOf('.');
  if (dot < 0 || dot == path.length - 1) return null;
  final extension = path.substring(dot + 1).toLowerCase();
  return proofImageExtensions.contains(extension) ? extension : null;
}

/// Storage stores whatever `Content-Type` the PUT declares, and the parent's
/// review sheet renders it back - a wrong type here shows as a broken image.
String proofContentType(String extension) {
  switch (extension) {
    case 'png':
      return 'image/png';
    case 'heic':
      return 'image/heic';
    case 'webp':
      return 'image/webp';
    default:
      return 'image/jpeg';
  }
}
