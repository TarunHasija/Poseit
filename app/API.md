# Poseit Backend API

This guide documents the FastAPI endpoints and shows how to call them from the Flutter client.

## Base URL

Use the API server's origin without a trailing slash:

| Where the Flutter app runs | Base URL example |
| --- | --- |
| Android emulator, local API | `http://10.0.2.2:8000` |
| iOS simulator, local API | `http://127.0.0.1:8000` |
| Physical device, local API | `http://<computer-LAN-IP>:8000` |
| Deployed API | `https://<your-render-service>.onrender.com` |

`localhost` on a phone or emulator points to that device, not your development computer. Start the backend locally with Uvicorn, or deploy it before using the Render URL.

## Authentication

Signup and login are public endpoints. The pose endpoints require a Supabase access token in the standard bearer header:

```http
Authorization: Bearer <access_token>
```

### `POST /auth/signup`

Creates a Supabase email/password user. JSON body:

```json
{
  "email": "person@example.com",
  "password": "at-least-8-characters"
}
```

Password must be at least 8 characters. The response contains `message` and `user`. Depending on the Supabase email-confirmation setting, the user may need to verify their email before logging in. Signup does not return an access token in this API.

### `POST /auth/login`

JSON body is the same as signup. A successful response contains:

```json
{
  "message": "Login successful",
  "access_token": "...",
  "refresh_token": "...",
  "expires_at": 1234567890,
  "user": {
    "id": "user-uuid",
    "email": "person@example.com",
    "email_confirmed_at": null,
    "phone_confirmed_at": null
  }
}
```

Send `access_token` as a bearer token for pose calls. Do not put the Supabase service-role key in the Flutter app; it belongs only in the backend's environment.

## Pose endpoints

All pose endpoints require `Authorization: Bearer <access_token>`.

### `POST /poses`

Uploads one image as `multipart/form-data`. The form field name must be `file`.

Supported content types are `image/jpeg`, `image/png`, `image/webp`, and `image/gif`; the file contents are decoded and checked against the declared MIME type. Uploads are limited to 15 MiB. Images are optimized before being stored in the configured private Supabase bucket (`poses` by default).

Success status: `201 Created`. The response is pose metadata:

```json
{
  "id": "pose-uuid",
  "bucket_name": "poses",
  "object_path": "pose-uuid.jpg",
  "original_filename": "pose.jpg",
  "mime_type": "image/jpeg",
  "size_bytes": 123456,
  "original_size_bytes": 234567,
  "width": 800,
  "height": 1200,
  "created_at": "2026-10-18T12:00:00Z"
}
```

### `POST /poses/bulk`

Uploads multiple images in one `multipart/form-data` request. Repeat the
`files` field once for each image. The metadata fields are applied to every
uploaded image; each returned `id` is a unique image ID.

| Field | Type | Meaning |
| --- | --- | --- |
| `files` | file, repeated | JPEG, PNG, WEBP, or GIF image; up to 20 images |
| `people_count` | integer | Shared people count, zero or greater |
| `category` | string | Shared category, 1–120 characters |
| `male` | integer | Shared male count, zero or greater |
| `female` | integer | Shared female count, zero or greater |
| `created_at` | ISO 8601 datetime | Shared capture/creation time; timezone is recommended |

Each image is limited to 15 MiB and the combined original upload size is
limited to 100 MiB. The server validates and optimizes each image, stores all
objects in the private bucket, and returns a list of pose metadata with status
`201 Created`. If an image or database write fails, the request is rolled back
and uploaded storage objects are removed where possible.

Example:

```bash
curl -X POST "$API_BASE_URL/poses/bulk" \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  -F "files=@./front.jpg" \
  -F "files=@./side.png" \
  -F "people_count=3" \
  -F "category=Family" \
  -F "male=1" \
  -F "female=2" \
  -F "created_at=2026-10-25T10:30:00Z"
```

The response is an array. Each item includes its own unique `id` plus the
shared metadata, image dimensions, and storage details.

### `GET /poses`

Returns the full pose catalog, including each image as base64. Each item contains all the metadata above plus `image_base64`:

```json
[
  {
    "id": "pose-uuid",
    "bucket_name": "poses",
    "object_path": "pose-uuid.jpg",
    "original_filename": "pose.jpg",
    "mime_type": "image/jpeg",
    "size_bytes": 123456,
    "original_size_bytes": 234567,
    "width": 800,
    "height": 1200,
    "created_at": "2026-10-18T12:00:00Z",
    "image_base64": "/9j/4AAQSk..."
  }
]
```

This endpoint downloads all objects and returns them in one response, so response size and memory use grow with the catalog. Use it when the whole catalog is needed at once.

### `GET /poses/{pose_id}`

Returns the image bytes directly with its image MIME type (for example, `image/jpeg`). The response includes metadata in headers such as `X-Pose-Id`, `X-Pose-Width`, `X-Pose-Height`, `X-Pose-Size`, and `X-Pose-Created-At`. A missing UUID returns `404`.

## Common errors

| Status | Meaning |
| --- | --- |
| `400` | Signup or login failed; inspect the response `detail`. |
| `401` | Missing, expired, or invalid bearer token. Log in again and retry. |
| `404` | No pose exists for the requested ID. |
| `413` | Upload is larger than 15 MiB. |
| `415` | MIME type is not supported, or file bytes do not match the declared image type. |
| `422` | Request body, UUID, or required file field is invalid. |
| `502` | Supabase Storage operation failed. Check backend logs and Supabase configuration. |

## Flutter setup

Add direct dependencies for HTTP requests and MIME detection:

```shell
flutter pub add http http_parser mime
```

Set the API base URL when running the app. For example, on an Android emulator:

```shell
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000
```

For production, set `API_BASE_URL` to the Render service URL. Do not include `/docs` or an endpoint path in the base URL.

## Flutter API client example

Create a small API client (for example, `lib/core/network/pose_api.dart`):

```dart
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

const apiBaseUrl = String.fromEnvironment('API_BASE_URL');

class PoseApi {
  PoseApi({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  String? _accessToken;

  Map<String, String> get _authHeaders => {
        if (_accessToken != null) 'Authorization': 'Bearer $_accessToken',
      };

  Uri _uri(String path) => Uri.parse('$apiBaseUrl$path');

  Future<void> login(String email, String password) async {
    final response = await _client.post(
      _uri('/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    if (response.statusCode != 200) {
      throw Exception('Login failed (${response.statusCode}): ${response.body}');
    }
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    _accessToken = json['access_token'] as String;
  }

  Future<Map<String, dynamic>> uploadPose(String filePath) async {
    final mime = lookupMimeType(filePath) ?? 'application/octet-stream';
    final request = http.MultipartRequest('POST', _uri('/poses'))
      ..headers.addAll(_authHeaders)
      ..files.add(await http.MultipartFile.fromPath(
        'file',
        filePath,
        contentType: MediaType.parse(mime),
      ));

    final streamed = await _client.send(request);
    final response = await http.Response.fromStream(streamed);
    if (response.statusCode != 201) {
      throw Exception('Upload failed (${response.statusCode}): ${response.body}');
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<List<Map<String, dynamic>>> getAllPoses() async {
    final response = await _client.get(_uri('/poses'), headers: _authHeaders);
    if (response.statusCode != 200) {
      throw Exception('Fetch failed (${response.statusCode}): ${response.body}');
    }
    return (jsonDecode(response.body) as List<dynamic>)
        .cast<Map<String, dynamic>>();
  }

  Future<List<int>> getPoseBytes(String poseId) async {
    final response = await _client.get(
      _uri('/poses/$poseId'),
      headers: _authHeaders,
    );
    if (response.statusCode != 200) {
      throw Exception('Fetch failed (${response.statusCode}): ${response.body}');
    }
    return response.bodyBytes;
  }

  void dispose() => _client.close();
}
```

Use the returned bytes from `getPoseBytes` directly in Flutter, for example `Image.memory(bytes)`. To render an item from `getAllPoses`, decode its base64 field:

```dart
final bytes = base64Decode(pose['image_base64'] as String);
Image.memory(bytes);
```

For an authenticated upload, call `login` first, then pass a local image path to `uploadPose`. If the app needs to keep a session after it closes, store tokens with an OS-backed secure-storage solution rather than plain preferences. Never store the service-role key in the client.

## Inspecting the API

With the backend running, Swagger UI is available at `/docs` on the API base URL. It can be used to inspect schemas and manually try calls. Log in first, copy `access_token`, click **Authorize**, enter `Bearer <access_token>`, then try the pose routes.
